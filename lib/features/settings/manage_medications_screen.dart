import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/medication.dart';
import '../../providers/pro_provider.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../theme/dimens.dart';
import '../../theme/typography.dart';
import '../../widgets/app_card.dart';
import '../../widgets/upsell_lock.dart';
import 'widgets/custom_limit.dart';

class ManageMedicationsScreen extends ConsumerWidget {
  const ManageMedicationsScreen({super.key});

  bool _isCustom(Medication m) => m.id.startsWith('custom_');

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final isPro = ref.read(isProProvider);
    final count = ref.read(customCountProvider);
    if (!CustomLimit.canAdd(isPro: isPro, currentCount: count)) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: const EdgeInsets.all(AppSpace.lg),
          content: UpsellLock(
            title: 'Custom limit reached',
            message:
                'Free includes up to ${CustomLimit.freeMax} custom items. Go '
                'Pro for unlimited custom medications.',
          ),
        ),
      );
      return;
    }
    final result = await showDialog<_MedDraft>(
      context: context,
      builder: (_) => const _AddMedDialog(),
    );
    if (result == null) return;
    await ref.read(medicationsProvider.notifier).add(
          result.name,
          defaultDoseMg: result.doseMg,
          kind: result.kind,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meds = ref.watch(medicationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Medications')),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(AppSpace.lg),
            children: [
              for (final m in meds)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.sm),
                  child: AppCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.lg, vertical: AppSpace.md),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(m.name, style: AppType.bodyHi),
                              const SizedBox(height: 2),
                              Text(
                                [
                                  if (m.defaultDoseMg != null)
                                    '${m.defaultDoseMg!.round()} mg',
                                  m.isPreventive ? 'Preventive' : 'Acute',
                                ].join(' · '),
                                style: AppType.caption,
                              ),
                            ],
                          ),
                        ),
                        if (_isCustom(m))
                          GestureDetector(
                            onTap: () => ref
                                .read(medicationsProvider.notifier)
                                .delete(m.id),
                            child: const Icon(Icons.delete_outline,
                                size: 20, color: AppColors.textLow),
                          )
                        else
                          Text('Default', style: AppType.caption),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: AppSpace.sm),
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
                          style:
                              AppType.label.copyWith(color: AppColors.accent)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedDraft {
  const _MedDraft(this.name, this.doseMg, this.kind);
  final String name;
  final double? doseMg;
  final int kind;
}

class _KindToggle extends StatelessWidget {
  const _KindToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(
              color: selected ? AppColors.accent : AppColors.line),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppType.label.copyWith(
            color: selected ? AppColors.textHi : AppColors.textMid,
          ),
        ),
      ),
    );
  }
}

class _AddMedDialog extends StatefulWidget {
  const _AddMedDialog();

  @override
  State<_AddMedDialog> createState() => _AddMedDialogState();
}

class _AddMedDialogState extends State<_AddMedDialog> {
  final _name = TextEditingController();
  final _dose = TextEditingController();
  int _kind = 0;

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New medication'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'Name'),
          ),
          const SizedBox(height: AppSpace.md),
          TextField(
            controller: _dose,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Default dose (mg)'),
          ),
          const SizedBox(height: AppSpace.md),
          Row(
            children: [
              Expanded(
                child: _KindToggle(
                  label: 'Acute',
                  selected: _kind == 0,
                  onTap: () => setState(() => _kind = 0),
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: _KindToggle(
                  label: 'Preventive',
                  selected: _kind == 1,
                  onTap: () => setState(() => _kind = 1),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final name = _name.text.trim();
            if (name.isEmpty) return;
            Navigator.of(context).pop(_MedDraft(
              name,
              double.tryParse(_dose.text.trim()),
              _kind,
            ));
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
