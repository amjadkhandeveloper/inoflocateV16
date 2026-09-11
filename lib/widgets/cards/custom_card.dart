import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_ui.dart';

class CustomContainer extends StatelessWidget {
  const CustomContainer({
    super.key,
    this.child,
    this.height,
    this.width,
    this.onTap,
    this.buttonRadius,
    this.borderRadius,
    required this.applyShawdow,
  });
  final Widget? child;
  final double? height;
  final double? width;
  final double? buttonRadius;
  final BorderRadiusGeometry? borderRadius;
  final bool applyShawdow;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: applyShawdow
            ? AppUi.cardColor(context)
            : AppUi.accent.withValues(alpha: AppUi.isDark(context) ? 0.16 : 0.08),
        borderRadius: borderRadius ??
            BorderRadius.all(Radius.circular(buttonRadius ?? AppUi.radius)),
        border: Border.all(color: AppUi.line(context)),
        boxShadow: applyShawdow
            ? [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: AppUi.isDark(context) ? 0.2 : 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}
