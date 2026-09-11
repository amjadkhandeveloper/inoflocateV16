import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:sizer/sizer.dart';

import '../../common_models/button_list_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_helper.dart';
import '../../utils/app_localization_key.dart';
import '../../utils/app_styles.dart';
import '../../utils/app_ui.dart';
import '../buttons/custom_icon_button.dart';
import 'map_model.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen(
      {super.key,
      required this.marker,
      this.hideBackButton = false,
      this.isAlertStatus = false});
  final GoogleMapModel? marker;
  final bool hideBackButton;
  final bool isAlertStatus;

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late final GoogleMapController _cameraController;
  LatLng currentLocation = kGooglePlex;
  Set<Marker> markers = <Marker>{};
  // @override
  // void didChangeDependencies() {
  //   setUpLocation(initaliseCamera: false);
  //   // await _cameraController
  //   //     .showMarkerInfoWindow(MarkerId(widget.marker!.vehicleId.toString()));
  //   // _cameraController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
  //   //     target: currentLocation,
  //   //     // LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
  //   //     zoom: 18)));

  //   super.didChangeDependencies();
  // }

  @override
  void initState() {
    // SystemChrome.setPreferredOrientations(
    //   [DeviceOrientation.landscapeLeft],
    // );
    setUpLocation(initaliseCamera: true);
    super.initState();
  }

  onTapMarker({required int? vehicleId}) {
    FocusScope.of(context).unfocus();
    // final vehicleStatusProvider =
    //     Provider.of<VehicleStatusProvider>(context, listen: false);

    final vehicle = widget.marker;
    if (vehicle == null) return;

    final buttonList = [
      // if (vehicle.Status != null)
      //   ButtonListModel(
      //     icon: SvgPicture.asset(
      //         AppHelper.returnIcons(title: vehicle.Status.toString()),
      //         // "assets/icons/new_icons/orange.svg",
      //         height: 3.h,
      //         // colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
      //         color:
      //             AppHelper.returnIconColor(title: vehicle.Status.toString())),
      //     title: vehicle.Status.toString(),
      //   ),
      if (vehicle.speed != null)
        ButtonListModel(
            icon: SvgPicture.asset(
              AppHelper.getSpeedometerIcon(int.parse(vehicle.speed.toString())),
              // "assets/icons/new_icons/orange.svg",
              height: 3.h,
              // colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
              color: AppHelper.getSpeedometerColor(
                  int.parse(vehicle.speed.toString())),
            ),
            title: "${vehicle.speed} mph"),
      if (vehicle.ignition != null)
        ButtonListModel(
          icon: SvgPicture.asset(
            'assets/icons/ignition.svg',
            height: 3.h,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: vehicle.ignition.toString() == "0" ? 'OFF' : 'ON',
        ),
      if (vehicle.odometer != null)
        ButtonListModel(
            icon: SvgPicture.asset(
              'assets/icons/odometer.svg',
              height: 3.h,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: "${vehicle.odometer} ${LocaliazationKey.miles.tr()}"),
      if (vehicle.engineOffdelay != null)
        ButtonListModel(
            icon: SvgPicture.asset(
              'assets/icons/enginedelay.svg',
              height: 3.h,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: vehicle.engineOffdelay.toString()),
      if (vehicle.idleduration != null)
        ButtonListModel(
            icon: SvgPicture.asset(
              'assets/icons/idle-duration.svg',
              height: 3.h,
              // colorFilter: ColorFilter.mode(
              //     Theme.of(context).colorScheme.primary, BlendMode.colorBurn),
              color: Theme.of(context).colorScheme.primary,
            ),
            title: "${vehicle.idleduration} min"),
      if (vehicle.stopduration != null)
        ButtonListModel(
            icon: Icon(
              Icons.power_off_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: vehicle.stopduration.toString()),
    ];

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(14),
        ),
      ),
      builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Padding(
            //   padding: const EdgeInsets.only(top: 14, right: 14),
            //   child: GestureDetector(
            //     onTap: () {
            //       Navigator.of(context).pop();
            //     },
            //     child: SvgPicture.asset("assets/icons/new_icons/cancel.svg",
            //         // "assets/icons/new_icons/orange.svg",
            //         height: 2.h,
            //         // colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
            //         color: Theme.of(context).iconTheme.color),
            //   ),
            // ),
            Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                    color: Theme.of(context).canvasColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: AppHelper.returnIconColor(
                              title: vehicle.statusName.toString(),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            )),
                        width: double.infinity,
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              widget.isAlertStatus
                                  ? "${LocaliazationKey.alert_status.tr()} : "
                                  : "${LocaliazationKey.vehicle_status.tr()} : ",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18),
                            ),
                            Expanded(
                              child: Text(
                                widget.isAlertStatus
                                    ? AppHelper.returnJapaneseText(
                                        title: AppHelper.returnAlertStatus(
                                          alertStatus:
                                              vehicle.statusName.toString(),
                                        ),
                                      )
                                    : AppHelper.returnJapaneseText(
                                        title: vehicle.statusName.toString(),
                                      ),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                vehicle.vehicleNo.toString(),
                                style: AppStyles.textStyle4(
                                    context: context, isBold: true, size: 18),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            // fit: FlexFit.tight,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                vehicle.vehicleTrackTime.toString(),
                                style: AppStyles.textStyle5(
                                  context: context,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          vehicle.vehicleLocation.toString(),
                          style:
                              AppStyles.textStyle4(context: context, size: 16),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: SizedBox(
                          width: SizerUtil.width,
                          // height: 8.h,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ...List.generate(
                                    buttonList.length,
                                    (index) => SizedBox(
                                      // height: 45,
                                      child: CustomIconBtn(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.black.withOpacity(0.5)
                                              : AppColors.grey,
                                          onTap: buttonList[index].onTap,
                                          icon: buttonList[index].icon,
                                          title: buttonList[index].title,
                                          direction: Axis.horizontal),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 6.w,
                  top: 3.h,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: SvgPicture.asset("assets/icons/new_icons/cancel.svg",
                        // "assets/icons/new_icons/orange.svg",
                        height: 2.h,
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                        color: Theme.of(context).iconTheme.color),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  setUpLocation({bool initaliseCamera = true}) async {
    markers = {};
    if (widget.marker == null || widget.marker!.latLng == null) return;
    currentLocation = widget.marker!.latLng!;
    final Uint8List data = await AppHelper.getBytesFromAsset(
        AppHelper.imagePathByStatusName(statusName: widget.marker!.statusName!),
        80);
    var markerIcon = BitmapDescriptor.fromBytes(data);

    markers.add(
      Marker(
        markerId: MarkerId(widget.marker!.vehicleId.toString()),
        position: widget.marker!.latLng!,
        icon: markerIcon,
        infoWindow: InfoWindow(title: widget.marker!.vehicleNo),
        onTap: widget.hideBackButton
            ? null
            : () => onTapMarker(vehicleId: widget.marker!.vehicleId),
      ),
    );
    if (mounted) setState(() {});
    if (initaliseCamera) {
      await initialiseCamerController();
    }
    moveCamera();
  }

  initialiseCamerController() async {
    _cameraController = await _controller.future;
  }

  Future<void> moveCamera() async {
    log(widget.marker!.vehicleId.toString());
    await Future.delayed(const Duration(seconds: 1));
    await _cameraController
        .showMarkerInfoWindow(MarkerId(widget.marker!.vehicleId.toString()));
    _cameraController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: currentLocation,
        // LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
        zoom: 18)));
  }

  @override
  void dispose() {
    // SystemChrome.setPreferredOrientations(
    //   [DeviceOrientation.portraitUp],
    // );
    // _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.marker!.statusName);
    // print(markers.length);
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              // mapType: MapType.hybrid,
              markers: markers,
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: currentLocation,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
            if (widget.hideBackButton == false)
              Positioned(
                top: 2.h,
                left: 2.w,
                child: Material(
                  color: AppUi.cardColor(context),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppUi.line(context)),
                      ),
                      child: Icon(Icons.arrow_back_rounded,
                          color: AppUi.ink(context)),
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
