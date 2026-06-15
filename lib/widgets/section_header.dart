import 'package:flutter/material.dart';

import '../theme/dimens.dart';
import '../theme/typography.dart';

/// A small all-caps-ish section label with an optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.md),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppType.title)),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );
  }
}
