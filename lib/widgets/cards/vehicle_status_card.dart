import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:infolocate/utils/app_ui.dart';

import 'custom_card.dart';

class VehicleStatusCard extends StatelessWidget {
  const VehicleStatusCard(
      {super.key,
      this.title,
      this.count,
      this.icon,
      this.percentage,
      required this.iconColor,
      this.cardType,
      this.isSlelected = false,
      this.enableBorder = false});
  final String? title;
  final String? count;
  final String? icon;
  final String? percentage;
  final Color iconColor;
  final int? cardType;
  final bool isSlelected;
  final bool enableBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(
            color: isSlelected
                ? AppUi.accent
                : enableBorder
                    ? AppUi.line(context)
                    : Colors.transparent,
            width: isSlelected ? 1.6 : 1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomContainer(
              applyShawdow: true,
              // width: double.infinity,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...getWidgetList(cardType: cardType, context: context)
                    // titleWidget(context),
                    // const SizedBox(
                    //   height: 8,
                    // ),
                    // // const Spacer(),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     valueWidget(context),
                    //     // const Spacer(),
                    //     iconWidgte(),
                    //   ],
                    // ),
                  ],
                ),
              )),
          isSlelected
              ? Positioned(
                  top: -10,
                  right: -10,
                  child: Container(
                    // height: 32,
                    // width: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppUi.cardColor(context),
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
    );
  }

  Container iconWidgte() {
    return Container(
      height: 28,
      width: 28,
      padding: const EdgeInsets.only(right: 1),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: SvgPicture.asset(
        icon ?? 'assets/icons/Group 134.svg',
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      ),
    );
  }

  Text valueWidget(BuildContext context) {
    return Text(
      count ?? '',
      style: AppUi.titleStyle(context).copyWith(fontSize: 22),
    );
  }

  Text titleWidget(BuildContext context) {
    return Text(
      title ?? '',
      style: AppUi.body(context).copyWith(fontSize: 14),
    );
  }

  List<Widget> getWidgetList(
      {required int? cardType, required BuildContext context}) {
    List<Widget> child = <Widget>[];
    cardType ??= 1;
    switch (cardType) {
      case 1:
        child = [
          titleWidget(context),
          const SizedBox(
            height: 8,
          ),
          // const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              valueWidget(context),
              // const Spacer(),
              iconWidgte(),
            ],
          ),
        ];
        break;
      case 2:
        child = [
          // const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              valueWidget(context),
              // const Spacer(),
              iconWidgte(),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          titleWidget(context),
        ];
        break;
      case 3:
        child = [
          titleWidget(context),
          const SizedBox(
            height: 8,
          ),
          // const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              valueWidget(context),
              // const Spacer(),
              iconWidgte(),
            ].reversed.toList(),
          ),
        ];

        break;
      case 4:
        child = [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              valueWidget(context),
              // const Spacer(),
              iconWidgte(),
            ].reversed.toList(),
          ),
          const SizedBox(
            height: 8,
          ),
          titleWidget(context),
        ];
        break;
      case 5:
        child = [
          valueWidget(context),

          const SizedBox(
            height: 8,
          ),
          // const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              titleWidget(context),
              // const Spacer(),
              iconWidgte(),
            ],
          ),
        ];
        break;
      case 6:
        child = [
          valueWidget(context),

          const SizedBox(
            height: 2,
          ),
          // const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: titleWidget(context)),
              // const Spacer(),
              iconWidgte(),
            ].reversed.toList(),
          ),
        ];
        break;
      default:
        child = [];
        break;
    }
    return child;
  }
}
