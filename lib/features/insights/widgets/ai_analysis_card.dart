import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/providers.dart';
import '../../../theme/colors.dart';
import '../../../theme/dimens.dart';
import '../../../theme/typography.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/primary_button.dart';
import '../../common/ai_consent.dart';

/// "Deep analysis" card on the Insights screen. Pro + opt-in + on-demand: the
/// network call only runs when the user taps Generate.
class AiAnalysisCard extends ConsumerWidget {
  const AiAnalysisCard({super.key, this.days = 90});

  final int days;

  Future<void> _generate(BuildContext context, WidgetRef ref) async {
    final ok = await ensureAiConsent(context, ref);
    if (!ok) return;
    await ref.read(aiAnalysisProvider(days).notifier).generate();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(aiAnalysisProvider(days));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
              const SizedBox(width: AppSpace.sm),
              Expanded(child: Text('Deep analysis', style: AppType.title)),
              if (state.hasValue && state.value != null)
                GestureDetector(
                  onTap: () => _generate(context, ref),
                  child: const Icon(Icons.refresh,
                      size: 18, color: AppColors.textMid),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          state.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpace.lg),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.accent),
                  ),
                  SizedBox(width: AppSpace.md),
                  Text('Analysing your last 90 days…'),
                ],
              ),
            ),
            error: (e, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.toString(), style: AppType.body),
                const SizedBox(height: AppSpace.md),
                PrimaryButton(
                  label: 'Try again',
                  filled: false,
                  onPressed: () => _generate(context, ref),
                ),
              ],
            ),
            data: (text) {
              if (text == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get a written read on your patterns over the last '
                      '90 days — trends, likely trigger correlations, and '
                      'questions to raise with your doctor.',
                      style: AppType.body,
                    ),
                    const SizedBox(height: AppSpace.lg),
                    PrimaryButton(
                      label: 'Generate analysis',
                      icon: Icons.auto_awesome,
                      onPressed: () => _generate(context, ref),
                    ),
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(text, style: AppType.body),
                  const SizedBox(height: AppSpace.sm),
                  Text(
                    'AI-generated from your data. Not medical advice.',
                    style: AppType.caption,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
