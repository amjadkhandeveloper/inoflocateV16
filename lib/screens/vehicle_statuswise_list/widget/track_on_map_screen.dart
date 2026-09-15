import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infolocate/screens/vehicle_statuswise_list/widget/history_select_widget.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:infolocate/utils/app_styles.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:infolocate/utils/enums.dart';
import 'package:infolocate/widgets/error_widget.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/app_globals.dart';
import '../../../utils/app_localization_key.dart';
import '../../../widgets/custom_dropdown.dart';
import '../../../widgets/custom_search_widget.dart';
import '../../dashboard/controller/dashboard_provider.dart';
import '../../dashboard/controller/sequel_dashboard_provider.dart';
import '../controller/vehicle_status_provider.dart';
import '../model/vehicle_status_request_model.dart';
import '../model/vehicle_status_response_model.dart';

class TrackOnMapScreen extends StatefulWidget {
  const TrackOnMapScreen({super.key, this.showTrackHistory = false});

  //  final List<GoogleMapModel?> markerList;

  final bool showTrackHistory;

  @override
  State<TrackOnMapScreen> createState() => _TrackOnMapScreenState();
}

class _TrackOnMapScreenState extends State<TrackOnMapScreen> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
  late final GoogleMapController _cameraController;
  late LatLngBounds bounds;
  late List<String?> choiceList = [];
  VehicleStatusResponseModelDataVehicleStatusdetails? selectedVehicle;

  String? selectedStatusValue;

  // LatLng currentLocation = kGooglePlex;
  // Set<Marker> markers = <Marker>{};
  // final List<GoogleMapModel?> markerList = [];

  @override
  void didChangeDependencies() {
    _fillChoiceList();
    super.didChangeDependencies();
  }

  void _fillChoiceList() {
    final statuses = <String>{};
    if (Global.isSequelClient) {
      final sequel = Provider.of<SequelDashboardProvider>(context, listen: false);
      for (final s in sequel.vehicleStatuses) {
        final name = AppHelper.returnJapaneseText(title: s.status);
        if (name.isNotEmpty && name != 'null') statuses.add(name);
      }
    } else {
      final dashBoardState = Provider.of<DashboardProvider>(context, listen: false);
      final list = dashBoardState.dashboardResponseModelData?.VehicleStatus ?? [];
      for (final e in list) {
        final name = AppHelper.returnJapaneseText(title: e?.status);
        if (name.isNotEmpty && name != 'null') statuses.add(name);
      }
    }
    choiceList = [
      LocaliazationKey.all.tr(),
      if (widget.showTrackHistory) LocaliazationKey.track_history.tr(),
      ...statuses,
    ];
    selectedStatusValue ??= choiceList.first;
  }

  void _appendStatusesFromVehicles(VehicleStatusProvider provider) {
    final extra = (provider.vehicleList ?? [])
        .map((e) => AppHelper.returnJapaneseText(title: e?.Status))
        .where((s) => s.isNotEmpty && s != 'null');
    for (final s in extra) {
      if (!choiceList.contains(s)) choiceList.add(s);
    }
    selectedStatusValue ??= choiceList.first;
  }

  // moveCameraAlongToMarker() async {
  //   if (selectedVehicle != null) {
  //     await _cameraController.animateCamera(
  //       CameraUpdate.newCameraPosition(
  //         CameraPosition(
  //             target: LatLng(selectedVehicle!.lat!, selectedVehicle!.lon!),
  //             zoom: 100),
  //       ),
  //     );
  //   }
  // }

  @override
  void initState() {
    // SystemChrome.setPreferredOrientations(
    //   [DeviceOrientation.landscapeLeft],
    // );
    Future.delayed(Duration.zero, () => setUpLocationData());
    choiceList = [];
    choiceList = [LocaliazationKey.all.tr(), if (widget.showTrackHistory == true) LocaliazationKey.track_history.tr()];
    // setUpLocation();
    super.initState();
  }

  setUpLocationData() async {
    try {
      final vehicleStatusState = Provider.of<VehicleStatusProvider>(context, listen: false);
      _fillChoiceList();
      vehicleStatusState.resetStatusName();
      selectedStatusValue = choiceList.first;

      await vehicleStatusState.fetchInBackground(
        vehicleStatusWiseListRequestModel: VehicleStatusWiseListRequestModel(
          statusId: 6,
          userId: Global.savedUserAuthData!.userid!,
          pSize: 0,
          pNo: defaultPageN0,
          sSearch: '',
        ),
      );
      if (vehicleStatusState.state == NotifierState.error) return;
      if (!mounted) return;
      _appendStatusesFromVehicles(vehicleStatusState);
      setState(() {});

      generateMarker();
      moveCamera();
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  // Future<Uint8List> getBytesFromAsset({String? path, int? width}) async {
  //   ByteData data = await rootBundle.load(path!);
  //   Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
  //       targetWidth: width);
  //   FrameInfo fi = await codec.getNextFrame();
  //   return (await fi.image.toByteData(format: ImageByteFormat.png))!
  //       .buffer
  //       .asUint8List();
  // }
//   Future<BitmapDescriptor> _bitmapDescriptorFromSvgAsset(BuildContext context, String assetName) async {
//     String svgString = await DefaultAssetBundle.of(context).loadString(assetName);
//     //Draws string representation of svg to DrawableRoot
//     SvgStringLoader svgDrawableRoot =  SvgStringLoader(svgString);
//     Picture picture = SvgTo svgDrawableRoot.toPicture();
//     Image image = await picture.toImage(26, 37);
//     ByteData bytes = await image.toByteData(format: ui.ImageByteFormat.png);
//     return BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
// }

  generateMarker() async {
    final provider = Provider.of<VehicleStatusProvider>(context, listen: false);
    provider.generateMarker();
    // final markerList = <Marker>{};
    // for (var vehicle in provider.vehicleList!) {
    //   final Uint8List data = await AppHelper.getBytesFromAsset(
    //       AppHelper.imagePathByStatusName(statusName: vehicle!.Status!), 60);
    //   var markerIcon = BitmapDescriptor.fromBytes(data);
    //   markerList.add(
    //     Marker(
    //       markerId: MarkerId(vehicle.Vehicleid.toString()),
    //       position: LatLng(vehicle.lat!, vehicle.lon!),
    //       infoWindow: InfoWindow(
    //         title: vehicle.VehicleNo,
    //         snippet: vehicle.tracktime,
    //       ),
    //       icon: markerIcon,
    //       // BitmapDescriptor.fromBytes(customMarker),
    //       onTap: () => onTapMarker(vehicleId: vehicle.Vehicleid),
    //     ),
    //   );
    // }
    // provider.setMarker = markerList;
  }

  LatLngBounds getLatLngBounds(List<LatLng> points) {
    inspect(points.length);
    double minLat = double.infinity;
    double minLng = double.infinity;
    double maxLat = double.negativeInfinity;
    double maxLng = double.negativeInfinity;

    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> moveCamera() async {
    final provider = Provider.of<VehicleStatusProvider>(context, listen: false);
    _cameraController = await _controller.future;
    // for (var vehicle in widget.markerList) {
    //   await _cameraController
    //       .showMarkerInfoWindow(MarkerId(vehicle!.vehicleId.toString()));
    // }

    await Future.delayed(const Duration(seconds: 1));

    var data = await _cameraController.getVisibleRegion();
    bounds = data;

    await _cameraController.animateCamera(CameraUpdate.newLatLngBounds(data, 50.0));
    _cameraController.animateCamera(CameraUpdate.newLatLng(provider.currentLocation));
  }

  //*

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleStatusProvider>(context);
    return Scaffold(
      backgroundColor: AppUi.pageBg(context),
      appBar: AppUi.appBar(
        context: context,
        title: LocaliazationKey.track_on_map.tr(),
      ),
      body: provider.state == NotifierState.error
          ? CustomErrorWidget(onPressed: () {
              setUpLocationData();
            })
          : SafeArea(
              child: Stack(
              children: [
                GoogleMap(
                  markers: provider.filterMarkers,
                  mapType: MapType.normal,
                  mapToolbarEnabled: false,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  initialCameraPosition: CameraPosition(target: provider.currentLocation),
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 4,
                    top: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: autoCompleteField(provider),
                      ),
                      Expanded(
                        child: Card(
                          child: CustomDropDownButton(
                              value: selectedStatusValue,
                              onChanged: (value) async {
                                selectedVehicle = null;
                                print(value);
                                setState(() {
                                  selectedStatusValue = value;
                                });

                                if (selectedStatusValue!.contains(LocaliazationKey.all.tr())) {
                                  provider.resetMarkers();
                                  provider.resetStatusName();

                                  await _cameraController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));

                                  return;
                                } else if (selectedStatusValue!.contains(LocaliazationKey.track_history.tr())) {
                                  var res = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const HistoryTrackWidget(),
                                      ));
                                  print(res);
                                  // if (res == null) return;
                                  // res = res as VideoPlayBackRequestModel;
                                } else {
                                  provider.showMarkersByStatusName(
                                    status: selectedStatusValue,
                                  );
                                  var newBounds =
                                      getLatLngBounds(provider.filterMarkers.map((e) => e.position).toList());
                                  var isInactive = AppHelper.returnJapaneseText(title: selectedStatusValue) ==
                                      AppHelper.returnJapaneseText(title: "Inactive");
                                  await _cameraController.animateCamera(
                                      CameraUpdate.newLatLngBounds(isInactive ? bounds : newBounds, 100.0));
                                }
                              },
                              icon: SvgPicture.asset(
                                'assets/icons/filter.svg',
                                height: 3.h,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              // value: selectedFilter,
                              items: choiceList),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
            ),
    );
  }

  Widget autoCompleteField(VehicleStatusProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(4),
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).cardColor : AppColors.grey),
      ),
      child: Autocomplete<String>(
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          return TextField(
            controller: textEditingController,
            focusNode: focusNode,
            style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black),
            decoration: AppStyles.inputFieldTrackStyle(
                prefixIcon: const Icon(Icons.search, size: 25),
                suffixIcon: IconButton(
                  onPressed: () async {
                    selectedVehicle = null;
                    final query = textEditingController.text.trim().toLowerCase();
                    VehicleStatusResponseModelDataVehicleStatusdetails? vehicle;
                    for (final element in provider.vehicleList ?? const []) {
                      if ((element?.VehicleNo ?? '').toLowerCase() == query) {
                        vehicle = element;
                        break;
                      }
                    }
                    if (vehicle != null) {
                      if (provider.filterMarkers
                          .map((e) => e.markerId)
                          .contains(MarkerId(vehicle.Vehicleid.toString()))) {
                        await _cameraController.hideMarkerInfoWindow(MarkerId(vehicle.Vehicleid.toString()));
                      }
                    }

                    textEditingController.clear();
                    focusNode.unfocus();
                    await _cameraController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.0));
                  },
                  icon: textEditingController.text.isNotEmpty
                      ? const Icon(
                          Icons.cancel,
                          color: Colors.red,
                        )
                      : const SizedBox.shrink(),
                ),
                hintText: LocaliazationKey.search.tr()),
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp('^\\s')),
            ],
          );
        },
        optionsViewBuilder: (BuildContext context, void Function(String) onSelected, Iterable<String> options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 6,
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240, maxWidth: 320),
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final opt = options.elementAt(index);
                    return ListTile(
                      dense: true,
                      title: Text(opt),
                      onTap: () {
                        onSelected(opt);
                        FocusScope.of(context).unfocus();
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
        optionsBuilder: (TextEditingValue textEditingValue) {
          final query = textEditingValue.text.trim().toLowerCase();
          if (query.isEmpty) {
            return const Iterable<String>.empty();
          }
          return (provider.vehicleList ?? [])
              .map((e) => e?.VehicleNo)
              .whereType<String>()
              .where((no) => no.toLowerCase().contains(query));
        },
        onSelected: (String value) async {
          provider.resetMarkers();
          provider.resetStatusName();
          if (choiceList.isNotEmpty) selectedStatusValue = choiceList[0];
          provider.updateMarker();
          setState(() {});
          FocusScope.of(context).unfocus();
          final match = value.toLowerCase();
          VehicleStatusResponseModelDataVehicleStatusdetails? vehicle;
          for (final element in provider.vehicleList ?? const []) {
            if ((element?.VehicleNo ?? '').toLowerCase() == match) {
              vehicle = element;
              break;
            }
          }
          if (vehicle == null || vehicle.lat == null || vehicle.lon == null) return;
          selectedVehicle = vehicle;
          await _cameraController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: LatLng(vehicle.lat!, vehicle.lon!), zoom: 100),
            ),
          );
          if (vehicle.Vehicleid != null &&
              provider.filterMarkers.map((e) => e.markerId).contains(MarkerId(vehicle.Vehicleid.toString()))) {
            await _cameraController.showMarkerInfoWindow(MarkerId(vehicle.Vehicleid.toString()));
          }
        },
      ),
    );
  }

// onTapMarker({required int? vehicleId}) {
//   if (mounted) FocusScope.of(context).unfocus();
//   final vehicleStatusProvider =
//       Provider.of<VehicleStatusProvider>(context, listen: false);
//   final vehicle = vehicleStatusProvider.getVehicleById(vehicleId: vehicleId);
//   if (vehicle == null) return;
//   final buttonList = [
//     // if (vehicle.Status != null)
//     //   ButtonListModel(
//     //     icon: SvgPicture.asset(
//     //         AppHelper.returnIcons(title: vehicle.Status.toString()),
//     //         // "assets/icons/new_icons/orange.svg",
//     //         height: 3.h,
//     //         // colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
//     //         color:
//     //             AppHelper.returnIconColor(title: vehicle.Status.toString())),
//     //     title: vehicle.Status.toString(),
//     //   ),
//     if (vehicle.speed != null)
//       ButtonListModel(
//           icon: SvgPicture.asset(
//             AppHelper.getSpeedometerIcon(int.parse(vehicle.speed.toString())),
//             // "assets/icons/new_icons/orange.svg",
//             height: 3.h,
//             // colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
//             color: AppHelper.getSpeedometerColor(
//                 int.parse(vehicle.speed.toString())),
//           ),
//           title: vehicle.speed.toString()),
//     if (vehicle.speed != null)
//       ButtonListModel(
//         icon: SvgPicture.asset(
//           'assets/icons/ignition.svg',
//           height: 3.h,
//           color: Theme.of(context).colorScheme.primary,
//         ),
//         title: vehicle.ignition.toString() == "0" ? 'OFF' : 'ON',
//       ),
//     if (vehicle.odometer != null)
//       ButtonListModel(
//           icon: SvgPicture.asset(
//             'assets/icons/odometer.svg',
//             height: 3.h,
//             color: Theme.of(context).colorScheme.primary,
//           ),
//           title: "${vehicle.odometer} ${LocaliazationKey.miles.tr()}"),
//     if (vehicle.EngineOffdelay != null)
//       ButtonListModel(
//           icon: SvgPicture.asset(
//             'assets/icons/enginedelay.svg',
//             height: 3.h,
//             color: Theme.of(context).colorScheme.primary,
//           ),
//           title: vehicle.EngineOffdelay.toString()),
//     if (vehicle.idleduration != null)
//       ButtonListModel(
//           icon: SvgPicture.asset(
//             'assets/icons/idle-duration.svg',
//             height: 3.h,
//             // colorFilter: ColorFilter.mode(
//             //     Theme.of(context).colorScheme.primary, BlendMode.colorBurn),
//             color: Theme.of(context).colorScheme.primary,
//           ),
//           title: vehicle.idleduration.toString()),
//     if (vehicle.stopduration != null)
//       ButtonListModel(
//           icon: Icon(
//             Icons.power_off_rounded,
//             color: Theme.of(context).colorScheme.primary,
//           ),
//           title: vehicle.stopduration.toString()),
//   ];
//   return showModalBottomSheet<void>(
//     context: context,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(
//         top: Radius.circular(14),
//       ),
//     ),
//     builder: (BuildContext context) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 14, right: 14),
//             child: GestureDetector(
//               onTap: () {
//                 Navigator.of(context).pop();
//               },
//               child: SvgPicture.asset("assets/icons/new_icons/cancel.svg",
//                   // "assets/icons/new_icons/orange.svg",
//                   height: 2.h,
//                   // colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
//                   color: Theme.of(context).iconTheme.color),
//             ),
//           ),
//           Container(
//             margin: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey.shade300, width: 1),
//               borderRadius: BorderRadius.circular(15),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                       color: AppHelper.returnIconColor(
//                         title: vehicle.Status.toString(),
//                       ),
//                       borderRadius: const BorderRadius.only(
//                         topLeft: Radius.circular(15),
//                         topRight: Radius.circular(15),
//                       )),
//                   width: double.infinity,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       const SizedBox(
//                         width: 14,
//                       ),
//                       Expanded(
//                         flex: 4,
//                         child: Text(
//                           "${LocaliazationKey.vehicle_status.tr()} : ",
//                           style: const TextStyle(
//                               color: Colors.white, fontSize: 18),
//                         ),
//                       ),
//                       Expanded(
//                         flex: 7,
//                         child: Text(
//                           vehicle.Status.toString(),
//                           style: const TextStyle(
//                               color: Colors.white, fontSize: 18),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Expanded(
//                       flex: 5,
//                       child: Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Text(
//                           vehicle.VehicleNo.toString(),
//                           style: AppStyles.textStyle4(
//                               context: context, isBold: true, size: 18),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       flex: 5,
//                       child: Padding(
//                         padding: const EdgeInsets.all(20),
//                         child: Text(
//                           vehicle.tracktime.toString(),
//                           style: AppStyles.textStyle5(context: context),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                   child: Text(
//                     vehicle.location.toString(),
//                     style: AppStyles.textStyle4(context: context, size: 16),
//                   ),
//                 ),
//                 SizedBox(
//                   width: SizerUtil.width,
//                   height: 6.h,
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     physics: const BouncingScrollPhysics(),
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 12),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           ...List.generate(
//                             buttonList.length,
//                             (index) => SizedBox(
//                               // height: 45,
//                               child: CustomIconBtn(
//                                   onTap: buttonList[index].onTap,
//                                   icon: buttonList[index].icon,
//                                   title: buttonList[index].title,
//                                   direction: Axis.horizontal),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       );
//     },
//   );
// }
}
