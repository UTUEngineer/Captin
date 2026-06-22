# Captain — Data Safety / App Privacy (Code-Verified)

Use this when filling **App Store Connect → App Privacy** and **Google Play → Data safety**. Verified against the Captain Flutter app and vision backend as of the current codebase.

> Not legal advice. Confirm backend deployment behavior (TLS, retention jobs) matches what you declare before submitting.

---

## Actual data flows (verified)

| Flow | What happens | Third parties |
|------|----------------|---------------|
| **Local storage** | Settings, boards, analysis cache, API keys — `SharedPreferences` + `flutter_secure_storage` on device | None |
| **Video analysis** | Video uploaded to **your vision backend** over HTTP(S); processed on server; files kept under `storage/videos/{id}/` on disk | None for inference (YOLO runs on your backend) |
| **AI scouting** | **Text stats only** (distances, speeds, heatmap summaries) sent **from the app** to `api.anthropic.com` using the **user’s Claude API key** | Anthropic |
| **Collaboration** | Optional Supabase **Realtime broadcast** (session code + display name + board events). **No Supabase Auth** — collaborator ID is a local UUID | Supabase (infrastructure) |
| **Leagues** | Optional requests to `v3.football.api-sports.io` with user’s API-Football key | API-Sports |
| **Analytics / crash SDKs** | None | — |

### Corrections vs `captain_data_safety_final.md`

1. **Not** Supabase Anonymous Auth — there is no `signIn` / auth module; IDs are app-generated UUIDs.
2. **Video is not sent to Anthropic** — only derived match statistics for scouting reports.
3. **Video is deleted from the vision backend** after analysis results are cached on device (`DELETE /api/v1/videos/{id}`), with a **7-day retention fallback** (`VIDEO_RETENTION_HOURS=168`) for orphaned uploads.

---

## 1. Apple App Privacy (App Store Connect)

| Category | Collected? | Linked to user? | Tracking? | Purpose |
|----------|------------|-----------------|-----------|---------|
| Contact Info (email) | **No** | — | — | — |
| Name | **Optional** — display name for collaboration only | **Not linked** (user-chosen nickname) | No | App functionality |
| Photos / Videos | **Yes** — match video for analysis | **Not linked** (no account system) | No | App functionality |
| Other user content | **Yes** — tactics, annotations, timeline | Not linked if local-only; ephemeral if collab session | No | App functionality |
| Identifiers — User ID | **Yes** — local UUID for collaboration | Not linked to Apple/real identity | No | App functionality |
| Identifiers — Device ID | **No** dedicated SDK collection | — | — | — |
| Other data — credentials | **Yes** — Claude + API-Football keys stored on device | Not linked | No | App functionality |
| Diagnostics / usage | **No** | — | — | — |
| Location, health, financial, etc. | **No** | — | — | — |

**Apple summary**

- **Data used to track you:** None  
- **Data linked to you:** None (no accounts; nicknames and UUIDs are not tied to real-world identity)  
- **Data not linked to you:** Videos, user content, optional name, API keys, collaboration UUID  

---

## 2. Google Play Data Safety

| Data type | Collected? | Shared with third party? | Purpose | Notes |
|-----------|------------|--------------------------|---------|-------|
| Email / phone | **No** | — | — | — |
| Name | **Optional** (collab display name) | **No** | App functionality | Free-text nickname |
| Photos and videos | **Yes** | **No** — sent to **your** vision backend only | Video analysis | Declare your backend as first-party processing, not “sharing” |
| Files / docs | Same as tactics export/cache | **No** | App functionality | Local + optional collab |
| App activity / crash logs | **No** | — | — | — |
| Device or other IDs | **Yes** — collaboration UUID | **No** (Supabase is your processor for realtime) | Collaboration | Not advertising ID |
| Personal info — other | **Yes** — match stats sent to Anthropic when user runs scouting | **Yes — Anthropic** | AI scouting reports | User’s key; text only, not video |
| App info from third-party APIs | **Yes** — league logos/stats if user enables leagues | **Yes — API-Sports** | Leagues feature | User’s key |

**Data handling practices**

| Question | Answer | Notes |
|----------|--------|-------|
| Encrypted in transit | **Yes** | HTTPS for Anthropic, API-Sports, Supabase; vision backend should use TLS in production |
| Users can request deletion | **Yes** | Settings → Clear all local data; server videos deleted via `DELETE /api/v1/videos/{id}` after results are cached (7-day retention fallback on backend) |
| Required for core app | **No** | Board/tactics work offline with zero collection; video/leagues/scouting are optional features |

---

## 3. Privacy policy — required disclosures

Published in `docs/PRIVACY_POLICY.md` (contact: **ayoa@smartgateapp.com**). Key points:

1. Match videos go to your configured vision backend; deleted after results are cached, with a 7-day safety retention.
2. AI scouting sends **derived match statistics** (not raw video) to **Anthropic** using **your own** API key stored on device.
3. Collaboration uses **Supabase Realtime** only — no email account or Supabase Auth.
4. Optional leagues data uses **API-Sports** with your API key.

---

## 4. Before store submission

- [x] In-app privacy policy — bundled from `docs/PRIVACY_POLICY.md` (Settings → Privacy policy)
- [ ] Publish the same file at a **public URL** for store listing fields; set `--dart-define=PRIVACY_POLICY_URL=https://your-domain.com/privacy` for release builds
- [ ] Enforce **HTTPS** on production vision backend (no plain HTTP except local dev)
- [ ] Verify API-Sports / Anthropic ToS for commercial logo and data use
- [ ] Fill App Store Connect + Play Console using tables above

---

## Paste-ready one-liner (forms)

**Apple:** No tracking. No data linked to identity. Collects videos, user content, optional nickname, collaboration UUID, and locally stored API keys — all not linked, for app functionality only.

**Google Play:** Collects photos/videos (processed on operator’s vision backend, deleted after results cached), optional name and session UUID for collaboration, and match statistics shared with Anthropic when user enables AI scouting. Optional league data via API-Sports. No email, location, or crash analytics. Encrypted in transit. Local + server deletion available.
