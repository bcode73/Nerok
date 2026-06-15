import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/pro_provider.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../theme/dimens.dart';
import '../../theme/typography.dart';
import '../../widgets/app_card.dart';
import '../../widgets/upsell_lock.dart';
import '../common/ai_consent.dart';
import 'backup_actions.dart';
import 'manage_catalog_screen.dart';
import 'manage_medications_screen.dart';
import 'widgets/settings_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProProvider);
    final settings = ref.watch(settingsProvider);

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
            AppSpace.lg, AppSpace.lg, AppSpace.lg, 120),
        children: [
          Text('Settings', style: AppType.display.copyWith(fontSize: 30)),
          const SizedBox(height: AppSpace.lg),
          _ProBanner(isPro: isPro),
          const SizedBox(height: AppSpace.xl),

          _GroupLabel('Tracking'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.bolt_outlined,
                  title: 'Triggers, symptoms & relief',
                  subtitle: 'Manage what you can log',
                  onTap: () => _push(context, const ManageCatalogScreen()),
                ),
                const _Divider(),
                SettingsTile(
                  icon: Icons.medication_outlined,
                  title: 'Medications',
                  subtitle: 'Your acute and preventive meds',
                  onTap: () =>
                      _push(context, const ManageMedicationsScreen()),
                ),
                const _Divider(),
                SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Daily reminder',
                  subtitle: settings.reminderEnabled
                      ? 'On · ${_fmtTime(settings.reminderHour, settings.reminderMinute)}'
                      : 'Off',
                  trailing: Switch(
                    value: settings.reminderEnabled,
                    activeThumbColor: AppColors.accent,
                    onChanged: (v) => _toggleReminder(context, ref, v),
                  ),
                  onTap: settings.reminderEnabled
                      ? () => _pickReminderTime(context, ref)
                      : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xl),

          _GroupLabel('Your data'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SettingsTile(
                  icon: Icons.ios_share,
                  title: 'Back up to JSON',
                  subtitle: isPro
                      ? 'Export all your data to a file'
                      : 'Pro — export all your data',
                  locked: !isPro,
                  onTap: () => isPro
                      ? BackupActions.export(context, ref)
                      : showPaywall(context),
                ),
                const _Divider(),
                SettingsTile(
                  icon: Icons.restore_page_outlined,
                  title: 'Restore from file',
                  subtitle: isPro
                      ? 'Replace data with a backup'
                      : 'Pro — restore from a backup',
                  locked: !isPro,
                  onTap: () => isPro
                      ? BackupActions.restore(context, ref)
                      : showPaywall(context),
                ),
                const _Divider(),
                SettingsTile(
                  icon: Icons.auto_awesome,
                  title: 'Deep analysis (AI)',
                  subtitle: !isPro
                      ? 'Pro — AI written summary of your data'
                      : settings.aiEnabled
                          ? 'On · anonymised summaries sent to DeepSeek'
                          : 'Off · data stays on this iPhone',
                  locked: !isPro,
                  trailing: isPro
                      ? Switch(
                          value: settings.aiEnabled,
                          activeThumbColor: AppColors.accent,
                          onChanged: (v) => _toggleAi(context, ref, v),
                        )
                      : null,
                  onTap: isPro ? null : () => showPaywall(context),
                ),
                const _Divider(),
                const SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Privacy',
                  subtitle:
                      'Your data stays on this iPhone, except the optional '
                      'AI analysis you turn on',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xl),

          _GroupLabel('Account'),
          AppCard(
            padding: EdgeInsets.zero,
            child: SettingsTile(
              icon: Icons.restart_alt,
              title: 'Restore purchases',
              subtitle: 'Already subscribed? Restore here',
              onTap: () => _restore(context, ref),
            ),
          ),
          const SizedBox(height: AppSpace.xl),

          Text(
            'Nerok is a tracking tool and does not provide medical advice.',
            style: AppType.caption,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpace.lg),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => screen));
  }

  String _fmtTime(int h, int m) {
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12:${m.toString().padLeft(2, '0')} $period';
  }

  Future<void> _toggleReminder(
      BuildContext context, WidgetRef ref, bool enabled) async {
    final notifier = ref.read(settingsProvider.notifier);
    if (enabled) {
      final granted =
          await ref.read(notificationServiceProvider).requestPermission();
      if (!granted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Enable notifications in Settings to get reminders.'),
          ));
        }
        return;
      }
    }
    final s = ref.read(settingsProvider);
    await notifier.setReminder(
      enabled: enabled,
      hour: s.reminderHour,
      minute: s.reminderMinute,
    );
  }

  Future<void> _pickReminderTime(BuildContext context, WidgetRef ref) async {
    final s = ref.read(settingsProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: s.reminderHour, minute: s.reminderMinute),
    );
    if (picked == null) return;
    await ref.read(settingsProvider.notifier).setReminder(
          enabled: true,
          hour: picked.hour,
          minute: picked.minute,
        );
  }

  Future<void> _toggleAi(
      BuildContext context, WidgetRef ref, bool enabled) async {
    if (enabled) {
      // Re-use the shared consent flow, which sets the flag on accept.
      await ensureAiConsent(context, ref);
    } else {
      await ref.read(settingsProvider.notifier).setAiEnabled(false);
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    try {
      final ok = await ref.read(revenueCatServiceProvider).restore();
      await ref.read(isProProvider.notifier).refresh();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok ? 'Purchases restored.' : 'No purchases to restore.'),
      ));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not restore purchases.')),
      );
    }
  }
}

class _ProBanner extends StatelessWidget {
  const _ProBanner({required this.isPro});
  final bool isPro;

  @override
  Widget build(BuildContext context) {
    if (isPro) {
      return AppCard(
        color: AppColors.surface2,
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.accent),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nerok Pro', style: AppType.title),
                  const SizedBox(height: 2),
                  Text('Thanks for your support.', style: AppType.caption),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const UpsellLock(
      title: 'Nerok Pro',
      message: 'Unlock full history, insights, the doctor report and backups.',
      cta: 'See Pro',
    );
  }
}

class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpace.xs, bottom: AppSpace.sm),
      child: Text(text.toUpperCase(),
          style: AppType.caption.copyWith(letterSpacing: 1)),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.line, indent: 56);
  }
}
