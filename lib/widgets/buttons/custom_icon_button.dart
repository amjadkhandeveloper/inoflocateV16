import 'package:flutter/material.dart';

import '../../utils/app_styles.dart';

class CustomIconBtn extends StatelessWidget {
  const CustomIconBtn(
      {super.key,
      this.icon,
      this.title,
      this.direction = Axis.horizontal,
      this.onTap,
      this.width,
      this.color});
  // final IconData? icon;
  final double? width;
  final String? title;
  final Widget? icon;
  final Color? color;
  final Function()? onTap;

  final Axis direction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          // width: width ?? 32.w,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: color ?? Theme.of(context).cardColor),
            // elevation: 0,
            // applyShawdow: false,
            // buttonRadius: 14,
            // borderRadius: BorderRadius.circular(8),
            // height: 5.h,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
              child: Row(
                children: [
                  icon ?? Container(),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    title ?? '',
                    style: color != null
                        ? AppStyles.textStyle4(
                            context: context,
                            size: 16,
                            color: Colors.grey,
                          )
                        : AppStyles.textStyle4(context: context, size: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
