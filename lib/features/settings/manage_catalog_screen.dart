import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/catalog_item.dart';
import '../../models/enums.dart';
import '../../providers/pro_provider.dart';
import '../../providers/providers.dart';
import '../../theme/colors.dart';
import '../../theme/dimens.dart';
import '../../theme/typography.dart';
import '../../widgets/app_card.dart';
import '../../widgets/upsell_lock.dart';
import 'widgets/custom_limit.dart';

class ManageCatalogScreen extends ConsumerWidget {
  const ManageCatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tracking'),
          bottom: const TabBar(
            labelColor: AppColors.accent,
            unselectedLabelColor: AppColors.textMid,
            indicatorColor: AppColors.accent,
            tabs: [
              Tab(text: 'Triggers'),
              Tab(text: 'Symptoms'),
              Tab(text: 'Relief'),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.pageGradient),
          child: const TabBarView(
            children: [
              _CatalogList(kind: CatalogKind.trigger),
              _CatalogList(kind: CatalogKind.symptom),
              _CatalogList(kind: CatalogKind.relief),
            ],
          ),
        ),
      ),
    );
  }
}

class _CatalogList extends ConsumerWidget {
  const _CatalogList({required this.kind});
  final CatalogKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(catalogByKindProvider(kind));

    return ListView(
      padding: const EdgeInsets.all(AppSpace.lg),
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.sm),
            child: _ItemRow(item: item),
          ),
        const SizedBox(height: AppSpace.sm),
        _AddButton(kind: kind),
      ],
    );
  }
}

class _ItemRow extends ConsumerWidget {
  const _ItemRow({required this.item});
  final CatalogItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.lg, vertical: AppSpace.md),
      child: Row(
        children: [
          Expanded(child: Text(item.name, style: AppType.bodyHi)),
          if (item.isCustom)
            GestureDetector(
              onTap: () => ref.read(catalogProvider.notifier).delete(item.id),
              child: const Icon(Icons.delete_outline,
                  size: 20, color: AppColors.textLow),
            )
          else
            Text('Default', style: AppType.caption),
        ],
      ),
    );
  }
}

class _AddButton extends ConsumerWidget {
  const _AddButton({required this.kind});
  final CatalogKind kind;

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final isPro = ref.read(isProProvider);
    final count = ref.read(customCountProvider);
    if (!CustomLimit.canAdd(isPro: isPro, currentCount: count)) {
      await showDialog<void>(
        context: context,
        builder: (_) => const _LimitDialog(),
      );
      return;
    }
    final name = await _promptName(context, kind.label);
    if (name == null || name.trim().isEmpty) return;
    await ref.read(catalogProvider.notifier).addCustom(name.trim(), kind);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
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
            Text('Add ${kind.label.toLowerCase()}',
                style: AppType.label.copyWith(color: AppColors.accent)),
          ],
        ),
      ),
    );
  }
}

class _LimitDialog extends StatelessWidget {
  const _LimitDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(AppSpace.lg),
      content: UpsellLock(
        title: 'Custom limit reached',
        message:
            'Free includes up to ${CustomLimit.freeMax} custom items. Go Pro '
            'for unlimited custom triggers, symptoms, relief and medications.',
      ),
    );
  }
}

Future<String?> _promptName(BuildContext context, String kindLabel) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('New $kindLabel'.toLowerCase().replaceFirstMapped(
          RegExp(r'^.'), (m) => m.group(0)!.toUpperCase())),
      content: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(controller.text),
          child: const Text('Add'),
        ),
      ],
    ),
  );
}
