# ⚽ Captain — Complete Project Brief & Engineering Overview

> **Document Type:** Project Overview, Features Completed & Actionable Roadmap  
> **Target Audience:** Coaches, Technical Analysts, Investors, Developers & Stakeholders  
> **Version:** 1.0 (Production Architecture & AI Integrations)  
> **Platforms:** Mobile (iOS / Android), Tablet, Web (3D Dashboard)  

---

## 🌟 1. Executive Summary: What is Captain?

**Captain** is an advanced tactical football intelligence platform designed for professional football coaches, analysts, and clubs. 

Most existing tactical apps are either **simple 2D drawing whiteboards** or **expensive, complex enterprise video suites**. Captain bridges this gap by unifying four cutting-edge capabilities into a single cohesive app:

1. **3D Interactive Playground:** Coaches don't just see a flat pitch — they can rotate the camera in full 3D, simulate formations, and even enter **"Be The Player" First-Person POV** to see what a midfielder sees before making a pass.
2. **AI Video & 3D Synchronization:** Real match broadcast footage runs frame-by-frame in tandem with a 3D tactical simulation, tracking all 22 players and computing dynamic heatmaps and passing risk corridors.
3. **Live League Scouting & Squad Ingestion:** Instant connection to live leagues (including the English Premier League, La Liga, Champions League, and **Iraq Stars League**), importing official matchday lineups onto the 3D pitch with a single tap.
4. **Claude 3.5 Sonnet AI Tactical Advisor:** An integrated UEFA Pro-level AI assistant that analyzes opponent formations, identifies defensive vulnerabilities, flags key players to press, and recommends counter-tactics.

---

## 🛠️ 2. Detailed Breakdown: What Was Built (Features Completed)

```
                                  CAPTAIN CORE ARCHITECTURE
   ┌───────────────────────────────────────────────────────────────────────────────────────────┐
   │                                   CAPTAIN MAIN DASHBOARD                                  │
   │                               (Interactive 3-Hub Architecture)                            │
   └───────────────┬───────────────────────────┬───────────────────────────┬───────────────────┘
                   │                           │                           │
                   ▼                           ▼                           ▼
      ┌─────────────────────────┐ ┌─────────────────────────┐ ┌─────────────────────────┐
      │   HUB 1: 3D PLAYGROUND  │ │  HUB 2: VIDEO/3D SYNC   │ │ HUB 3: SCOUTING & AI    │
      ├─────────────────────────┤ ├─────────────────────────┤ ├─────────────────────────┤
      │ • 3D Camera Controls    │ │ • Split-Screen Video    │ │ • Live Match Fixtures   │
      │ • "Be The Player" POV   │ │ • Frame-Accurate Sync   │ │ • Official Lineups      │
      │ • Animated Formations   │ │ • 22 Player Trajectories│ │ • Iraq Stars League     │
      │ • Keyframe Animator     │ │ • 3D Heatmaps           │ │ • Claude 3.5 Scouting   │
      │ • Tactical Annotations  │ │ • Passing Risk Corridors│ │ • 1-Click 3D Import     │
      │ • Cloud Board Save/Load │ │ • Timeline Scrubber     │ │ • PDF Export Engine     │
      └─────────────────────────┘ └─────────────────────────┘ └─────────────────────────┘
```

---

### HUB 1: 3D Tactical Playground & First-Person POV
*Location in code:* `lib/screens/virtual_playground_screen.dart`, `lib/widgets/interactive_3d_pitch.dart`

- **Interactive 3D Pitch:**
  - Full 3D rendering with pitch lighting, boundary markings, and dynamic player tokens.
  - Orbit, pan, tilt, and zoom camera controls for complete tactical flexibility.
- **"Be The Player" First-Person Camera Mode:**
  - One-click camera switch that positions the viewpoint at exact human eye-level (1.75 meters high) from any selected player.
  - Allows coaches to test whether a player realistically has the line-of-sight to see an open winger or if a passing lane is obstructed by defenders.
- **Animated Formations Engine:**
  - Supports 5 core tactical formations: `4-3-3`, `4-2-3-1`, `3-5-2`, `4-4-2`, and `5-3-2`.
  - Players transition smoothly between formations with animated movement rather than snapping instantly.
- **Tactical Keyframe Sequence Engine:**
  - Enables coaches to choreograph multi-phase set pieces or tactical attacks (Phase 1: Build-up ➔ Phase 2: Overlap ➔ Phase 3: Cross).
  - Keyframes are recorded, positions are automatically interpolated, and the entire play can be played back with play/pause and scrubbing.
- **Cloud Board Synchronization:**
  - Boards can be saved directly to the Supabase PostgreSQL cloud database and loaded on any device.

---

### HUB 2: AI Video vs. 3D Simulation Sync
*Location in code:* `lib/screens/video_match_analysis_screen.dart`, `lib/services/tracking_player_engine.dart`

- **Frame-by-Frame Dual Synchronization:**
  - Displays real match video side-by-side (or top-and-bottom) with the 3D virtual pitch.
  - Scrubbing the video slider automatically updates player positions in the 3D pitch at 25 frames per second.
- **22-Player AI Tracking Ingestion:**
  - Ingests computer vision coordinates (derived from YOLOv8 + ByteTrack object tracking) for all 22 players plus the match ball.
- **3D Dynamic Heatmaps:**
  - Renders real-time player intensity heatmaps directly onto the 3D pitch surface, showing areas of high possession or defensive saturation.
- **Passing Risk Corridors:**
  - Visual corridors drawn between players that calculate risk levels:
    - **Green Corridor:** Safe passing lane with low interception probability.
    - **Yellow Corridor:** Contested passing lane.
    - **Red Corridor:** High-risk lane with an intercepting defender in the corridor.

---

### HUB 3: League Scouting & Claude 3.5 AI Advisor
*Location in code:* `lib/screens/league_scouting_screen.dart`, `lib/services/claude_scouting_service.dart`, `lib/services/football_api_service.dart`

- **Live League Ingestion:**
  - Fetches live fixtures, schedules, and official lineups across world leagues: Premier League, La Liga, Serie A, UEFA Champions League.
  - **Special Feature:** Full native support and data seeding for the **Iraq Stars League** (*دوري نجوم العراق*), including clubs like Al-Zawraa, Al-Shorta, Al-Quwa Al-Jawiya, and Al-Talaba with their real rosters.
- **1-Click Squad Ingestion:**
  - Automatically converts official API team sheets into 3D player coordinates and loads both starting XIs directly onto the 3D playground.
- **Claude 3.5 Sonnet Scouting Engine:**
  - Sends opponent formations and player roles to Anthropic's Claude 3.5 Sonnet with a specialized UEFA Pro prompt.
  - Generates a structured tactical dossier:
    1. **Team Vulnerability:** Key defensive weaknesses (e.g., space left behind attacking fullbacks).
    2. **Team Strength:** Primary attacking threat (e.g., rapid counter-attacks via wingers).
    3. **Recommended Counter-Strategy:** Tailored tactical scheme to neutralize the opponent.
    4. **Counter-Formation:** Suggested tactical lineup to exploit gaps.
    5. **Key Player to Press:** Pinpoints the opposing playmaker and provides the tactical reason for pressing them.

---

### ADDITIONAL MODULES & INFRASTRUCTURE

#### 1. 2D Tactical Whiteboard & Presentation Mode
*Location:* `lib/features/tactical_board/`, `lib/features/presentation_mode/`
- Vector-drawn pitch with vertical/horizontal orientations and striped/solid grass.
- Curved, straight, pass, run, and press arrows with magnetic anchoring.
- 50-step undo/redo stack.
- Presentation mode equipped with a laser pointer, spotlight focusing, and zoom.

#### 2. Training Drills & Session Designer
*Location:* `lib/features/training/`
- Custom drill path styling (straight, curved bezier, dashed sprints, ball dribble).
- Pitch training props: cones, agility ladders, training mannequins, hurdles, and mini-goals.
- Pre-built drill templates (rondo, counter-attack drills, passing triangles).

#### 3. Match Event Timeline
*Location:* `lib/features/timeline/`
- Visual match event timeline recording goals, substitutions, cards, and tactical shifts minute-by-minute.

#### 4. Automated Tactical PDF Match Reports
*Location:* `lib/services/pdf_tactical_report_service.dart`, `lib/features/export/`
- Generates print-ready A4 PDF tactical match reports.
- Full bilingual Arabic (RTL with Cairo font) and English support.
- Contains pitch snapshots, starting XI tables, opponent analysis, and counter-tactics.

#### 5. Web 3D Dashboard
*Location:* `web_dashboard/`
- Vite + React + Three.js application (`Tactical3DCanvas.jsx`) providing browser-based 3D tactics.

---

## 📊 3. Technical Stack & Architecture

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Frontend Framework** | **Flutter 3.x / Dart 3.12** | Cross-platform mobile, tablet, and desktop app |
| **State Management** | **Flutter Riverpod 2.6** | Reactive, testable state & dependency injection |
| **Navigation** | **GoRouter 15.x** | Declarative deep-linkable URL routing |
| **3D Engine** | **Three.js / Flutter 3D** | Interactive pitch rendering, lighting, camera |
| **Backend & Database** | **Supabase (PostgreSQL + RLS)** | Cloud board persistence, schemas, caching |
| **AI Intelligence** | **Claude 3.5 Sonnet (Anthropic)** | UEFA Pro tactical opponent scouting reports |
| **Football Data API** | **API-Football + Custom Seeding** | Live fixtures, lineups, Iraq Stars League data |
| **Video Playback** | **video_player** | Synced match footage playback |
| **Document Export** | **pdf + printing** | High-resolution PDF generation with Arabic Cairo fonts |

---

## 🚀 4. What Should Be Done Next (Actionable Roadmap)

### Phase 1: Immediate Enhancements (Short-Term / High Priority)
1. **Automated Pitch Homography Calibration:**
   - *Current:* User manually clicks 4 pitch reference points on video frames.
   - *Next Step:* Implement an automated computer vision model that recognizes penalty boxes and the center circle automatically.
2. **Real-Time Multi-Coach Collaboration:**
   - *Current:* Cloud boards save and load on demand.
   - *Next Step:* Connect Supabase Realtime WebSocket channels so multiple coaches on separate iPads/laptops can see player movements and arrows in real-time during halftime talks.
3. **Offline-First Local Storage Fallback:**
   - *Current:* Relies on active internet for cloud save and API queries.
   - *Next Step:* Implement full local SQLite/Hive caching so coaches can use all boards and saved tactics without internet on the pitch.
4. **Custom Club PDF Templates:**
   - Allow clubs to upload their own team badge, custom colors, and coach signature blocks for matchday report exports.

### Phase 2: Advanced Football Analytics (Medium-Term)
1. **Expected Threat (xT) & Compactness Polygons:**
   - Compute real-time geometric area (in $m^2$) of the team's defensive block to quantify compactness.
   - Overlay Expected Threat (xT) grids showing which passing direction yields the highest threat.
2. **Live Matchday Bench Mode (Dugout Interface):**
   - A simplified 1-touch live interface for tablets on the bench: log chances, fouls, pressing breakdowns, and preview substitution impact before making changes.
3. **Voiceover Tactical Audio Notes:**
   - Allow coaches to record voice notes attached directly to specific keyframe animation steps.
4. **Player Mobile Portal:**
   - Restricted player view where players receive their specific role instructions, opponent direct matchups, and tactical quizzes.

### Phase 3: Production & Scaling (Long-Term)
1. **Cloud GPU Video Processing Cluster:**
   - Containerized FastAPI + TensorRT workers on AWS/RunPod for processing full 90-minute 4K match video in under 15 minutes.
2. **App Store & Google Play Launch:**
   - Automated CI/CD build signing via Fastlane, Google Play Store AAB, and Apple App Store TestFlight distribution.

---

*Brief generated for Captain Football Tactical System.*
