// ignore_for_file: use_build_context_synchronously
import 'dart:developer';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/screens/video_playback/controller/video_playback_provider.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/enums.dart';
import 'package:infolocate/widgets/custom_toast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../animation/custom_fade_animation.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/app_globals.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/app_ui.dart';
import '../../../widgets/custom_webview.dart';
import '../../../widgets/error_widget.dart';
import '../model/video_playback_request_model.dart';
import '../model/video_vehicle_list_response_model.dart';

class VideoPlayBackScreen extends StatefulWidget {
  const VideoPlayBackScreen({Key? key}) : super(key: key);

  @override
  State<VideoPlayBackScreen> createState() => _VideoPlayBackScreenState();
}

class _VideoPlayBackScreenState extends State<VideoPlayBackScreen> {
  String fromDateTime = "yyyy-mm-dd hh:mm:ss";
  String toDateTime = "yyyy-mm-dd hh:mm:ss";
  TimeOfDay selectedTime = TimeOfDay.now();
  int? userId;
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
  }

  Future<void> _onGenerate(VideoPlayBackProvider videoPlayBackState) async {
    final selected = videoPlayBackState.selectedVehicle;
    if (selected == null || selected.VehicleId == null) {
      customToast(message: LocaliazationKey.please_select_vehicle_no.tr());
      return;
    }
    if (fromDateTime == "yyyy-mm-dd hh:mm:ss") {
      customToast(
          message: LocaliazationKey.please_select_from_date_and_time.tr());
      return;
    }
    if (toDateTime == "yyyy-mm-dd hh:mm:ss") {
      customToast(
          message: LocaliazationKey.please_select_to_date_and_time.tr());
      return;
    }

    final format = DateFormat("yyyy-MM-dd HH:mm:ss");
    final fromDate = format.parse(fromDateTime);
    final toDate = format.parse(toDateTime);
    if (fromDate.isAfter(DateTime.now())) {
      customToast(
        message: LocaliazationKey
            .selected_from_time_should_not_greater_than_current_time
            .tr(),
      );
      return;
    }
    if (toDate.isAfter(DateTime.now())) {
      customToast(
        message: LocaliazationKey
            .selected_to_time_should_not_greater_than_current_time
            .tr(),
      );
      return;
    }
    if (fromDate.isAfter(toDate)) {
      customToast(
        message: LocaliazationKey.please_select_proper_date_time.tr(),
      );
      return;
    }
    if (toDate.difference(fromDate).inMinutes > 1) {
      customToast(
          message: LocaliazationKey
              .time_difference_should_not_be_greater_than_1min
              .tr());
      return;
    }

    await videoPlayBackState.generateVideoPlayback(
      VideoPlayBackRequestModel(
        userId: userId!.toInt(),
        vehicleId: selected.VehicleId,
        startDate: fromDateTime,
        endDate: toDateTime,
      ),
    );
    final playback = videoPlayBackState.playbackVideo;
    final playBackUrl = playback?.Purl?.trim().isNotEmpty == true
        ? playback!.Purl!.trim()
        : videoPlayBackState.playBackUrl;
    if (!mounted || playBackUrl == null || playBackUrl.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          url: playBackUrl,
          title: selected.VehicleNo,
        ),
      ),
    );
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
    final vehicles = videoPlayBackState.allVehicles;

    return Scaffold(
      backgroundColor: AppUi.pageBg(context),
      appBar: AppUi.appBar(
        context: context,
        title: LocaliazationKey.video_playback.tr(),
      ),
      body: videoPlayBackState.state == NotifierState.loading
          ? const Center(
              child: CircularProgressIndicator(color: AppUi.accent),
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
                              "${LocaliazationKey.live_vehicle.tr()}:",
                              style: AppStyles.textStyle4(
                                  context: context, size: 16),
                            ),
                          ),
                          Container(
                            width: 100.w,
                            margin: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppUi.cardColor(context),
                              border: Border.all(color: AppUi.line(context)),
                              borderRadius: BorderRadius.circular(AppUi.radiusSm),
                            ),
                            child: DropdownSearch<VideoVehicleListDataVehicles>(
                              popupProps: PopupProps.menu(
                                showSearchBox: true,
                                showSelectedItems: true,
                                itemBuilder: (context, item, isSelected) {
                                  final enabled = item.isPlaybackEnabled;
                                  return Container(
                                    margin: const EdgeInsets.all(1),
                                    padding: const EdgeInsets.all(12),
                                    color: enabled
                                        ? (AppUi.isDark(context)
                                            ? const Color(0xFF14532D)
                                            : Colors.green.shade200)
                                        : (AppUi.isDark(context)
                                            ? AppUi.pageBg(context)
                                            : Colors.grey.shade300),
                                    child: Text(
                                      item.VehicleNo ?? '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: enabled
                                            ? AppUi.ink(context)
                                            : AppUi.muted(context),
                                      ),
                                    ),
                                  );
                                },
                                searchFieldProps: TextFieldProps(
                                  style: AppUi.body(context),
                                  decoration: AppUi.inputDecoration(
                                    context: context,
                                    hintText: LocaliazationKey.search.tr(),
                                  ),
                                ),
                                disabledItemFn: (item) => !item.isPlaybackEnabled,
                              ),
                              items: vehicles,
                              itemAsString: (item) => item.VehicleNo ?? '',
                              compareFn: (a, b) => a.VehicleId == b.VehicleId,
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                baseStyle: AppUi.body(context).copyWith(fontSize: 16),
                                dropdownSearchDecoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(
                                      left: 12, top: 12, bottom: 12),
                                  hintText: LocaliazationKey.select.tr(),
                                  hintStyle: AppUi.mutedStyle(context),
                                ),
                              ),
                              onChanged: videoPlayBackState.selectVehicle,
                              selectedItem: videoPlayBackState.selectedVehicle,
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
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: AppUi.primaryButton(
                              title: LocaliazationKey.generate.tr(),
                              loading: videoPlayBackState.isGenerating,
                              onPressed: videoPlayBackState.isGenerating
                                  ? null
                                  : () => _onGenerate(videoPlayBackState),
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
