import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../providers/pro_provider.dart';
import '../../theme/colors.dart';
import '../../theme/dimens.dart';
import '../../theme/typography.dart';
import '../../widgets/primary_button.dart';

/// Loads the RevenueCat `default` offering.
final offeringProvider = FutureProvider<Offering?>((ref) {
  return ref.watch(revenueCatServiceProvider).currentOffering();
});

enum _Plan { annual, monthly }

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  _Plan _selected = _Plan.annual; // Annual pre-selected.
  bool _busy = false;

  static const _features = [
    ('Unlimited history + heatmap', Icons.calendar_month),
    ('Insights & trends', Icons.insights),
    ('Doctor PDF report', Icons.description),
    ('JSON backups', Icons.shield_outlined),
  ];

  Package? _packageFor(Offering? offering, _Plan plan) {
    if (offering == null) return null;
    return switch (plan) {
      _Plan.annual => offering.annual,
      _Plan.monthly => offering.monthly,
    };
  }

  Future<void> _purchase(Offering? offering) async {
    final package = _packageFor(offering, _selected);
    if (package == null) {
      _toast('Plans are not available yet. Please try again later.');
      return;
    }
    setState(() => _busy = true);
    try {
      final ok = await ref.read(revenueCatServiceProvider).purchase(package);
      if (!mounted) return;
      if (ok) {
        await ref.read(isProProvider.notifier).refresh();
        if (mounted) Navigator.of(context).pop();
      }
    } catch (_) {
      _toast('Something went wrong with the purchase.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    try {
      final ok = await ref.read(revenueCatServiceProvider).restore();
      if (!mounted) return;
      await ref.read(isProProvider.notifier).refresh();
      if (ok) {
        if (mounted) Navigator.of(context).pop();
      } else {
        _toast('No purchases to restore.');
      }
    } catch (_) {
      _toast('Could not restore purchases.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final offeringAsync = ref.watch(offeringProvider);
    final offering = offeringAsync.valueOrNull;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close, color: AppColors.textMid),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
                  children: [
                    Text('Get the full picture.',
                        style: AppType.display),
                    const SizedBox(height: AppSpace.sm),
                    Text(
                      'Unlock everything Nerok can do — all on your iPhone, '
                      'nothing in the cloud.',
                      style: AppType.body,
                    ),
                    const SizedBox(height: AppSpace.xl),
                    for (final f in _features) _FeatureRow(f.$1, f.$2),
                    const SizedBox(height: AppSpace.xl),
                    _PlanCard(
                      title: 'Annual',
                      price: '${_price(offering?.annual, r'$29.99')} / yr',
                      subtitle: 'Best value',
                      badge: 'Save 50%',
                      selected: _selected == _Plan.annual,
                      onTap: () => setState(() => _selected = _Plan.annual),
                    ),
                    const SizedBox(height: AppSpace.md),
                    _PlanCard(
                      title: 'Monthly',
                      price: '${_price(offering?.monthly, r'$4.99')} / mo',
                      subtitle: '7 days free',
                      selected: _selected == _Plan.monthly,
                      onTap: () => setState(() => _selected = _Plan.monthly),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpace.lg),
                child: Column(
                  children: [
                    PrimaryButton(
                      label: 'Start 7-day free trial',
                      loading: _busy,
                      onPressed: () => _purchase(offering),
                    ),
                    const SizedBox(height: AppSpace.md),
                    _FooterRow(onRestore: _busy ? null : _restore),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _price(Package? package, String fallback) {
    return package?.storeProduct.priceString ?? fallback;
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow(this.label, this.icon);
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.md),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.accent),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(child: Text(label, style: AppType.bodyHi)),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String price;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.all(AppSpace.lg),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.card),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.line,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.accent : AppColors.textLow,
            ),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: AppType.title),
                      if (badge != null) ...[
                        const SizedBox(width: AppSpace.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.sm, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius:
                                BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Text(
                            badge!,
                            style: AppType.caption.copyWith(
                                color: AppColors.page,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppType.caption),
                ],
              ),
            ),
            Text(price, style: AppType.bodyHi),
          ],
        ),
      ),
    );
  }
}

class _FooterRow extends StatelessWidget {
  const _FooterRow({required this.onRestore});
  final VoidCallback? onRestore;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: onRestore,
          child: Text('Restore', style: AppType.caption),
        ),
        Text('·', style: AppType.caption),
        TextButton(
          onPressed: () {},
          child: Text('Terms', style: AppType.caption),
        ),
        Text('·', style: AppType.caption),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm),
          child: Text('Cancel anytime', style: AppType.caption),
        ),
      ],
    );
  }
}
