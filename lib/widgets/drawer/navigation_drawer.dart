// ignore_for_file: use_build_context_synchronously
import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/screens/alerts/view/alert_screen.dart';
import 'package:infolocate/screens/dynamic_status/view/dynamic_status_screen.dart';
import 'package:infolocate/screens/login/view/user_login_view.dart';
import 'package:infolocate/screens/settings/view/settings_screen.dart';
import 'package:infolocate/screens/vehicle_statuswise_list/widget/track_on_map_screen.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:infolocate/utils/app_routes.dart';
import 'package:infolocate/utils/app_styles.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import '../../screens/vehicle_statuswise_list/view/live_vehicles_list.dart';
import '../../screens/video_playback/view/video_playback_screen.dart';
import '../../utils/app_constants.dart';
import '../../utils/app_localization_key.dart';
import '../dialog_box/alert_dialog.dart';

// ignore: must_be_immutable
class CustomNavigationDrawer extends StatelessWidget {
  CustomNavigationDrawer({super.key});

  bool isLoading = false;

  navigateToTrackOnMap(BuildContext context) async {
    if (await Permission.location.request().isGranted) {
      Global.isVehicleListBackgroundFetching = true;

      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TrackOnMapScreen(
            showTrackHistory: true,
            // markerList: provider.vehicleList!
            //     .map((e) => GoogleMapModel(
            //         latLng: LatLng(e!.lat!, e.lon!),
            //         vehicleId: e.Vehicleid,
            //         vehicleNo: e.VehicleNo))
            //     .toList(),
          ),
        ),
      ).then((value) => Global.isVehicleListBackgroundFetching = false);
      Global.locationPermission = Global.box.get(locationPermission);
    }
  }

  @override
  Widget build(BuildContext context) {
    final drawerIconColor = Theme.of(context).colorScheme.primary;
    log("Location permission ${Global.locationPermission}");
    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return Drawer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: SizedBox(
                    child: Column(
                      children: [
                        SizedBox(height: 6.h,),
                        SizedBox(
                          height: 5.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 15,
                              ),
                              Text(
                                'InfoLocate V14',
                                style: AppStyles.infoLocateTextStyle(
                                    context: context).copyWith(fontSize: 30),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 1.h,),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '${LocaliazationKey.welcome.tr()} ${Global.savedUserAuthData != null ? Global.savedUserAuthData!.username! : ""}',
                            style: AppStyles.textStyle4(
                                context: context, isBold: true),
                          ),
                        ),
                        Container(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.2),
                          child: ListTile(
                            leading: Icon(
                              Icons.home,
                              color: drawerIconColor,
                            ),
                            title: Text(LocaliazationKey.dashboard.tr()),
                            onTap: () {
                              Navigator.pushNamedAndRemoveUntil(context,
                                  AppRoutes.dashboardRoute(), (route) => false);
                            },
                          ),
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.notification_important,
                            color: drawerIconColor,
                          ),
                          title: Text(LocaliazationKey.alerts.tr()),
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(AlertDashboardScreen.routeName);
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.dynamic_form,
                            color: drawerIconColor,
                          ),
                          title: Text(LocaliazationKey.dynamic_status.tr()),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const DynamicStatusScreen(),
                              ),
                            );
                            // Navigator.of(context)
                            //     .pushNamed(DynamicStatusScreen.routeName);
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.local_taxi,
                            color: drawerIconColor,
                          ),
                          title: Text(LocaliazationKey.live_vehicle.tr()),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const LiveVehicleList()),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.map,
                            color: drawerIconColor,
                          ),
                          title: Text(LocaliazationKey.track_on_map.tr()),
                          onTap: () async {
                            // final provider = Provider.of<VehicleStatusProvider>(
                            //     context,
                            //     listen: false);
                            if (Global.locationPermission == true) {
                              navigateToTrackOnMap(context);
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text("Grant Permission"),
                                    content: const Text(
                                      'Infolocate app collects location information for the loading of the map to view vehicle locations.',
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('DENY'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('ACCEPT'),
                                        onPressed: () async {
                                          await Global.box
                                              .put(locationPermission, true);
                                          navigateToTrackOnMap(context);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.video_camera_back,
                            color: drawerIconColor,
                          ),
                          title: Text(LocaliazationKey.video_playback.tr()),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    const VideoPlayBackScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.settings,
                            color: drawerIconColor,
                          ),
                          title: Text(LocaliazationKey.setting.tr()),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const SettingsScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(
                            Icons.exit_to_app,
                            color: drawerIconColor,
                          ),
                          title: isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                              : Text(LocaliazationKey.logout.tr()),
                          onTap: isLoading
                              ? null
                              : () async {
                                  final isLogOut =
                                      await logoutAlertDialog(context);
                                  if (isLogOut != null && isLogOut) {
                                    setState(() {
                                      isLoading = true;
                                    });

                                    await logout(context: context);
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text('${LocaliazationKey.version.tr()} 1.0.0'),
              ),
            ],
          ),
        );
      },
    );
  }

  logout({required BuildContext context}) async {
    try {
      // AdaptiveTheme.of(context).setLight();
      // AppHelper().setCustomTheme(
      //     context: context, primaryColor: primeryColorConstant, reset: true);
      // final SharedPreferences prefs = await SharedPreferences.getInstance();
      await Global.box.delete(userAuthBoxKey);
      await AppHelper.getHiveBoxData();
      // await Global.box.put(clientAuthBoxKey, Global.savedClientAuthData);
      // await prefs
      //     .clear(); //*for removing stored theme which is using by Adaptive theme package.

      Navigator.pushNamedAndRemoveUntil(
          context, UserLoginScreen.routeName, (route) => false);
    } catch (err) {
      log(err.toString());
    }
  }
}
