import 'package:flutter/material.dart';

import '../features/paywall/paywall_screen.dart';
import '../theme/colors.dart';
import '../theme/dimens.dart';
import '../theme/typography.dart';
import 'app_card.dart';
import 'primary_button.dart';

/// Opens the paywall as a modal route.
Future<void> showPaywall(BuildContext context) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute(builder: (_) => const PaywallScreen()),
  );
}

/// A soft locked card used to upsell Pro features (Insights, Report, Backup).
class UpsellLock extends StatelessWidget {
  const UpsellLock({
    super.key,
    required this.title,
    required this.message,
    this.cta = 'Unlock Pro',
  });

  final String title;
  final String message;
  final String cta;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline, color: AppColors.accent, size: 20),
              const SizedBox(width: AppSpace.sm),
              Expanded(child: Text(title, style: AppType.title)),
            ],
          ),
          const SizedBox(height: AppSpace.sm),
          Text(message, style: AppType.body),
          const SizedBox(height: AppSpace.lg),
          PrimaryButton(
            label: cta,
            icon: Icons.auto_awesome,
            onPressed: () => showPaywall(context),
          ),
        ],
      ),
    );
  }
}

/// A subtle inline upsell row (used at the bottom of the History list).
class UpsellRow extends StatelessWidget {
  const UpsellRow({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => showPaywall(context),
      color: AppColors.surface2,
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: AppColors.accent, size: 18),
          const SizedBox(width: AppSpace.md),
          Expanded(child: Text(message, style: AppType.bodyHi)),
          const Icon(Icons.chevron_right, color: AppColors.textMid),
        ],
      ),
    );
  }
}
