import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sizer/sizer.dart';

import '../../utils/app_helper.dart';
import '../../utils/app_styles.dart';
import '../../utils/app_ui.dart';

class AlertStatusCard extends StatelessWidget {
  const AlertStatusCard(
      {super.key,
      this.alertCount,
      this.alertType,
      this.cardType,
      this.isSelected = false});
  final int? alertCount;
  final String? alertType;
  final int? cardType;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // color: Colors.amber,
      width: 20.w,
      height: 15.h,
      child: Column(
        children: [
          InkWell(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 10.w,
                  // height: 9.h,
                  height: 5.h,
                  decoration: getShape(cardType: cardType, context: context),
                  child: SvgPicture.asset(
                    AppHelper.returnIcons(
                      title: alertType.toString() == "yaccel end" ||
                              alertType.toString() == "xaccel end"
                          ? AppHelper.returnAlertStatus(
                              alertStatus: alertType.toString(),
                            )
                          : alertType.toString(),
                    ),
                    fit: BoxFit.cover,
                    // colorFilter: ColorFilter.mode(
                    //     Theme.of(context).colorScheme.primary, BlendMode.color),
                    height: 20,
                  ),
                  //  Text(
                  //   alertCount.toString(),
                  //   style: AppStyles.textStyle3(
                  //           context: context, color: Colors.white)
                  //       .copyWith(fontSize: 34),
                  // ),
                ),
                isSelected
                    ? Positioned(
                        top: -10,
                        right: -10,
                        child: Container(
                          // height: 32,
                          // width: 32,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            // border: Border.all(
                            //   width: 4,
                            //   color: Theme.of(context).scaffoldBackgroundColor,
                            // ),
                            color: Colors.white,
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.lightGreen,
                            size: 24,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                alertType.toString() == "yaccel end" ||
                        alertType.toString() == "xaccel end"
                    ? AppHelper.returnJapaneseText(
                        title: AppHelper.returnAlertStatus(
                        alertStatus: alertType.toString(),
                      ))
                    : AppHelper.returnJapaneseText(title: alertType.toString()),
                // textAlign: TextAlign.center,
                style:
                    AppStyles.textStyle4(context: context, size: 12).copyWith(
                  color: AppUi.muted(context),
                  overflow: TextOverflow.ellipsis,
                ),
                // overflow: TextOverflow.fade,
              ),
            ),
          ),
          Expanded(
              child: Text(alertCount.toString(),
                  style: AppStyles.textStyle4(
                    context: context,
                    size: 25,
                    color: AppUi.ink(context),
                  ))),
          // const Spacer()
        ],
      ),
    );
  }

  BoxDecoration getShape(
      {required int? cardType, required BuildContext context}) {
    BoxDecoration shape;

    cardType ??= 1;
    switch (cardType) {
      case 1:
        shape = BoxDecoration(
            border: Border.all(
                color: isSelected ? Colors.lightGreen : Colors.transparent,
                width: 3),
            color: AppUi.accent.withValues(alpha: 0.12),
            borderRadius: const BorderRadius.all(Radius.circular(12)));
        break;
      case 2:
        shape = BoxDecoration(
          border: Border.all(
              color: isSelected ? Colors.lightGreen : Colors.transparent,
              width: 3),
          color: AppUi.accent.withValues(alpha: 0.12),
        );
        break;

      default:
        shape = BoxDecoration(
          border: Border.all(
              color: isSelected ? Colors.lightGreen : Colors.transparent,
              width: 3),
          shape: BoxShape.circle,
          color: AppUi.accent.withValues(alpha: 0.12),
        );
        break;
    }
    return shape;
  }
}
