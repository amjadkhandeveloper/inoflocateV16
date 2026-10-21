// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/screens/vehicle_statuswise_list/controller/vehicle_status_provider.dart';
import 'package:infolocate/screens/vehicle_statuswise_list/widget/history_track_map.dart';
import 'package:infolocate/screens/vehicle_statuswise_list/model/vehicle_status_request_model.dart';
import 'package:infolocate/screens/vehicle_statuswise_list/model/vehicle_status_response_model.dart';
import 'package:infolocate/screens/vehicle_statuswise_list/repository/vehicle_status_repo.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/enums.dart';
import 'package:infolocate/widgets/buttons/custom_button.dart';
import 'package:infolocate/widgets/custom_toast.dart';
import 'package:infolocate/widgets/searchable_vehicle_dropdown.dart';
import 'package:provider/provider.dart';

import '../../../animation/custom_fade_animation.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/app_globals.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/app_ui.dart';
import '../../../widgets/error_widget.dart';
import '../model/history_track_request_model.dart';
import '../model/history_track_response_model.dart';

class HistoryTrackWidget extends StatefulWidget {
  const HistoryTrackWidget({super.key});

  @override
  State<HistoryTrackWidget> createState() => _HistoryTrackWidgetState();
}

class _HistoryTrackWidgetState extends State<HistoryTrackWidget> {
  String fromDateTime = "yyyy-mm-dd hh:mm:ss";
  String toDateTime = "yyyy-mm-dd hh:mm:ss";
  TimeOfDay selectedTime = TimeOfDay.now();
  int? vehicleId;
  int? userId;
  bool _loadingVehicles = true;
  String? _vehicleLoadError;
  List<VehicleStatusResponseModelDataVehicleStatusdetails> _vehicles = [];

  String? selectedValue;
  @override
  void initState() {
    super.initState();
    userId = Global.savedUserAuthData!.userid!.toInt();
    Future.delayed(Duration.zero, () => getData());
  }

  _datePicker() async {
    const Locale enLocale = Locale('en', 'US');
    final nowDate = DateTime.now();
    final result = await showDatePicker(
        builder: (context, child) => CustomFadeScaleTransition(
            duration: const Duration(milliseconds: 400), child: child),
        context: context,
        initialDate: nowDate,
        firstDate: nowDate.subtract(const Duration(days: 94)),
        lastDate: nowDate,
        cancelText: LocaliazationKey.cancel.tr(),
        confirmText: LocaliazationKey.ok.tr(),
        helpText: LocaliazationKey.select_date.tr(),
        locale: enLocale);
    if (result == null) return;
    log(result.toLocal().toString());
    var newDate = DateFormat('yyyy-MM-dd').format(result);
    final selected = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: CustomFadeScaleTransition(
              duration: const Duration(milliseconds: 400), child: child),
        );
      },
    );

    if (selected == null) return;
    final minute = selected.minute.toString().padLeft(2, '0');
    final time = "${selected.hour}:$minute:00";
    log("Time $time");
    newDate = "$newDate $time";
    fromDateTime = newDate;
    log("DateTime $fromDateTime");
    setState(() {});
  }

  _datePicker2() async {
    final nowDate = DateTime.now();
    final result = await showDatePicker(
      context: context,
      initialDate: nowDate,
      firstDate: nowDate.subtract(const Duration(days: 94)),
      lastDate: nowDate,
      cancelText: LocaliazationKey.cancel.tr(),
      confirmText: LocaliazationKey.ok.tr(),
      helpText: LocaliazationKey.select_date.tr(),
      locale: enLocale,
    );
    if (result == null) return;
    log(result.toLocal().toString());
    var newDate = DateFormat('yyyy-MM-dd').format(result);
    final selected = await showTimePicker(
      context: context,
      initialTime: selectedTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selected == null) return;
    final minute = selected.minute.toString().padLeft(2, '0');
    final time = "${selected.hour}:$minute:00";
    log("Time $time");
    newDate = "$newDate $time";
    toDateTime = newDate;
    log("DateTime $toDateTime");
    setState(() {});
  }

  getData() async {
    setState(() {
      _loadingVehicles = true;
      _vehicleLoadError = null;
    });
    try {
      final result = await VehicleStatusService().getVehicleList(
        vehicleStatusWiseListRequestModel: VehicleStatusWiseListRequestModel(
          userId: userId!,
          statusId: 6,
          pSize: 0,
          pNo: defaultPageN0,
          sSearch: '',
        ),
      );
      _vehicles = (result?.vehicleStatusdetails ?? [])
          .whereType<VehicleStatusResponseModelDataVehicleStatusdetails>()
          .where((vehicle) => (vehicle.VehicleNo ?? '').trim().isNotEmpty)
          .toList()
        ..sort((a, b) => (a.VehicleNo ?? '')
            .toLowerCase()
            .compareTo((b.VehicleNo ?? '').toLowerCase()));
      selectedValue = null;
      vehicleId = null;
    } catch (error) {
      _vehicleLoadError = error.toString();
    }
    if (mounted) {
      setState(() => _loadingVehicles = false);
    }
  }

  bool endTimeAlwaysGreater(String startStr, String endStr) {
    DateTime startTime = DateTime.parse(startStr);
    DateTime endTime = DateTime.parse(endStr);

    // Check if endTime is greater than startTime
    if (endTime.isBefore(startTime)) {
      return false;
    }
    return true;
  }

  bool checkTimeDifference(String startStr, String endStr) {
    DateTime startTime = DateTime.parse(startStr);
    DateTime endTime = DateTime.parse(endStr);

    Duration difference = endTime.difference(startTime);
    // Check if difference is greater than 48 hours
    if (difference.inHours > 48) {
      return false;
    }
    return true;
  }

  List<VehicleHistoryTrackModelDataVehicleHistory> removeDuplicate(
      {required List<VehicleHistoryTrackModelDataVehicleHistory?>? list}) {
    final originalList = (list ?? [])
        .whereType<VehicleHistoryTrackModelDataVehicleHistory>()
        .where((e) => AppHelper.isValidLatLng(e.lat, e.lon))
        .toList();
    log('length before filter ${list?.length ?? 0}');
    log('length after valid coords ${originalList.length}');

    final seen = <String>{};
    final filterList = <VehicleHistoryTrackModelDataVehicleHistory>[];
    for (final point in originalList) {
      final key =
          '${point.lat!.toStringAsFixed(6)},${point.lon!.toStringAsFixed(6)}';
      if (seen.add(key)) {
        filterList.add(point);
      }
    }
    log('length after unique lat/lon ${filterList.length}');
    return filterList;
  }

  @override
  Widget build(BuildContext context) {
    final vehicleStatusState = Provider.of<VehicleStatusProvider>(context);

    return Scaffold(
      backgroundColor: AppUi.pageBg(context),
      appBar: AppUi.appBar(
        context: context,
        title: LocaliazationKey.track_history.tr(),
      ),
      body: _loadingVehicles
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _vehicleLoadError != null
              ? CustomErrorWidget(
                  onPressed: getData,
                  errorMsg: _vehicleLoadError!,
                )
              : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 14,
                              top: 14,
                            ),
                            child: Text(
                              "${LocaliazationKey.all_vehicles.tr()}:",
                              style: AppStyles.textStyle4(
                                  context: context, size: 16),
                            ),
                          ),
                          SearchableVehicleDropdown<String>(
                            items: _vehicles
                                .map((e) => e.VehicleNo.toString())
                                .toList(),
                            selectedItem: selectedValue,
                            itemAsString: (value) => value,
                            onChanged: (value) {
                              setState(() {
                                selectedValue = value;
                                final match = _vehicles.where(
                                  (vehicle) => vehicle.VehicleNo == value,
                                );
                                vehicleId = match.isEmpty
                                    ? null
                                    : match.first.Vehicleid;
                                log("Vehicle Id: $vehicleId");
                              });
                            },
                          ),

                          Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                    "${LocaliazationKey.from_date_time.tr()}: "),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _datePicker();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppUi.line(context),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Row(
                                        children: [
                                          Expanded(
                                              flex: 9,
                                              child: Text(fromDateTime)),
                                          const Expanded(
                                              flex: 1,
                                              child: Icon(Icons.calendar_month))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("${LocaliazationKey.to_date_time.tr()}: "),
                                const SizedBox(
                                  height: 8,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _datePicker2();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: AppUi.line(context),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Expanded(
                                              flex: 9, child: Text(toDateTime)),
                                          const Expanded(
                                              flex: 1,
                                              child: Icon(Icons.calendar_month))
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          vehicleStatusState.state == NotifierState.loading
                              ? const Center(child: CircularProgressIndicator())
                              : Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: CustomButton(
                                    onPressed: () async {
                                      if (selectedValue == null ||
                                          selectedValue!.trim().isEmpty ||
                                          vehicleId == null) {
                                        customToast(
                                            message: LocaliazationKey
                                                .please_select_vehicle_no
                                                .tr());
                                        return;
                                      }
                                      if (fromDateTime ==
                                          "yyyy-mm-dd hh:mm:ss") {
                                        customToast(
                                            message: LocaliazationKey
                                                .please_select_from_date_and_time
                                                .tr());
                                        return;
                                      }
                                      if (toDateTime == "yyyy-mm-dd hh:mm:ss") {
                                        customToast(
                                            message: LocaliazationKey
                                                .please_select_to_date_and_time
                                                .tr());
                                        return;
                                      }

                                      DateFormat format =
                                          DateFormat("yyyy-MM-dd HH:mm:ss");
                                      DateTime fromDate =
                                          format.parse(fromDateTime);
                                      DateTime toDate =
                                          format.parse(toDateTime);
                                      if (fromDate.isAfter(
                                        DateTime.now(),
                                      )) {
                                        customToast(
                                          message: LocaliazationKey
                                              .selected_from_time_should_not_greater_than_current_time
                                              .tr(),
                                        );
                                        return;
                                      }
                                      if (toDate.isAfter(
                                        DateTime.now(),
                                      )) {
                                        customToast(
                                          message: LocaliazationKey
                                              .selected_to_time_should_not_greater_than_current_time
                                              .tr(),
                                        );
                                        return;
                                      }
                                      if (fromDate.isAfter(toDate)) {
                                        // Condition satisfied
                                        customToast(
                                          message: LocaliazationKey
                                              .please_select_proper_date_time
                                              .tr(),
                                        );
                                        return;
                                      }
                                      if (toDate.difference(fromDate).inHours >=
                                          24) {
                                        // Condition not
                                        customToast(
                                            message: LocaliazationKey
                                                .time_difference_should_not_be_greater_than_24hours
                                                .tr());
                                        return;
                                      }
                                      // }
                                      print(userId);
                                      print(vehicleId);
                                      print(fromDateTime);
                                      print(toDateTime);
                                      HistoryTrackRequestModel
                                          videoPlayBackRequestModel =
                                          HistoryTrackRequestModel(
                                              UserId: userId!.toInt(),
                                              VehicleID: vehicleId!.toInt(),
                                              // VehicleID: 14,
                                              FromDatetime: fromDateTime,
                                              ToDatetime: toDateTime);

                                      await vehicleStatusState
                                          .getVehicleHistoryTrack(
                                              vehicleHistoryTrackRequestModel:
                                                  videoPlayBackRequestModel);

                                      final historyPoints = removeDuplicate(
                                        list: vehicleStatusState
                                            .historyTrackList,
                                      );
                                      if (historyPoints.isEmpty) {
                                        if ((vehicleStatusState
                                                    .historyTrackList ??
                                                [])
                                            .isNotEmpty) {
                                          customToast(
                                            message: LocaliazationKey
                                                .location_unavailable
                                                .tr(),
                                          );
                                        }
                                        return;
                                      }
                                      if (mounted) {
                                        log('history points ${historyPoints.length}');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                VehicleHistoryTrackScreen(
                                              historyTrackList: historyPoints,
                                            ),
                                          ),
                                        );
                                      }

                                      // await videoPlayBackState.generateVideoPlayback(
                                      //     videoPlayBackRequestModel);
                                      // final playBackUrl =
                                      //     videoPlayBackState.playBackUrl;

                                      // Navigator.pop(
                                      //     context, videoPlayBackRequestModel);
                                    },
                                    title: LocaliazationKey.track_vehicle.tr(),
                                  ),
                                ),
                        ],
                      ),
                    ),
    );
  }
}
