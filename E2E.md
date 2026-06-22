# Local E2E — Captain Flutter + Vision Backend

This guide connects the **Captain app** (`c:\captin`) to the **vision backend** (`c:\captin-vision-backend`) on your machine.

## 0. Preflight checklist (run first)

| Check | Command | Expected |
|-------|---------|----------|
| Docker Desktop running | `docker ps` | Lists containers (no pipe error) |
| Backend health | `curl http://127.0.0.1:8000/health` | `{"status":"ok",...}` |
| ffmpeg on host (if not using Docker) | `ffprobe -version` | Version string (required for uploads) |
| Flutter tests | `cd c:\captin; flutter test` | All tests pass |

**Common blockers on Windows:**

- **Docker not running** → start Docker Desktop, then `docker compose up` in `captin-vision-backend\docker`
- **Health OK but upload fails** → ffmpeg/ffprobe missing on host; use Docker stack instead of bare uvicorn
- **Backend `.env` missing** → `copy c:\captin-vision-backend\.env.example c:\captin-vision-backend\.env`

Host-only uvicorn (no Docker) can pass `/health` but **video upload still needs ffmpeg**.

## 1. Start the backend stack

**Recommended (includes ffmpeg, Redis, worker):**

```powershell
cd c:\captin-vision-backend\docker
docker compose up --build
```

**Alternative — uvicorn on the host (requires ffmpeg on PATH):**

```powershell
# Install ffmpeg: winget install Gyan.FFmpeg  (then restart terminal)
cd c:\captin-vision-backend
$env:CELERY_TASK_ALWAYS_EAGER = "true"
py -m uv run uvicorn app.main:app --host 127.0.0.1 --port 8001
```

Use port **8001** if something else already listens on 8000.

Wait until:

- http://localhost:8000/health → `"status": "ok"`
- http://localhost:8000/docs opens Swagger

First video analysis on CPU can take **several minutes** (YOLO + tracking).

## 2. Run the automated smoke test (optional)

With the stack running:

```powershell
cd c:\captin-vision-backend
py -m uv run python scripts/e2e_smoke.py --base-url http://127.0.0.1:8000
```

If the API runs on another port, pass `--base-url http://127.0.0.1:8001`.

This runs upload → process → calibrate → process → result over HTTP.

## 3. Run the Flutter app

Pick the base URL for your target:

| Target | `VISION_API_BASE_URL` |
|--------|------------------------|
| Windows / macOS / Linux desktop | `http://127.0.0.1:8000` |
| Android emulator | `http://10.0.2.2:8000` |
| iOS simulator | `http://127.0.0.1:8000` |
| Physical phone (same Wi‑Fi) | `http://YOUR_PC_LAN_IP:8000` |

```powershell
cd c:\captin
flutter pub get
flutter run --dart-define=VISION_API_BASE_URL=http://127.0.0.1:8000
```

Android emulator example:

```powershell
flutter run --dart-define=VISION_API_BASE_URL=http://10.0.2.2:8000
```

## 4. Manual app flow

1. Home → **Analyze Match Video**
2. Upload a short clip (< 10 min) or paste a YouTube URL
3. Wait on the processing screen (polls `/status`)
4. When prompted, place **4 calibration pins** on the penalty box
5. Processing resumes automatically → **Analysis result** screen
6. Use timeline, heatmap overlay, stats, **Open as board**

## 5. Troubleshooting

| Issue | Fix |
|-------|-----|
| “Vision backend unavailable” on Analyze screen | Stack not running, or wrong `VISION_API_BASE_URL` |
| Upload / smoke test fails with ffprobe error | Install ffmpeg on the backend host, or use Docker |
| Port 8000 already in use | Use `--port 8001` for uvicorn and matching `--dart-define` |
| Android cannot connect | Use `10.0.2.2`, not `127.0.0.1`; debug build allows HTTP cleartext |
| Processing never completes | Check worker logs: `docker compose logs worker -f` |
| Calibration screen blank | Run `/process` first so frames exist; check `GET .../first-frame` in Swagger |
| Very slow analysis | Expected on CPU Docker; use GPU deploy for real throughput |

## 6. Related docs

- Backend API & Docker: `c:\captin-vision-backend\README.md`
- GPU / RunPod deploy: `c:\captin-vision-backend\DEPLOY.md`
