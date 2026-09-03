import 'package:flutter/material.dart';

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
      decoration: applyShawdow
          ? BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).scaffoldBackgroundColor
                  : Colors.white,
              borderRadius: borderRadius ??
                  BorderRadius.all(Radius.circular(buttonRadius ?? 20)),
            )
          : BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(context).cardColor
                  : Theme.of(context).colorScheme.primary.withOpacity(0.04),
              //  AppColors.grey,
              borderRadius: borderRadius ??
                  BorderRadius.all(Radius.circular(buttonRadius ?? 20)),
            ),
      child: child,
    );
  }
}
