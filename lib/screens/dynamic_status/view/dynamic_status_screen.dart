// ignore_for_file: prefer_if_null_operators, prefer_null_aware_operators
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infolocate/screens/dynamic_status/controller/dyanmic_status_provider.dart';
import 'package:infolocate/screens/dynamic_status/model/dynamic_status_request_model.dart';
import 'package:infolocate/utils/app_extensions.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/app_globals.dart';
import '../../../utils/app_localization_key.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/enums.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/cards/pin_vehicle_card.dart';
import '../../../widgets/custom_search_widget.dart';
import '../../../widgets/custom_shimmer_effects.dart';
import '../../../widgets/custom_toast.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/google_map/map_model.dart';
import '../../../widgets/page_count_widget.dart';

/// Live vehicle list with search, pagination, and periodic background refresh.
class DynamicStatusScreen extends StatefulWidget {
  static String routeName = '/dynamicStatus';

  const DynamicStatusScreen({super.key});

  @override
  State<DynamicStatusScreen> createState() => _DynamicStatusScreenState();
}

class _DynamicStatusScreenState extends State<DynamicStatusScreen> {
  Timer? _timer = Timer(const Duration(seconds: 0), () {});
  Timer? _debounce;
  int pageNo = defaultPageN0;
  final TextEditingController searchCtl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late DynamicStatusRequestModel dynamicListRequestModel;
  String? selectedValue;

  @override
  void initState() {
    Future.delayed(Duration.zero, () => setDynamicStatusData());
    super.initState();
  }

  _onSearchChanged(String query) {
    final dynamicStatusState = Provider.of<DynamicStatusProvider>(context, listen: false);

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        // Reset pagination and reload default data
        pageNo = defaultPageN0;
        dynamicListRequestModel.sSearch = '';
        dynamicListRequestModel.PNo = pageNo;
        dynamicListRequestModel.pSize = pageSize;
        dynamicStatusState.clearDynamicList();
        loadMoreData();
      } else {
        // Handle search logic
        dynamicListRequestModel.sSearch = query;
        pageNo = defaultPageN0;
        dynamicListRequestModel.PNo = pageNo;
        dynamicListRequestModel.pSize = maxPageSize; // Fetch more records for search filter
        dynamicStatusState.onSearchChange(
          keyWord: query,
          dynamicListRequestModel: dynamicListRequestModel,
        );
      }
    });
  }

  setDynamicStatusData() {
    //* this method should only call in init state only once
    final dynamicStatusState = Provider.of<DynamicStatusProvider>(context, listen: false);
    dynamicStatusState.clearDynamicList();

    dynamicListRequestModel =
        DynamicStatusRequestModel(PNo: pageNo, pSize: pageSize, UserId: Global.savedUserAuthData!.userid);
    handleScroll(dynamicStatusState: dynamicStatusState);
    loadMoreData();
    handleBackgroundFetch(dynamicStatusState: dynamicStatusState);
  }

  handleBackgroundFetch({required DynamicStatusProvider dynamicStatusState}) {
    //* fetch data in background after 10 sec.
    _timer!.cancel();

    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (searchCtl.text.isNotEmpty) return;
      //* when user is typing dont fetch data.
      await dynamicStatusState.fetchInBackground(
          dynamicListRequestModel: DynamicStatusRequestModel(
              PNo: defaultPageN0,
              pSize: dynamicListRequestModel.PNo! * pageSize,
              UserId: Global.savedUserAuthData!.userid));
    });
  }

  loadMoreData({bool loadMore = false}) async {
    final dynamicStatusState = Provider.of<DynamicStatusProvider>(context, listen: false);
    try {
      if (dynamicStatusState.hasMoreData) {
        dynamicListRequestModel.PNo = pageNo++;
        await dynamicStatusState.getDynamicStatusList(
            dynamicListRequestModel: dynamicListRequestModel, loadMore: loadMore);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  handleScroll({required DynamicStatusProvider dynamicStatusState}) {
    //*commented
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          dynamicStatusState.isMoreDataLoading == false &&
          dynamicStatusState.hasMoreData == false) {
        customToast(message: LocaliazationKey.no_more_data.tr());
      }
    });
  }

  @override
  void dispose() {
    searchCtl.dispose();
    _debounce?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dynamicStatusState = Provider.of<DynamicStatusProvider>(context);
    // log(dynamicStatusState.filterList!.length.toString());
    // log(dynamicStatusState.dynamicStatusList!.length.toString());
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          // iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
          centerTitle: true,
          title: Text(
            LocaliazationKey.dynamic_status.tr(),
            // style: TextStyle(
            //     color: Theme.of(context).textTheme.bodyLarge!.color)
          ),
          // backgroundColor: Colors.transparent,
          // elevation: 0,
        ),
        body: dynamicStatusState.state == NotifierState.loading
            ? const ListShimmerEffect(
                isDynamicStatus: true,
              )
            : dynamicStatusState.state == NotifierState.error
                ? CustomErrorWidget(
                    onPressed: () {},
                    errorMsg: dynamicStatusState.failure.message,
                  )
                : dynamicStatusState.dynamicStatusList!.isEmpty
                    ? Center(
                        child: Text(
                        LocaliazationKey.no_records.tr(),
                        style: AppStyles.textStyle4(context: context),
                      ))
                    : Column(
                        children: [
                          // if (dynamicStatusState.dynamicStatusList!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: SearchWidget(
                              controller: searchCtl,
                              isLoading: dynamicStatusState.isSearchLoading,
                              onChanged: _onSearchChanged,
                              onPressedClear: () {
                                searchCtl.clear();
                                _onSearchChanged('');
                              },
                            ),
                          ),

                          2.h.height,
                          if (dynamicStatusState.filterList!.isNotEmpty && searchCtl.text.isEmpty)
                            Align(
                              alignment: Alignment.center,
                              child: PageCountWidget(
                                // pageCount:
                                //     '${alertListRequestModel!.pNo! - 1} / ${(alertState.totalCount).ceil()}',
                                pageCount:
                                    '${dynamicStatusState.filterList!.length} / ${(dynamicStatusState.totalCount)}',
                              ),
                            ),

                          dynamicStatusState.filterList!.isEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(top: SizerUtil.height * 0.10),
                                  child: Text(
                                    LocaliazationKey.no_matching_records_found.tr(),
                                    style: AppStyles.textStyle4(context: context),
                                  ),
                                )
                              : Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: AnimationLimiter(
                                          child: ListView.builder(
                                              controller: _scrollController,
                                              itemCount: dynamicStatusState.filterList!.length + 1,
                                              // shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                if (index == dynamicStatusState.filterList!.length) {
                                                  return Center(
                                                      child: dynamicStatusState.isMoreDataLoading
                                                          ? const CircularProgressIndicator()
                                                          : dynamicStatusState.hasMoreData && searchCtl.text.isEmpty
                                                              ? Padding(
                                                                  padding: EdgeInsets.only(top: 2.h),
                                                                  child: CustomButton(
                                                                    onPressed: () async {
                                                                      loadMoreData(loadMore: true);
                                                                    },
                                                                    title: LocaliazationKey.load_more.tr(),
                                                                  ),
                                                                )
                                                              : Container());
                                                } else {
                                                  final data = dynamicStatusState.filterList![index]!;
                                                  final latLng = (data.Mapit != null && data.Mapit!.contains(','))
                                                      ? data.Mapit!.split(',')
                                                      : null;

                                                  final lat = latLng != null && latLng.isNotEmpty
                                                      ? double.tryParse(latLng[0])
                                                      : null;
                                                  final long = latLng != null && latLng.length > 1
                                                      ? double.tryParse(latLng[1])
                                                      : null;

                                                  if (lat == null || long == null) {
                                                    print("Invalid latitude or longitude");
                                                  }

                                                  return AnimationConfiguration.staggeredList(
                                                    duration: const Duration(milliseconds: 500),
                                                    position: index,
                                                    child: SlideAnimation(
                                                      horizontalOffset: 100.0,
                                                      child: FadeInAnimation(
                                                        child: PinVehicleCard(
                                                          vehicleNo: data.VehicleNo?.toString() ?? 'Unknown',
                                                          vehicleId: data.VehicleId?.toInt() ?? -1,
                                                          location:
                                                              data.Location != "" ? data.Location : "Location not available",
                                                          trackTime: data.TrackingTime ?? 'N/A',
                                                          status: data.Status ?? 'Unknown',
                                                          liveUrl: data.LiveUrl,
                                                          ignition: data.ignition?.toString() ?? 'N/A',
                                                          idelDuration: data.Idleduration ?? 0,
                                                          odometer: data.odometer ?? 0,
                                                          speed: data.speed?.toString() ?? '0',
                                                          urlTitle: data.VehicleNo,
                                                          enableUrl: data.LiveUrl != null,
                                                              // && data.deviceType == "MDVR" || data.deviceType == "MDVR AI",
                                                          liveUrlList: null,
                                                          showPinnedIcon: false,
                                                          statusId: data.id ?? -1,
                                                          mapData: GoogleMapModel(
                                                            ignition: data.ignition,
                                                            idleduration: data.Idleduration?.toString(),
                                                            odometer: data.odometer?.toString(),
                                                            speed: data.speed?.toString() ?? '0',
                                                            statusName: data.Status,
                                                            latLng: (lat != null && long != null)
                                                                ? LatLng(lat, long)
                                                                : null,
                                                            vehicleId: data.VehicleId,
                                                            vehicleNo: data.VehicleNo,
                                                            engineOffdelay: null,
                                                            stopduration: null,
                                                            vehicleLocation: data.Location?.toString(),
                                                            vehicleTrackTime: data.TrackingTime?.toString(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );

                                                  // Padding(
                                                  //     padding:
                                                  //         EdgeInsets.symmetric(
                                                  //             vertical: 2.h),
                                                  //     child: DynamicStatusCard(
                                                  // dynamicStatusDetails:
                                                  //     dynamicStatusState
                                                  //             .filterList![
                                                  //         index]!,
                                                  //     ));
                                                }
                                              }),
                                        )),
                                  ),
                                ),
                        ],
                      ),
      ),
    );
  }
}
