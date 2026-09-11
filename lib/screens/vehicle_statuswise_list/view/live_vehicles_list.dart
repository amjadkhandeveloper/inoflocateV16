import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infolocate/utils/app_extensions.dart';
import 'package:infolocate/widgets/custom_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/app_constants.dart';
import '../../../utils/app_globals.dart';
import '../../../utils/app_helper.dart';
import '../../../utils/app_localization_key.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/app_ui.dart';
import '../../../utils/enums.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/cards/live_vehicle_list_widget.dart';
import '../../../widgets/custom_search_widget.dart';
import '../../../widgets/custom_shimmer_effects.dart';
import '../../../widgets/custom_toast.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/page_count_widget.dart';
import '../controller/vehicle_status_provider.dart';
import '../model/vehicle_status_request_model.dart';

class LiveVehicleList extends StatefulWidget {
  const LiveVehicleList({super.key});

  @override
  State<LiveVehicleList> createState() => _LiveVehicleListState();
}

class _LiveVehicleListState extends State<LiveVehicleList> {
  Timer? _timer = Timer(const Duration(seconds: 0), () {});
  Timer? _debounce = Timer(const Duration(seconds: 0), () {});
  int pageNo = defaultPageN0;
  int statusId = 1;
  final TextEditingController searchCtl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // late VehicleStatusWiseListRequestModel vehicleStatusWiseListRequestModel;
  late VehicleStatusWiseListRequestModel vehicleStatusResponseModelData;

  List<VehicleStatusModel> dropDownItems = [];
  String? selectedStatus;

  @override
  void dispose() {
    Global.isVehicleListBackgroundFetching =
        false; //* must be added so that on dashboard vehicle  list should fetch in background.
    _debounce?.cancel();
    _timer?.cancel();

    super.dispose();
  }

  @override
  void initState() {
    Global.isVehicleListBackgroundFetching = true;
    dropDownItems = [
      VehicleStatusModel(statusId: 3, statusName: LocaliazationKey.moving.tr()),
      VehicleStatusModel(statusId: 1, statusName: LocaliazationKey.idle.tr()),
    ];
    selectedStatus = dropDownItems.first.statusName;
    vehicleStatusResponseModelData = VehicleStatusWiseListRequestModel(
      statusId: dropDownItems.first.statusId!,
      userId: Global.savedUserAuthData!.userid!,
      // userId: 1,
      pSize: pageSize,
      pNo: pageNo, sSearch: '',
    );
    Future.delayed(Duration.zero, () => getVehicleList());
    // vehicleStatusResponseModelData.statusId = widget.statusId;
    // log("Status Id ${vehicleStatusResponseModelData.statusId}");
    super.initState();
  }

  getVehicleList() async {
    //* this method should only call in init state only once
    final vehicleStatusState =
        Provider.of<VehicleStatusProvider>(context, listen: false);
    handleScroll(vehicleStatusState: vehicleStatusState);

    vehicleStatusState.clearVehicleList();
    vehicleStatusState.setExpectedTotal(null);
    if (Global.savedClientAuthData == null) {
      //* assuring base url is not null
      await AppHelper.getHiveBoxData();
    }
    handleBackgroundFetch(vehicleStatusState: vehicleStatusState);
    // userData = Global.box.get(userAuthBoxKey);
    // log("Hive UserId ${userData.userid.toString()}");
    // userId = userData.userid!.toInt();
    // dashboardRequestModel.userId = userId;
    // myFuture =
    // await vehicleStatusState.getVehicleList(
    //     vehicleStatusWiseListRequestModel: vehicleStatusResponseModelData);
    // final data = vehicleStatusState.vehicleStatusResponseModelData;
    loadMoreData();
  }

  handleBackgroundFetch({required VehicleStatusProvider vehicleStatusState}) {
    //* fetch data in background after 10 sec.

    _timer!.cancel();

    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (searchCtl.text.isNotEmpty) return;
      //* when user is typing dont fetch data.
      await vehicleStatusState.fetchInBackground(
          vehicleStatusWiseListRequestModel: VehicleStatusWiseListRequestModel(
              pNo: defaultPageN0,
              pSize: vehicleStatusResponseModelData.pNo * pageSize,
              sSearch: '',
              statusId: vehicleStatusResponseModelData.statusId,
              userId: vehicleStatusResponseModelData.userId));
    });
  }

  // handleScroll({required VehicleStatusProvider vehicleStatusState}) {
  //   _scrollController.addListener(() {
  //     if (_scrollController.position.pixels ==
  //             _scrollController.position.maxScrollExtent &&
  //         vehicleStatusState.isMoreDataLoading == false &&
  //         searchCtl.text.isEmpty) {
  //       log('need to load items');
  //       loadMoreData(loadMore: true);
  //     }
  //   });
  // }
  handleScroll({required VehicleStatusProvider vehicleStatusState}) {
    //*commented
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          vehicleStatusState.isMoreDataLoading == false &&
          vehicleStatusState.hasMoreData == false) {
        customToast(message: LocaliazationKey.no_more_data.tr());
      }
    });
  }

  _onSearchChanged(String query) {
    final vehicleStatusState =
        Provider.of<VehicleStatusProvider>(context, listen: false);
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      vehicleStatusResponseModelData.sSearch = searchCtl.text;
      pageNo = vehicleStatusResponseModelData.pNo = defaultPageN0;
      vehicleStatusResponseModelData.pSize = query.isEmpty
          ? pageSize
          : maxPageSize; //* fetch max 100 records only for search filter
      vehicleStatusState.onSearchChange(
          keyWord: query,
          vehicleStatusWiseListRequestModel: vehicleStatusResponseModelData);
    });
  }

  loadMoreData({bool loadMore = false}) async {
    final vehicleStatusState =
        Provider.of<VehicleStatusProvider>(context, listen: false);
    try {
      log('need to load more data');
      if (vehicleStatusState.hasMoreData) {
        vehicleStatusResponseModelData.pNo = pageNo++;

        await vehicleStatusState.getVehicleList(
            vehicleStatusWiseListRequestModel: vehicleStatusResponseModelData,
            backgroundFetch: loadMore);
      }
      // vehicleStatusResponseModelData = VehicleStatusWiseListRequestModel(
      //   statusId: vehicleStatusResponseModelData.statusId,
      //   userId: Global.savedUserAuthData!.userid!,
      //   // userId: 1,
      //   pSize: pageSize,
      //   pNo: pageNo++,
      // );

      log("Page Value ${vehicleStatusResponseModelData.pNo} ");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicleStatusState = Provider.of<VehicleStatusProvider>(context);
    final data = vehicleStatusState.vehicleStatusResponseModelData;
    // print(vehicleStatusState.filterList!.length.toString());
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppUi.pageBg(context),
        appBar: AppUi.appBar(
          context: context,
          title: LocaliazationKey.live_vehicle.tr(),
          actions: [
            CustomDropDownButton(
              onChanged: (value) async {
                final res = dropDownItems.firstWhere(
                    (element) => element.statusName == value,
                    orElse: () => VehicleStatusModel());
                if (res.statusId != null) {
                  print(res.statusId);
                  vehicleStatusResponseModelData.statusId = res.statusId!;
                  vehicleStatusResponseModelData.pNo = defaultPageN0;
                  vehicleStatusResponseModelData.sSearch = '';

                  await vehicleStatusState.getVehicleList(
                      vehicleStatusWiseListRequestModel:
                          vehicleStatusResponseModelData,
                      backgroundFetch: false);
                }

                setState(() {
                  selectedStatus = value;
                });
              },
              value: selectedStatus,
              icon: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: SvgPicture.asset(
                  'assets/icons/filter.svg',
                  height: 3.h,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              items: dropDownItems.map((e) => e.statusName).toList(),
            )
          ],
        ),
        body: vehicleStatusState.state == NotifierState.loading
            ? const ListShimmerEffect()
            : vehicleStatusState.state != NotifierState.error && data != null
                ? vehicleStatusState.vehicleList!.isEmpty
                    ? Center(
                        child: Text(
                          LocaliazationKey.no_records.tr(),
                          style: AppStyles.textStyle4(context: context),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: SearchWidget(
                                controller: searchCtl,
                                onChanged: _onSearchChanged,
                                onPressedClear: () {
                                  searchCtl.clear();
                                  _onSearchChanged(searchCtl.text);
                                },
                                isLoading: vehicleStatusState.isSearchLoading,
                              ),
                            ),
                            2.h.height,
                            if (vehicleStatusState.filterList!.isNotEmpty &&
                                searchCtl.text.isEmpty)
                              Align(
                                alignment: Alignment.center,
                                child: PageCountWidget(
                                  // pageCount:
                                  //     '${vehicleStatusResponseModelData.pNo} / ${(vehicleStatusState.totalCount / 10).ceil()}',
                                  pageCount:
                                      '${vehicleStatusState.filterList!.length} / ${(vehicleStatusState.totalCount)}',
                                ),
                              ),
                            vehicleStatusState.filterList!.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 10.h),
                                      child: Text(
                                        LocaliazationKey
                                            .no_matching_records_found
                                            .tr(),
                                        style: AppStyles.textStyle4(
                                            context: context),
                                      ),
                                    ),
                                  )
                                : Expanded(
                                    child: AnimationLimiter(
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        itemCount: vehicleStatusState
                                                .filterList!.length +
                                            1,
                                        itemBuilder: ((context, index) {
                                          if (index ==
                                              vehicleStatusState
                                                  .filterList!.length) {
                                            return Center(
                                              child: vehicleStatusState
                                                      .isMoreDataLoading
                                                  ? const CircularProgressIndicator()
                                                  : vehicleStatusState
                                                          .hasMoreData
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 2.h,
                                                                  right: 1.5.h,
                                                                  left: 1.5.h),
                                                          child: CustomButton(
                                                            onPressed:
                                                                () async {
                                                              loadMoreData(
                                                                  loadMore:
                                                                      true);
                                                            },
                                                            title:
                                                                LocaliazationKey
                                                                    .load_more
                                                                    .tr(),
                                                          ),
                                                        )
                                                      : Container(),
                                            );
                                            // LazyLoadingProgressWidget(
                                            //     hasMoreData: vehicleStatusState
                                            //             .hasMoreData &&
                                            //         searchCtl.text.isEmpty);
                                          } else {
                                            final cardData = vehicleStatusState
                                                .filterList![index];

                                            return AnimationConfiguration
                                                .staggeredList(
                                              position: index,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              child: SlideAnimation(
                                                horizontalOffset: 100.0,
                                                child: FadeInAnimation(
                                                    child:
                                                        LiveVehicleListWidget(
                                                  vehicleNo: cardData!.VehicleNo
                                                      .toString(),
                                                  location: cardData.location ?? "No location",
                                                  tracktime: cardData.tracktime ?? 'N/A',
                                                  enableVideo: false
                                                      //       cardData.Status!
                                                      //         .toLowerCase() ==
                                                      //     idle ||
                                                      // cardData.Status!
                                                      //         .toLowerCase() ==
                                                      //     moving
                                                  ,
                                                  liveUrl: cardData.LiveUrl,
                                                )),
                                              ),
                                            );
                                          }
                                        }),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      )
                : CustomErrorWidget(
                    onPressed: () {},
                    errorMsg: vehicleStatusState.failure.message,
                  ),
      ),
    );
  }
}

class VehicleStatusModel {
  final int? statusId;

  final String? statusName;

  VehicleStatusModel({this.statusId, this.statusName});
}
