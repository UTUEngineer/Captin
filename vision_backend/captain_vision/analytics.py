"""Pure-numpy analytics: homography, smoothing, distance, sprints, heatmaps,
team clustering and possession. No ML dependencies so it is unit-testable."""
from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np

PITCH_LENGTH_M = 105.0
PITCH_WIDTH_M = 68.0

# Speed thresholds (km/h) following common GPS-tracking conventions.
SPRINT_KMH = 25.2
SPRINT_EXIT_KMH = 21.0
MIN_SPRINT_SECONDS = 1.0
MAX_HUMAN_KMH = 38.0


# ── Homography ──────────────────────────────────────────────────────────


def to_metres(pitch_points: np.ndarray) -> np.ndarray:
    """Calibration pitch coordinates → metres (length, width).

    The app sends metres ([length from goal line, width from touchline]).
    Older builds sent normalized values (≤ 1.5) — scale those to a 105×68
    pitch.
    """
    pts = np.asarray(pitch_points, dtype=np.float64)
    if np.all(np.abs(pts) <= 1.5):
        pts = pts * np.array([PITCH_LENGTH_M, PITCH_WIDTH_M])
    return pts


def compute_homography(pixels: np.ndarray, pitch_m: np.ndarray) -> np.ndarray:
    """Direct linear transform for ≥4 correspondences (pixel → metres)."""
    src = np.asarray(pixels, dtype=np.float64)
    dst = np.asarray(pitch_m, dtype=np.float64)
    if len(src) < 4 or len(src) != len(dst):
        raise ValueError("need at least 4 point pairs")
    rows = []
    for (x, y), (u, v) in zip(src, dst):
        rows.append([-x, -y, -1, 0, 0, 0, u * x, u * y, u])
        rows.append([0, 0, 0, -x, -y, -1, v * x, v * y, v])
    _, _, vt = np.linalg.svd(np.asarray(rows))
    h = vt[-1].reshape(3, 3)
    return h / h[2, 2]


def apply_homography(h: np.ndarray, points: np.ndarray) -> np.ndarray:
    pts = np.asarray(points, dtype=np.float64).reshape(-1, 2)
    homo = np.hstack([pts, np.ones((len(pts), 1))]) @ h.T
    return homo[:, :2] / homo[:, 2:3]


def default_homography(frame_w: int, frame_h: int) -> np.ndarray:
    """Uncalibrated fallback: assume a wide broadcast shot showing the whole
    pitch with mild perspective (far touchline narrower)."""
    pixels = np.array([
        [frame_w * 0.12, frame_h * 0.30],  # far-left corner
        [frame_w * 0.88, frame_h * 0.30],  # far-right corner
        [frame_w * 1.00, frame_h * 0.98],  # near-right corner
        [frame_w * 0.00, frame_h * 0.98],  # near-left corner
    ])
    pitch = np.array([
        [0, PITCH_WIDTH_M],
        [PITCH_LENGTH_M, PITCH_WIDTH_M],
        [PITCH_LENGTH_M, 0],
        [0, 0],
    ])
    return compute_homography(pixels, pitch)


def metres_to_board(points_m: np.ndarray) -> np.ndarray:
    """Metres (length, width) → app board coords (x across 0..1, y along
    0..1 with the analysed team's goal at the bottom)."""
    pts = np.asarray(points_m, dtype=np.float64).reshape(-1, 2)
    x = np.clip(pts[:, 1] / PITCH_WIDTH_M, 0, 1)
    y = np.clip(1 - pts[:, 0] / PITCH_LENGTH_M, 0, 1)
    return np.stack([x, y], axis=1)


# ── Trajectory metrics ──────────────────────────────────────────────────


def smooth(series: np.ndarray, window: int = 5) -> np.ndarray:
    """Centered moving average per column; keeps endpoints."""
    s = np.asarray(series, dtype=np.float64)
    if len(s) < 3 or window <= 1:
        return s.copy()
    window = min(window, len(s) if len(s) % 2 else len(s) - 1)
    pad = window // 2
    padded = np.pad(s, ((pad, pad), (0, 0)), mode="edge")
    kernel = np.ones(window) / window
    return np.stack(
        [np.convolve(padded[:, c], kernel, mode="valid") for c in range(s.shape[1])],
        axis=1,
    )


@dataclass
class TrackMetrics:
    distance_km: float
    max_speed_kmh: float
    avg_speed_kmh: float
    sprint_count: int
    sprint_distance_m: float
    speeds_kmh: list = field(default_factory=list)


def track_metrics(times: np.ndarray, pos_m: np.ndarray) -> TrackMetrics:
    """Distance, speeds and sprint count for one player trajectory in metres."""
    t = np.asarray(times, dtype=np.float64)
    p = smooth(np.asarray(pos_m, dtype=np.float64), window=5)
    if len(t) < 2:
        return TrackMetrics(0, 0, 0, 0, 0, [])
    dt = np.diff(t)
    step = np.linalg.norm(np.diff(p, axis=0), axis=1)
    valid = dt > 0
    speed_ms = np.zeros_like(step)
    speed_ms[valid] = step[valid] / dt[valid]
    # Reject tracking jumps (ID switches / homography edge noise).
    jump = speed_ms * 3.6 > MAX_HUMAN_KMH
    step = np.where(jump, 0.0, step)
    speed_kmh = np.where(jump, np.nan, speed_ms * 3.6)
    speed_kmh = _fill_nan(speed_kmh)

    sprints, sprint_dist = 0, 0.0
    in_sprint, start_t, acc = False, 0.0, 0.0
    for i, v in enumerate(speed_kmh):
        now = t[i + 1]
        if not in_sprint and v >= SPRINT_KMH:
            in_sprint, start_t, acc = True, t[i], 0.0
        if in_sprint:
            acc += step[i]
            if v < SPRINT_EXIT_KMH or i == len(speed_kmh) - 1:
                if now - start_t >= MIN_SPRINT_SECONDS:
                    sprints += 1
                    sprint_dist += acc
                in_sprint = False

    total_time = t[-1] - t[0]
    distance = float(step.sum())
    return TrackMetrics(
        distance_km=distance / 1000,
        max_speed_kmh=float(np.nanmax(speed_kmh)) if len(speed_kmh) else 0.0,
        avg_speed_kmh=float(distance / total_time * 3.6) if total_time > 0 else 0.0,
        sprint_count=sprints,
        sprint_distance_m=sprint_dist,
        speeds_kmh=[round(float(v), 2) for v in speed_kmh],
    )


def _fill_nan(values: np.ndarray) -> np.ndarray:
    v = values.copy()
    if np.all(np.isnan(v)):
        return np.zeros_like(v)
    idx = np.arange(len(v))
    good = ~np.isnan(v)
    v[~good] = np.interp(idx[~good], idx[good], v[good])
    return v


def heatmap(board_xy: np.ndarray, rows: int = 12, cols: int = 8) -> list[list[float]]:
    """Occupancy grid in board space (rows along length), normalized 0..1."""
    grid = np.zeros((rows, cols))
    pts = np.asarray(board_xy, dtype=np.float64).reshape(-1, 2)
    if len(pts):
        c = np.clip((pts[:, 0] * cols).astype(int), 0, cols - 1)
        r = np.clip((pts[:, 1] * rows).astype(int), 0, rows - 1)
        np.add.at(grid, (r, c), 1)
        # light blur so short tracks still read as areas
        blurred = grid.copy()
        blurred[1:, :] += grid[:-1, :] * 0.5
        blurred[:-1, :] += grid[1:, :] * 0.5
        blurred[:, 1:] += grid[:, :-1] * 0.5
        blurred[:, :-1] += grid[:, 1:] * 0.5
        grid = blurred
        if grid.max() > 0:
            grid = grid / grid.max()
    return [[round(float(v), 4) for v in row] for row in grid]


# ── Teams ───────────────────────────────────────────────────────────────


def kmeans(features: np.ndarray, k: int = 2, iters: int = 30, seed: int = 0):
    x = np.asarray(features, dtype=np.float64)
    if len(x) < k:
        return np.zeros(len(x), dtype=int), x
    rng = np.random.default_rng(seed)
    # k-means++ init
    centers = [x[rng.integers(len(x))]]
    for _ in range(1, k):
        d = np.min([np.sum((x - c) ** 2, axis=1) for c in centers], axis=0)
        probs = d / d.sum() if d.sum() > 0 else None
        centers.append(x[rng.choice(len(x), p=probs)])
    centers = np.array(centers)
    labels = np.zeros(len(x), dtype=int)
    for _ in range(iters):
        dist = np.stack([np.sum((x - c) ** 2, axis=1) for c in centers], axis=1)
        labels = dist.argmin(axis=1)
        new = np.array([
            x[labels == j].mean(axis=0) if np.any(labels == j) else centers[j]
            for j in range(k)
        ])
        if np.allclose(new, centers):
            break
        centers = new
    return labels, centers


def assign_teams(track_colors: dict[int, np.ndarray]) -> dict[int, str]:
    """Cluster per-track jersey colors into teams A/B; far outliers (referees,
    keepers in odd kits) become 'other'."""
    ids = list(track_colors)
    if not ids:
        return {}
    feats = np.stack([track_colors[i] for i in ids])
    labels, centers = kmeans(feats, k=2)
    dists = np.linalg.norm(feats - centers[labels], axis=1)
    cutoff = max(np.median(dists) * 3, np.median(dists) + 2.5 * np.std(dists), 25.0)
    result = {}
    for i, tid in enumerate(ids):
        if len(ids) >= 6 and dists[i] > cutoff:
            result[tid] = "other"
        else:
            result[tid] = "A" if labels[i] == 0 else "B"
    return result


def possession_zones(
    times: np.ndarray,
    ball_board: np.ndarray,
    players_board: dict[int, tuple[np.ndarray, np.ndarray]],
    teams: dict[int, str],
    control_radius_board: float = 0.035,
) -> dict:
    """Share of controlled-ball time per team in each third of the pitch."""
    counts = {"A": np.zeros(3), "B": np.zeros(3)}
    for k, t in enumerate(times):
        bx, by = ball_board[k]
        if np.isnan(bx):
            continue
        best, best_d = None, control_radius_board
        for tid, (pt, pxy) in players_board.items():
            team = teams.get(tid)
            if team not in ("A", "B") or len(pt) == 0:
                continue
            j = np.searchsorted(pt, t)
            if j >= len(pt) or abs(pt[j] - t) > 0.25:
                continue
            d = np.hypot(pxy[j, 0] - bx, pxy[j, 1] - by)
            if d < best_d:
                best, best_d = team, d
        if best is None:
            continue
        third = min(2, int((1 - by) * 3))  # 0 = own third for team A
        counts[best][third] += 1
    total = sum(c.sum() for c in counts.values())

    def zones(c):
        if total == 0:
            return {"defensive": 0.0, "middle": 0.0, "attacking": 0.0}
        return {
            "defensive": round(float(c[0] / total), 4),
            "middle": round(float(c[1] / total), 4),
            "attacking": round(float(c[2] / total), 4),
        }

    # Team B attacks the other way: mirror thirds.
    b = counts["B"][::-1]
    return {"team_a": zones(counts["A"]), "team_b": zones(b)}


def interpolate_ball(times: np.ndarray, xy: np.ndarray, max_gap_s: float = 1.0):
    """Linearly fill short gaps (NaN) in the ball trajectory."""
    out = xy.copy()
    for c in range(2):
        col = out[:, c]
        good = ~np.isnan(col)
        if good.sum() < 2:
            continue
        idx = np.where(~good)[0]
        for i in idx:
            prev = np.where(good[:i])[0]
            nxt = np.where(good[i:])[0]
            if len(prev) == 0 or len(nxt) == 0:
                continue
            a, b = prev[-1], i + nxt[0]
            if times[b] - times[a] <= max_gap_s:
                w = (times[i] - times[a]) / (times[b] - times[a])
                col[i] = col[a] * (1 - w) + col[b] * w
    return out
