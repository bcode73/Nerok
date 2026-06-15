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
import '../common/ai_consent.dart';

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
  bool _includeAi = false;

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

  String? _aiText() {
    if (!_includeAi) return null;
    return ref.read(aiAnalysisProvider(_range.days)).valueOrNull;
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
      aiAnalysis: _aiText(),
    );
  }

  Future<void> _toggleAi(bool enabled) async {
    if (!enabled) {
      setState(() => _includeAi = false);
      return;
    }
    final ok = await ensureAiConsent(context, ref);
    if (!ok) return;
    setState(() => _includeAi = true);
    // Generate (or reuse) the analysis for this range, then refresh preview.
    await ref.read(aiAnalysisProvider(_range.days).notifier).generate();
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
    // Watch so the preview rebuilds when the analysis arrives.
    final aiState = ref.watch(aiAnalysisProvider(_range.days));
    final aiReady = _includeAi && aiState.hasValue && aiState.value != null;
    // Key forces PdfPreview to regenerate when inputs change.
    final previewKey = ValueKey('${_range.days}_${_includeAi}_$aiReady');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpace.lg, AppSpace.lg, AppSpace.lg, AppSpace.sm),
          child: _RangeSelector(
            value: _range,
            onChanged: (r) => setState(() => _range = r),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
          child: _AiToggle(
            value: _includeAi,
            state: aiState,
            onChanged: _toggleAi,
          ),
        ),
        const SizedBox(height: AppSpace.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpace.sm),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.input),
                child: PdfPreview(
                  key: previewKey,
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

class _AiToggle extends StatelessWidget {
  const _AiToggle({
    required this.value,
    required this.state,
    required this.onChanged,
  });

  final bool value;
  final AsyncValue<String?> state;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final loading = value && state.isLoading;
    final error = value && state.hasError;
    final subtitle = error
        ? state.error.toString()
        : loading
            ? 'Generating analysis…'
            : 'Add an AI written summary to the PDF';

    return AppCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.lg, vertical: AppSpace.sm),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.accent, size: 20),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Include AI analysis', style: AppType.bodyHi),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppType.caption.copyWith(
                    color: error ? AppColors.accent : AppColors.textLow,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (loading)
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.accent),
            )
          else
            Switch(
              value: value,
              activeThumbColor: AppColors.accent,
              onChanged: onChanged,
            ),
        ],
      ),
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
