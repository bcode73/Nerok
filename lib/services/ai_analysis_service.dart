import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/episode.dart';
import '../providers/insights_provider.dart';

/// Talks to the DeepSeek-backed analysis endpoint. The DeepSeek API key never
/// ships in the app — this calls a Firebase Cloud Function proxy that holds the
/// key server-side, rate-limits, and forwards to DeepSeek.
///
/// Only *aggregated* data is sent (counts, averages, trigger frequencies, type
/// distribution). Free-text notes and the patient's name never leave the device.
class AiAnalysisService {
  AiAnalysisService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  // TODO(samuel): set to your deployed Firebase Cloud Function URL, e.g.
  // https://us-central1-<project-id>.cloudfunctions.net/analyzeHeadaches
  static const String endpoint =
      'TODO(samuel): firebase_function_url';

  // TODO(samuel): optional shared secret checked by the function. Add Firebase
  // App Check for stronger protection against abuse.
  static const String appSecret = 'TODO(samuel): app_shared_secret';

  bool get isConfigured => !endpoint.startsWith('TODO');

  /// Builds the aggregate-only payload sent for analysis.
  static Map<String, dynamic> buildPayload(
    Insights insights,
    List<Episode> episodes,
    int days,
  ) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final inRange = episodes.where((e) => e.startAt.isAfter(cutoff)).toList();

    final typeCounts = <String, int>{};
    for (final e in inRange) {
      typeCounts[e.type.label] = (typeCounts[e.type.label] ?? 0) + 1;
    }

    return {
      'rangeDays': days,
      'episodeCount': insights.episodeCount,
      'priorEpisodeCount': insights.priorEpisodeCount,
      'avgIntensity': double.parse(insights.avgIntensity.toStringAsFixed(2)),
      'avgDurationMinutes': insights.avgDuration.inMinutes,
      'episodesPerWeek':
          double.parse(insights.episodesPerWeek.toStringAsFixed(2)),
      'typeDistribution': typeCounts,
      'topTriggers':
          insights.topTriggers.map((t) => {'name': t.name, 'count': t.count}).toList(),
      'weeklyCounts': insights.weekBuckets.map((b) => b.count).toList(),
    };
  }

  /// Returns the analysis text, or throws on failure. [appCheckToken] attests
  /// the request to the proxy; pass null when App Check isn't configured.
  Future<String> analyze(
    Map<String, dynamic> payload, {
    String? appCheckToken,
  }) async {
    if (!isConfigured) {
      throw const AiAnalysisException(
          'Analysis is not set up yet. Add the Firebase function URL.');
    }

    final headers = <String, String>{'Content-Type': 'application/json'};
    if (!appSecret.startsWith('TODO')) {
      headers['x-app-secret'] = appSecret;
    }
    if (appCheckToken != null) {
      headers['X-Firebase-AppCheck'] = appCheckToken;
    }

    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(endpoint),
            headers: headers,
            body: jsonEncode({'data': payload}),
          )
          .timeout(const Duration(seconds: 90));
    } on TimeoutException {
      throw const AiAnalysisException('The analysis timed out. Try again.');
    } catch (_) {
      throw const AiAnalysisException('Could not reach the analysis service.');
    }

    if (response.statusCode != 200) {
      throw AiAnalysisException(
          'Analysis failed (${response.statusCode}). Please try again.');
    }

    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final text = (body['analysis'] ?? body['result'] ?? body['text'])
          as String?;
      if (text == null || text.trim().isEmpty) {
        throw const AiAnalysisException('The analysis came back empty.');
      }
      return text.trim();
    } on AiAnalysisException {
      rethrow;
    } catch (_) {
      throw const AiAnalysisException('Unexpected response from the service.');
    }
  }

  void dispose() => _client.close();
}

class AiAnalysisException implements Exception {
  const AiAnalysisException(this.message);
  final String message;

  @override
  String toString() => message;
}
