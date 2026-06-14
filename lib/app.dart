import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'features/onboarding/onboarding_flow.dart';
import 'providers/providers.dart';
import 'theme/app_theme.dart';
import 'widgets/nerok_scaffold.dart';

class NerokApp extends ConsumerWidget {
  const NerokApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Nerok',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const _RootGate(),
    );
  }
}

/// Shows onboarding until it is completed, then the main tab shell.
class _RootGate extends ConsumerWidget {
  const _RootGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingDone =
        ref.watch(settingsProvider.select((s) => s.onboardingDone));
    return onboardingDone ? const NerokScaffold() : const OnboardingFlow();
  }
}
