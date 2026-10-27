import numpy as np
import cv2

from captain_vision import analytics as A
from captain_vision.pipeline import Detection, detections_from_iterable, run_pipeline


def test_homography_roundtrip():
    pixels = np.array([[100, 50], [500, 60], [620, 400], [20, 390]], float)
    pitch = np.array([[0, 13.84], [0, 54.16], [16.5, 54.16], [16.5, 13.84]])
    H = A.compute_homography(pixels, pitch)
    back = A.apply_homography(H, pixels)
    assert np.allclose(back, pitch, atol=1e-6)


def test_legacy_normalized_pitch_is_scaled():
    pts = A.to_metres(np.array([[0.5, 0.5]]))
    assert np.allclose(pts, [[52.5, 34.0]])


def test_track_metrics_distance_and_sprints():
    t = np.arange(0, 10, 0.1)
    # 3 s jog at 4 m/s, 3 s sprint at 8 m/s (28.8 km/h), 4 s walk at 1.5 m/s
    speed = np.where(t < 3, 4.0, np.where(t < 6, 8.0, 1.5))
    x = np.concatenate([[0], np.cumsum(speed[:-1] * 0.1)])
    pos = np.stack([x, np.full_like(x, 30)], axis=1)
    m = A.track_metrics(t, pos)
    assert abs(m.distance_km * 1000 - x[-1]) < 3
    assert m.sprint_count == 1
    assert 26 < m.max_speed_kmh < 31


def test_tracking_jumps_are_ignored():
    t = np.arange(0, 2, 0.1)
    pos = np.stack([np.linspace(0, 4, len(t)), np.zeros(len(t))], axis=1)
    pos[10:] += 40  # ID switch teleport
    m = A.track_metrics(t, pos)
    assert m.distance_km < 0.02


def test_team_clustering():
    rng = np.random.default_rng(1)
    colors = {i: np.array([200, 120, 130]) + rng.normal(0, 3, 3) for i in range(6)}
    colors.update({10 + i: np.array([60, 140, 110]) + rng.normal(0, 3, 3) for i in range(6)})
    teams = A.assign_teams(colors)
    a = {teams[i] for i in range(6)}
    b = {teams[10 + i] for i in range(6)}
    assert len(a) == 1 and len(b) == 1 and a != b


def test_heatmap_normalized():
    grid = A.heatmap(np.array([[0.5, 0.5]] * 10 + [[0.1, 0.9]]))
    flat = np.array(grid)
    assert flat.shape == (12, 8)
    assert flat.max() == 1.0


def _synthetic_video(path, seconds=4, fps=25, w=640, h=360):
    vw = cv2.VideoWriter(str(path), cv2.VideoWriter_fourcc(*"mp4v"), fps, (w, h))
    frames = int(seconds * fps)
    for f in range(frames):
        img = np.zeros((h, w, 3), np.uint8)
        img[:] = (40, 140, 40)  # grass (BGR)
        vw.write(img)
    vw.release()
    return frames, fps


def test_end_to_end_with_fake_detector(tmp_path):
    video = tmp_path / "clip.mp4"
    frames, fps = _synthetic_video(video)
    target_fps = 10
    n = int(frames / fps * target_fps)
    seq = []
    for k in range(n):
        x = 100 + k * 6  # runner moving right
        seq.append([
            Detection(1, 0, 0.9, (x - 10, 150, x + 10, 210)),
            Detection(2, 0, 0.9, (400, 200, 420, 260)),
            Detection(None, 32, 0.6, (x + 8, 205, x + 14, 211)),
        ])
    H = A.compute_homography(
        np.array([[0, 0], [640, 0], [640, 360], [0, 360]], float),
        np.array([[0, 68], [105, 68], [105, 0], [0, 0]], float),
    )
    r = run_pipeline(str(video), H, detections_from_iterable(seq), resolution="medium")
    assert len(r.tracks) == 2
    runner = next(p for p in r.players if p["track_id"] == 1)
    still = next(p for p in r.players if p["track_id"] == 2)
    assert runner["distance_km"] > still["distance_km"]
    assert len(r.ball) > 0
    assert set(r.possession_zones) == {"team_a", "team_b"}
    assert r.calibrated
