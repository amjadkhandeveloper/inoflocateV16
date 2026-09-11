// ignore_for_file: prefer_null_aware_operators, prefer_if_null_operators

import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infolocate/animation/custom_fade_animation.dart';
import 'package:infolocate/screens/dashboard/controller/ads_provider.dart';
import 'package:infolocate/screens/dashboard/controller/dashboard_provider.dart';
import 'package:infolocate/screens/dashboard/model/dashboard_request_model.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/app_extensions.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_styles.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:infolocate/utils/enums.dart';
import 'package:infolocate/widgets/cards/alert_status_card.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../animation/shake_animation.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_helper.dart';
import '../../../utils/app_localization_key.dart';
import '../../../widgets/cards/custom_card.dart';
import '../../../widgets/cards/pin_vehicle_card.dart';
import '../../../widgets/cards/vehicle_status_card.dart';
import '../../../widgets/circle_avatar/custom_avatar.dart';
import '../../../widgets/custom_pie_chart.dart';
import '../../../widgets/custom_shimmer_effects.dart';
import '../../../widgets/cutom_carousel_widget.dart';
import '../../../widgets/drawer/navigation_drawer.dart';
import '../../../widgets/error_widget.dart';
import '../../../widgets/google_map/map_model.dart';
import '../../alerts/view/alert_screen.dart';
import '../../card_types_screen/controller/card_type_provider.dart';
import '../../language/controller/language_provider.dart';
import '../../login/model/user_login_response_model.dart';
import '../../pin_vehicles/controller/pin_vehicle_provider.dart';
import '../../vehicle_statuswise_list/controller/vehicle_status_provider.dart';
import '../../vehicle_statuswise_list/model/vehicle_status_request_model.dart';
import '../../vehicle_statuswise_list/view/vehicle_status_list.dart';
import '../../vehicle_statuswise_list/widget/map_overview.dart';
import '../../vehicle_statuswise_list/widget/track_on_map_screen.dart';
import '../model/dashboard_model.dart';
import '../model/dashboard_response_model.dart';

/// Main dashboard after login: fleet summary, charts, pinned vehicles, drawer navigation.
class HomeScreen extends StatefulWidget {
  static String routeName = '/homeRoute';

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final controller = PageController();
  final alertController = ScrollController();
  final carouselController = PageController();

  // final ExpansionTileController expansionTileController =
  //     ExpansionTileController();
  int currentIndex = 0;
  late UserLoginResponseModelDataUser userData;
  int totalFleetCount = 0;
  Map<String, double> pieChartValue = {};

  // late var _authBox;
  int userId = 1;
  bool isVehicleStatus = false;
  double alertCardWith = 0;
  bool isDrawerOpen = false;
  bool isVehicleStatusExpanded = true;
  int? tabBarIndex = 0;
  List<DashboardResponseModelDataVehicleStatus?>? displayList = [];

  List<ButtonModel> buttonData = [];

  final colorList = <Color>[
    const Color(0xff289348), //moving
    const Color(0xffEE9229), //idle
    const Color(0xffed220d), //stopped
    const Color(0xff6c4bf1), //working/operation
    const Color(0xff929292), //inactive
    const Color(0xff970e52), //all vehicles
    Colors.pink.shade800,
    Colors.indigo,
    Colors.orange,
  ];

  Timer? _timer = Timer(const Duration(seconds: 1), () {});

  final PageController _pageController = PageController();

  double currentPage = 0;
  double visiblePercentage = 100.0;
  int _currentItem = 0;
  bool disableVisiblity = false;
  bool enableArrowIcon = false;

  bool? showAdvertise = Global.box.get(userAdvertisement) as bool?;

  @override
  void initState() {
    super.initState();

    print("Advertisement: $showAdvertise ");

    alertController.addListener(() {
      if (alertController.position.pixels == 0.0) {
        setState(() {
          _currentItem = 0;
        });
      }
      if (alertController.position.pixels == alertController.position.maxScrollExtent) {
        setState(() {
          enableArrowIcon = false;
        });
      } else {
        setState(() {
          enableArrowIcon = true;
        });
      }
    });
    Future.delayed(Duration.zero, () {
      LanguageProvider languageProvider = Provider.of<LanguageProvider>(context, listen: false);
      languageProvider.setCurrentLanguage();
    });

    Future.delayed(Duration.zero, () => getUserData());

    // dashboardProvider.getDashboardData(
    //     dashboardRequestModel: dashboardRequestModel);
  }

  // @override
  // void didChangeDependencies() {

  //   final dashBoardState =
  //       Provider.of<DashboardProvider>(context, listen: false);
  //   if (dashBoardState.dashboardResponseModelData == null) return;
  // if (dashBoardState.dashboardResponseModelData!.Pinvehicle != null &&
  //     dashBoardState.dashboardResponseModelData!.Pinvehicle!.isEmpty) {
  //   expansionTileController.expand();
  // }
  //   super.didChangeDependencies();
  // }

  @override
  void dispose() {
    _timer!.cancel();
    _pageController.dispose();
    alertController.dispose();
    super.dispose();
  }

  reloadData() {
    // print("In reload data");
    final dashBoardState = Provider.of<DashboardProvider>(context, listen: false);
    final vehicleStatusState = Provider.of<VehicleStatusProvider>(context, listen: false);

    try {
      _timer!.cancel();
      _timer = Timer.periodic(const Duration(seconds: 10), (_) {
        if (dashBoardState.state == NotifierState.error && dashBoardState.dashboardResponseModelData == null) {
          _timer?.cancel();
        }
        if (Global.savedUserAuthData != null) {
          Future.wait([
            if (Global.isVehicleListBackgroundFetching ==
                false) //* this is to avoid duplicate fetch when another screen is feteching.
              vehicleStatusState.fetchInBackground(
                vehicleStatusWiseListRequestModel: VehicleStatusWiseListRequestModel(
                  statusId: 6,
                  userId: Global.savedUserAuthData!.userid!,
                  // userId: 1,
                  pSize: 0,
                  //* 0 means all data
                  pNo: defaultPageN0,
                  sSearch: '',
                ),
              ),
            getAds(),
            dashBoardState.getData(
                dashboardRequestModel: DashboardRequestModel(
              userId: Global.savedUserAuthData!.userid!,
              pSize: 100,
              pNo: 1,
            )),
          ]);
        }

        // if (dashBoardState.dashboardResponseModelData!.Pinvehicle != null &&
        //     dashBoardState.dashboardResponseModelData!.Pinvehicle!.isEmpty) {
        //   expansionTileController.expand();
        // }
        // dashBoardState.getData(
        //     dashboardRequestModel: DashboardRequestModel(
        //   userId: Global.savedUserAuthData!.userid!,
        //   pSize: 100,
        //   pNo: 1,
        // ));
      });
      final data = dashBoardState.dashboardResponseModelData;
      if (data == null || data.VehicleStatus == null || data.VehicleStatus == null) return;
      totalFleetCount = 0;
      // pieChartValue={};
      for (final vehicleData in data.VehicleStatus!) {
        totalFleetCount += vehicleData!.Value!.toInt();
        String status = vehicleData.status.toString();
        double value = vehicleData.Value!.toDouble();
        pieChartValue[status] = value;
      }

      log("Total fleet count $totalFleetCount");
    } catch (err) {
      _timer?.cancel();
      debugPrint(err.toString());
    }
  }

  Future<void> getAds() async {
    final adsState = Provider.of<AdsProvider>(context, listen: false);
    try {
      await adsState.getAds(clientId: Global.savedClientAuthData!.clientId!.toInt());
      setState(() {});
    } catch (e) {
      log("error on getAds() method-- ${e.toString()}");
    }
  }

  getUserData() async {
    final dashBoardState = Provider.of<DashboardProvider>(context, listen: false);
    final vehicleStatusState = Provider.of<VehicleStatusProvider>(context, listen: false);

    final pinVehicleState = Provider.of<PinVehicleProvider>(context, listen: false);
    CardTypeProvider cardTypeProvider =
        // ignore: use_build_context_synchronously
        Provider.of<CardTypeProvider>(context, listen: false);

    try {
      // cardTypeProvider.initialiseCardSettings();
      cardTypeProvider.setCurrentVehicleStatusCard();
      cardTypeProvider.setCurrentAlertStatusCard();
      getAds();
      //! uncomment this line during release of apk
      reloadData();
      // if (Global.savedClientAuthData == null) {
      //* assuring base url is not null

      // }

      // userData = Global.box.get(userAuthBoxKey);
      // log("Hive UserId ${userData.userid.toString()}");
      // userId = userData.userid!.toInt();
      // dashboardRequestModel.userId = userId;
      // myFuture =
      // displayList = [];

      await dashBoardState.getDashboardData(
          dashboardRequestModel: DashboardRequestModel(
        userId: Global.savedUserAuthData!.userid!,
        pSize: pageSize,
        pNo: defaultPageN0,
      ));
      await vehicleStatusState.getVehicleList(
        vehicleStatusWiseListRequestModel: VehicleStatusWiseListRequestModel(
          statusId: 6,
          userId: Global.savedUserAuthData!.userid!,
          // userId: 1,
          pSize: maxPageSize,
          pNo: defaultPageN0,
          sSearch: '',
        ),
      );

      pinVehicleState.lengthOfPinVehicles = dashBoardState.dashboardResponseModelData!.Pinvehicle!.length;
      // log("Length of PinVehicle ${pinVehicleState.lengthOfPinVehicles}");

      final data = dashBoardState.dashboardResponseModelData;
      displayList = data!.VehicleStatus;

      if (data.VehicleStatus == null || data.VehicleStatus == null) return;
      totalFleetCount = 0;
      for (final vehicleData in data.VehicleStatus!) {
        totalFleetCount += vehicleData!.Value!.toInt();
        String status = vehicleData.status.toString();
        double value = vehicleData.Value!.toDouble();
        pieChartValue[status] = value;
      }
      if (data.StatusCount != null && data.StatusCount!.isNotEmpty) {
        alertController.jumpTo(0.01);
      }
      Future.delayed(const Duration(seconds: 1), () => setState(() {}));
    } catch (err) {
      log("error on getUserData() methode-- ${err.toString()}");
    }
  }

  // expansionControllerhandler() {

  // }

  @override
  Widget build(BuildContext context) {
    final dashBoardState = Provider.of<DashboardProvider>(context);
    LanguageProvider languageProvider = Provider.of<LanguageProvider>(context);
    final data = dashBoardState.dashboardResponseModelData;
    final adsState = Provider.of<AdsProvider>(context);

    // bool defaultFromTime = true;
    // log(AppHelper.getCustomTimeFormat(dateTime: DateTime.now()).toString());
    // final vehicleStatusState = Provider.of<VehicleStatusProvider>(context);
    // log("display list length ${displayList!.length}");
    // log(dashBoardState.state.toString());
    // print("min scroll ${alertController.position.pixels}");

    return Scaffold(
        // floatingActionButton: FloatingActionButton(onPressed: () async {
        //   final bx = await Hive.openBox(myBox);
        //   bx.get(cardTypeSettingKey)!.alertStatusCardsList!.forEach(
        //         (element) => print(element!.cardTypeId.toString() +
        //             element.isSelected.toString()),
        //       );
        // }),
        backgroundColor: AppUi.pageBg(context),
        appBar: AppUi.appBar(
          context: context,
          title: LocaliazationKey.dashboard.tr(),
          leading: Builder(builder: (context) {
            return IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: Icon(Icons.menu_rounded, color: AppUi.ink(context)),
            );
          }),
          actions: [
            GestureDetector(
              onTap: () {
                profileDialogBox(context, languageProvider.selectedLanguage);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0x1F2563EB),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: AppUi.accent,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: dashBoardState.state == NotifierState.loading
            ? const DasboardShimmerEffect()
            : dashBoardState.state != NotifierState.error && data != null
                ? RefreshIndicator(
                    color: AppUi.accent,
                    onRefresh: () async {
                      totalFleetCount = 0;
                      getUserData();
                    },
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 0.0),
                              child: Text(
                                LocaliazationKey.dashboard.tr(),
                                style: AppUi.titleStyle(context).copyWith(fontSize: 22),
                              ),
                            ),
                            const SizedBox(height: 12),
                            data.StatusCount!.isEmpty ? Container() : alertStatusListTwo(data),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12, left: 2, right: 2),
                              child: Text(
                                LocaliazationKey.vehicle_status.tr(),
                                style: AppUi.sectionLabel(context),
                              ),
                            ),
                            CustomContainer(
                              applyShawdow: true,
                              // height: 12.h,
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ExpansionPanelList(
                                        elevation: 0,
                                        expandedHeaderPadding: EdgeInsets.zero,
                                        dividerColor: AppUi.line(context),
                                        expansionCallback: (int index, bool isExpanded) {
                                          log("Boolean Value ${isExpanded.toString()}");
                                          setState(() {
                                            isVehicleStatusExpanded = !isVehicleStatusExpanded;
                                            log("Is Tile Expanded $isVehicleStatusExpanded");
                                          });
                                        },
                                        children: [
                                          ExpansionPanel(
                                            backgroundColor: Colors.transparent,
                                            isExpanded: isVehicleStatusExpanded,
                                            headerBuilder: (BuildContext context, bool isExpanded) {
                                              return ListTile(
                                                // tileColor: Colors.transparent,
                                                leading: ClipRRect(
                                                  borderRadius: BorderRadius.circular(15),
                                                  child: SvgPicture.asset(
                                                    'assets/icons/Group 254.svg',
                                                    fit: BoxFit.cover,
                                                    colorFilter: ColorFilter.mode(
                                                        Theme.of(context).colorScheme.primary, BlendMode.color),
                                                    height: 40,
                                                  ),
                                                ),
                                                title: InkWell(
                                                  onTap: () {
                                                    if (_timer != null && _timer!.isActive) {
                                                      _timer!.cancel();
                                                    }
                                                    Navigator.of(context)
                                                        .push(
                                                          MaterialPageRoute(
                                                            builder: (context) => VehicleStatusScreen(
                                                              title: LocaliazationKey.all_vehicles.tr(),
                                                              statusId: 6,
                                                              isLiveVehicle: false,
                                                              totalCount: totalFleetCount,
                                                            ),
                                                          ),
                                                        )
                                                        .then(
                                                          (value) => getUserData(),
                                                        );
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      // 2.w.width,
                                                      Text(
                                                        totalFleetCount.toString(),
                                                        style: AppUi.titleStyle(context).copyWith(fontSize: 24),
                                                      ),
                                                      1.w.height,
                                                      Text(
                                                        LocaliazationKey.total_fleet.tr(),
                                                        style: AppUi.mutedStyle(context),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                            body: Column(
                                              children: [
                                                SizedBox(
                                                  height: data.VehicleStatus!.length <= 4
                                                      ? tabBarIndex == 0 && data.VehicleStatus!.length <= 2
                                                          ? 22.h
                                                          : 36.h
                                                      : 50.h,
                                                  child: DefaultTabController(
                                                    length: 3,
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                          height: 38,
                                                          margin: const EdgeInsets.symmetric(horizontal: 10),
                                                          decoration: BoxDecoration(
                                                            color:
                                                                Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                                            borderRadius: BorderRadius.circular(28),
                                                          ),
                                                          child: TabBar(
                                                            onTap: (index) {
                                                              tabBarIndex = index;
                                                              setState(() {});
                                                            },
                                                            tabs: [
                                                              Tab(
                                                                text: LocaliazationKey.data.tr(),
                                                              ),
                                                              Tab(text: LocaliazationKey.graph.tr()),
                                                              Tab(text: LocaliazationKey.map.tr()),
                                                            ],
                                                            labelColor: Colors.white,
                            unselectedLabelColor: AppUi.ink(context),
                                                            labelStyle: const TextStyle(fontSize: 16.0),
                                                            unselectedLabelStyle: const TextStyle(fontSize: 16.0),
                                                            indicator: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(28.0),
                                                              color: Theme.of(context).colorScheme.primary,
                                                            ),
                                                            indicatorSize: TabBarIndicatorSize.tab,
                                                          ),
                                                        ),
                                                        1.h.height,
                                                        Expanded(
                                                          child: TabBarView(
                                                            physics: const NeverScrollableScrollPhysics(),
                                                            children: [
                                                              // vehicleStatusGrid(data),
                                                              newVehicleStatusGrid(data),
                                                              Padding(
                                                                padding: EdgeInsets.only(top: 1.h),
                                                                child: CustomPieChart(
                                                                  data: data.VehicleStatus,
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: SizerUtil.width * 0.85,
                                                                // height: 300,
                                                                child: Column(
                                                                  children: [
                                                                    Expanded(
                                                                      flex: 3,
                                                                      child: Padding(
                                                                        padding: EdgeInsets.only(
                                                                          top: 1.8.h,
                                                                          left: 3.w,
                                                                          right: 3.w,
                                                                        ),
                                                                        child: const MapOverview(),
                                                                      ),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed: () {
                                                                        Global.isVehicleListBackgroundFetching = true;
                                                                        Navigator.push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                const TrackOnMapScreen(),
                                                                          ),
                                                                        ).then((value) => false);
                                                                      },
                                                                      child: Text(
                                                                        LocaliazationKey.view_more.tr(),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ]),
                                  ],
                                ),
                              ),
                            ),
                            // alertStatusList(data),
                            const SizedBox(height: 16),
                            data.Pinvehicle!.isEmpty
                                ? Container()
                                : Row(
                                    key: UniqueKey(),
                                    children: [
                                      // Container(
                                      //   height: 25,
                                      //   width: 25,
                                      //   margin: const EdgeInsets.only(left: 5),
                                      //   decoration: BoxDecoration(
                                      //       color: Theme.of(context)
                                      //           .colorScheme
                                      //           .primary,
                                      //       borderRadius:
                                      //           BorderRadius.circular(4)),
                                      //   child: Padding(
                                      //     padding: const EdgeInsets.all(5.0),
                                      //     child: SvgPicture.asset(
                                      //       'assets/icons/new_icons/pin_vehicle.svg',
                                      //       color: Colors.white,
                                      //       // theme: const SvgTheme(
                                      //       //   currentColor: Colors.black,
                                      //       // ),
                                      //       // colorFilter: ColorFilter.mode(
                                      //       //   Theme.of(context)
                                      //       //       .colorScheme
                                      //       //       .primary,
                                      //       //   BlendMode.color,
                                      //       // ),
                                      //       height: 28,
                                      //     ),
                                      //   ),
                                      // ),
                                      2.w.width,
                                      Text(
                                        LocaliazationKey.pin_vehicle.tr(),
                                        style: AppUi.sectionLabel(context),
                                      ),
                                    ],
                                  ),
                            data.Pinvehicle!.isEmpty
                                ? Container()
                                : AnimationLimiter(
                                    child: ListView.builder(
                                        physics: const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: data.Pinvehicle!.length,
                                        itemBuilder: (context, index) {
                                          final pinCardData = data.Pinvehicle![index];
                                          String mapIt = pinCardData!.Mapit ?? "0.0,0.0";
                                          // print("Map it Value $mapIt");
                                          List<String> latLong = mapIt.split(",");
                                          String value1 = latLong[0];
                                          String value2 = latLong[1];
                                          double lat = double.parse(value1);
                                          double lon = double.parse(value2);
                                          // print("Lat Long $lat $lon");

                                          return AnimationConfiguration.staggeredList(
                                            duration: const Duration(milliseconds: 500),
                                            position: index,
                                            child: SlideAnimation(
                                              horizontalOffset: 100.0,
                                              child: FadeInAnimation(
                                                child: PinVehicleCard(
                                                  // key: UniqueKey(),
                                                  vehicleNo: pinCardData.VehicleNo.toString(),
                                                  vehicleId: pinCardData.VehicleId!.toInt(),
                                                  location: pinCardData.Location.toString(),
                                                  trackTime: pinCardData.TrackingTime.toString(),
                                                  status: pinCardData.Status.toString(),
                                                  isPinned: pinCardData.isPin,
                                                  liveUrl: pinCardData.LiveUrl,
                                                  ignition: pinCardData.ignition.toString(),
                                                  idelDuration: pinCardData.Idleduration,
                                                  odometer: pinCardData.odometer,
                                                  speed: pinCardData.speed.toString(),
                                                  urlTitle: pinCardData.VehicleNo,
                                                  enableUrl: pinCardData.Status!.toLowerCase() == moving ||
                                                      pinCardData.Status!.toLowerCase() == idle,
                                                  liveUrlList: null,
                                                  showPinnedIcon: true,
                                                  statusId: pinCardData.id,
                                                  mapData: GoogleMapModel(
                                                      ignition:
                                                          pinCardData.ignition == null ? null : pinCardData.ignition,
                                                      idleduration: pinCardData.Idleduration == null
                                                          ? null
                                                          : pinCardData.Idleduration.toString(),
                                                      odometer: pinCardData.odometer == null
                                                          ? null
                                                          : pinCardData.odometer.toString(),
                                                      speed: pinCardData.speed.toString(),
                                                      statusName: pinCardData.Status,
                                                      latLng: LatLng(lat, lon),
                                                      vehicleId: pinCardData.VehicleId,
                                                      vehicleNo: pinCardData.VehicleNo,
                                                      engineOffdelay: null,
                                                      stopduration: null,
                                                      vehicleLocation: pinCardData.Location == null
                                                          ? null
                                                          : pinCardData.Location.toString(),
                                                      vehicleTrackTime: pinCardData.TrackingTime == null
                                                          ? null
                                                          : pinCardData.TrackingTime.toString()),
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                            // 3.h.height,

                            if (showAdvertise! && adsState.urlList.isNotEmpty) const CustomCarouselWidget(),
                          ],
                        ),
                      ),
                    ),
                  )
                : CustomErrorWidget(
                    onPressed: () {
                      getUserData();
                    },
                    errorMsg: dashBoardState.failure.message,
                  ),
        drawer: CustomNavigationDrawer());
  }

  Future<dynamic> profileDialogBox(BuildContext context, String selectedLanguage) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CustomFadeScaleTransition(
          duration: const Duration(milliseconds: 400),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LottieBuilder.asset(
                      'assets/animation/user_animation.json',
                      repeat: false,
                      width: 120,
                      height: 120,
                      fit: BoxFit.fill,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            LocaliazationKey.user_name.tr(),
                            style: AppStyles.textStyle5(context: context, isBold: false),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(Global.savedUserAuthData!.username!)),
                        const SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            LocaliazationKey.selected_language.tr(),
                            style: AppStyles.textStyle5(context: context, isBold: false),
                          ),
                        ),
                        Container(
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(selectedLanguage)),
                      ],
                    ),
                    const SizedBox(
                      height: 38,
                    ),
                  ],
                ),
                Positioned(
                  right: 2,
                  top: 0,
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  SingleChildScrollView newVehicleStatusGrid(DashboardResponseModelData data) {
    final cardTypeProvider = Provider.of<CardTypeProvider>(context);
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              runSpacing: 4,
              alignment: WrapAlignment.center,
              direction: Axis.horizontal,
              children: [
                for (int i = 0; i < data.VehicleStatus!.length; i++)
                  // i.isEven && i < displayList!.length - 1
                  //     ?
                  SizedBox(
                    width: (i.isEven && i == data.VehicleStatus!.length - 1) ? 82.w : 40.w,
                    // 18.h,

                    child: GestureDetector(
                      onTap: () {
                        if (_timer != null && _timer!.isActive) {
                          _timer!.cancel();
                        }
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) => VehicleStatusScreen(
                                  title: AppHelper.returnJapaneseText(
                                    title: data.VehicleStatus![i]!.status.toString(),
                                  ),
                                  statusId: AppHelper.returnStatusId(status: data.VehicleStatus![i]!.status.toString()),
                                  isLiveVehicle: false,
                                  totalCount: data.VehicleStatus![i]!.Value,
                                ),
                              ),
                            )
                            .then(
                              (value) => getUserData(),
                            );
                      },
                      child: VehicleStatusCard(
                        count: data.VehicleStatus![i]!.Value.toString(),
                        icon: AppHelper.returnIcons(title: data.VehicleStatus![i]!.status.toString()),
                        title: AppHelper.returnJapaneseText(
                          title: data.VehicleStatus![i]!.status.toString(),
                        ),
                        iconColor: AppHelper.returnIconColor(title: data.VehicleStatus![i]!.status.toString()),
                        percentage: AppHelper.returnPercentage(
                                value: data.VehicleStatus![i]!.Value!.toInt(), totalcount: totalFleetCount)
                            // .floor()
                            .toString(),
                        cardType: cardTypeProvider.currentSelectedVehicleStatusCard!.cardTypeId,
                      ),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget alertStatusList(DashboardResponseModelData data) {
    List<DashboardResponseModelDataStatusCount?>? alertStatusList = data.StatusCount;
    // [
    //   DashboardResponseModelDataStatusCount(AlertCount: 1, AlertType: 'alert1'),
    //   DashboardResponseModelDataStatusCount(
    //     AlertCount: 2,
    //     AlertType: 'alert2',
    //   ),
    //   DashboardResponseModelDataStatusCount(AlertCount: 3, AlertType: 'alert3'),
    //   DashboardResponseModelDataStatusCount(AlertCount: 4, AlertType: 'alert4'),
    //   DashboardResponseModelDataStatusCount(AlertCount: 5, AlertType: 'alert5'),
    // ];

    return Container(
      margin: EdgeInsets.only(top: 2.h),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? Theme.of(context).cardColor : AppColors.grey,
        borderRadius: BorderRadius.circular(20),
        // border: Border.all(
        //   color: Colors.grey.shade400,
        // ),
        // boxShadow: [
        //   BoxShadow(
        //     color: Theme.of(context).brightness == Brightness.dark
        //         ? Colors.black26
        //         : Colors.grey.withOpacity(0.2),
        //     spreadRadius: 5,
        //     blurRadius: 10,
        //     offset: const Offset(0, 3), // changes position of shadow
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
              child: Text(
                LocaliazationKey.alert_status.tr(),
                style: AppStyles.textStyle4(
                  context: context,
                  size: 16,
                  // isBold: true,
                ),
              ),
            ),
          ),
          // 1.h.height,
          SizedBox(
            height: 130,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: alertController,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemCount: alertStatusList!.length,
              itemBuilder: (context, index) {
                return VisibilityDetector(
                  key: Key(index.toString()),
                  onVisibilityChanged: (VisibilityInfo info) {
                    // log(info.size.toString());
                    alertCardWith = info.size.width;
                    if (disableVisiblity == false) {
                      if (info.visibleFraction == 1 && alertController.position.pixels > 0.0) {
                        setState(() {
                          _currentItem = index;
                          print(_currentItem);
                        });
                      }
                    }
                    Future.delayed(const Duration(milliseconds: 200), () {
                      disableVisiblity = false;
                    });
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: (index <= 1 && alertStatusList.length == 2) ? 4.w : 1.w,
                    ),
                    child: SizedBox(
                      width: 38.w,
                      child: FractionallySizedBox(
                        heightFactor: 1,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AlertDashboardScreen(
                                  alertTypeId: alertStatusList[index]!.AlertTypeID,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                              left: 18,
                              right: 18,
                              top: 14,
                              bottom: 14,
                            ),
                            padding: const EdgeInsets.only(top: 14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Theme.of(context).cardColor
                                  : AppColors.grey,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.black26
                                      : Colors.grey.withOpacity(0.2),
                                  spreadRadius: 3,
                                  blurRadius: 10,
                                  offset: const Offset(0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                CustomAvatar(
                                  bgColor: Theme.of(context).colorScheme.primary,
                                  icon: Text(
                                    alertStatusList[index]!.AlertCount.toString(),
                                    style: AppStyles.textStyle4(
                                      context: context,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 1.5.h,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Text(
                                      alertStatusList[index]!.AlertType.toString() == "yaccel end" ||
                                              alertStatusList[index]!.AlertType.toString() == "xaccel end"
                                          ? AppHelper.returnJapaneseText(
                                              title: AppHelper.returnAlertStatus(
                                              alertStatus: alertStatusList[index]!.AlertType.toString(),
                                            ))
                                          : AppHelper.returnJapaneseText(
                                              title: alertStatusList[index]!.AlertType.toString()),
                                      textAlign: TextAlign.center,
                                      style: AppStyles.textStyle4(
                                          context: context,
                                          color: Theme.of(context).brightness == Brightness.light
                                              ? AppColors.darkGrey
                                              : null),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          1.h.height,
          SizedBox(
            height: 14,
            child: alertStatusList.length <= 2
                ? Container()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // AnimatedOpacity(
                      //   opacity: _currentItem != 0 ? 1 : 0,
                      //   duration: const Duration(milliseconds: 300),
                      //   child: InkWell(
                      //     onTap: () {
                      //       disableVisiblity = true;
                      //       if (_currentItem > 0) {
                      //         setState(() {
                      //           _currentItem--;
                      //         });
                      //         log(_currentItem.toString());
                      //         alertController
                      //             .jumpTo(alertCardWith * _currentItem);
                      //       }
                      //     },
                      //     child: const Icon(
                      //       Icons.arrow_back_ios_new_rounded,
                      //       size: 15,
                      //     ),
                      //   ),
                      // ),
                      ...List.generate(
                        alertStatusList.length,
                        (index) => _currentItem == index
                            ? Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: CircleAvatar(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  radius: 4,
                                ),
                              )
                            : const Padding(
                                padding: EdgeInsets.all(2.0),
                                child: CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  radius: 4,
                                ),
                              ),
                      ),
                      // AnimatedOpacity(
                      //   opacity:
                      //       _currentItem != alertStatusList.length - 1 ? 1 : 0,
                      //   duration: const Duration(milliseconds: 300),
                      //   child: InkWell(
                      //     onTap: () {
                      //       disableVisiblity = true;
                      //       if (_currentItem < alertStatusList.length) {
                      //         setState(() {
                      //           _currentItem++;
                      //         });
                      //         log(_currentItem.toString());
                      //         alertController
                      //             .jumpTo(alertCardWith * _currentItem);
                      //       }
                      //     },
                      //     child: const Icon(
                      //       Icons.arrow_forward_ios,
                      //       size: 15,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget alertStatusListTwo(DashboardResponseModelData data) {
    List<DashboardResponseModelDataStatusCount?>? alertStatusList = data.StatusCount;
    CardTypeProvider cardTypeProvider =
        // ignore: use_build_context_synchronously
        Provider.of<CardTypeProvider>(context, listen: false);
    // log(enableArrowIcon.toString());
    // log(visiblePercentage.toString());

    return Column(
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12, left: 2, right: 2),
            child: Text(
              LocaliazationKey.alert_status.tr(),
              style: AppUi.sectionLabel(context),
            ),
          ),
        ),
        // 1.h.height,
        Stack(
          children: [
            SizedBox(
              height: 15.h,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: alertController,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: alertStatusList!.length,
                itemBuilder: (context, index) {
                  return VisibilityDetector(
                    key: Key(index.toString()),
                    onVisibilityChanged: (VisibilityInfo info) {
                      var visiblePercentage = info.visibleFraction * 100;
                      visiblePercentage = visiblePercentage;
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: SizedBox(
                        width: 20.w,
                        child: InkWell(
                            onTap: () {
                              print(alertStatusList[index]!.AlertType);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlertDashboardScreen(
                                    alertTypeId: alertStatusList[index]!.AlertTypeID,
                                  ),
                                ),
                              );
                            },
                            child: AlertStatusCard(
                              alertCount: alertStatusList[index]!.AlertCount,
                              alertType: alertStatusList[index]!.AlertType,
                              cardType: cardTypeProvider.currentSelectedAlertStatusCard!.cardTypeId,
                            )),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (enableArrowIcon && visiblePercentage != 100.0)
              Positioned(
                right: 4.w,
                top: 3.h,
                child: ShakeWidget(
                  duration: const Duration(seconds: 2),
                  child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        shape: BoxShape.circle,
                        // border: Border.all(
                        //     color: Theme.of(context).iconTheme.color!)
                      ),
                      child: const Padding(
                          padding: EdgeInsets.all(5.0),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            color: Colors.white,
                          ))),
                ),
              )
          ],
        ),
        1.h.height,
      ],
    );
  }
}
