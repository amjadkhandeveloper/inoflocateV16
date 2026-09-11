import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infolocate/screens/vehicle_statuswise_list/controller/vehicle_status_provider.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/app_extensions.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/app_globals.dart';
import '../../../utils/app_helper.dart';
import '../../../utils/app_localization_key.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/app_ui.dart';
import '../../../utils/enums.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/cards/live_vehicle_list_widget.dart';
import '../../../widgets/cards/pin_vehicle_card.dart';
import '../../../widgets/custom_search_widget.dart';
import '../../../widgets/custom_shimmer_effects.dart';
import '../../../widgets/custom_toast.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/google_map/map_model.dart';
import '../../../widgets/page_count_widget.dart';
import '../model/vehicle_status_request_model.dart';

class VehicleStatusScreen extends StatefulWidget {
  final int statusId;
  final String title;
  final bool isLiveVehicle;
  final int? totalCount;

  const VehicleStatusScreen({
    Key? key,
    required this.statusId,
    required this.title,
    required this.isLiveVehicle,
    this.totalCount,
  }) : super(key: key);

  @override
  State<VehicleStatusScreen> createState() => _VehicleStatusScreenState();
}

class _VehicleStatusScreenState extends State<VehicleStatusScreen> {
  Timer? _timer = Timer(const Duration(seconds: 0), () {});
  Timer? _debounce = Timer(const Duration(seconds: 0), () {});
  int pageNo = defaultPageN0;
  final TextEditingController searchCtl = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // late VehicleStatusWiseListRequestModel vehicleStatusWiseListRequestModel;
  late VehicleStatusWiseListRequestModel vehicleStatusResponseModelData;

  @override
  void dispose() {
    _debounce?.cancel();
    _timer?.cancel();
    //* must be added so that on dashboard vehicle list should fetch in background.
    Global.isVehicleListBackgroundFetching = false;
    Provider.of<VehicleStatusProvider>(context, listen: false)
        .setExpectedTotal(null, notify: false);
    super.dispose();
  }

  @override
  void initState() {
    vehicleStatusResponseModelData = VehicleStatusWiseListRequestModel(
      statusId: widget.statusId,
      userId: Global.savedUserAuthData!.userid!,
      // userId: 1,
      pSize: pageSize,
      pNo: pageNo,
      sSearch: '',
    );
    Future.delayed(Duration.zero, () => getVehicleList());
    // vehicleStatusResponseModelData.statusId = widget.statusId;
    log("Status Id ${vehicleStatusResponseModelData.statusId}");
    super.initState();
  }

  getVehicleList() async {
    final vehicleStatusState = Provider.of<VehicleStatusProvider>(context, listen: false);
    handleScroll(vehicleStatusState: vehicleStatusState);

    vehicleStatusState.clearVehicleList();
    vehicleStatusState.setExpectedTotal(widget.totalCount);
    if (Global.savedClientAuthData == null) {
      await AppHelper.getHiveBoxData();
    }
    handleBackgroundFetch(vehicleStatusState: vehicleStatusState);
    loadMoreData();
  }

  handleBackgroundFetch({required VehicleStatusProvider vehicleStatusState}) {
    //* fetch data in background after 10 sec.
    Global.isVehicleListBackgroundFetching = true;

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

  handleScroll({required VehicleStatusProvider vehicleStatusState}) {
    //*commented
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          vehicleStatusState.isMoreDataLoading == false &&
          vehicleStatusState.hasMoreData == false) {
        customToast(message: LocaliazationKey.no_more_data.tr());
      }
    });
  }

  _onSearchChanged(String query) {
    final vehicleStatusState = Provider.of<VehicleStatusProvider>(context, listen: false);

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        // Reset the pagination and reload the default data
        pageNo = defaultPageN0;
        vehicleStatusResponseModelData.sSearch = '';
        vehicleStatusResponseModelData.pNo = pageNo;
        vehicleStatusResponseModelData.pSize = pageSize;

        vehicleStatusState.clearVehicleList();
        loadMoreData();
      } else {
        // Search mode: Set the search parameters and load filtered data
        vehicleStatusResponseModelData.sSearch = query;
        pageNo = defaultPageN0;
        vehicleStatusResponseModelData.pNo = pageNo;
        vehicleStatusResponseModelData.pSize = maxPageSize; // Fetch larger results for search

        vehicleStatusState.onSearchChange(
          keyWord: query,
          vehicleStatusWiseListRequestModel: vehicleStatusResponseModelData,
        );
      }
    });
  }


  loadMoreData({bool loadMore = false}) async {
    final vehicleStatusState = Provider.of<VehicleStatusProvider>(context, listen: false);
    try {
      log('need to load more data');
      if (vehicleStatusState.hasMoreData) {
        vehicleStatusResponseModelData.pNo = pageNo++;

        await vehicleStatusState.getVehicleList(vehicleStatusWiseListRequestModel: vehicleStatusResponseModelData, backgroundFetch: loadMore);
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppUi.pageBg(context),
        appBar: AppUi.appBar(
          context: context,
          title: widget.title,
        ),
        body: vehicleStatusState.state == NotifierState.loading
            ? const ListShimmerEffect()
            : vehicleStatusState.state != NotifierState.error && data != null
                ? (vehicleStatusState.vehicleList?.isEmpty ?? true)
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
                                  _onSearchChanged('');
                                },
                                isLoading: vehicleStatusState.isSearchLoading,
                              ),
                            ),
                            2.h.height,
                            if (searchCtl.text.isEmpty &&
                                (vehicleStatusState.loadedCount > 0 ||
                                    vehicleStatusState.totalCount > 0))
                              Align(
                                alignment: Alignment.center,
                                child: PageCountWidget(
                                  pageCount:
                                      '${vehicleStatusState.loadedCount} / ${vehicleStatusState.totalCount}',
                                ),
                              ),
                            (vehicleStatusState.filterList!.isEmpty)
                                ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 10.h),
                                      child: Text(
                                        LocaliazationKey.no_matching_records_found.tr(),
                                        style: AppStyles.textStyle4(context: context),
                                      ),
                                    ),
                                  )
                                : Expanded(
                                    child: AnimationLimiter(
                                      child: ListView.builder(
                                        controller: _scrollController,
                                        itemCount: (vehicleStatusState.filterList?.length ?? 0) + 1,
                                        itemBuilder: ((context, index) {
                                          if (index == (vehicleStatusState.filterList?.length ?? 0)) {
                                            return Center(
                                              child: vehicleStatusState.isMoreDataLoading
                                                  ? const CircularProgressIndicator()
                                                  : vehicleStatusState.hasMoreData
                                                      ? Padding(
                                                          padding: EdgeInsets.only(top: 2.h, right: 1.5.h, left: 1.5.h),
                                                          child: CustomButton(
                                                            onPressed: () async {
                                                              loadMoreData(loadMore: true);
                                                            },
                                                            title: LocaliazationKey.load_more.tr(),
                                                          ),
                                                        )
                                                      : Container(),
                                            );
                                            // LazyLoadingProgressWidget(
                                            //     hasMoreData: vehicleStatusState
                                            //             .hasMoreData &&
                                            //         searchCtl.text.isEmpty);
                                          } else {
                                            final cardData = vehicleStatusState.filterList![index];

                                            print("Card Data: ${widget.isLiveVehicle}");

                                            if (cardData == null) {
                                              return const SizedBox.shrink();
                                            }

                                            return AnimationConfiguration.staggeredList(
                                              position: index,
                                              duration: const Duration(milliseconds: 500),
                                              child: SlideAnimation(
                                                horizontalOffset: 100.0,
                                                child: FadeInAnimation(
                                                  child: widget.isLiveVehicle
                                                      ? LiveVehicleListWidget(
                                                          vehicleNo: cardData.VehicleNo ?? "Unknown",
                                                          location: cardData.location ?? "",
                                                          tracktime: cardData.tracktime ?? "",
                                                          enableVideo: (cardData.Status?.toLowerCase() == idle ||
                                                              cardData.Status?.toLowerCase() == moving ||
                                                              (cardData.Status?.toLowerCase() == stopped && (cardData.EngineOffdelay ?? 0) > 0)),
                                                          liveUrl: cardData.LiveUrl,
                                                        )
                                                      : Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                                          child: PinVehicleCard(
                                                            mapData: GoogleMapModel(
                                                              statusName: cardData.Status,
                                                              latLng: LatLng(cardData.lat ?? 0, cardData.lon ?? 0),
                                                              vehicleId: cardData.Vehicleid ?? 0,
                                                              vehicleNo: cardData.VehicleNo ?? "Unknown",
                                                              engineOffdelay: cardData.EngineOffdelay?.toString() ?? "0",
                                                              ignition: cardData.ignition?.toString() ?? "Off",
                                                              speed: cardData.speed?.toString() ?? "0",
                                                              odometer: cardData.odometer?.toString(),
                                                              idleduration: cardData.idleduration?.toString(),
                                                              stopduration: cardData.stopduration?.toString(),
                                                              vehicleLocation: cardData.location ?? "Unknown",
                                                              vehicleTrackTime: cardData.tracktime ?? "",
                                                            ),
                                                            vehicleNo: cardData.VehicleNo.toString(),
                                                            vehicleId: cardData.Vehicleid ?? 0,
                                                            location: cardData.location,
                                                            trackTime: cardData.tracktime.toString(),
                                                            status: cardData.Status.toString(),
                                                            liveUrl: cardData.LiveUrl,
                                                            urlTitle: cardData.VehicleNo,
                                                            ignition: cardData.ignition.toString(),
                                                            speed: cardData.speed.toString(),
                                                            odometer: cardData.odometer,
                                                            idelDuration: cardData.idleduration,
                                                            stopDuration: cardData.stopduration,
                                                            enableUrl: cardData.LiveUrl != null && cardData.devicetype == "MDVR" || cardData.devicetype == "MDVR AI",
                                                            // enableUrl: cardData.Status != null &&
                                                            //     (cardData.Status!.toLowerCase() == idle ||
                                                            //         cardData.Status!.toLowerCase() == moving ||
                                                            //         (cardData.Status!.toLowerCase() == stopped && (cardData.EngineOffdelay ?? 0) > 0)),
                                                            engineOffdelay: cardData.EngineOffdelay.toString(),
                                                            isPinned: cardData.IsPinVehicle == 0 ? false : true,
                                                            showPinnedIcon: true,
                                                            statusId: widget.statusId,
                                                            liveUrlList: null,
                                                          ),
                                                        ),
                                                ),
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

        //  Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        //   child: count == 0
        //       ? Center(
        //           child: Text(
        //             "No data found",
        //             textAlign: TextAlign.center,
        //             style: AppStyles.textStyle4(
        //                     context: context, color: Colors.black)
        //                 .copyWith(fontSize: 18),
        //           ),
        //         )
        //       : ListView.builder(
        //           itemCount: count,
        //           itemBuilder: (context, index) {
        //             return PinVehicleCard();
        //           }),
        // )
      ),
    );
  }
}
