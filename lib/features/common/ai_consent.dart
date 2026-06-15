import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../theme/dimens.dart';
import '../../theme/typography.dart';

/// Ensures the user has opted in to DeepSeek analysis. Returns true when consent
/// is in place (already given, or just granted). Shows a clear, one-time consent
/// dialog explaining that aggregated data leaves the device.
Future<bool> ensureAiConsent(BuildContext context, WidgetRef ref) async {
  final settings = ref.read(settingsProvider);
  if (settings.aiEnabled) return true;

  final accepted = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
          const SizedBox(width: AppSpace.sm),
          Text('Deep analysis', style: AppType.title),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To generate a deeper analysis, Nerok sends an anonymised summary '
            'of your tracking data to our analysis service (powered by '
            'DeepSeek).',
            style: AppType.body,
          ),
          const SizedBox(height: AppSpace.md),
          _Point('Only aggregates are sent — counts, averages, trigger '
              'frequencies and types.'),
          _Point('Your notes and your name never leave this iPhone.'),
          _Point('You can turn this off any time in Settings.'),
          const SizedBox(height: AppSpace.md),
          Text(
            'This is an aid for discussion with your doctor, not a diagnosis.',
            style: AppType.caption,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Not now'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Enable'),
        ),
      ],
    ),
  );

  if (accepted == true) {
    await ref.read(settingsProvider.notifier).setAiEnabled(true);
    return true;
  }
  return false;
}

class _Point extends StatelessWidget {
  const _Point(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check, size: 14, color: AppColors.good),
          ),
          const SizedBox(width: AppSpace.sm),
          Expanded(child: Text(text, style: AppType.caption)),
        ],
      ),
    );
  }
}
