# Nerok — DeepSeek analysis proxy

A single Firebase Cloud Function (`analyzeHeadaches`) that the Nerok app calls
to generate the "Deep analysis" text. It holds the DeepSeek API key server-side
so the key never ships inside the mobile app.

## What the app sends

Only **aggregated** data — counts, averages, episodes-per-week, type
distribution and trigger frequencies. No free-text notes, no patient name.

## Deploy

```bash
# from the repo root
npm --prefix functions install

# set secrets (you'll be prompted to paste the values)
firebase functions:secrets:set DEEPSEEK_API_KEY
firebase functions:secrets:set APP_SHARED_SECRET   # optional; see below

firebase deploy --only functions
```

After deploy, copy the printed URL (e.g.
`https://us-central1-<project-id>.cloudfunctions.net/analyzeHeadaches`) into the
app at `lib/services/ai_analysis_service.dart` → `AiAnalysisService.endpoint`.
If you set `APP_SHARED_SECRET`, put the same value in
`AiAnalysisService.appSecret`.

## Notes / hardening

- `APP_SHARED_SECRET` is a lightweight gate only — a secret shipped in a mobile
  binary can be extracted. For real protection add
  [Firebase App Check](https://firebase.google.com/docs/app-check) and verify
  the token in this function.
- Model defaults to `deepseek-reasoner` (deeper, slower). Switch to
  `deepseek-chat` in `index.js` for lower latency/cost.
- The function returns `{ "analysis": "..." }`.
