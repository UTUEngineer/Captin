# Captain Vision backend

Player + ball detection and match analytics for the Captain app.

**Pipeline**: YOLOv8 (`person`, `sports ball`) → ByteTrack IDs → jersey-colour
k-means (team A / B / other) → 4-point homography to metres → smoothed
trajectories → distance, avg/max speed, sprints (>25.2 km/h for ≥1 s),
sprint distance, 12×8 heatmaps, ball trajectory (gaps ≤1 s interpolated),
possession by pitch third.

## Run

```bash
cd vision_backend
python -m venv .venv && .venv\Scripts\activate      # Windows
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

First run downloads `yolov8n.pt`. For better accuracy set
`YOLO_WEIGHTS=yolov8m.pt` (or a football-tuned model). A GPU makes
processing ~10× faster.

Point the app at it with `VISION_API_BASE_URL=http://<your-ip>:8000` in `.env`
(or in Settings → backend URL).

| Env var | Default | Meaning |
|---|---|---|
| `CAPTAIN_DATA_DIR` | `./data` | Uploaded clips + results |
| `YOLO_WEIGHTS` | `yolov8n.pt` | Detector weights |
| `REQUIRE_AUTH` | `0` | `1` = require Supabase JWT |
| `SUPABASE_URL` | – | For JWKS when auth is on |
| `MAX_UPLOAD_MB` | `800` | Upload limit |

Calibration points: `pixel` = image coords, `pitch` = metres
`[distance from goal line, distance from touchline]` (the app sends the four
penalty-box corners). Without calibration a default broadcast-view
homography is used and the result is flagged `calibrated: false`.

## Tests

```bash
pip install pytest && python -m pytest tests
```
