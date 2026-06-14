import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';

import '../../models/episode.dart';
import '../../providers/episodes_provider.dart';
import '../../providers/insights_provider.dart';
import '../../providers/pro_provider.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../theme/dimens.dart';
import '../../theme/typography.dart';
import '../../widgets/app_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/upsell_lock.dart';

enum _Range {
  d30(30, '30 days'),
  d90(90, '90 days'),
  all(36500, 'All');

  const _Range(this.days, this.label);
  final int days;
  final String label;
}

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  _Range _range = _Range.d90;
  bool _exporting = false;

  List<Episode> _episodesInRange() {
    final all = ref.read(episodesProvider);
    final cutoff = DateTime.now().subtract(Duration(days: _range.days));
    return all.where((e) => e.startAt.isAfter(cutoff)).toList();
  }

  String get _rangeLabel => switch (_range) {
        _Range.all => 'All time',
        _ => 'Last ${_range.label}',
      };

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final bytes = await _buildBytes();
      await Printing.sharePdf(bytes: bytes, filename: 'nerok-report.pdf');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<Uint8List> _buildBytes() {
    final pdf = ref.read(pdfServiceProvider);
    final insights = ref.read(reportInsightsProvider(_range.days));
    final settings = ref.read(settingsProvider);
    return pdf.build(
      episodes: _episodesInRange(),
      insights: insights,
      rangeLabel: _rangeLabel,
      patientName: settings.patientName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isPro = ref.watch(isProProvider);
    final hasData = ref.watch(episodesProvider).isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Doctor report')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: SafeArea(
          child: !isPro
              ? _buildLocked()
              : !hasData
                  ? const EmptyState(
                      icon: Icons.description_outlined,
                      title: 'Nothing to report yet',
                      message:
                          'Log a few episodes and you can generate a clean '
                          'PDF to bring to your doctor.',
                    )
                  : _buildReport(),
        ),
      ),
    );
  }

  Widget _buildLocked() {
    return ListView(
      padding: const EdgeInsets.all(AppSpace.lg),
      children: const [
        UpsellLock(
          title: 'Doctor report',
          message:
              'Turn your history into a clean, clinical PDF — summary stats, '
              'an episode log, and trigger frequencies — ready to share or '
              'print for your appointment.',
          cta: 'Start 7-day free trial',
        ),
      ],
    );
  }

  Widget _buildReport() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: _RangeSelector(
            value: _range,
            onChanged: (r) => setState(() => _range = r),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpace.sm),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.input),
                child: PdfPreview(
                  build: (_) => _buildBytes(),
                  canChangePageFormat: false,
                  canChangeOrientation: false,
                  canDebug: false,
                  allowPrinting: false,
                  allowSharing: false,
                  loadingWidget: const LoadingState(),
                  pdfPreviewPageDecoration: const BoxDecoration(),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpace.lg),
          child: PrimaryButton(
            label: 'Export PDF',
            icon: Icons.ios_share,
            loading: _exporting,
            onPressed: _export,
          ),
        ),
      ],
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({required this.value, required this.onChanged});
  final _Range value;
  final ValueChanged<_Range> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          for (final r in _Range.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(r),
                child: AnimatedContainer(
                  duration: AppMotion.fast,
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
                  decoration: BoxDecoration(
                    color: value == r ? AppColors.accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    r.label,
                    textAlign: TextAlign.center,
                    style: AppType.label.copyWith(
                      color: value == r ? AppColors.page : AppColors.textMid,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
