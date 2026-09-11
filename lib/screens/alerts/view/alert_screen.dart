import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infolocate/animation/custom_fade_animation.dart';
import 'package:infolocate/screens/alerts/controller/alert_provider.dart';
import 'package:infolocate/screens/alerts/model/alert_list_request_model.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/app_extensions.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_styles.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:infolocate/utils/enums.dart';
import 'package:infolocate/widgets/buttons/custom_button.dart';
import 'package:infolocate/widgets/custom_dropdown.dart';
import 'package:infolocate/widgets/error_widget.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/app_helper.dart';
import '../../../widgets/cards/pin_vehicle_card.dart';
import '../../../widgets/custom_search_widget.dart';
import '../../../widgets/custom_shimmer_effects.dart';
import '../../../widgets/custom_toast.dart';
import '../../../widgets/google_map/map_model.dart';
import '../../../widgets/page_count_widget.dart';
import '../model/alert_list_response_model.dart';

class AlertDashboardScreen extends StatefulWidget {
  static String routeName = '/alertDashboard';

  const AlertDashboardScreen({super.key, this.alertTypeId});

  final int? alertTypeId;

  @override
  State<AlertDashboardScreen> createState() => _AlertDashboardScreenState();
}

class _AlertDashboardScreenState extends State<AlertDashboardScreen> {
  TimeOfDay? fromTimeObject;
  TimeOfDay? toTimeObject;
  String? fromTime = timeFormat;
  String? toTime = timeFormat;
  final TextEditingController searchCtl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _chipScrollController = ScrollController();

  // final FocusNode _chipFocusNode = FocusNode();
  Timer? _debounce;
  int pageNo = defaultPageN0;
  late AlertListRequestModel? alertListRequestModel;
  String? selectedValue;

  // List<String?> alertDropDown = [allValue];
  // List<ChoiceChipModel> choiceChipList = [ChoiceChipModel(title: allValue)];
  List<DropDownModel?> filterList = [
    // LocaliazationKey.date.tr(),
    // LocaliazationKey.time.tr(),
    // LocaliazationKey.time.tr()
  ];
  String? selectedFilter;
  String? selectedAppBarDropDownValue;

  //  [ChoiceChipModel(title: allValue)];
  bool isFilterselect = false;
  double? chipScrollIndex = 0;
  DateTime? selectedDate;
  bool chooseTime = false;

  // late TimeOfDay? _timeOne;
  // late TimeOfDay? _timeTwo;
  // List<double> scrollOffsetList = [];

  @override
  void initState() {
    filterList = [
      DropDownModel(value: LocaliazationKey.date.tr()),
      // DropDownModel(value: LocaliazationKey.time.tr()),
      DropDownModel(value: LocaliazationKey.clear_filter.tr())
    ];
    alertListRequestModel = AlertListRequestModel(
        pNo: pageNo,
        pSize: pageSize,
        userId: Global.savedUserAuthData!.userid,
        // alertdt: DateTime.now().toLocal().toString(),
        vno: '',
        fromDate: AppHelper.getCustomTimeFormat(dateTime: DateTime.now(), defaultTime: defaultFromTime),
        alertTypeId: 0,
        toDate: AppHelper.getCustomTimeFormat(dateTime: DateTime.now(), defaultTime: defaultToTime));
    // selectedFilter = choiceChipList[0].title;
    // selectedValue = alertDropDown[0];
    Future.delayed(Duration.zero, () => getAlerts());

    super.initState();
  }

  _onSearchChanged(String query) {
    final alertState = Provider.of<AlertProvider>(context, listen: false);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      alertListRequestModel!.vno = searchCtl.text;
      pageNo = alertListRequestModel!.pNo = defaultPageN0;
      alertListRequestModel!.pSize = maxPageSize; //* fetch max 100 records only for search filter
      alertState.onSearchChange(keyWord: query, alertListRequestModel: alertListRequestModel!);
      alertListRequestModel!.pNo = alertListRequestModel!.pNo! + 1;
    });
  }

  // handleScroll({required AlertProvider alertState}) {  //*commented
  //   _scrollController.addListener(() {
  //     if (_scrollController.position.pixels ==
  //             _scrollController.position.maxScrollExtent &&
  //         alertState.isMoreDataLoading == false &&
  //         searchCtl.text.isEmpty) {
  //       //* if search field is empty then only load more data,other wise it will add duplicate data while u pull down after search so i i am checking searchCtl.text.isEmpty
  //       log('need to load items');
  //       loadMoreData(loadMore: true);
  //     }
  //   });
  // }
  handleScroll({required AlertProvider alertState}) {
    //*commented
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          alertState.isMoreDataLoading == false &&
          alertState.hasMoreData == false) {
        customToast(message: LocaliazationKey.no_more_data.tr());
      }
    });
  }

  getAlerts() async {
    //* this method should only call in init state only once
    final alertState = Provider.of<AlertProvider>(context, listen: false);
    // final dashBoardState =
    //     Provider.of<DashboardProvider>(context, listen: false);
    handleScroll(alertState: alertState);
    alertState.clearAlerts();
    alertListRequestModel!.pNo = defaultPageN0;
    // if (dashBoardState.dashboardResponseModelData != null) {
    //   choiceChipList.addAll(dashBoardState
    //       .dashboardResponseModelData!.StatusCount!
    //       .map((e) => ChoiceChipModel(
    //           alertTypeId: e!.AlertTypeID,
    //           title: AppHelper.returnAlertStatus(alertStatus: e.AlertType))));
    //   if (widget.alertTypeId != null) {
    //     final selectedChip = choiceChipList.firstWhere(
    //         (element) => element.alertTypeId == widget.alertTypeId,
    //         orElse: () => ChoiceChipModel());
    //     if (selectedChip.alertTypeId != null) {
    //       selectedChip.isSelected = true;
    //       alertListRequestModel!.alertTypeId = selectedChip.alertTypeId;
    //       selectedFilter = selectedChip.title;
    //     }
    //   }
    // }

    // selectedFilter = alertState.alertTypesFilterList![0]!.AlertType!;
    if (widget.alertTypeId != null) {
      alertListRequestModel!.alertTypeId = widget.alertTypeId;
    }
    await loadMoreData();
    final types = alertState.alertTypesFilterList ?? [];
    if (widget.alertTypeId != null) {
      final selectedChip = types.cast<AlertListResponseModelDataAlerttypes?>().firstWhere(
          (element) => element?.AlertTypeID == widget.alertTypeId,
          orElse: () => AlertListResponseModelDataAlerttypes());
      if (selectedChip != null && selectedChip.AlertTypeID != null) {
        selectedChip.isSelected = true;
        selectedFilter = selectedChip.AlertType;
      }
    } else if (types.isNotEmpty && types.first?.AlertType != null) {
      selectedFilter = types.first!.AlertType;
    }
  }

  loadMoreData({bool loadMore = false}) async {
    final alertState = Provider.of<AlertProvider>(context, listen: false);
    try {
      await alertState.getAlertList(
        alertListRequestModel: alertListRequestModel!,
        // loadMore: loadMore
      );
      alertListRequestModel!.pNo = alertListRequestModel!.pNo! + 1;
    } catch (e) {
      print(e.toString());
    }
  }

  loadNextPage() async {
    final alertState = Provider.of<AlertProvider>(context, listen: false);
    await alertState.getAlertListInBackground(alertListRequestModel: alertListRequestModel!);
    alertListRequestModel!.pNo = alertListRequestModel!.pNo! + 1;

    // //* for scrolling position
    // if (scrollOffsetList.isEmpty) return;
    // await Future.delayed(Duration(milliseconds: 500));
    // print(_scrollController.position.maxScrollExtent);

    // var newOffset = _scrollController.position.maxScrollExtent -
    //     scrollOffsetList.reduce((value, element) => value + element);
    // newOffset = newOffset - scrollOffsetList.last;
    // print(newOffset);
    // scrollOffsetList.add(newOffset);
    // print(scrollOffsetList.reduce((value, element) => value + element));
  }

  // _onChipSelected({required ChoiceChipModel chip, bool buttonStatus = false}) {
  //   setState(() {
  //     for (var ele in choiceChipList) {
  //       ele.isSelected = false;
  //     }
  //     chip.isSelected = buttonStatus;
  //   });
  //   // searchCtl.clear();
  //   // alertListRequestModel!.alertTypeId = 0;
  //   // alertListRequestModel!.pNo = pageNo = defaultPageN0;
  //   // alertListRequestModel!.vno = '';
  //   resetModel();
  //   if (chip.isSelected == false) {
  //     loadMoreData();
  //     return;
  //   } else {
  //     alertListRequestModel!.alertTypeId = chip.alertTypeId;
  //     loadMoreData();
  //   }
  // }

  resetTime() {
    fromTime = timeFormat;
    toTime = timeFormat;
    fromTimeObject = null;
    fromTimeObject = null;

    for (var element in filterList) {
      if (element!.value == LocaliazationKey.time.tr()) {
        element.isSelected = false;
        setState(() {});
      }
    }
  }

  Future<dynamic> _newDateTimePicker() {
    print(selectedDate);
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState2) {
          Locale enLocale = const Locale('en', 'US');
          return CustomFadeScaleTransition(
            duration: const Duration(milliseconds: 400),
            child: Material(
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.sizeOf(context).height,
                  child: Column(
                    children: [
                      Localizations.override(
                        context: context,
                        locale: enLocale,
                        child: CalendarDatePicker(
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 60)),
                          lastDate: DateTime.now(),
                          onDateChanged: (value) {
                            print(value);
                            selectedDate = value;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 2.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Row(
                          children: [
                            Text(
                              LocaliazationKey.choose_time.tr(),
                              style: AppStyles.textStyle4(context: context, size: 18),
                            ),
                            Checkbox(
                              value: chooseTime,
                              onChanged: (value) {
                                setState2(() {
                                  chooseTime = value!;
                                });
                              },
                            )
                          ],
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Visibility(
                        visible: chooseTime,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocaliazationKey.pick_time_range.tr(),
                                style: AppStyles.textStyle4(context: context, size: 16),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text("${LocaliazationKey.from_time.tr()}: "),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: GestureDetector(
                                        onTap: () async {
                                          var res = await _showTimePicker();
                                          if (res != null) {
                                            fromTime = res.timeOfDayString;
                                            fromTimeObject = res.timeOfDayObject;
                                            setState2(() {});
                                          }
                                          // _datePicker();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Row(
                                              children: [
                                                // Expanded(flex: 8, child: Text(fromTime!)),
                                                Expanded(flex: 8, child: Text(fromTime!)),
                                                const Expanded(flex: 2, child: Icon(Icons.calendar_month))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(14.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(flex: 2, child: Text("${LocaliazationKey.to_time.tr()}: ")),
                                    Expanded(
                                      flex: 3,
                                      child: GestureDetector(
                                        onTap: () async {
                                          var res = await _showTimePicker();
                                          if (res != null) {
                                            toTime = res.timeOfDayString;
                                            toTimeObject = res.timeOfDayObject;
                                            setState2(() {});
                                          }
                                          // _datePicker2();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                // Expanded(flex: 8, child: Text(toTime!)),
                                                Expanded(flex: 8, child: Text(toTime!)),
                                                const Expanded(flex: 2, child: Icon(Icons.calendar_month))
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black54),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: CustomButton(
                                  buttonColor: Colors.white,
                                  textColor: Colors.redAccent,
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  title: LocaliazationKey.cancel.tr(),
                                ),
                              ),
                            ),
                            const Spacer(),
                            Expanded(
                              child: CustomButton(
                                onPressed: () {
                                  selectedDate ??= DateTime.now();

                                  if (chooseTime) {
                                    if (fromTime == timeFormat) {
                                      customToast(message: LocaliazationKey.please_select_from_time.tr());
                                      return;
                                    }
                                    if (toTime == timeFormat) {
                                      customToast(message: LocaliazationKey.please_select_to_time.tr());
                                      return;
                                    }

                                    //  Add Time validation here
                                    if (fromTimeObject == null && fromTimeObject == null) {
                                      return;
                                    }
                                    // print(toTimeObject!.compareToTime(fromTimeObject!));
                                    if (toTimeObject!.compareToTime(fromTimeObject!) == -1) {
                                      customToast(message: LocaliazationKey.from_Time_should_be_less_to_time.tr());
                                      return;
                                    }
                                    var fromDateAndTimeString = AppHelper.getCustomTimeFormat(
                                        dateTime: selectedDate, defaultTime: chooseTime ? fromTime : defaultToTime);
                                    DateTime fromDateAndTime =
                                        DateFormat("yyyy-MM-dd hh:mm:ss").parse(fromDateAndTimeString!);
                                    var toDateAndTimeString = AppHelper.getCustomTimeFormat(
                                        dateTime: selectedDate, defaultTime: chooseTime ? toTime : defaultToTime);
                                    DateTime toDateAndTime =
                                        DateFormat("yyyy-MM-dd hh:mm:ss").parse(toDateAndTimeString!);
                                    print("to Date $toDateAndTimeString");

                                    if (fromDateAndTime.isAfter(DateTime.now())) {
                                      customToast(
                                        message: LocaliazationKey
                                            .selected_from_time_should_not_greater_than_current_time
                                            .tr(),
                                      );
                                      return;
                                    }

                                    if (toDateAndTime.isAfter(DateTime.now())) {
                                      customToast(
                                        message:
                                            LocaliazationKey.selected_to_time_should_not_greater_than_current_time.tr(),
                                      );
                                      return;
                                    }
                                  }
                                  resetModel(
                                      persistAlertId: false); //* its mandatory to reset model data before calling API.
                                  //*commented
                                  // alertListRequestModel!.alertdt = result.toLocal().toString();
                                  // resetTime();
                                  print("Date and Time $selectedDate and $fromTime");
                                  print("Date and Time $selectedDate and $toTime");

                                  alertListRequestModel!.fromDate = AppHelper.getCustomTimeFormat(
                                      dateTime: selectedDate, defaultTime: chooseTime ? fromTime : defaultFromTime);

                                  alertListRequestModel!.toDate = AppHelper.getCustomTimeFormat(
                                      dateTime: selectedDate, defaultTime: chooseTime ? toTime : defaultToTime);
                                  loadMoreData();

                                  Navigator.of(context).pop(selectedDate!.isToday());
                                },
                                title: LocaliazationKey.apply.tr(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 5.h,
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<dynamic> showPickTimeDailog() {
    // fromTime = timeFormat;
    // toTime = timeFormat;

    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState2) {
          return CustomFadeScaleTransition(
            duration: const Duration(milliseconds: 400),
            child: AlertDialog(
              title: Row(
                children: [
                  Expanded(flex: 7, child: Text(LocaliazationKey.pick_time_range.tr())),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(CupertinoIcons.clear),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text("${LocaliazationKey.from_time.tr()}: "),
                          ),
                          Expanded(
                            flex: 3,
                            child: GestureDetector(
                              onTap: () async {
                                var res = await _showTimePicker();
                                if (res != null) {
                                  fromTime = res.timeOfDayString;
                                  fromTimeObject = res.timeOfDayObject;
                                  setState2(() {});
                                }
                                // _datePicker();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Row(
                                    children: [
                                      Expanded(flex: 8, child: Text(fromTime!)),
                                      const Expanded(flex: 2, child: Icon(Icons.calendar_month))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(flex: 2, child: Text("${LocaliazationKey.to_time.tr()}: ")),
                          Expanded(
                            flex: 3,
                            child: GestureDetector(
                              onTap: () async {
                                var res = await _showTimePicker();
                                if (res != null) {
                                  toTime = res.timeOfDayString;
                                  toTimeObject = res.timeOfDayObject;
                                  setState2(() {});
                                }
                                // _datePicker2();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(flex: 8, child: Text(toTime!)),
                                      const Expanded(flex: 2, child: Icon(Icons.calendar_month))
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                CustomButton(
                  onPressed: () {
                    if (fromTime == timeFormat) {
                      customToast(message: LocaliazationKey.please_select_from_time.tr());
                      return;
                    }
                    if (toTime == timeFormat) {
                      customToast(message: LocaliazationKey.please_select_to_time.tr());
                      return;
                    }
                    if (fromTimeObject == null && fromTimeObject == null) {
                      return;
                    }
                    // print(toTimeObject!.compareToTime(fromTimeObject!));
                    if (toTimeObject!.compareToTime(fromTimeObject!) == -1) {
                      customToast(message: LocaliazationKey.from_Time_should_be_less_to_time.tr());
                      return;
                    }
                    Navigator.of(context).pop(true);
                  },
                  title: LocaliazationKey.done.tr(),
                )
              ],
            ),
          );
        });
      },
    );
  }

  Future<TimeModel?> _showTimePicker() async {
    final selected = await showTimePicker(
      builder: (context, child) => CustomFadeScaleTransition(duration: const Duration(milliseconds: 400), child: child),
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selected == null) return null;

    final minute = selected.minute.toString().padLeft(2, '0');
    final time = "${selected.hour.toString().padLeft(2, '0')}:$minute:00";
    print(time);
    return TimeModel(timeOfDayObject: selected, timeOfDayString: time);
  }

  resetModel({bool persistAlertId = false}) {
    searchCtl.clear();
    if (persistAlertId == false) {
      alertListRequestModel!.alertTypeId = 0;
    }
    alertListRequestModel!.pNo = pageNo = defaultPageN0;
    alertListRequestModel!.vno = '';
  }

  @override
  void dispose() {
    searchCtl.dispose();
    _scrollController.dispose();
    _chipScrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertState = Provider.of<AlertProvider>(context);
    // log(alertState.totalCount.toString());
    //  _chipScrollController.animateTo(
    //           3,
    //           curve: Curves.ease,
    //           duration: Duration(seconds: 1),
    //         );
    // final dashBoardState = Provider.of<DashboardProvider>(context);
    // log(DateFormat(DateFormat.YEAR_MONTH_DAY,DateTime.now().toLocal()).locale );

    // log(alertState.filterList!.length.toString());
    // log(alertState.hasMoreData.toString());
    // log(alertState.filterList!.length.toString());
    // log(alertState.alertList!.length.toString());
    // loadMoreData(loadMore: true);
    return Scaffold(
      backgroundColor: AppUi.pageBg(context),
      appBar: AppUi.appBar(
        context: context,
        title: LocaliazationKey.alerts.tr(),
        subtitle: DateFormat("MM/dd/yyyy").format(
            DateTime.parse(alertListRequestModel!.fromDate.toString())),
        actions: [
          if (alertState.state != NotifierState.error)
            CustomDropDownButton(
              onChanged: (value) async {
                // searchCtl.clear();
                // alertListRequestModel!.alertTypeId = 0;
                // alertListRequestModel!.pNo = pageNo = defaultPageN0;
                // alertListRequestModel!.vno = '';
                resetModel(persistAlertId: true);
                //*commented
                // alertListRequestModel!.alertdt =
                //     DateTime.now().toLocal().toString();

                setState(() {
                  selectedValue = value;
                });

                if (value!.contains(LocaliazationKey.clear_filter.tr())) {
                  for (var element in filterList) {
                    element!.isSelected = false;
                  }
                  alertListRequestModel!.fromDate =
                      AppHelper.getCustomTimeFormat(dateTime: DateTime.now(), defaultTime: defaultFromTime);

                  alertListRequestModel!.toDate =
                      AppHelper.getCustomTimeFormat(dateTime: DateTime.now(), defaultTime: defaultToTime);
                  resetModel(persistAlertId: true);
                  selectedDate = null;
                  fromTime = timeFormat;
                  toTime = timeFormat;
                  selectedAppBarDropDownValue = null;

                  loadMoreData();

                  return;
                }
                //  else if (value.contains(LocaliazationKey.time.tr())) {
                //   var res = await showPickTimeDailog();
                //   if (res != null && res == true) {
                //     selectedAppBarDropDownValue = selectedValue;
                //     resetModel(
                //         persistAlertId:
                //             true); //* its mandatory to reset model data before calling API.
                //     alertListRequestModel!.fromDate =
                //         AppHelper.getCustomTimeFormat(
                //             dateTime:
                //                 alertListRequestModel!.fromDate!.toDateTime(),
                //             defaultTime: fromTime);
                //     alertListRequestModel!.toDate = AppHelper.getCustomTimeFormat(
                //         dateTime: alertListRequestModel!.fromDate!.toDateTime(),
                //         defaultTime: toTime);
                //     loadMoreData();
                //     for (var element in filterList) {
                //       if (element!.value == value) {
                //         element.isSelected = true;
                //       }
                //     }
                //   }
                // }
                else if (value.contains(LocaliazationKey.date.tr())) {
                  // var res = await _datePicker();
                  var res = await _newDateTimePicker();
                  if (res != null && res == false) {
                    selectedAppBarDropDownValue = selectedValue;
                    for (var element in filterList) {
                      if (element!.value == value) {
                        element.isSelected = true;
                      }
                    }
                    if (alertState.alertTypesFilterList != null &&
                        alertState.alertTypesFilterList!.isNotEmpty) {
                      selectedFilter =
                          alertState.alertTypesFilterList!.first!.AlertType;
                    }
                  }
                }
              },
              icon: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.calendar_month,
                    size: 30,
                  ),
                  // SvgPicture.asset(
                  //   'assets/icons/filter.svg',
                  //   height: 3.h,
                  //   color: Theme.of(context).iconTheme.color,
                  //
                  //*commented
                  // alertListRequestModel!.alertdt!.toDateTime().isToday()
                  filterList.every((element) => element!.isSelected == false)
                      ? Container()
                      : Positioned(
                          left: -1.w,
                          top: 0.1.h,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20), color: Theme.of(context).colorScheme.primary),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 2),
                              child: Text(
                                '\t${filterList.where((element) => element!.isSelected == true).length} ',
                                style: AppStyles.textStyle4(context: context, size: 10, color: Colors.white),
                              ),
                            ),
                          ))
                ],
              ),
              value: selectedAppBarDropDownValue,
              items: filterList.map((e) => e!.value).toList(),
            ),

          // CustomDropDownButton(
          //   value: selectedValue!.contains(clearFilter) ? null : selectedValue,
          //   items: alertDropDown,
          //   // dashBoardState.dashboardResponseModelData!.StatusCount!
          //   //     .map((e) =>
          //   //         AppHelper.returnAlertStatus(alertStatus: e!.AlertType))
          //   //     .toList(),
          //   // icon: const Icon(Icons.more_vert),
          //   onChanged: (value) async {
          // searchCtl.clear();
          // alertListRequestModel!.alertTypeId = 0;
          // alertListRequestModel!.pNo = pageNo = defaultPageN0;
          // alertListRequestModel!.vno = '';
          // setState(() {
          //   selectedValue = value;
          // });

          // if (value!.contains(allValue)) {
          //   loadMoreData();
          //   return;
          // }

          //     var alertId = dashBoardState.getStatusByAlertType(
          //         alertType: AppHelper.returnOriginalAlertStatus(
          //             alertStatus:
          //                 value)); //* here i am converting alertType as original like API to compare with list.
          //     if (alertId == null) return;
          //     alertListRequestModel!.alertTypeId = alertId;

          //     loadMoreData();
          //   },
          // ),
          5.w.width
        ],
      ),
      body: alertState.state == NotifierState.loading
          ? const ListShimmerEffect(
              isAlert: true,
            )
          : alertState.state == NotifierState.error
              ? CustomErrorWidget(
                  onPressed: () {
                    getAlerts();
                  },
                  errorMsg: alertState.failure.message,
                )
              : alertState.alertList!.isEmpty
                  // && selectedFilter == null
                  //! Remove this after
                  ? Center(
                      child: Text(
                        LocaliazationKey.no_records.tr(),
                        style: AppStyles.textStyle4(context: context),
                      ),
                    )
                  : Stack(
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: SearchWidget(
                                        controller: searchCtl,
                                        isLoading: alertState.isSearchLoading,
                                        onChanged: _onSearchChanged,
                                        onPressedClear: () {
                                          searchCtl.clear();
                                          _onSearchChanged(searchCtl.text);
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomDropDownButton(
                                        value: selectedFilter,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedFilter = value;
                                          });
                                          resetModel();
                                          if (selectedFilter!.contains(LocaliazationKey.all.tr())) {
                                            loadMoreData();
                                            return;
                                          }
                                          final res = alertState.alertTypesFilterList!.firstWhere(
                                              (element) => element!.AlertType == selectedFilter,
                                              orElse: () => AlertListResponseModelDataAlerttypes());
                                          if (res == null || res.AlertTypeID == null) return;
                                          alertListRequestModel!.alertTypeId = res.AlertTypeID;
                                          loadMoreData();
                                        },
                                        icon: Stack(
                                          alignment: Alignment.center,
                                          clipBehavior: Clip.none,
                                          children: [
                                            SvgPicture.asset(
                                              'assets/icons/filter.svg',
                                              height: 3.h,
                                              color: Theme.of(context).iconTheme.color,
                                            ),
                                            selectedFilter == null ||
                                                    selectedFilter!.contains(LocaliazationKey.all.tr())
                                                ? Container()
                                                : Positioned(
                                                    left: -10,
                                                    top: -1.h,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(20),
                                                          color: Theme.of(context).colorScheme.primary),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.symmetric(horizontal: 3.0, vertical: 2),
                                                        child: Text(
                                                          '\t1 ',
                                                          style: AppStyles.textStyle4(
                                                              context: context, size: 10, color: Colors.white),
                                                        ),
                                                      ),
                                                    ))
                                          ],
                                        ),
                                        // value: selectedFilter,
                                        items:
                                            alertState.alertTypesFilterList!.map((e) => e!.AlertType).toSet().toList(),
                                      ),
                                    )
                                  ],
                                ),
                                2.h.height,
                                if (alertState.filterList!.isNotEmpty && searchCtl.text.isEmpty)
                                  Align(
                                    alignment: Alignment.center,
                                    child: PageCountWidget(
                                      // pageCount:
                                      //     '${alertListRequestModel!.pNo! - 1} / ${(alertState.totalCount).ceil()}',
                                      pageCount: '${alertState.filterList!.length} / ${(alertState.totalCount)}',
                                    ),
                                  ),
                                alertState.filterList!.isEmpty
                                    ? Align(
                                        child: Padding(
                                            padding: EdgeInsets.only(top: SizerUtil.height * 0.10),
                                            child: Text(
                                              LocaliazationKey.no_matching_records_found.tr(),
                                              style: AppStyles.textStyle4(context: context),
                                            )),
                                      )
                                    : Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(bottom: 8.0),
                                          child: AnimationLimiter(
                                            child: ListView.builder(
                                              controller: _scrollController,
                                              // shrinkWrap: true,
                                              itemCount: alertState.filterList!.length + 1,
                                              itemBuilder: (context, index) {
                                                if (index == alertState.filterList!.length) {
                                                  return Center(
                                                      child: alertState.isMoreDataLoading
                                                          ? const CircularProgressIndicator()
                                                          : alertState.hasMoreData
                                                              ? CustomButton(
                                                                  onPressed: () async {
                                                                    loadNextPage();
                                                                  },
                                                                  title: LocaliazationKey.load_more.tr(),
                                                                )
                                                              : Container());
                                                  //  LazyLoadingProgressWidget(
                                                  //   hasMoreData: alertState.hasMoreData,
                                                  // );
                                                } else {
                                                  final cardData = alertState.filterList![index];
                                                  if (cardData == null) {
                                                    return const SizedBox.shrink();
                                                  }
                                                  final videoUrls = AppHelper.decodeVideoPath(
                                                      unitNo: cardData.UnitNo?.toString() ?? '',
                                                      urlPath: cardData.Videofilepath);
                                                  return AnimationConfiguration.staggeredList(
                                                      duration: const Duration(milliseconds: 500),
                                                      position: index,
                                                      child: SlideAnimation(
                                                        horizontalOffset: 100.0,
                                                        child: FadeInAnimation(
                                                          child: Padding(
                                                            padding: EdgeInsets.only(
                                                                bottom: index == alertState.filterList!.length - 1
                                                                    ? 3.h
                                                                    : 0),
                                                            child: PinVehicleCard(
                                                              location: cardData.Location ?? '',
                                                              mapData: (cardData.Lat != null && cardData.Lon != null)
                                                                  ? GoogleMapModel(
                                                                  latLng: LatLng(cardData.Lat!, cardData.Lon!),
                                                                  vehicleId: cardData.VehicleID,
                                                                  statusName: cardData.AlertType,
                                                                  vehicleNo: cardData.VehicleNo,
                                                                  engineOffdelay: null,
                                                                  idleduration: null,
                                                                  ignition: cardData.ignition == null
                                                                      ? null
                                                                      : cardData.ignition.toString(),
                                                                  odometer: null,
                                                                  speed: cardData.speed == null
                                                                      ? null
                                                                      : cardData.speed.toString(),
                                                                  stopduration: null,
                                                                  vehicleLocation: cardData.Location,
                                                                  vehicleTrackTime: cardData.Alertdatetime)
                                                                  : null,
                                                              alertType: LocaliazationKey.alert_video.tr(),
                                                              liveUrlList: videoUrls,
                                                              status: cardData.AlertType == "yaccel end" ||
                                                                      cardData.AlertType == "xaccel end"
                                                                  ? AppHelper.returnAlertStatus(
                                                                      alertStatus: cardData.AlertType!)
                                                                  : cardData.AlertType ?? '',
                                                              ignition: cardData.ignition.toString(),
                                                              speed: cardData.speed.toString(),
                                                              trackTime: cardData.Alertdatetime ?? '',
                                                              vehicleNo: cardData.VehicleNo ?? '',
                                                              vehicleId: cardData.VehicleID ?? 0,
                                                              enableUrl: videoUrls.isNotEmpty,
                                                              // && cardData.deviceType == "MDVR" || cardData.deviceType == "MDVR AI",
                                                              showPinnedIcon: false,
                                                              // disableLiveUrl: cardData.Status!
                                                              //         .toLowerCase() ==
                                                              //     inactive,
                                                            ),
                                                          ),
                                                        ),
                                                      ));
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                              ],
                            )),
                        // Align(
                        //     alignment: Alignment.centerRight,
                        //     child: Column(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         Card(
                        //             child: IconButton(
                        //                 onPressed: () {
                        //                   _scrollController.jumpTo(
                        //                       _scrollController
                        //                           .initialScrollOffset);

                        //                   // if (scrollOffsetList.isNotEmpty) {
                        //                   //   _scrollController
                        //                   //       .jumpTo(scrollOffsetList.last);
                        //                   //   scrollOffsetList.removeAt(
                        //                   //       scrollOffsetList.length - 1);

                        //                   // }
                        //                 },
                        //                 icon: const Icon(
                        //                     Icons.keyboard_arrow_up_outlined))),
                        //         Card(
                        //             child: IconButton(
                        //                 onPressed: () async {
                        //                   _scrollController.jumpTo(
                        //                       _scrollController
                        //                           .position.maxScrollExtent);
                        //                   if (alertState.hasMoreData) {
                        //                     await loadNextPage();
                        //                   }
                        //                   // _scrollController.jumpTo(
                        //                   //     _scrollController
                        //                   //         .position.maxScrollExtent);
                        //                 },
                        //                 icon: const Icon(Icons
                        //                     .keyboard_arrow_down_outlined))),
                        //       ],
                        //     ))
                      ],
                    ),
    );
  }
}

class TimeModel {
  final TimeOfDay? timeOfDayObject;
  final String? timeOfDayString;

  TimeModel({required this.timeOfDayObject, required this.timeOfDayString});
}

class DropDownModel {
  final String? value;
  bool isSelected = false;

  DropDownModel({this.value, this.isSelected = false});
}
