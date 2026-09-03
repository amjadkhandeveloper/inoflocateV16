// ignore_for_file: use_build_context_synchronously
import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
import '../../../widgets/custom_webview.dart';
import '../../../widgets/error_widget.dart';
import '../model/video_playback_request_model.dart';

class VideoPlayBackScreen extends StatefulWidget {
  const VideoPlayBackScreen({Key? key}) : super(key: key);

  @override
  State<VideoPlayBackScreen> createState() => _VideoPlayBackScreenState();
}

class _VideoPlayBackScreenState extends State<VideoPlayBackScreen> {
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
    final nowDate = DateTime.now();
    final result = await showDatePicker(
      builder: (context, child) => CustomFadeScaleTransition(
          duration: const Duration(milliseconds: 400), child: child),
      context: context,
      initialDate: nowDate,
      firstDate: nowDate.subtract(const Duration(days: 7)),
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
      builder: (context, child) => CustomFadeScaleTransition(
          duration: const Duration(milliseconds: 400), child: child),
      context: context,
      initialDate: nowDate,
      firstDate: nowDate.subtract(const Duration(days: 7)),
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

  // bool endTimeAlwaysGreater(String startStr, String endStr) {
  //   DateTime startTime = DateTime.parse(startStr);
  //   DateTime endTime = DateTime.parse(endStr);

  //   // Check if endTime is greater than startTime
  //   if (endTime.isBefore(startTime)) {
  //     return false;
  //   }
  //   return true;
  // }

  // bool checkTimeDifference(String startStr, String endStr) {
  //   DateTime startTime = DateTime.parse(startStr);
  //   DateTime endTime = DateTime.parse(endStr);

  //   Duration difference = endTime.difference(startTime);
  //   // Check if difference is greater than 48 hours
  //   if (difference.inHours > 48) {
  //     return false;
  //   }
  //   return true;
  // }

  @override
  Widget build(BuildContext context) {
    final videoPlayBackState = Provider.of<VideoPlayBackProvider>(context);
    final data = videoPlayBackState.allVehicles;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocaliazationKey.video_playback.tr()),
      ),
      body: videoPlayBackState.state == NotifierState.loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : videoPlayBackState.state != NotifierState.error
              ? data == null
                  ? Container()
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
                              "${LocaliazationKey.live_vehicle.tr()}:",
                              style: AppStyles.textStyle4(
                                  context: context, size: 16),
                            ),
                          ),
                          Container(
                            // height: 42,
                            width: 100.w,
                            margin: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownSearch<String>(
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                showSelectedItems: true,
                                itemBuilder: (context, item, isSelected) {
                                  Color color = Colors.white;
                                  Color textColor = Colors.black;
                                  for (var element in data) {
                                    print("Element ${element!.VehicleNo}, ${element.deviceType}, ${element.DelayEnable}");
                                    if (element.VehicleNo == item) {
                                      if (element.DelayEnable! <= 0 &&
                                          element.DelayEnable != null
                                      //     || element.deviceType != "MDVR"
                                      ) {
                                        color = Colors.grey.shade300;
                                        textColor = Colors.grey;
                                      } else {
                                        color = Colors.green.shade200;
                                        textColor = Colors.black;
                                      }
                                    }
                                  }
                                  return Container(
                                    margin: const EdgeInsets.all(1),
                                    padding: const EdgeInsets.all(4),
                                    color: color,
                                    // height: 30,
                                    // width: 150,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        item,
                                        style: TextStyle(
                                            fontSize: 16, color: textColor),
                                      ),
                                    ),
                                  );
                                },
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
                                disabledItemFn: (String s) {
                                  // final item = data.firstWhere((element) => element!['VehicleNo'] == s, orElse: () => null);
                                  // return item?['DelayEnable'] >= 0;

                                  final item = data.firstWhere((element) =>
                                  element!["VehicleNo"].toString() == s);
                                  final delayEnable = item!["DelayEnable"];
                                  return delayEnable != null &&
                                      delayEnable <= 0;

                                },
                              ),
                              items: data
                                  .map((e) => e!.VehicleNo.toString())
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
                                        color: Colors.grey,
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
                                        color: Colors.grey,
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
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: CustomButton(
                              onPressed: () async {
                                if (selectedValue!
                                    .contains(LocaliazationKey.select.tr())) {
                                  customToast(
                                      message: LocaliazationKey
                                          .please_select_vehicle_no
                                          .tr());
                                  return;
                                }
                                if (fromDateTime == "yyyy-mm-dd hh:mm:ss") {
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
                                DateTime fromDate = format.parse(fromDateTime);
                                DateTime toDate = format.parse(toDateTime);
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
                                if (toDate.difference(fromDate).inMinutes > 1) {
                                  // Condition not
                                  // customToast(
                                  //     message: LocaliazationKey
                                  //         .time_difference_should_not_be_greater_than_24hours
                                  //         .tr());
                                  customToast(
                                      message: LocaliazationKey
                                          .time_difference_should_not_be_greater_than_1min
                                          .tr());
                                  return;
                                }
                                // if (endTimeAlwaysGreater(
                                //         fromDateTime, toDateTime) ==
                                //     false) {
                                //   customToast(
                                //       message:
                                //           "Please select proper date time");
                                //   return;
                                // }
                                // if (checkTimeDifference(
                                //         fromDateTime, toDateTime) ==
                                //     false) {
                                //   customToast(
                                //       message:
                                //           "Time difference should not be greater than 48hours");
                                //   return;
                                // }
                                print(userId);
                                print(vehicleId);
                                print(fromDateTime);
                                print(toDateTime);
                                VideoPlayBackRequestModel
                                    videoPlayBackRequestModel =
                                    VideoPlayBackRequestModel(
                                        userId: userId!.toInt(),
                                        vehicleId: vehicleId!.toInt(),
                                        startDate: fromDateTime,
                                        endDate: toDateTime);

                                await videoPlayBackState.generateVideoPlayback(
                                    videoPlayBackRequestModel);
                                final playBackUrl =
                                    videoPlayBackState.playBackUrl;
                                if (playBackUrl != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoPlayerScreen(
                                        url: playBackUrl,
                                        title: selectedValue,
                                      ),
                                    ),
                                  );
                                }
                              },
                              title: LocaliazationKey.generate.tr(),
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
