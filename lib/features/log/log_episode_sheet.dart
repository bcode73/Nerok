import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../models/enums.dart';
import '../../models/episode.dart';
import '../../models/med_log.dart';
import '../../providers/episodes_provider.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../theme/dimens.dart';
import '../../theme/typography.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/select_chip.dart';
import 'widgets/intensity_picker.dart';
import 'widgets/med_rows.dart';

/// Full-screen modal for logging (or editing) an episode. Always free — logging
/// is never gated.
class LogEpisodeSheet extends ConsumerStatefulWidget {
  const LogEpisodeSheet({super.key, this.episode});

  /// When provided, the sheet edits this episode instead of creating one.
  final Episode? episode;

  @override
  ConsumerState<LogEpisodeSheet> createState() => _LogEpisodeSheetState();
}

class _LogEpisodeSheetState extends ConsumerState<LogEpisodeSheet> {
  late DateTime _startAt;
  late bool _ongoing;
  DateTime? _endAt;
  late int _intensity;
  late EpisodeType _type;
  late Set<String> _triggers;
  late Set<String> _symptoms;
  late Set<String> _relief;
  late List<MedLog> _meds;
  late TextEditingController _notes;

  bool get _isEdit => widget.episode != null;

  @override
  void initState() {
    super.initState();
    final e = widget.episode;
    _startAt = e?.startAt ?? DateTime.now();
    _ongoing = e == null ? false : e.isOngoing;
    _endAt = e?.endAt;
    _intensity = e?.intensity ?? 5;
    _type = e?.type ?? EpisodeType.migraine;
    _triggers = {...?e?.triggerIds};
    _symptoms = {...?e?.symptomIds};
    _relief = {...?e?.reliefIds};
    _meds = [...?e?.meds];
    _notes = TextEditingController(text: e?.notes ?? '');
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startAt,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startAt),
    );
    if (!mounted) return;
    setState(() {
      _startAt = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _startAt.hour,
        time?.minute ?? _startAt.minute,
      );
    });
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final episode = widget.episode ??
        Episode(
          id: const Uuid().v4(),
          startAt: _startAt,
          intensity: _intensity,
          type: _type,
          createdAt: now,
          updatedAt: now,
        );

    episode
      ..startAt = _startAt
      ..endAt = _ongoing ? null : (_endAt ?? now)
      ..intensity = _intensity
      ..type = _type
      ..triggerIds = _triggers.toList()
      ..symptomIds = _symptoms.toList()
      ..reliefIds = _relief.toList()
      ..meds = _meds
      ..notes = _notes.text.trim();

    await ref.read(episodesProvider.notifier).save(episode);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isEdit ? 'Episode updated' : 'Episode saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final triggers = ref.watch(catalogByKindProvider(CatalogKind.trigger));
    final symptoms = ref.watch(catalogByKindProvider(CatalogKind.symptom));
    final relief = ref.watch(catalogByKindProvider(CatalogKind.relief));

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.pageGradient),
      child: Column(
        children: [
          _Header(
            title: _isEdit ? 'Edit episode' : 'Log episode',
            onClose: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  AppSpace.lg, 0, AppSpace.lg, AppSpace.xl),
              children: [
                _StartRow(
                  startAt: _startAt,
                  ongoing: _ongoing,
                  onPickStart: _pickStart,
                  onToggleOngoing: (v) => setState(() => _ongoing = v),
                ),
                const SizedBox(height: AppSpace.xl),
                IntensityPicker(
                  value: _intensity,
                  onChanged: (v) => setState(() => _intensity = v),
                ),
                const SizedBox(height: AppSpace.xl),
                _ChipSection(
                  title: 'Type',
                  child: Wrap(
                    spacing: AppSpace.sm,
                    runSpacing: AppSpace.sm,
                    children: [
                      for (final t in EpisodeType.values)
                        SelectChip(
                          label: t.label,
                          selected: _type == t,
                          onTap: () => setState(() => _type = t),
                        ),
                    ],
                  ),
                ),
                _MultiChips(
                  title: 'Triggers',
                  items: triggers,
                  selected: _triggers,
                  onToggle: (id) => setState(() => _toggle(_triggers, id)),
                ),
                _MultiChips(
                  title: 'Symptoms',
                  items: symptoms,
                  selected: _symptoms,
                  onToggle: (id) => setState(() => _toggle(_symptoms, id)),
                ),
                _MultiChips(
                  title: 'Relief',
                  items: relief,
                  selected: _relief,
                  onToggle: (id) => setState(() => _toggle(_relief, id)),
                ),
                _ChipSection(
                  title: 'Medication',
                  child: MedRows(
                    meds: _meds,
                    onChanged: (next) => setState(() => _meds = next),
                  ),
                ),
                _ChipSection(
                  title: 'Notes',
                  child: TextField(
                    controller: _notes,
                    minLines: 2,
                    maxLines: 5,
                    style: AppType.bodyHi,
                    decoration: const InputDecoration(
                      hintText: 'Anything else worth remembering?',
                    ),
                  ),
                ),
                const SizedBox(height: AppSpace.xl),
                PrimaryButton(label: 'Save', onPressed: _save),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggle(Set<String> set, String id) {
    if (!set.add(id)) set.remove(id);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onClose});
  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpace.lg, AppSpace.md, AppSpace.sm, AppSpace.md),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppType.titleLarge)),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, color: AppColors.textMid),
          ),
        ],
      ),
    );
  }
}

class _StartRow extends StatelessWidget {
  const _StartRow({
    required this.startAt,
    required this.ongoing,
    required this.onPickStart,
    required this.onToggleOngoing,
  });

  final DateTime startAt;
  final bool ongoing;
  final VoidCallback onPickStart;
  final ValueChanged<bool> onToggleOngoing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Started', style: AppType.label),
        const SizedBox(height: AppSpace.sm),
        GestureDetector(
          onTap: onPickStart,
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.lg, vertical: AppSpace.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.input),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, size: 18, color: AppColors.textMid),
                const SizedBox(width: AppSpace.sm),
                Text(
                  DateFormat('EEE d MMM · h:mm a').format(startAt),
                  style: AppType.bodyHi,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        Row(
          children: [
            Expanded(
              child: Text('Still ongoing', style: AppType.bodyHi),
            ),
            Switch(
              value: ongoing,
              activeThumbColor: AppColors.accent,
              onChanged: onToggleOngoing,
            ),
          ],
        ),
      ],
    );
  }
}

class _ChipSection extends StatelessWidget {
  const _ChipSection({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppType.label),
          const SizedBox(height: AppSpace.md),
          child,
        ],
      ),
    );
  }
}

class _MultiChips extends StatelessWidget {
  const _MultiChips({
    required this.title,
    required this.items,
    required this.selected,
    required this.onToggle,
  });

  final String title;
  final List items; // List<CatalogItem>
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return _ChipSection(
      title: title,
      child: Wrap(
        spacing: AppSpace.sm,
        runSpacing: AppSpace.sm,
        children: [
          for (final item in items)
            SelectChip(
              label: item.name as String,
              selected: selected.contains(item.id),
              onTap: () => onToggle(item.id as String),
            ),
        ],
      ),
    );
  }
}
