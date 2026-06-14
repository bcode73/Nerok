import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/dimens.dart';
import '../theme/typography.dart';

/// A pill button with a subtle press-scale. [filled] uses the ember accent;
/// otherwise it is a quiet outlined button.
class PrimaryButton extends StatefulWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = true,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;
  final IconData? icon;
  final bool loading;
  final bool expand;

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final scale = (_pressed && !reduceMotion) ? AppMotion.pressScale : 1.0;
    final fg = widget.filled ? AppColors.page : AppColors.textHi;

    final child = AnimatedScale(
      scale: scale,
      duration: AppMotion.fast,
      curve: Curves.easeOut,
      child: Container(
        width: widget.expand ? double.infinity : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.xl,
          vertical: AppSpace.lg,
        ),
        decoration: BoxDecoration(
          color: widget.filled
              ? (_enabled ? AppColors.accent : AppColors.surface2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: widget.filled
              ? null
              : Border.all(color: AppColors.line2),
        ),
        child: Row(
          mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.loading)
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: fg),
              )
            else ...[
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 18, color: fg),
                const SizedBox(width: AppSpace.sm),
              ],
              Text(
                widget.label,
                style: AppType.button.copyWith(color: fg),
              ),
            ],
          ],
        ),
      ),
    );

    return GestureDetector(
      onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
      onTap: _enabled ? widget.onPressed : null,
      child: Opacity(opacity: _enabled ? 1 : 0.6, child: child),
    );
  }
}
