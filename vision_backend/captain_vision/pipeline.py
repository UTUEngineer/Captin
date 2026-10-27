"""Video → tracks → analytics.

Detection + tracking uses Ultralytics YOLO with the built-in ByteTrack
tracker (COCO classes: 0 = person, 32 = sports ball). The detector is
injectable so the pipeline can be tested without model weights.
"""
from __future__ import annotations

import os
from dataclasses import dataclass, field
from typing import Callable, Iterable, Protocol

import numpy as np

from . import analytics as A

PERSON = 0
BALL = 32


@dataclass
class Detection:
    track_id: int | None  # None for untracked (ball)
    cls: int
    conf: float
    box: tuple[float, float, float, float]  # x1, y1, x2, y2 pixels


class Detector(Protocol):
    def __call__(self, frame: np.ndarray) -> list[Detection]: ...


class YoloByteTrackDetector:
    """Ultralytics YOLO + ByteTrack. Weights: $YOLO_WEIGHTS (default
    yolov8n.pt, auto-downloaded on first run)."""

    def __init__(self, weights: str | None = None, imgsz: int = 1280):
        from ultralytics import YOLO  # heavy import, only when used

        self.model = YOLO(weights or os.getenv("YOLO_WEIGHTS", "yolov8n.pt"))
        self.imgsz = imgsz

    def __call__(self, frame: np.ndarray) -> list[Detection]:
        res = self.model.track(
            frame,
            persist=True,
            tracker="bytetrack.yaml",
            classes=[PERSON, BALL],
            conf=0.15,
            imgsz=self.imgsz,
            verbose=False,
        )[0]
        out: list[Detection] = []
        boxes = res.boxes
        if boxes is None or len(boxes) == 0:
            return out
        xyxy = boxes.xyxy.cpu().numpy()
        cls = boxes.cls.cpu().numpy().astype(int)
        conf = boxes.conf.cpu().numpy()
        ids = boxes.id.cpu().numpy().astype(int) if boxes.id is not None else [None] * len(cls)
        for b, c, s, i in zip(xyxy, cls, conf, ids):
            out.append(Detection(None if c == BALL else (int(i) if i is not None else None), int(c), float(s), tuple(map(float, b))))
        return out


@dataclass
class PipelineResult:
    duration_seconds: float
    tracks: list[dict]
    players: list[dict]
    ball: list[dict]
    possession_zones: dict
    calibrated: bool
    frame_size: tuple[int, int]
    summary: dict = field(default_factory=dict)


def jersey_color(frame: np.ndarray, box) -> np.ndarray | None:
    """Mean upper-body color (Lab) with grass pixels masked out."""
    import cv2

    x1, y1, x2, y2 = [int(round(v)) for v in box]
    h = y2 - y1
    x1, x2 = max(0, x1), min(frame.shape[1], x2)
    top, bottom = max(0, y1 + int(h * 0.15)), max(0, min(frame.shape[0], y1 + int(h * 0.5)))
    if x2 - x1 < 3 or bottom - top < 3:
        return None
    crop = frame[top:bottom, x1:x2]
    hsv = cv2.cvtColor(crop, cv2.COLOR_BGR2HSV)
    grass = (hsv[..., 0] > 35) & (hsv[..., 0] < 85) & (hsv[..., 1] > 60)
    lab = cv2.cvtColor(crop, cv2.COLOR_BGR2LAB).reshape(-1, 3)[~grass.reshape(-1)]
    if len(lab) < 10:
        return None
    return lab.mean(axis=0)


def iter_frames(path: str, target_fps: float):
    """Yields (timestamp_s, frame_index, frame) sampled at ~target_fps."""
    import cv2

    cap = cv2.VideoCapture(path)
    fps = cap.get(cv2.CAP_PROP_FPS) or 25.0
    step = max(1, int(round(fps / target_fps)))
    idx = 0
    try:
        while True:
            ok = cap.grab()
            if not ok:
                break
            if idx % step == 0:
                ok, frame = cap.retrieve()
                if not ok:
                    break
                yield idx / fps, idx, frame
            idx += 1
    finally:
        cap.release()


def video_info(path: str) -> tuple[float, int, int, float]:
    import cv2

    cap = cv2.VideoCapture(path)
    fps = cap.get(cv2.CAP_PROP_FPS) or 25.0
    frames = cap.get(cv2.CAP_PROP_FRAME_COUNT) or 0
    w = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
    h = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
    cap.release()
    return (frames / fps if fps else 0.0), w, h, fps


RESOLUTION_FPS = {"low": 5.0, "medium": 10.0, "high": 15.0}


def run_pipeline(
    path: str,
    homography: np.ndarray | None,
    detector: Detector,
    resolution: str = "medium",
    progress: Callable[[str, int], None] = lambda stage, pct: None,
    min_track_seconds: float = 1.0,
) -> PipelineResult:
    duration, w, h, _ = video_info(path)
    calibrated = homography is not None
    H = homography if calibrated else A.default_homography(w, h)
    target_fps = RESOLUTION_FPS.get(resolution, 10.0)

    raw: dict[int, list[tuple[float, int, float, float]]] = {}
    colors: dict[int, list[np.ndarray]] = {}
    ball_samples: list[tuple[float, int, float | None, float | None]] = []

    total = max(1, int(duration * target_fps))
    progress("detecting", 5)
    for n, (t, fidx, frame) in enumerate(iter_frames(path, target_fps)):
        dets = detector(frame)
        best_ball = None
        for d in dets:
            if d.cls == BALL:
                if best_ball is None or d.conf > best_ball.conf:
                    best_ball = d
                continue
            if d.cls != PERSON or d.track_id is None:
                continue
            x1, y1, x2, y2 = d.box
            foot = ((x1 + x2) / 2, y2)
            raw.setdefault(d.track_id, []).append((t, fidx, *foot))
            if len(colors.get(d.track_id, [])) < 12 and n % 3 == 0:
                c = jersey_color(frame, d.box)
                if c is not None:
                    colors.setdefault(d.track_id, []).append(c)
        if best_ball is not None:
            x1, y1, x2, y2 = best_ball.box
            ball_samples.append((t, fidx, (x1 + x2) / 2, (y1 + y2) / 2))
        else:
            ball_samples.append((t, fidx, None, None))
        if n % 10 == 0:
            progress("tracking", 5 + int(70 * min(1.0, n / total)))

    progress("analyzing", 80)

    # Keep tracks that last long enough to be real players.
    tracks_m: dict[int, tuple[np.ndarray, np.ndarray, np.ndarray]] = {}
    for tid, samples in raw.items():
        arr = np.array(samples)
        if arr[-1, 0] - arr[0, 0] < min_track_seconds:
            continue
        pos_m = A.apply_homography(H, arr[:, 2:4])
        inside = (
            (pos_m[:, 0] > -3) & (pos_m[:, 0] < A.PITCH_LENGTH_M + 3)
            & (pos_m[:, 1] > -3) & (pos_m[:, 1] < A.PITCH_WIDTH_M + 3)
        )
        if inside.mean() < 0.6:  # mostly off-pitch → crowd / bench
            continue
        tracks_m[tid] = (arr[inside, 0], arr[inside, 1].astype(int), pos_m[inside])

    teams = A.assign_teams({
        tid: np.mean(colors[tid], axis=0) for tid in tracks_m if colors.get(tid)
    })

    tracks_out, players_out = [], []
    players_board = {}
    for tid, (times, frames, pos_m) in tracks_m.items():
        board = A.metres_to_board(A.smooth(pos_m, 5))
        players_board[tid] = (times, board)
        m = A.track_metrics(times, pos_m)
        team = teams.get(tid, "A" if tid % 2 else "B")
        tracks_out.append({
            "track_id": tid,
            "team": team,
            "positions": [
                {"x": round(float(x), 4), "y": round(float(y), 4),
                 "timestamp_seconds": round(float(t), 3), "frame": int(f)}
                for (x, y), t, f in zip(board, times, frames)
            ],
        })
        players_out.append({
            "track_id": tid,
            "team": team,
            "distance_km": round(m.distance_km, 3),
            "sprint_count": m.sprint_count,
            "sprint_distance_m": round(m.sprint_distance_m, 1),
            "max_speed_kmh": round(m.max_speed_kmh, 1),
            "avg_speed_kmh": round(m.avg_speed_kmh, 1),
            "heatmap": A.heatmap(board),
        })

    ball_times = np.array([s[0] for s in ball_samples]) if ball_samples else np.zeros(0)
    ball_px = np.array([[np.nan if s[2] is None else s[2], np.nan if s[3] is None else s[3]] for s in ball_samples]) if ball_samples else np.zeros((0, 2))
    ball_board = np.full_like(ball_px, np.nan)
    good = ~np.isnan(ball_px[:, 0]) if len(ball_px) else np.zeros(0, bool)
    if good.any():
        ball_board[good] = A.metres_to_board(A.apply_homography(H, ball_px[good]))
    ball_board = A.interpolate_ball(ball_times, ball_board) if len(ball_board) else ball_board
    ball_out = [
        {"x": round(float(x), 4), "y": round(float(y), 4),
         "timestamp_seconds": round(float(t), 3), "frame": int(s[1])}
        for (x, y), t, s in zip(ball_board, ball_times, ball_samples)
        if not np.isnan(x)
    ]

    zones = A.possession_zones(ball_times, ball_board, players_board, teams)
    progress("analyzing", 95)

    summary = {
        "players_tracked": len(tracks_out),
        "ball_detected_ratio": round(float(good.mean()), 3) if len(good) else 0.0,
        "team_a_distance_km": round(sum(p["distance_km"] for p in players_out if p["team"] == "A"), 2),
        "team_b_distance_km": round(sum(p["distance_km"] for p in players_out if p["team"] == "B"), 2),
        "total_sprints": sum(p["sprint_count"] for p in players_out),
    }
    return PipelineResult(
        duration_seconds=round(duration, 3),
        tracks=tracks_out,
        players=players_out,
        ball=ball_out,
        possession_zones=zones,
        calibrated=calibrated,
        frame_size=(w, h),
        summary=summary,
    )


def result_to_json(video_id: str, r: PipelineResult) -> dict:
    return {
        "video_id": video_id,
        "duration_seconds": r.duration_seconds,
        "tracks": r.tracks,
        "players": r.players,
        "ball": r.ball,
        "possession_zones": r.possession_zones,
        "calibrated": r.calibrated,
        "frame_size": list(r.frame_size),
        "summary": r.summary,
    }


def detections_from_iterable(items: Iterable[list[Detection]]) -> Detector:
    """Test helper: replay pre-computed detections frame by frame."""
    it = iter(items)

    def detect(_frame):
        return next(it, [])

    return detect
