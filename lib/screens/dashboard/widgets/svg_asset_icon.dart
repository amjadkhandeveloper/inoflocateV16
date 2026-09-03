import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomSvgIcon extends StatelessWidget {
  const CustomSvgIcon({
    super.key,
    this.icon,
    this.color,
  });
  final String? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon!,
      color: color ?? Theme.of(context).iconTheme.color,
      // colorFilter: ColorFilter.mode(
      //     Theme.of(context).colorScheme.primary, BlendMode.color),
      cacheColorFilter: true,
      fit: BoxFit.scaleDown,
      height: 22,
      width: 22,
    );
  }
}
