import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infolocate/utils/app_colors.dart';
import 'package:infolocate/utils/app_extensions.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_styles.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/app_constants.dart';
import '../../../utils/app_helper.dart';
import '../../../widgets/google_map/map_zoom_controls.dart';
import '../controller/vehicle_status_provider.dart';
import '../model/history_track_response_model.dart';

class VehicleHistoryTrackScreen extends StatefulWidget {
  const VehicleHistoryTrackScreen({super.key, required this.historyTrackList});
  final List<VehicleHistoryTrackModelDataVehicleHistory?>? historyTrackList;

  @override
  State<VehicleHistoryTrackScreen> createState() =>
      _VehicleHistoryTrackScreenState();
}

class _VehicleHistoryTrackScreenState extends State<VehicleHistoryTrackScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _cameraController;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> markers = <Marker>{};
  Set<Polyline> polylines = <Polyline>{};
  List<LatLng> polyLineCoordinates = [];
  final List<String?> vehicleIconList = [
    "assets/images/car_marker.png",
    "assets/images/truck_marker.png",
  ];
  int selectVehicleIconIndex = 0;
  int count = 0;
  // var currentLocation = kGooglePlex;
  // double? rotation = 0.0;
  BitmapDescriptor icon = BitmapDescriptor.defaultMarker;
  var endLocation = kGooglePlex;
  Timer _timer = Timer(Duration.zero, () {});
  late AnimationController _animationController;
  bool isPlaying = false;
  BitmapDescriptor source_marker = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destination_marker = BitmapDescriptor.defaultMarker;

  double _progressValue = 0.0;

  @override
  void initState() {
    Future.delayed(Duration.zero, () => setUpMap());
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    super.initState();
  }

  setUpMap() {
    generateMarkers();
    // getPolyLines();
    generatePolylines();
    moveCamera();
  }
  // assets/images/car_marker.png

  Future<void> moveCamera() async {
    _cameraController = await _controller.future;
    if (polyLineCoordinates.isEmpty) return;
    await AppHelper.moveCameraToPoints(
      _cameraController!,
      polyLineCoordinates,
      padding: 80,
    );
  }

  generatePolylines() {
    polyLineCoordinates.clear();
    for (final element in widget.historyTrackList ?? const []) {
      if (element == null) continue;
      if (!AppHelper.isValidLatLng(element.lat, element.lon)) continue;
      polyLineCoordinates.add(LatLng(element.lat!, element.lon!));
    }
  }

  generateMarkers() async {
    final provider = Provider.of<VehicleStatusProvider>(context, listen: false);
    final history = widget.historyTrackList ?? const [];
    if (history.isEmpty || history.first == null) return;
    final firstMarkerData = history.first;
    provider.updateHistoryTrack(data: firstMarkerData);
    // currentLocation = LatLng(firstMarkerData!.lat!, firstMarkerData.lon!);
    // endLocation = LatLng(secondMarkerData!.lat!, secondMarkerData.lon!);
    // icon =
    //     await getBitmapDescriptorFromSvgAsset("assets/images/map_marker.svg");
    // setState(() {});
    // BitmapDescriptor.fromAssetImage(
    //   const ImageConfiguration(size: Size.square(5), devicePFixelRatio: 3),
    //   'assets/images/box-truck.png',
    // ).then((value) => icon = value);
    var hiveVehicleIconIndex = Global.box.get(vehicleMarkerIconKey);
    if (hiveVehicleIconIndex != null) {
      selectVehicleIconIndex = hiveVehicleIconIndex;
    }
    final Uint8List markerIcon = await AppHelper.getBytesFromAsset(
      vehicleIconList[selectVehicleIconIndex]!,
      120,
    );
    icon = BitmapDescriptor.fromBytes(markerIcon);
    final Uint8List data = await AppHelper.getBytesFromAsset(
        AppHelper.imagePathByStatusName(statusName: "Source"), 100);
    var sMarker = BitmapDescriptor.fromBytes(data);
    source_marker = sMarker;
    final Uint8List data2 = await AppHelper.getBytesFromAsset(
        AppHelper.imagePathByStatusName(statusName: "Destination"), 100);
    var dMarker = BitmapDescriptor.fromBytes(data2);
    destination_marker = dMarker;
    setState(() {});
  }

  LatLng interpolatePosition(LatLng start, LatLng end, double fraction) {
    return LatLng(
      start.latitude + (end.latitude - start.latitude) * fraction,
      start.longitude + (end.longitude - start.longitude) * fraction,
    );
  }

  double getBearing(LatLng start, LatLng end) {
    double startLat = degreesToRadians(start.latitude);
    double startLng = degreesToRadians(start.longitude);
    double endLat = degreesToRadians(end.latitude);
    double endLng = degreesToRadians(end.longitude);

    double dLng = endLng - startLng;
    double bearing = atan2(
      sin(dLng) * cos(endLat),
      cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLng),
    );
    return radiansToDegrees(bearing).clamp(0.0, 360.0);
  }

  double degreesToRadians(double degrees) => degrees * (pi / 180);
  double radiansToDegrees(double radians) => radians * (180 / pi);


  void _updateProgress({required double fraction}) {
    final total = widget.historyTrackList?.length ?? 0;
    if (total <= 0) {
      _progressValue = 0.0;
      return;
    }
    // Each history record advances the bar equally:
    // 2 records -> 50%, 100%; 10 records -> 10%, 20%, ... 100%.
    final next = (count + fraction) / total;
    _progressValue =
        (!next.isFinite || next.isNaN) ? 0.0 : next.clamp(0.0, 1.0);
  }

  double get _safeProgress {
    final value = _progressValue;
    if (!value.isFinite || value.isNaN) return 0.0;
    return value.clamp(0.0, 1.0);
  }

  void startMoving({bool restart = false}) async {
    _timer.cancel();
    final history = widget.historyTrackList;
    if (history == null || history.isEmpty) return;

    final provider = Provider.of<VehicleStatusProvider>(context, listen: false);

    if (restart) {
      count = 0;
      _progressValue = 0.0;
      provider.updateHistoryTrack(data: history.first);
      isPlaying = true;
      _animationController.forward();
    }

    if (count >= history.length) {
      _progressValue = 1.0;
      isPlaying = false;
      _animationController.reverse();
      if (mounted) setState(() {});
      return;
    }

    final current = history[count];
    if (current?.lat == null || current?.lon == null) return;

    LatLng start = provider.historyCurrentLocation;
    LatLng end = LatLng(current!.lat!, current.lon!);

    double fraction = 0.0;
    const duration = Duration(milliseconds: 1000);
    const totalSteps = 20; // Smoothness of the animation
    final stepDuration = duration.inMilliseconds ~/ totalSteps;

    _timer = Timer.periodic(Duration(milliseconds: stepDuration), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      fraction += 1 / totalSteps;
      if (fraction > 1.0) {
        fraction = 1.0;
      }

      LatLng newPosition = interpolatePosition(start, end, fraction);

      provider.updateHistoryTrack(
        data: history[count],
      );

      _cameraController?.moveCamera(CameraUpdate.newLatLng(newPosition));
      _updateProgress(fraction: fraction);
      setState(() {});

      if (fraction >= 1.0) {
        timer.cancel();
        count++;
        if (count < history.length) {
          startMoving(); // Move to the next segment
        } else {
          _progressValue = 1.0;
          isPlaying = false;
          _animationController.reverse();
          if (mounted) setState(() {});
        }
      }
    });
  }


  void pauseTimer() {
    _timer.cancel();
  }

  void _handleOnPressed() {
    setState(() {
      isPlaying = !isPlaying;
      if (isPlaying) {
        final total = widget.historyTrackList?.length ?? 0;
        final restart = total > 0 && count >= total;
        startMoving(restart: restart);
        _animationController.forward();
      } else {
        _animationController.reverse();
        pauseTimer();
      }
    });
  }

  showSelectVehicleSheet() {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) => StatefulBuilder(builder: (context, setState2) {
        return Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 48, 12),
                  child: Text(
                    LocaliazationKey.choose_vehicle_icon.tr(),
                    style: AppStyles.textStyle4(
                        context: context, color: Colors.grey.shade600),
                  ),
                ),
                3.h.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ...List.generate(
                      vehicleIconList.length,
                      (index) => InkWell(
                        onTap: () async {
                          selectVehicleIconIndex = index;
                          final Uint8List markerIcon =
                              await AppHelper.getBytesFromAsset(
                            vehicleIconList[selectVehicleIconIndex]!,
                            100,
                          );
                          icon = BitmapDescriptor.fromBytes(markerIcon);
                          setState2(() {});
                          setState(() {});
                          await Global.box.put(
                              vehicleMarkerIconKey, selectVehicleIconIndex);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: selectVehicleIconIndex == index
                                  ? Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.1)
                                  : null,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(12)),
                              border: Border.all(
                                  color: selectVehicleIconIndex == index
                                      ? AppColors.primeryColor
                                      : AppColors.customGrey)),
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Image.asset(vehicleIconList[index]!,
                                height: 6.h),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                3.h.height
              ],
            ),
            Positioned(
              // top: 1.h,
              right: 3.w,
              child: IconButton(
                  onPressed: () {
                    Navigator.maybePop(context);
                  },
                  icon: const Icon(
                    CupertinoIcons.clear,
                    size: 16,
                  )),
            )
          ],
        );
      }),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<VehicleStatusProvider>(context);
    // print(widget.historyTrackList!.length);
    // log(polylines.length.toString());

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            GoogleMap(
              // mapType: MapType.hybrid,
              markers: {
                Marker(
                    markerId: const MarkerId(
                      'vehicle_marker',
                    ),
                    icon: icon,
                    rotation: provider.markerRotation ?? 0,
                    position: provider.historyCurrentLocation,
                    anchor: const Offset(0.5, 0.5),
                    // onTap: () => showSelectVehicleSheet(),
                    flat: true),
                if ((widget.historyTrackList ?? []).isNotEmpty &&
                    AppHelper.isValidLatLng(
                      widget.historyTrackList!.last?.lat,
                      widget.historyTrackList!.last?.lon,
                    ))
                  Marker(
                    markerId: const MarkerId(
                      'source_marker',
                    ),
                    icon: source_marker,
                    position: LatLng(widget.historyTrackList!.last!.lat!,
                        widget.historyTrackList!.last!.lon!),
                  ),
                if ((widget.historyTrackList ?? []).isNotEmpty &&
                    AppHelper.isValidLatLng(
                      widget.historyTrackList!.first?.lat,
                      widget.historyTrackList!.first?.lon,
                    ))
                  Marker(
                    markerId: const MarkerId(
                      'destination_marker',
                    ),
                    icon: destination_marker,
                    position: LatLng(widget.historyTrackList!.first!.lat!,
                        widget.historyTrackList!.first!.lon!),
                  ),
              },
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              minMaxZoomPreference: const MinMaxZoomPreference(3, 20),
              initialCameraPosition:
                  CameraPosition(target: provider.historyCurrentLocation),
              onMapCreated: (GoogleMapController controller) {
                _cameraController = controller;
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                }
              },
              polylines: {
                Polyline(
                    polylineId: const PolylineId(
                      'lines',
                    ),
                    points: polyLineCoordinates,
                    color: Colors.purple,
                    width: 3)
              },
            ),
            if (provider.movingVehicleDetail != null)
              Positioned(
                  // top: -10,
                  bottom: -10,
                  right: -1,
                  left: -1,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      // borderRadius: const BorderRadius.only(
                      //   bottomLeft: Radius.circular(14),
                      //   bottomRight: Radius.circular(14),
                      // ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          color: AppUi.accent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 38,
                                    // width: 32,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    child: Center(
                                      child: InkWell(
                                        onTap: () {
                                          _handleOnPressed();
                                        },
                                        child: AnimatedIcon(
                                          icon: AnimatedIcons.play_pause,
                                          progress: _animationController,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 10,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: _safeProgress,
                                      minHeight: 8,
                                      color: const Color(0xffFE713A),
                                      backgroundColor:
                                          Colors.white.withValues(alpha: 0.35),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 38,
                                    // width: 32,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle),
                                    child: Center(
                                      child: IconButton(
                                        onPressed: () async {
                                          _timer.cancel();
                                          startMoving(restart: true);
                                        },
                                        icon: Icon(
                                          Icons.restart_alt,
                                          size: 20,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        1.h.height,
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: CustomValueWidget(
                                      icon: Icon(
                                        Icons.local_taxi_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      isDarkTheme: isDarkTheme,
                                      value: provider
                                          .movingVehicleDetail!.VehicleNo
                                          .toString(),
                                      titleFontSize: 20,
                                      isBold: true,
                                    ),
                                  ),
                                  Expanded(
                                    child: CustomValueWidget(
                                      icon: Icon(
                                        Icons.watch_later_outlined,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      isDarkTheme: isDarkTheme,
                                      value: provider
                                          .movingVehicleDetail!.tracktime
                                          .toString(),
                                      isBold: false,
                                    ),
                                  ),
                                ],
                              ),
                              2.h.height,
                              CustomValueWidget(
                                icon: Icon(
                                  Icons.location_on_outlined,
                                  color: AppUi.accent,
                                ),
                                isDarkTheme: isDarkTheme,
                                value: provider.movingVehicleDetail!.location
                                    .toString(),
                                isBold: false,
                                valueFontSize: 18,
                              ),
                              2.h.height,
                              Row(
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: CustomValueWidget(
                                      icon: SvgPicture.asset(
                                        AppHelper.getSpeedometerIcon(int.parse(
                                            provider.movingVehicleDetail!
                                                        .speed ==
                                                    null
                                                ? '0'
                                                : provider
                                                    .movingVehicleDetail!.speed
                                                    .toString())),
                                        // "assets/icons/new_icons/orange.svg",
                                        height: 3.h,
                                        // colorFilter: const ColorFilter.mode(Colors.blue, BlendMode.srcIn),
                                        color: AppHelper.getSpeedometerColor(
                                            int.parse(provider
                                                        .movingVehicleDetail!
                                                        .speed ==
                                                    null
                                                ? '0'
                                                : provider
                                                    .movingVehicleDetail!.speed
                                                    .toString())),
                                      ),
                                      isDarkTheme: isDarkTheme,
                                      value: provider
                                                  .movingVehicleDetail!.speed ==
                                              null
                                          ? '0'
                                          : '${provider.movingVehicleDetail!.speed} ${LocaliazationKey.km_h.tr()}',
                                      isBold: false,
                                      valueFontSize: 16,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        showSelectVehicleSheet();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 10),
                                        minimumSize: const Size(0, 40),
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        LocaliazationKey.change_vehicle.tr(),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppStyles.textStyle4(
                                            context: context, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              2.h.height,
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back)),
            MapZoomControls(
              controller: _controller,
              mapController: _cameraController,
              // Keep clear of the bottom trip panel and back button.
              top: 72,
              right: 12,
              minZoom: 3,
              maxZoom: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomValueWidget extends StatelessWidget {
  const CustomValueWidget(
      {super.key,
      required this.isDarkTheme,
      required this.value,
      this.isBold = false,
      required this.icon,
      this.titleFontSize,
      this.valueFontSize});

  final bool isDarkTheme;
  final String value;
  final bool? isBold;
  final double? titleFontSize;
  final double? valueFontSize;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 22,
          width: 22,
          child: icon,
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppStyles.textStyle4(
                context: context,
                isBold: isBold ?? false,
                size: isBold ?? false
                    ? titleFontSize ?? 16
                    : valueFontSize ?? 14),
          ),
        )
      ],
    );
  }
}
