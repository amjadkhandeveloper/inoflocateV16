import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/widgets/cards/custom_card.dart';
import 'package:infolocate/widgets/custom_toast.dart';
import 'package:sizer/sizer.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_styles.dart';
import '../custom_webview.dart';

class LiveVehicleListWidget extends StatelessWidget {
  final String vehicleNo;
  final String location;
  final String tracktime;
  final String? liveUrl;
  final bool enableVideo;
  const LiveVehicleListWidget({
    super.key,
    required this.vehicleNo,
    required this.location,
    required this.tracktime,
    this.liveUrl,
    this.enableVideo = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).cardColor
            : AppColors.grey,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.black26
                : Colors.grey.withOpacity(0.2),
            spreadRadius: 3,
            blurRadius: 8,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor
                : Colors.grey.shade300,
            width: 1),
        // color: Colors.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(14),
        ),
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    vehicleNo,
                    style: AppStyles.textStyle4(context: context)
                        .copyWith(fontSize: 20),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: enableVideo
                      ? InkWell(
                          onTap: enableVideo == false
                              ? () => customToast(
                                  message:
                                      LocaliazationKey.video_unavailable.tr())
                              : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoPlayerScreen(
                                        title: vehicleNo,
                                        url: liveUrl,
                                        // orientationMode: Orientation.landscape,
                                      ),
                                    ),
                                  ),
                          child: SizedBox(
                            // width: width ?? 32.w,
                            child: CustomContainer(
                              applyShawdow: true,
                              buttonRadius: 14,
                              // height: 5.h,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.play_circle,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      LocaliazationKey.play_video.tr(),
                                      style: AppStyles.textStyle5(
                                          context: context, isBold: true),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                      : const Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 4),
                          child: Text(""),
                        ),
                ),
                const SizedBox(
                  width: 14,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    location,
                    style: AppStyles.textStyle4(context: context)
                        .copyWith(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Spacer(),
                const Icon(
                  Icons.watch_later_outlined,
                  size: 15,
                ),
                SizedBox(
                  width: 2.w,
                ),
                Flexible(
                  child: Text(
                    tracktime,
                    style: AppStyles.textStyle5(
                      context: context,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
