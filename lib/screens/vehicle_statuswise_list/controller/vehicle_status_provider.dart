import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infolocate/screens/vehicle_statuswise_list/repository/vehicle_status_repo.dart';
import 'package:infolocate/utils/app_colors.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:sizer/sizer.dart';

import '../../../app.dart';
import '../../../common_models/button_list_model.dart';
import '../../../common_models/failure_model.dart';
import '../../../utils/app_globals.dart';
import '../../../utils/app_localization_key.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/enums.dart';
import '../../../widgets/buttons/custom_icon_button.dart';
import '../../../widgets/custom_toast.dart';
import '../model/history_track_request_model.dart';
import '../model/history_track_response_model.dart';
import '../model/vehicle_status_request_model.dart';
import '../model/vehicle_status_response_model.dart';

/// Vehicle status list, map markers, and track-history playback state.
class VehicleStatusProvider extends ChangeNotifier with StateInterface {
  int? _totalCount = 0;
  VehicleHistoryTrackModelDataVehicleHistory? _movingVehicleDetail;
  NotifierState _state = NotifierState.initial;
  LatLng _currentLocation = kGooglePlex;
  var _historyCurrentLocation = kGooglePlex;
  double? _markerRotation = 0.0;
  Failure? _failure;
  bool _isMoreDataLoading = false;
  bool _hasMoreData = true;

  // bool _isFilterApplied = false;
  String? statusName;
  VehicleStatusResponseModelData? _vehicleStatusResponseModelData;
  Set<Marker> _markers = <Marker>{};
  Set<Marker> _filterMarkers = <Marker>{};
  Set<Marker> _overviewMarkers = <Marker>{};
  List<VehicleStatusResponseModelDataVehicleStatusdetails?>? _vehicleList = [];
  List<VehicleStatusResponseModelDataVehicleStatusdetails?>? _filterList = [];
  List<VehicleHistoryTrackModelDataVehicleHistory?>? _historyTrackList = [];
  // List<String?> _choiceChipList = [];
  // final Completer<GoogleMapController> _controller =
  //     Completer<GoogleMapController>();
  // late final GoogleMapController _cameraController;
  int get totalCount => _totalCount!;
  LatLng get currentLocation => _currentLocation;
  LatLng get historyCurrentLocation => _historyCurrentLocation;

  double? get markerRotation => _markerRotation;

  // Completer<GoogleMapController> get controller => _controller;

  Set<Marker> get markers => {..._markers};

  Set<Marker> get filterMarkers => {..._filterMarkers};
  Set<Marker> get overviewMarkers => {..._overviewMarkers};

  bool _isSearchLoading = false;

  bool get isSearchLoading => _isSearchLoading;
  List<VehicleHistoryTrackModelDataVehicleHistory?>? get historyTrackList =>
      [..._historyTrackList ?? []];

  List<VehicleStatusResponseModelDataVehicleStatusdetails?>? get vehicleList =>
      [..._vehicleList ?? []];
  List<VehicleStatusResponseModelDataVehicleStatusdetails?>? get filterList =>
      [..._filterList ?? []];
  // List<String?> get choiceChipList => [..._choiceChipList];

  NotifierState get state => _state;
  bool get hasMoreData => _hasMoreData;
  bool get isMoreDataLoading => _isMoreDataLoading;

  Failure get failure => _failure ?? Failure('');

  VehicleStatusResponseModelData? get vehicleStatusResponseModelData =>
      _vehicleStatusResponseModelData;
  VehicleHistoryTrackModelDataVehicleHistory? get movingVehicleDetail =>
      _movingVehicleDetail;

  @override
  void setState(NotifierState state) {
    _state = state;
    if (state == NotifierState.loading) {
      _isMoreDataLoading = true;
    }

    _isMoreDataLoading = false;

    notifyListeners();
  }

  // onSearchChange({required String? keyWord}) {
  //   _filterList = vehicleList;
  //   _filterList!.retainWhere((alert) =>
  //       alert!.VehicleNo!.toLowerCase().contains(keyWord!.toLowerCase()));
  //   notifyListeners();
  // }
  onSearchChange({
    required String? keyWord,
    required VehicleStatusWiseListRequestModel
        vehicleStatusWiseListRequestModel,
  }) async {
    _isSearchLoading = true;
    _hasMoreData = false;
    notifyListeners();
    try {
      final result = await VehicleStatusService().getVehicleList(
          vehicleStatusWiseListRequestModel: vehicleStatusWiseListRequestModel);
      _filterList = result!.vehicleStatusdetails ?? [];
    } catch (e) {
      debugPrint(e.toString());
    }
    _isSearchLoading = false;
    notifyListeners();
  }

  @override
  void setFailure(Failure failure) {
    _vehicleStatusResponseModelData = null;
    setState(NotifierState.error);
    customToast(message: failure.message.toString());
    _failure = failure;
    notifyListeners();
  }

  clearVehicleList() {
    _hasMoreData = true;
    _vehicleList = _filterList = [];
    notifyListeners();
  }

  VehicleStatusResponseModelDataVehicleStatusdetails? getVehicleById(
      {required int? vehicleId}) {
    var res = vehicleList!.firstWhere(
        (element) => element!.Vehicleid == vehicleId,
        orElse: () => VehicleStatusResponseModelDataVehicleStatusdetails());
    return res;
  }

  updatePinValue({required int? vehicleId, required int? value}) {
    final data = _vehicleList!.firstWhere(
        (element) => element!.Vehicleid == vehicleId,
        orElse: () => VehicleStatusResponseModelDataVehicleStatusdetails());
    if (data != null) {
      data.IsPinVehicle = value;
    }
    final filterdData = _filterList!.firstWhere(
        (element) => element!.Vehicleid == vehicleId,
        orElse: () => VehicleStatusResponseModelDataVehicleStatusdetails());
    if (filterdData != null) {
      filterdData.IsPinVehicle = value;
    }

    notifyListeners();
  }

  Future<void> fetchInBackground({
    required VehicleStatusWiseListRequestModel
        vehicleStatusWiseListRequestModel,
  }) async {
    //* fetch all vehicles in the background without lazy loading
    // clearVehicleList();
    try {
      final result = await VehicleStatusService().getVehicleList(
          vehicleStatusWiseListRequestModel: vehicleStatusWiseListRequestModel);
      _vehicleStatusResponseModelData = result;
      // bool condition = result!.vehicleStatusdetails!.length < pageSize;
      // if (condition) {
      //   // if (backgroundFetch) {
      //   // customToast(message: LocaliazationKey.no_more_data.tr());
      //   // }
      //   _hasMoreData = false;
      // } else {
      //   _hasMoreData = true;
      // }

      _vehicleList = result!.vehicleStatusdetails;
      // log("Vehicle List Data");
      // log(_vehicleStatusResponseModelData!.toJson().toString());

      _filterList = _vehicleList;
      if (result.vehicleCount!.isNotEmpty) {
        _totalCount = result.vehicleCount!.first!.recCnt!;
      }

      if (_vehicleList!.isNotEmpty) {
        _currentLocation =
            LatLng(_vehicleList!.first!.lat!, _vehicleList!.first!.lon!);
        if (_markers.isNotEmpty) {
          // generateMarker();
          // updateMarker();
        }
      }
      setState(NotifierState.loaded);
      notifyListeners();
    } on Failure catch (err) {
      if (err.message == LocaliazationKey.no_internet_connection.tr()) {
        setFailure(err);
      }
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  Future<void> getVehicleList(
      {required VehicleStatusWiseListRequestModel
          vehicleStatusWiseListRequestModel,
      bool backgroundFetch = false}) async {
    if (backgroundFetch == false) {
      setState(NotifierState.loading);
      clearVehicleList();
    }
    try {
      final result = await VehicleStatusService().getVehicleList(
          vehicleStatusWiseListRequestModel: vehicleStatusWiseListRequestModel);
      _vehicleStatusResponseModelData = result;
      bool condition = result!.vehicleStatusdetails!.length < pageSize;
      if (condition) {
        // if (backgroundFetch) {
        // customToast(message: LocaliazationKey.no_more_data.tr());
        // }
        _hasMoreData = false;
      } else {
        _hasMoreData = true;
      }
      _vehicleList!.addAll(result.vehicleStatusdetails ?? []);
      // log("Vehicle List Data");
      // log(_vehicleStatusResponseModelData!.toJson().toString());

      _filterList = _vehicleList;
      if (result.vehicleCount!.isNotEmpty) {
        _totalCount = result.vehicleCount!.first!.recCnt!;
      }

      if (_vehicleList!.isNotEmpty) {
        _currentLocation =
            LatLng(_vehicleList!.first!.lat!, _vehicleList!.first!.lon!);
        if (_markers.isNotEmpty) {
          // generateMarker();
          // updateMarker();
        }
      }

      // generateMarker(context: context);
      notifyListeners();
    } on Failure catch (failure) {
      backgroundFetch == false
          ? setFailure(failure)
          : customToast(message: failure.message.toString());
    } catch (err) {
      print(err.toString());
    }
    // if (loadMore == false) setState(NotifierState.loaded);
    if (backgroundFetch == false) setState(NotifierState.loaded);
  }

  getVehicleHistoryTrack(
      {required HistoryTrackRequestModel
          vehicleHistoryTrackRequestModel}) async {
    setState(NotifierState.loading);
    try {
      final result = await VehicleStatusService().vehicleHistoryTrackApi(
          vehicleHistoryTrackRequestModel: vehicleHistoryTrackRequestModel);
      _historyTrackList = result!.VehicleHistory;
      if (_historyTrackList!.isEmpty) {
        customToast(message: 'History data not available for selected period');
      }
      //* generate random id for each element for markers;
      for (var i = 0; i < _historyTrackList!.length; i++) {
        // final id = i+1;
        _historyTrackList![i]!.uniqueId = i.toString();
      }

      notifyListeners();
    } on Failure catch (failure) {
      setFailure(failure);
    }
    setState(NotifierState.loaded);
  }

  set setMarker(Set<Marker> value) {
    _filterMarkers = _markers = value;
    notifyListeners();
  }

  set setOverviewMarker(Set<Marker> value) {
    _overviewMarkers = value;
    notifyListeners();
  }

  // updateDropDown({required List<String?>? choiceList}) {
  //   _choiceChipList = choiceList!;
  //   _choiceChipList.insert(0, allValue);
  //   // notifyListeners();
  // }
  generateMarker() async {
    _markers = {};
    for (var vehicle in vehicleList!) {
      final Uint8List data = await AppHelper.getBytesFromAsset(
          AppHelper.imagePathByStatusName(statusName: vehicle!.Status), 60);
      var markerIcon = BitmapDescriptor.fromBytes(data);

      _markers.add(
        Marker(
          markerId: MarkerId(vehicle.Vehicleid.toString()),
          position: LatLng(vehicle.lat!, vehicle.lon!),
          infoWindow: InfoWindow(
            title: vehicle.VehicleNo,
            snippet: vehicle.tracktime,
          ),
          icon: markerIcon,

          // BitmapDescriptor.fromBytes(customMarker),
          onTap: () => onTapMarker(vehicleId: vehicle.Vehicleid),
        ),
      );
    }
    _filterMarkers = _markers;
    notifyListeners();
  }

  void updateMarker() async {
    //* this methode is used to update marker whenever there is change in vehicle data.
    var myMarker = <Marker>{};
    for (var vehicle in vehicleList!) {
      var res = _markers.firstWhere(
          (element) => element.markerId.value == vehicle!.Vehicleid.toString(),
          orElse: () => const Marker(markerId: MarkerId('-1')));
      if (res.mapsId.value != '-1') {
        final Uint8List data = await AppHelper.getBytesFromAsset(
            AppHelper.imagePathByStatusName(statusName: vehicle!.Status), 60);
        var markerIcon = BitmapDescriptor.fromBytes(data);
        // log("Before");
        // log(res.infoWindow.snippet.toString());
        res = res.copyWith(
          positionParam: LatLng(vehicle.lat!, vehicle.lon!),
          infoWindowParam:
              InfoWindow(title: vehicle.VehicleNo, snippet: vehicle.tracktime),
          iconParam: markerIcon,
        );
        // log("After");
        // log(res.infoWindow.snippet.toString());
        myMarker.add(res);
        notifyListeners();
      }
    }

    _overviewMarkers = _filterMarkers = _markers = myMarker;

    if (statusName != null) showMarkersByStatusName(status: statusName);
    // if (_isFilterApplied) {
    //   //* if filter is applied then dont add the latest data in _filterMarkers otherwise it will remove filtered marker and show all markers
    //   _filterMarkers = _markers;
    // }
    notifyListeners();
  }

  // updateMarkerInfoWindowById({String? markerId}){
  //   var res = _markers.firstWhere((element) => element.markerId.value==markerId);

  // }

  resetMarkers() {
    //* for shwowing all status markers.
    _filterMarkers = markers;
    notifyListeners();
  }

  resetStatusName() {
    statusName = null;
  }

  showMarkersByStatusName({String? status}) {
    //* this method will show only specific markers based on status you provided.
    _filterMarkers = markers;
    statusName = status;
    if (status == null) return;
    final vehicles = vehicleList!.where((element) {
      return AppHelper.returnJapaneseText(title: element!.Status) == status;
    });
    print(vehicles.length);
    _filterMarkers.retainWhere(
      (marker) => vehicles
          .map((e) => e!.Vehicleid)
          .contains(int.tryParse(marker.markerId.value)),
    ); //* here i am filterring vehicles by its vehicleId
    print('markers length');
    print(_filterMarkers.length);
    notifyListeners();
  }

  updateHistoryTrack(
      {required VehicleHistoryTrackModelDataVehicleHistory? data}) {
    try {
      _historyCurrentLocation = LatLng(data!.lat!, data.lon!);
      _markerRotation = data.direction!.toDouble();
      _movingVehicleDetail = data;
      notifyListeners();
    } catch (err) {
      debugPrint(err.toString());
    }
  }

  // set updateMarker(Set<Marker> value) {
  //   _markers = value;
  //   // notifyListeners();
  // }

  // generateMarker({required BuildContext context}) {
  //   final _markerList = <Marker>{};
  //   for (var vehicle in vehicleList!) {
  //     _markerList.add(
  //       Marker(
  //           markerId: MarkerId(vehicle!.Vehicleid.toString()),
  //           position: LatLng(vehicle.lat!, vehicle.lon!),
  //           infoWindow: InfoWindow(title: vehicle.VehicleNo),
  //           onTap: () {
  //             showModalBottomSheet<void>(
  //               // context and builder are
  //               // required properties in this widget
  //               context: context,
  //               builder: (BuildContext context) {
  //                 // we set up a container inside which
  //                 // we create center column and display text

  //                 // Returning SizedBox instead of a Container
  //                 return SizedBox(
  //                   height: 200,
  //                   child: Center(
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.center,
  //                       children: const <Widget>[
  //                         Text('GeeksforGeeks'),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               },
  //             );
  //           }),
  //     );
  //   }
  //   _markers = _markerList;
  //   if (_markers.isNotEmpty) {
  //     _currentLocation = _markers.first.position;
  //   }
  //   notifyListeners();
  // }

  // removeMarker() {
  //   _markers.remove(_markers.last);
  //   notifyListeners();
  // }

  // Future<void> moveCamera() async {
  //   _cameraController = await _controller.future;
  //   // for (var vehicle in widget.markerList) {
  //   //   await _cameraController
  //   //       .showMarkerInfoWindow(MarkerId(vehicle!.vehicleId.toString()));
  //   // }

  //   await Future.delayed(const Duration(seconds: 1));

  //   var data = await _cameraController.getVisibleRegion();
  //   await _cameraController
  //       .animateCamera(CameraUpdate.newLatLngBounds(data, 50.0));
  //   notifyListeners();
  // }

  onTapMarker({required int? vehicleId}) {
    final vehicle = getVehicleById(vehicleId: vehicleId);
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
            title: vehicle.speed.toString()),
      if (vehicle.speed != null)
        ButtonListModel(
          icon: SvgPicture.asset(
            'assets/icons/ignition.svg',
            height: 3.h,
            color: Global.savedPrimeryColor,
          ),
          title: vehicle.ignition.toString() == "0" ? 'OFF' : 'ON',
        ),
      if (vehicle.odometer != null)
        ButtonListModel(
            icon: SvgPicture.asset(
              'assets/icons/odometer.svg',
              height: 3.h,
              color: Global.savedPrimeryColor,
            ),
            title: "${vehicle.odometer} ${LocaliazationKey.miles.tr()}"),
      if (vehicle.EngineOffdelay != null)
        ButtonListModel(
            icon: SvgPicture.asset(
              'assets/icons/enginedelay.svg',
              height: 3.h,
              color: Global.savedPrimeryColor,
            ),
            title: vehicle.EngineOffdelay.toString()),
      if (vehicle.idleduration != null)
        ButtonListModel(
            icon: SvgPicture.asset(
              'assets/icons/idle-duration.svg',
              height: 3.h,
              // colorFilter: ColorFilter.mode(
              //     Theme.of(context).colorScheme.primary, BlendMode.colorBurn),
              color: Global.savedPrimeryColor,
            ),
            title: vehicle.idleduration.toString()),
      if (vehicle.stopduration != null)
        ButtonListModel(
            icon: Icon(
              Icons.power_off_rounded,
              color: Global.savedPrimeryColor,
            ),
            title: vehicle.stopduration.toString()),
    ];
// navigatorKey.currentContext;
    return showModalBottomSheet<void>(
      context: navigatorKey.currentContext!,
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
                    color: Theme.of(context).cardColor,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
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
                              title: vehicle.Status.toString(),
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            )),
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              "${LocaliazationKey.vehicle_status.tr()} : ",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                            Expanded(
                              child: Text(
                                AppHelper.returnJapaneseText(
                                  title: vehicle.Status.toString(),
                                ),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16),
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
                                vehicle.VehicleNo.toString(),
                                style: AppStyles.textStyle4(
                                    context: context, isBold: true, size: 20),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            // fit: FlexFit.tight,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                vehicle.tracktime.toString(),
                                style: AppStyles.textStyle5(context: context),
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          vehicle.location.toString(),
                          style:
                              AppStyles.textStyle4(context: context, size: 16),
                        ),
                      ),
                      SizedBox(
                        width: SizerUtil.width,
                        height: 9.h,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
}
