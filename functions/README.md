# Nerok — DeepSeek analysis proxy

A single Firebase Cloud Function (`analyzeHeadaches`) that the Nerok app calls
to generate the "Deep analysis" text. It holds the DeepSeek API key server-side
so the key never ships inside the mobile app.

## What the app sends

Only **aggregated** data — counts, averages, episodes-per-week, type
distribution and trigger frequencies. No free-text notes, no patient name.

## Deploy the function

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

## App Check (required by default)

The function rejects any request without a valid Firebase **App Check** token
(`REQUIRE_APP_CHECK = true` in `index.js`). To make the app produce those
tokens:

1. **Add Firebase to the app** (creates the native config files):
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure --project <your-project-id>
   ```
   This drops `ios/Runner/GoogleService-Info.plist` and
   `android/app/google-services.json` into place. `firebase_core` then
   initialises from them automatically — no `firebase_options.dart` import is
   needed by our code.
2. **Register App Check providers** in the Firebase console → *App Check*:
   - iOS: **App Attest** (and DeviceCheck as fallback). Enable the *App Attest*
     capability for the Runner target in Xcode.
   - Android: **Play Integrity**.
3. **Debug builds:** the app uses the App Check *debug* provider in debug mode.
   Run once, copy the debug token printed in the console, and add it under
   *App Check → Apps → Manage debug tokens*.
4. In *App Check → APIs*, set **Cloud Functions** enforcement to **Enforced**
   once you've confirmed real builds work.

If Firebase isn't configured yet, the app still launches normally — the Deep
analysis feature just stays unavailable until the steps above are done.

## Notes

- App Check is the primary gate. `APP_SHARED_SECRET` is an optional extra check;
  on its own a secret shipped in a binary can be extracted, so prefer App Check.
- Model is `deepseek-reasoner` (deeper, slower). Switch to `deepseek-chat` in
  `index.js` for lower latency/cost.
- The function returns `{ "analysis": "..." }`.
