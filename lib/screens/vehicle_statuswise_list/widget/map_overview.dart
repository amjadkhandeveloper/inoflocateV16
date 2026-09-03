import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_constants.dart';
import '../../../utils/app_globals.dart';
import '../../../utils/app_helper.dart';
import '../../../utils/enums.dart';
import '../../../widgets/error_widget.dart';
import '../controller/vehicle_status_provider.dart';
import '../model/vehicle_status_request_model.dart';

class MapOverview extends StatefulWidget {
  const MapOverview({super.key});

  @override
  State<MapOverview> createState() => _MapOverviewState();
}

class _MapOverviewState extends State<MapOverview> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late final GoogleMapController _cameraController;
  late LatLngBounds bounds;
  late List<String?> choiceList;

  String? selectedStatusValue;
  // LatLng currentLocation = kGooglePlex;
  // Set<Marker> markers = <Marker>{};
  // final List<GoogleMapModel?> markerList = [];

  @override
  void initState() {
    // SystemChrome.setPreferredOrientations(
    //   [DeviceOrientation.landscapeLeft],
    // );
    Future.delayed(Duration.zero, () => setUpLocationData());
    // setUpLocation();
    super.initState();
  }

  setUpLocationData() async {
    try {
      // final dashBoardState =
      //     Provider.of<DashboardProvider>(context, listen: false);
      final vehicleStatusState =
          Provider.of<VehicleStatusProvider>(context, listen: false);

      await vehicleStatusState.fetchInBackground(
        vehicleStatusWiseListRequestModel: VehicleStatusWiseListRequestModel(
          statusId: 6,
          userId: Global.savedUserAuthData!.userid!,
          // userId: 1,
          pSize: 0, //* get all vehicles if psize 0.
          pNo: defaultPageN0, sSearch: '',
        ), //* calling this api to ensure have all markers on map.
      );
      if (vehicleStatusState.state == NotifierState.error) return;

      generateMarker();
      moveCamera();
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  generateMarker() async {
    final provider = Provider.of<VehicleStatusProvider>(context, listen: false);
    final markerList = <Marker>{};
    // final Uint8List customMarker = await svgToPng(
    //     svgString: "assets/icons/idle.svg", //paste the custom image path
    //     context: context // size of custom image as marker
    //     );
    for (var vehicle in provider.vehicleList!) {
      // final icon = await BitmapDescriptor.fromAssetImage(
      //     const ImageConfiguration(size: Size(1, 1)),
      //     "assets/images/ic_lang_jap.png");
      // var _icon = imagePathByStatusName
      final Uint8List data = await AppHelper.getBytesFromAsset(
          AppHelper.imagePathByStatusName(statusName: vehicle!.Status), 60);
      var markerIcon = BitmapDescriptor.fromBytes(data);

      markerList.add(
        Marker(
          markerId: MarkerId(vehicle.Vehicleid.toString()),
          position: LatLng(vehicle.lat!, vehicle.lon!),
          infoWindow: InfoWindow(
            title: vehicle.VehicleNo,
            snippet: vehicle.tracktime,
          ),
          icon: markerIcon,
        ),
      );
    }
    provider.setOverviewMarker = markerList;
    // setState(() {});
    // if (markers.isNotEmpty) {
    //   provider. = _markers.first.position;
    // }
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
    await _cameraController
        .animateCamera(CameraUpdate.newLatLngBounds(data, 50.0));
    _cameraController
        .animateCamera(CameraUpdate.newLatLng(provider.currentLocation));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VehicleStatusProvider>(context);

    // _cameraController.animateCamera(CameraUpdate.newLatLng(currentLocation));

    // print(currentLocation);
    return Container(
      child: provider.state == NotifierState.error
          ? CustomErrorWidget(onPressed: () {
              setUpLocationData();
            })
          : GoogleMap(
              // mapType: MapType.hybrid,
              markers: provider.overviewMarkers,
              mapType: MapType.normal,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,

              mapToolbarEnabled: false,
              initialCameraPosition:
                  CameraPosition(target: provider.currentLocation),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                // provider.controller.complete(controller);
              },
            ),
    );
  }
}
