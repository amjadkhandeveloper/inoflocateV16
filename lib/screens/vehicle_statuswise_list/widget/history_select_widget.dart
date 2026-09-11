// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infolocate/screens/vehicle_statuswise_list/controller/vehicle_status_provider.dart';
import 'package:infolocate/screens/vehicle_statuswise_list/widget/history_track_map.dart';
import 'package:infolocate/screens/video_playback/controller/video_playback_provider.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/enums.dart';
import 'package:infolocate/widgets/buttons/custom_button.dart';
import 'package:infolocate/widgets/custom_toast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

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
    final videoPlayBackState =
        Provider.of<VideoPlayBackProvider>(context, listen: false);
    await videoPlayBackState.getVehicleList();
    // selectedValue = videoPlayBackState.allVehicles!.first!.VehicleNo.toString();
    selectedValue = LocaliazationKey.select.tr();
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

  List<VehicleHistoryTrackModelDataVehicleHistory?>? removeDuplicate(
      {required List<VehicleHistoryTrackModelDataVehicleHistory?>? list}) {
    log('length before filter');
    final originalList = list;
    log(originalList!.length.toString());
    log('length after filter');
    var filteredLatLon =
        originalList.map((e) => LatLng(e!.lat!, e.lon!)).toSet().toList();

    List<VehicleHistoryTrackModelDataVehicleHistory?>? filterList = [];
    for (var element in filteredLatLon) {
      filterList.add(
          originalList.firstWhere((e) => LatLng(e!.lat!, e.lon!) == element));
    }
    // originalList.retainWhere((element) =>
    //     filteredLatLon.contains(LatLng(element!.lat!, element.lon!)));
    log(filterList.length.toString());
    return filterList;
  }

  @override
  Widget build(BuildContext context) {
    final videoPlayBackState = Provider.of<VideoPlayBackProvider>(context);
    final vehicleStatusState = Provider.of<VehicleStatusProvider>(context);
    final data = videoPlayBackState.allVehicles;

    return Scaffold(
      backgroundColor: AppUi.pageBg(context),
      appBar: AppUi.appBar(
        context: context,
        title: LocaliazationKey.track_history.tr(),
      ),
      body: videoPlayBackState.state == NotifierState.loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : videoPlayBackState.state != NotifierState.error
              ? SingleChildScrollView(
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
                          Container(
                            // height: 40,
                            width: 100.w,
                            margin: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppUi.line(context)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownSearch<String>(
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                showSelectedItems: true,
                                searchFieldProps: TextFieldProps(
                                  decoration:
                                      AppStyles.inputFieldStyle().copyWith(
                                    hintText: LocaliazationKey.search.tr(),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 2),
                                    ),
                                  ),
                                ),
                              ),
                              items: data
                                  .map((e) => e.VehicleNo.toString())
                                  .toList(),
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                // textAlign: TextAlign.left,
                                baseStyle: const TextStyle(
                                  fontSize: 18,
                                ),
                                dropdownSearchDecoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.only(left: 8, top: 12),
                                  hintText: LocaliazationKey.select.tr(),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value ?? "";
                                  if (selectedValue !=
                                      LocaliazationKey.select.tr()) {
                                    vehicleId =
                                        videoPlayBackState.returnVehicleId(
                                            vehicleNo:
                                                selectedValue.toString());
                                    log("Vehicle Id: $vehicleId");
                                  }
                                });
                              },
                              selectedItem: selectedValue,
                            ),
                          ),
                          // Container(
                          //   height: 45,
                          //   width: 100.w,
                          //   margin: const EdgeInsets.all(14),
                          //   decoration: BoxDecoration(
                          //     border: Border.all(color: Colors.grey),
                          //     borderRadius: BorderRadius.circular(8),
                          //   ),
                          //   child: Padding(
                          //     padding: const EdgeInsets.all(8.0),
                          //     child: DropdownButton<String>(
                          //       underline: Container(),
                          //       value: selectedValue,
                          //       isExpanded: true,
                          //       elevation: 2,
                          //       // iconEnabledColor: Colors.black,
                          //       items: data
                          //           .map((e) => e!.VehicleNo.toString())
                          //           .map<DropdownMenuItem<String>>(
                          //               (String value) {
                          //         return DropdownMenuItem<String>(
                          //           value: value,
                          //           child: Text(
                          //             value,
                          //             style: AppStyles.textStyle4(
                          //               context: context,
                          //             ),
                          //           ),
                          //         );
                          //       }).toList(),
                          //       hint: const Text(
                          //         select,
                          //       ),
                          //       onChanged: (value) {
                          //         setState(() {
                          //           selectedValue = value ?? "";
                          //           if (selectedValue != select) {
                          //             vehicleId =
                          //                 videoPlayBackState.returnVehicleId(
                          //                     vehicleNo:
                          //                         selectedValue.toString());
                          //             log("Vehicle Id: $vehicleId");
                          //           }
                          //         });
                          //       },
                          //     ),
                          //   ),
                          // ),

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
                                      if (selectedValue!.contains(
                                          LocaliazationKey.select.tr())) {
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

                                      if (vehicleStatusState.state !=
                                              NotifierState.error &&
                                          vehicleStatusState
                                              .historyTrackList!.isNotEmpty) {
                                        // final data = vehicleStatusState
                                        //     .historyTrackList!;
                                        if (mounted) {
                                          log('length before set()');
                                          log(vehicleStatusState
                                              .historyTrackList!.length
                                              .toString());
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    VehicleHistoryTrackScreen(
                                                        historyTrackList:
                                                            removeDuplicate(
                                                                list: vehicleStatusState
                                                                    .historyTrackList)),
                                              ));
                                        }
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
                    )
              : CustomErrorWidget(
                  onPressed: () {
                    getData();
                  },
                  errorMsg: videoPlayBackState.failure.message,
                ),
    );
  }
}
