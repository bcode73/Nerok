import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/medication.dart';
import '../../../models/med_log.dart';
import '../../../providers/providers.dart';
import '../../../theme/colors.dart';
import '../../../theme/dimens.dart';
import '../../../theme/typography.dart';
import '../../../widgets/app_card.dart';

/// Editable list of medications taken during an episode, plus an
/// "Add medication" action that picks from the user's medication list.
class MedRows extends ConsumerWidget {
  const MedRows({super.key, required this.meds, required this.onChanged});

  final List<MedLog> meds;
  final ValueChanged<List<MedLog>> onChanged;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final medications = ref.read(medicationsProvider);
    final picked = await showModalBottomSheet<Medication>(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (_) => _MedPicker(medications: medications),
    );
    if (picked == null) return;
    final next = [...meds];
    next.add(MedLog(
      medId: picked.id,
      name: picked.name,
      doseMg: picked.defaultDoseMg,
      takenAt: DateTime.now(),
    ));
    onChanged(next);
  }

  void _setEffectiveness(int index, int? value) {
    final next = [...meds];
    next[index].effectiveness = value;
    onChanged(next);
  }

  void _remove(int index) {
    final next = [...meds]..removeAt(index);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        for (var i = 0; i < meds.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.sm),
            child: AppCard(
              padding: const EdgeInsets.all(AppSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          meds[i].doseMg == null
                              ? meds[i].name
                              : '${meds[i].name} · ${_fmtDose(meds[i].doseMg!)}',
                          style: AppType.bodyHi,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _remove(i),
                        child: const Icon(Icons.close,
                            size: 18, color: AppColors.textLow),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpace.sm),
                  Row(
                    children: [
                      Text('Helped?', style: AppType.caption),
                      const SizedBox(width: AppSpace.sm),
                      _EffChip(
                        label: 'No',
                        selected: meds[i].effectiveness == 0,
                        onTap: () => _setEffectiveness(i, 0),
                      ),
                      const SizedBox(width: AppSpace.xs),
                      _EffChip(
                        label: 'Some',
                        selected: meds[i].effectiveness == 1,
                        onTap: () => _setEffectiveness(i, 1),
                      ),
                      const SizedBox(width: AppSpace.xs),
                      _EffChip(
                        label: 'Fully',
                        selected: meds[i].effectiveness == 2,
                        onTap: () => _setEffectiveness(i, 2),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        GestureDetector(
          onTap: () => _add(context, ref),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.input),
              border: Border.all(color: AppColors.line2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, size: 18, color: AppColors.accent),
                const SizedBox(width: AppSpace.sm),
                Text('Add medication',
                    style: AppType.label.copyWith(color: AppColors.accent)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _fmtDose(double mg) =>
      mg == mg.roundToDouble() ? '${mg.round()} mg' : '$mg mg';
}

class _EffChip extends StatelessWidget {
  const _EffChip(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpace.md, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : AppColors.surface2,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
              color: selected ? AppColors.accent : Colors.transparent),
        ),
        child: Text(
          label,
          style: AppType.caption.copyWith(
            color: selected ? AppColors.textHi : AppColors.textMid,
          ),
        ),
      ),
    );
  }
}

class _MedPicker extends StatelessWidget {
  const _MedPicker({required this.medications});
  final List<Medication> medications;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpace.lg),
            child: Row(
              children: [
                Text('Choose medication', style: AppType.title),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: medications.length,
              itemBuilder: (context, i) {
                final m = medications[i];
                return ListTile(
                  title: Text(m.name, style: AppType.bodyHi),
                  subtitle: m.defaultDoseMg == null
                      ? null
                      : Text('${m.defaultDoseMg!.round()} mg default',
                          style: AppType.caption),
                  trailing: const Icon(Icons.add, color: AppColors.accent),
                  onTap: () => Navigator.of(context).pop(m),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
