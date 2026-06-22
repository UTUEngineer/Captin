# Captain — Privacy Policy

**Last updated:** June 22, 2026  
**Contact:** ayoa@smartgateapp.com

Captain ("we", "the app") is a tactical football coaching app. This policy describes what data the app handles and how.

---

## Summary

- Captain collects minimal data and does not sell or share it for advertising
- Video you upload is sent only to the vision backend for analysis, then deleted — never to third-party AI services
- Text statistics and match data are sent to Anthropic's API for tactical commentary, using your own API key
- No account email or real-world identity is required
- All network requests in production should use HTTPS

---

## 1. Data We Collect

### 1.1 Video Data

When you upload a match video for analysis, it is transmitted to the vision backend (the URL you configure in Settings). The backend processes the video to extract tactical events and annotations, then returns the results to your device.

- **Retention:** Videos are deleted from the backend after your device caches the analysis results (`DELETE /api/v1/videos/{id}`). A maximum retention period of **7 days** applies as a safety net for incomplete sessions (`VIDEO_RETENTION_HOURS=168`). An automatic purge runs on backend startup to remove orphaned uploads beyond this window.
- **Third-party sharing:** Video data is processed only by the vision backend. It is not forwarded to Anthropic or any other third party.
- **User-initiated deletion:** You can delete cached analysis results and request removal of associated server videos via **Settings → Clear analysis cache**, or wipe all local data via **Settings → Clear all local data**.

> **Self-hosted backends:** If you connect Captain to a self-hosted or third-party vision backend, that operator's data handling applies instead of this policy. We cannot make guarantees about backends we do not operate.

### 1.2 Match Statistics and Text Data

Text-based match statistics (player distances, speeds, zone summaries, possession, etc.) are sent to Anthropic's API to generate AI scouting reports and tactical commentary. This uses the Claude API key you provide in Settings.

- Your API key is stored in **secure storage on your device** and sent directly from the app to Anthropic per request
- Captain does **not** store your API key on any Captain-operated server
- Anthropic's own [Privacy Policy](https://www.anthropic.com/privacy) and [Usage Policy](https://www.anthropic.com/policies) apply to data processed through their API

### 1.3 Session Identifier and Display Name

For optional live collaboration, Captain generates a random UUID when you join or start a session, and you may enter a display name (e.g. "Coach").

- These are **not** linked to your email or real-world identity
- The UUID is scoped to the collaboration session flow, not an advertising or device fingerprint
- Board events and display names may pass through **Supabase Realtime** when Supabase is configured

### 1.4 Football Data

Leagues, teams, standings, and player data are fetched from API-Football (api-sports.io) when you provide an API-Football key. Captain sends query parameters (league ID, season, team ID) using your key — no personal data is included in these requests. API-Football's terms and privacy policy apply to their service.

### 1.5 Collaboration Infrastructure

Collaborative sessions use **Supabase Realtime** (broadcast channels) to sync tactical board state between devices. **No email, password, or Supabase Auth account** is required. If Supabase is not configured, collaboration is unavailable and no session data is sent.

---

## 2. Data We Do Not Collect

- Email address or password (no login account)
- Device advertising identifiers
- Precise or approximate location
- Crash reports or analytics (no third-party SDK is active)
- Audio from uploaded videos (audio tracks are not extracted or processed)
- Payment information (no in-app purchases)

Optional collaboration **display names** are user-chosen nicknames only — not verified identity.

---

## 3. Data Sharing

| Recipient | Data Shared | Purpose |
|---|---|---|
| Vision backend (operator-configured) | Match video | Tactical analysis |
| Anthropic | Match statistics (text) | AI scouting / tactical commentary |
| API-Football / api-sports.io | Query parameters + your API key (client-side) | Football data |
| Supabase | Realtime board/session events | Collaborative board sync |

We do not sell data. We do not share data for advertising or marketing purposes.

---

## 4. Security

Production network requests should use HTTPS (Anthropic, Supabase, API-Sports, and your vision backend). API keys are stored in platform secure storage on your device and are not logged on Captain-operated servers.

---

## 5. Children

Captain is not directed at children under 13 (or under 16 in the EU). We do not knowingly collect any data from children.

---

## 6. Changes to This Policy

If we make material changes, we will update the "Last updated" date above. Continued use of the app after changes constitutes acceptance of the revised policy.

---

## 7. Contact

For privacy questions or data deletion requests:  
**ayoa@smartgateapp.com**
