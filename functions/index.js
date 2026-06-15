/**
 * Nerok — DeepSeek analysis proxy (Firebase Cloud Functions, 2nd gen).
 *
 * The Flutter app POSTs an *aggregated* summary of the user's headache data
 * here; this function forwards it to DeepSeek with the API key that lives only
 * on the server, and returns the written analysis. The DeepSeek key never ships
 * inside the app.
 *
 * Setup:
 *   1. firebase functions:secrets:set DEEPSEEK_API_KEY
 *   2. (optional) firebase functions:secrets:set APP_SHARED_SECRET
 *   3. npm --prefix functions install
 *   4. firebase deploy --only functions
 *   5. Put the deployed URL into AiAnalysisService.endpoint in the app.
 */

import { onRequest } from "firebase-functions/v2/https";
import { defineSecret } from "firebase-functions/params";
import * as logger from "firebase-functions/logger";

const DEEPSEEK_API_KEY = defineSecret("DEEPSEEK_API_KEY");
// Optional lightweight gate against random callers. For real protection, add
// Firebase App Check.
const APP_SHARED_SECRET = defineSecret("APP_SHARED_SECRET");

const DEEPSEEK_URL = "https://api.deepseek.com/chat/completions";
// "deepseek-reasoner" gives deeper, reasoned analysis; swap to "deepseek-chat"
// for lower latency/cost.
const MODEL = "deepseek-reasoner";

const SYSTEM_PROMPT = `You are a careful health-data assistant inside a migraine and headache tracking app called Nerok.
You receive an ANONYMISED, AGGREGATED summary of one person's own tracked headache data (no name, no free-text notes).
Write a clear, calm, plain-language analysis the person can read and bring to their doctor.

Rules:
- Do NOT diagnose, do NOT prescribe, do NOT name specific medications to start or stop.
- Describe patterns and trends you actually see in the numbers (frequency, intensity, duration, common triggers, type mix, change vs the prior period).
- Be explicit that correlation in self-tracked data is not proof of causation.
- End with 2-4 concrete questions the person could ask their doctor.
- Keep it to roughly 150-220 words, no markdown headings, short paragraphs.
- If there is very little data, say so honestly and suggest logging more.`;

function buildUserMessage(d) {
  return [
    `Range: last ${d.rangeDays} days.`,
    `Episodes this period: ${d.episodeCount} (prior equal period: ${d.priorEpisodeCount}).`,
    `Average intensity (1-10): ${d.avgIntensity}.`,
    `Average duration: ${d.avgDurationMinutes} minutes.`,
    `Episodes per week: ${d.episodesPerWeek}.`,
    `Type distribution: ${JSON.stringify(d.typeDistribution)}.`,
    `Top triggers (name:count): ${(d.topTriggers || [])
      .map((t) => `${t.name}:${t.count}`)
      .join(", ") || "none recorded"}.`,
    `Weekly episode counts (oldest to newest): ${JSON.stringify(d.weeklyCounts)}.`,
    "",
    "Write the analysis now.",
  ].join("\n");
}

export const analyzeHeadaches = onRequest(
  {
    secrets: [DEEPSEEK_API_KEY, APP_SHARED_SECRET],
    cors: true,
    timeoutSeconds: 120,
    memory: "256MiB",
  },
  async (req, res) => {
    if (req.method !== "POST") {
      res.status(405).json({ error: "Method not allowed" });
      return;
    }

    const expectedSecret = APP_SHARED_SECRET.value();
    if (expectedSecret && req.get("x-app-secret") !== expectedSecret) {
      res.status(401).json({ error: "Unauthorized" });
      return;
    }

    // Accept either {data: {...}} (callable-style) or the payload directly.
    const payload = req.body?.data ?? req.body;
    if (!payload || typeof payload !== "object" || payload.rangeDays == null) {
      res.status(400).json({ error: "Invalid payload" });
      return;
    }

    try {
      const response = await fetch(DEEPSEEK_URL, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${DEEPSEEK_API_KEY.value()}`,
        },
        body: JSON.stringify({
          model: MODEL,
          stream: false,
          messages: [
            { role: "system", content: SYSTEM_PROMPT },
            { role: "user", content: buildUserMessage(payload) },
          ],
        }),
      });

      if (!response.ok) {
        const text = await response.text();
        logger.error("DeepSeek error", response.status, text);
        res.status(502).json({ error: "Upstream analysis failed" });
        return;
      }

      const json = await response.json();
      const analysis = json?.choices?.[0]?.message?.content?.trim();
      if (!analysis) {
        res.status(502).json({ error: "Empty analysis" });
        return;
      }

      res.status(200).json({ analysis });
    } catch (err) {
      logger.error("analyzeHeadaches failed", err);
      res.status(500).json({ error: "Internal error" });
    }
  }
);
