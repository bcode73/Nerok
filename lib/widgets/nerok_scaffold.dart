import 'package:flutter/material.dart';

import '../features/history/history_screen.dart';
import '../features/home/home_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/log/log_episode_sheet.dart';
import '../features/settings/settings_screen.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

/// Bottom tab shell: Home, History, [center raised Log FAB], Insights, Settings.
/// The Log FAB opens the Log Episode sheet as a full-screen modal.
class NerokScaffold extends StatefulWidget {
  const NerokScaffold({super.key});

  @override
  State<NerokScaffold> createState() => _NerokScaffoldState();
}

class _NerokScaffoldState extends State<NerokScaffold> {
  int _index = 0;

  static const _tabs = <Widget>[
    HomeScreen(),
    HistoryScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  Future<void> _openLog() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.bg,
      builder: (_) => const LogEpisodeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: IndexedStack(index: _index, children: _tabs),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _LogFab(onTap: _openLog),
      bottomNavigationBar: _BottomBar(
        index: _index,
        onChanged: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _LogFab extends StatelessWidget {
  const _LogFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.accent, AppColors.accentDeep],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentDeep.withValues(alpha: 0.45),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: AppColors.page, size: 30),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _item(0, Icons.home_outlined, Icons.home, 'Home'),
              _item(1, Icons.calendar_month_outlined, Icons.calendar_month,
                  'History'),
              const Spacer(),
              _item(2, Icons.insights_outlined, Icons.insights, 'Insights'),
              _item(3, Icons.settings_outlined, Icons.settings, 'Settings'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i, IconData icon, IconData active, String label) {
    final selected = index == i;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? active : icon,
              size: 24,
              color: selected ? AppColors.accent : AppColors.textLow,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppType.caption.copyWith(
                color: selected ? AppColors.accent : AppColors.textLow,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
