// ignore_for_file: prefer_null_aware_operators

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_styles.dart';
import 'package:infolocate/widgets/custom_toast.dart';
import 'package:infolocate/widgets/custom_webview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../common_models/button_list_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/app_globals.dart';
import '../../../utils/app_helper.dart';
import '../../../widgets/buttons/custom_icon_button.dart';
import '../../../widgets/google_map/google_map_screen.dart';
import '../../../widgets/google_map/map_model.dart';
import '../model/dynamic_status_response_model.dart';

class DynamicStatusCard extends StatelessWidget {
  const DynamicStatusCard({
    super.key,
    this.dynamicStatusDetails,
  });
  final DynamicStatusModelDataVehicledetails? dynamicStatusDetails;

  @override
  Widget build(BuildContext context) {
    final latLng = dynamicStatusDetails!.Mapit!.split(',');

    final lat = double.tryParse(latLng[0]);
    final long = double.tryParse(latLng[1]);

    final mapData = GoogleMapModel(
        latLng: LatLng(lat!, long!),
        statusName: dynamicStatusDetails!.Status,
        vehicleId: dynamicStatusDetails!.VehicleId,
        vehicleNo: dynamicStatusDetails!.VehicleNo,
        engineOffdelay: null,
        idleduration: dynamicStatusDetails!.Idleduration == null
            ? null
            : dynamicStatusDetails!.Idleduration.toString(),
        ignition: dynamicStatusDetails!.ignition == null
            ? null
            : dynamicStatusDetails!.ignition.toString(),
        odometer: dynamicStatusDetails!.odometer == null
            ? null
            : dynamicStatusDetails!.odometer.toString(),
        speed: dynamicStatusDetails!.speed == null
            ? null
            : dynamicStatusDetails!.speed.toString(),
        stopduration: null,
        vehicleLocation: dynamicStatusDetails!.Location == null
            ? null
            : dynamicStatusDetails!.Location.toString(),
        vehicleTrackTime: dynamicStatusDetails!.TrackingTime == null
            ? null
            : dynamicStatusDetails!.TrackingTime.toString());
    final buttonList = [
      ButtonListModel(
        icon: SvgPicture.asset(
            AppHelper.returnIcons(
                title: dynamicStatusDetails!.Status.toString()),
            // "assets/icons/new_icons/orange.svg",
            height: 2.h,
            // colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            color:
                AppHelper.returnIconColor(title: dynamicStatusDetails!.Status)),
        title: dynamicStatusDetails!.Status,
      ),
      if (!Global.isSequelClient &&
          (dynamicStatusDetails!.LiveUrl ?? '').trim().isNotEmpty)
        ButtonListModel(
            icon: SvgPicture.asset(
              "assets/icons/new_icons/live-video.svg",
              height: 2.h,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: LocaliazationKey.live_video.tr(),
            value: dynamicStatusDetails!.LiveUrl,
            onTap: dynamicStatusDetails!.Status!.toLowerCase() == idle ||
                    dynamicStatusDetails!.Status!.toLowerCase() == moving
                ? () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoPlayerScreen(
                            url: dynamicStatusDetails!.LiveUrl,
                            title: dynamicStatusDetails!.VehicleNo,
                          ),
                        ));
                  }
                : () => customToast(
                    message: LocaliazationKey.video_unavailable.tr())),
      ButtonListModel(
          icon: SvgPicture.asset(
            "assets/icons/new_icons/mapit.svg",
            // "assets/icons/new_icons/orange.svg",
            height: 2.h,
            // colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            color: Theme.of(context).colorScheme.primary,
          ),
          title: LocaliazationKey.map_it.tr(),
          value: dynamicStatusDetails!.Location,
          onTap: () async {
            if (await Permission.location.request().isGranted) {
              // ignore: use_build_context_synchronously
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GoogleMapScreen(
                      marker: mapData,
                    ),
                  ));
              // Either the permission was already granted before or the user just granted it.
            }
          }),
      ButtonListModel(
          icon: SvgPicture.asset(
            AppHelper.getSpeedometerIcon(
                int.parse(dynamicStatusDetails!.speed.toString())),
            // "assets/icons/new_icons/orange.svg",
            height: 2.h,
            // colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            color: AppHelper.getSpeedometerColor(
                int.parse(dynamicStatusDetails!.speed.toString())),
          ),
          title: "${dynamicStatusDetails!.speed} ${LocaliazationKey.km_h.tr()}"),
      ButtonListModel(
        icon: SvgPicture.asset(
          'assets/icons/ignition.svg',
          height: 2.h,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: dynamicStatusDetails!.ignition!.toUpperCase(),
      ),
      ButtonListModel(
          icon: SvgPicture.asset(
            'assets/icons/odometer.svg',
            height: 2.h,
            color: Theme.of(context).colorScheme.primary,
          ),
          title:
              "${dynamicStatusDetails!.odometer} ${LocaliazationKey.km.tr()}"),
      if (dynamicStatusDetails!.Status == "Idle")
        ButtonListModel(
          icon: SvgPicture.asset(
            'assets/icons/idle-duration.svg',
            height: 2.h,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: "${dynamicStatusDetails!.Idleduration} min",
        ),
    ];

    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 1),
          borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dynamicStatusDetails!.VehicleNo ?? '',
                              style: AppStyles.textStyle4(
                                  context: context, isBold: true, size: 18),
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Text(
                              dynamicStatusDetails!.Location ?? '',
                              style: AppStyles.textStyle5(context: context),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  // fit: FlexFit.tight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(
                            //   'USER: SEQUEL_BLR',
                            //   style: AppStyles.textStyle5(
                            //       context: context, isBold: true),
                            // ),
                            // SizedBox(
                            //   height: 2.h,
                            // ),
                            Text(
                              dynamicStatusDetails!.TrackingTime ?? '',
                              style: AppStyles.textStyle5(context: context),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(
              width: SizerUtil.width,
              height: 9.h,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ...List.generate(
                        buttonList.length,
                        (index) => SizedBox(
                              // height: 45,
                              child: CustomIconBtn(
                                  onTap: buttonList[index].onTap,
                                  icon: buttonList[index].icon,
                                  title: buttonList[index].title,
                                  direction: Axis.horizontal),
                            ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
