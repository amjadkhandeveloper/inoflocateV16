import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:sizer/sizer.dart';
import '../../../utils/app_colors.dart';
import '../../../widgets/cards/custom_card.dart';

class TripDashboardLoading extends StatelessWidget {
  const TripDashboardLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Column(
        children: [
          for (int i = 0; i < 3; i++)
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              // baseColor: Colors.grey[300]!,
              // highlightColor: Colors.grey[100]!,
              highlightColor: Colors.grey.shade200,
              child: Column(
                children: [
                  if (i != 0)
                    SizedBox(
                      height: 5.h,
                    ),
                  Stack(
                    children: [
                      Container(
                        // width: double.infinity,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Theme.of(context).cardColor
                                    : AppColors.grey,
                                width: 0),
                            // color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20))),
                        child: Column(
                          children: [
                            CustomContainer(
                              applyShawdow: false,
                              height: 12.h,
                              width: double.infinity,
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20)),
                            ),
                            Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    // color: Theme.of(context).cardColor,
                                    border: Border.all(
                                        color: Theme.of(context).cardColor,
                                        width: 1),
                                    // color: Colors.white,
                                    borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(20),
                                        bottomRight: Radius.circular(20))),
                                // height: 8.h,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Column(
                                            children: [myContainer()],
                                          ),
                                          const Spacer(),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: myContainer(),
                                              ),
                                              myContainer(width: 25.w),
                                            ],
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 15.0),
                                        child: Row(
                                          children: [
                                            ...List.generate(
                                                6,
                                                (index) => Expanded(
                                                        child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 2.0),
                                                      child: myContainer(
                                                          width: null,
                                                          color:
                                                              AppColors.grey),
                                                    )))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                      Positioned(
                          right: 4.w,
                          top: 1.w,
                          child: const Icon(
                            Icons.more_horiz,
                            color: Colors.grey,
                          ))
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Container myContainer({double? width, Color? color}) {
    return Container(
      height: 1.8.h,
      width: width ?? 30.w,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color ?? Colors.grey.shade300),
    );
  }
}
