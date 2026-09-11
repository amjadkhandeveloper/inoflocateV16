import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infolocate/screens/pin_vehicles/controller/pin_vehicle_provider.dart';
import 'package:infolocate/screens/pin_vehicles/model/pin_vehicle_request_model.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:infolocate/widgets/custom_toast.dart';
import 'package:infolocate/widgets/custom_webview.dart';
import 'package:infolocate/widgets/grid_webview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../common_models/button_list_model.dart';
import '../../screens/dashboard/controller/dashboard_provider.dart';
import '../../screens/dashboard/controller/sequel_dashboard_provider.dart';
import '../../screens/dashboard/model/dashboard_request_model.dart';
import '../../screens/vehicle_statuswise_list/controller/vehicle_status_provider.dart';
import '../../utils/app_globals.dart';
import '../../utils/app_localization_key.dart';
import '../../utils/app_ui.dart';
import '../buttons/custom_icon_button.dart';
import '../google_map/google_map_screen.dart';
import '../google_map/map_model.dart';

class PinVehicleCard extends StatefulWidget {
  final String? vehicleNo;
  final String? location;
  final String? trackTime;
  final String? status;
  final String? liveUrl;
  final List<String?>? liveUrlList;
  final String? urlTitle;
  final bool isPinned;
  final bool showPinnedIcon;
  final int vehicleId;
  final bool enableUrl;
  final String? alertType;
  final GoogleMapModel? mapData;

  final String? ignition;
  final String? speed;
  final double? odometer;
  final int? idelDuration;
  final int? stopDuration;
  final String? engineOffdelay;
  final int? statusId;
  const PinVehicleCard(
      {super.key,
      required this.vehicleNo,
      required this.location,
      required this.trackTime,
      required this.status,
      required this.vehicleId,
      required this.showPinnedIcon,
      this.liveUrl,
      this.urlTitle,
      this.ignition,
      this.speed,
      this.odometer,
      this.idelDuration,
      this.stopDuration,
      this.engineOffdelay,
      this.isPinned = false,
      this.liveUrlList = const [],
      this.enableUrl = false,
      this.alertType,
      this.mapData,
      this.statusId});

  @override
  State<PinVehicleCard> createState() => _PinVehicleCardState();
}

class _PinVehicleCardState extends State<PinVehicleCard> {
  // refreshList({bool loadMore = false}) async {
  //   final vehicleStatusState =
  //       Provider.of<VehicleStatusProvider>(context, listen: false);
  //   try {
  //     await vehicleStatusState.getVehicleList(
  //         vehicleStatusWiseListRequestModel: VehicleStatusWiseListRequestModel(
  //           pSize: pageSize,
  //           pNo: defaultPageN0,
  //           userId: Global.savedUserAuthData!.userid!.toInt(),
  //           statusId: widget.statusId!.toInt(),
  //           sSearch: '',
  //         ),
  //         loadMore: loadMore);
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final pinVehicleState = Provider.of<PinVehicleProvider>(context);
    final vehicleStatusState = Provider.of<VehicleStatusProvider>(context);
    final dashBoardState =
        Provider.of<DashboardProvider>(context, listen: false);
    final sequelDashState =
        Provider.of<SequelDashboardProvider>(context, listen: false);
    // log(widget.status.toString());

    print('Widget Live: ${widget.liveUrlList}');

    final buttonList = [
      if (widget.status != null)
        ButtonListModel(
          icon: SvgPicture.asset(
            AppHelper.returnIcons(title: widget.status.toString()),
            // "assets/icons/new_icons/orange.svg",
            height: 2.4.h,
            // colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            color: AppHelper.returnIconColor(title: widget.status),
          ),
          title: AppHelper.returnJapaneseText(title: widget.status),
        ),
      ButtonListModel(
          icon: SvgPicture.asset(
            "assets/icons/new_icons/live-video.svg",
            // "assets/icons/new_icons/orange.svg",
            height: 2.h,
            // colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            color: widget.enableUrl
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
          ),
          title: widget.alertType ?? LocaliazationKey.live_video.tr(),
          value: widget.liveUrl,
          onTap: widget.enableUrl
              ? () {
                  if (widget.liveUrlList != null) {
                    print("Live Url: ${widget.liveUrlList}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GridVideoPlayerScreen(
                          url: widget.liveUrlList,
                          title: widget.vehicleNo,
                        ),
                      ),
                    );
                    return;
                  } else if (widget.liveUrl != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(
                          url: widget.liveUrl,
                          title: widget.vehicleNo,
                        ),
                      ),
                    );
                  }
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
          value: widget.location ?? '',
          onTap: widget.mapData == null
              ? null
              : () async {
                  if (await Permission.location.request().isGranted) {
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GoogleMapScreen(
                            marker: widget.mapData!,
                            isAlertStatus:
                                widget.alertType != null ? true : false,
                          ),
                        ));
                    // Either the permission was already granted before or the user just granted it.
                  }
                }),
      if (widget.speed != null)
        ButtonListModel(
          icon: SvgPicture.asset(
            AppHelper.getSpeedometerIcon(int.parse(widget.speed.toString())),
            // "assets/icons/new_icons/orange.svg",
            height: 2.h,

            color: AppHelper.getSpeedometerColor(
                int.parse(widget.speed.toString())),
          ),
          title: "${widget.speed} mph",
        ),
      if (widget.ignition != null)
        ButtonListModel(
          icon: SvgPicture.asset(
            'assets/icons/ignition.svg',
            height: 2.h,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: widget.ignition == "0" ? 'OFF' : 'ON',
        ),
      if (widget.odometer != null)
        ButtonListModel(
            icon: SvgPicture.asset(
              'assets/icons/odometer.svg',
              height: 2.h,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: "${widget.odometer} ${LocaliazationKey.miles.tr()}"),
      if (widget.stopDuration != null)
        ButtonListModel(
            icon: SvgPicture.asset(
              'assets/icons/enginedelay.svg',
              height: 2.h,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: widget.engineOffdelay.toString()),
      if (widget.stopDuration != null)
        ButtonListModel(
            icon: Icon(
              Icons.power_off_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: widget.engineOffdelay.toString()),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Stack(
        children: [
          Container(
            decoration: AppUi.cardDecoration(context),
            child: Column(
              children: [
                Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppUi.cardColor(context),
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppUi.radius),
                          topRight: Radius.circular(AppUi.radius)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      widget.vehicleNo ?? '',
                                      style: AppUi.body(context).copyWith(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    (widget.status!.toLowerCase() == inactive ||
                                            (widget.status!.toLowerCase() ==
                                                    stopped &&
                                                !widget.enableUrl))
                                        ? Text(
                                            LocaliazationKey.offline.tr(),
                                            style: AppUi.mutedStyle(context),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              // const Spacer(),
                              Expanded(
                                flex: widget.showPinnedIcon ? 6 : 4,
                                child: Row(
                                  // mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.schedule_rounded,
                                      size: 15,
                                      color: Color(0xFF64748B),
                                    ),
                                    SizedBox(
                                      width: 2.w,
                                    ),
                                    Flexible(
                                      child: Text(
                                        widget.trackTime ?? '',
                                        style: AppUi.mutedStyle(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          Text(
                            widget.location ?? '',
                            style: AppUi.body(context),
                          )
                        ],
                      ),
                    )),
                Container(
                  height: 7.h,
                  decoration: BoxDecoration(
                      color: AppUi.pageBg(context),
                      border: Border(
                          top: BorderSide(color: AppUi.line(context))),
                      borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(AppUi.radius),
                          bottomRight: Radius.circular(AppUi.radius))),
                  // height: 8.h,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ...List.generate(
                            buttonList.length,
                            (index) => SizedBox(
                                  // height: 40,
                                  child: CustomIconBtn(
                                    onTap: buttonList[index].onTap,
                                    icon: buttonList[index].icon,
                                    title: buttonList[index].title,
                                    color: !widget.enableUrl &&
                                            buttonList[index].title ==
                                                "Live Video"
                                        ? Colors.grey.shade200
                                        : null,
                                  ),
                                ))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          widget.showPinnedIcon
              ? Positioned(
                  right: 3.w,
                  top: 3.w,
                  child: GestureDetector(
                      onTap: () async {
                        if (pinVehicleState.lengthOfPinVehicles! >= 6 &&
                            !widget.isPinned) {
                          customToast(
                              message: LocaliazationKey
                                  .max_6_vehicles_can_be_pinned
                                  .tr());
                          return;
                        }
                        vehicleStatusState.updatePinValue(
                            vehicleId: widget.vehicleId,
                            value: widget.isPinned ? 0 : 1);
                        if (Global.isSequelClient) {
                          sequelDashState.updatePinValue(
                              vehicleId: widget.vehicleId,
                              value: widget.isPinned ? false : true);
                        } else {
                          dashBoardState.updatePinValue(
                              vehicleId: widget.vehicleId,
                              value: widget.isPinned ? false : true);
                        }

                        await pinVehicleState.pinUnpinVehicle(
                          pinVehicleRequestModel: PinVehicleRequestModel(
                              clientId:
                                  Global.savedClientAuthData!.clientId!.toInt(),
                              userId: Global.savedUserAuthData!.userid!.toInt(),
                              vehicleid: widget.vehicleId.toInt(),
                              insertMode: widget.isPinned ? 1 : 0),
                        );
                        if (Global.isSequelClient) {
                          await sequelDashState.loadDashboard(
                              showLoader: false);
                          pinVehicleState.lengthOfPinVehicles =
                              sequelDashState.data?.Pinvehicle?.length;
                        } else {
                          await dashBoardState.getDashboardData(
                              dashboardRequestModel: DashboardRequestModel(
                                userId: Global.savedUserAuthData!.userid!,
                                pSize: pageSize,
                                pNo: defaultPageN0,
                              ),
                              backgroundFetch: true);
                          pinVehicleState.lengthOfPinVehicles = dashBoardState
                              .dashboardResponseModelData!.Pinvehicle!.length;
                        }
                        log("Length of PinVehicle ${pinVehicleState.lengthOfPinVehicles}");
                        if (pinVehicleState.pinVehicleResponseModel!.pinvehicle!
                                    .first!.Remark ==
                                "Vehicle is already added Sucessfully" ||
                            pinVehicleState.pinVehicleResponseModel!.pinvehicle!
                                    .first!.Remark ==
                                "Vehicle added Sucessfully") {
                          customToast(
                            message: LocaliazationKey
                                .vehicle_pinned_successfully
                                .tr(),
                          );
                        } else if (pinVehicleState.pinVehicleResponseModel!
                                .pinvehicle!.first!.Remark ==
                            "Vehicle deleted Sucessfully") {
                          customToast(
                            message: LocaliazationKey
                                .vehicle_unppined_successfully
                                .tr(),
                          );
                        } else {
                          customToast(
                            message: pinVehicleState.pinVehicleResponseModel!
                                .pinvehicle!.first!.Remark
                                .toString(),
                          );
                        }
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(seconds: 500),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                        child: widget.isPinned
                            ? SvgPicture.asset(
                                'assets/icons/Group 264.svg',
                                colorFilter: ColorFilter.mode(
                                    Theme.of(context).colorScheme.primary,
                                    BlendMode.srcIn),
                                height: 22,
                              )
                            : SvgPicture.asset(
                                'assets/icons/Group 264.svg',
                                color: Colors.grey,
                              ),
                      )
                      // AnimatedCrossFade(
                      //     firstChild: SvgPicture.asset(
                      //       'assets/icons/Group 264.svg',
                      //       colorFilter: ColorFilter.mode(
                      //           Theme.of(context).colorScheme.primary,
                      //           BlendMode.srcIn),
                      //       // height: 20,
                      //     ),
                      //     secondChild: SvgPicture.asset(
                      //       'assets/icons/Group 264.svg',
                      //       color: Colors.grey,
                      //     ),
                      //     crossFadeState: widget.isPinned
                      //         ? CrossFadeState.showFirst
                      //         : CrossFadeState.showSecond,
                      //     duration: const Duration(microseconds: 500)),
                      ),
                )
              : Container()
        ],
      ),
    );
  }
}
