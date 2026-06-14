import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../theme/dimens.dart';
import '../../theme/typography.dart';
import '../../widgets/primary_button.dart';
import '../paywall/paywall_screen.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    _controller.nextPage(
      duration: AppMotion.medium,
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    await ref.read(settingsProvider.notifier).completeOnboarding();
    if (!mounted) return;
    // Offer Pro once, but never block entry — the root gate already shows the
    // app once onboarding is done.
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const PaywallScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _page = i),
                  children: const [_PageOne(), _PageTwo()],
                ),
              ),
              _Dots(count: 2, index: _page),
              const SizedBox(height: AppSpace.lg),
              Padding(
                padding: const EdgeInsets.all(AppSpace.lg),
                child: PrimaryButton(
                  label: _page == 0 ? 'Get started' : 'Continue',
                  onPressed: _page == 0 ? _next : _finish,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageOne extends StatelessWidget {
  const _PageOne();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('See the pattern\nbehind the pain.', style: AppType.display),
          const SizedBox(height: AppSpace.lg),
          Text(
            'Log a headache in seconds. Over time, Nerok shows you what sets '
            'yours off — so you can do something about it.',
            style: AppType.body,
          ),
          const SizedBox(height: AppSpace.xl),
          _PrivacyLine(),
        ],
      ),
    );
  }
}

class _PrivacyLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined,
              color: AppColors.good, size: 20),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Text(
              'Everything stays on this iPhone. No account, no cloud.',
              style: AppType.caption.copyWith(color: AppColors.textMid),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageTwo extends StatelessWidget {
  const _PageTwo();

  static const _steps = [
    (
      '1',
      'Log the episode',
      'Intensity, type, triggers and meds — a few taps when it hits.',
      Icons.edit_outlined,
    ),
    (
      '2',
      'Spot your triggers',
      'Nerok aggregates your own data into clear, calm patterns.',
      Icons.insights_outlined,
    ),
    (
      '3',
      'Bring proof to your doctor',
      'Export a clean PDF report for your next appointment.',
      Icons.description_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Three taps a day\nis all it takes.', style: AppType.display),
          const SizedBox(height: AppSpace.xl),
          for (final s in _steps) _Step(s.$1, s.$2, s.$3, s.$4),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.number, this.title, this.body, this.icon);
  final String number;
  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.xl),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.accent, size: 20),
          ),
          const SizedBox(width: AppSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppType.title),
                const SizedBox(height: 2),
                Text(body, style: AppType.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: AppMotion.fast,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == index ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index ? AppColors.accent : AppColors.surface2,
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
          ),
      ],
    );
  }
}
