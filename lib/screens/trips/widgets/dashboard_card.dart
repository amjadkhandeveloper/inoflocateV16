import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/buttons/custom_icon_button.dart';
import '../../../widgets/cards/custom_card.dart';

class TripDashBoardCard extends StatelessWidget {
  const TripDashBoardCard({super.key});

  @override
  Widget build(BuildContext context) {
    Map<int, Icon> iconListMap = const {
      0: Icon(CupertinoIcons.location),
      1: Icon(CupertinoIcons.calendar),
      2: Icon(CupertinoIcons.car_detailed),
      3: Icon(CupertinoIcons.airplane),
      4: Icon(CupertinoIcons.video_camera_solid),
      5: Icon(CupertinoIcons.app_badge_fill),
      6: Icon(CupertinoIcons.map),
      7: Icon(CupertinoIcons.exclamationmark_octagon_fill),
    };
    return Padding(
      padding: EdgeInsets.only(top: 3.h),
      child: Stack(
        children: [
          Container(
              // width: double.infinity,
              decoration: BoxDecoration(
                  border:
                      Border.all(color: Theme.of(context).cardColor, width: 2),
                  // color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(20))),
              child: Column(
                children: [
                  CustomContainer(
                    width: double.infinity,
                    height: 15.h,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20)),
                    applyShawdow: false,
                    child: Image.asset("assets/images/map_route.png"),
                  ),
                  // Lottie.network(
                  //     "https://assets6.lottiefiles.com/packages/lf20_ug4q6zc4.json",
                  //     height: 100),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'KA-01-A-1234',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20),
                                  ),
                                  SizedBox(
                                    height: 1.h,
                                  ),
                                  Text(
                                    'Brigade Buena Vista, cheemasandra, Benglaluru - 560002, Karnataka INDIA',
                                    style:
                                        Theme.of(context).textTheme.titleSmall,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'USER: SEQUEL_BLR',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                  SizedBox(
                                    height: 2.h,
                                  ),
                                  const Text(
                                    '08/11/2022 / 01:10:23',
                                    style: TextStyle(fontSize: 12),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ...List.generate(
                            6,
                            (index) => CustomIconBtn(
                                  icon: iconListMap.containsKey(index)
                                      ? Icon(iconListMap[index]!.icon)
                                      : const Icon(Icons.apple),
                                  title: '45 km',
                                  direction: Axis.vertical,
                                ))
                      ],
                    ),
                  ),
                ],
              )),
          Positioned(
              right: 5.w,
              top: 2.w,
              child: Icon(
                // i == 0
                //     ?
                Icons.more_horiz,
                // : Icons.bookmark_border_outlined,
                color: Colors.grey,
                size: 25.sp,
              ))
        ],
      ),
    );
  }
}
