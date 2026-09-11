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
import 'package:infolocate/utils/app_ui.dart';
import 'package:permission_handler/permission_handler.dart';
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
          ),
        ),
      ).then((value) => Global.isVehicleListBackgroundFetching = false);
      Global.locationPermission = Global.box.get(locationPermission);
    }
  }

  @override
  Widget build(BuildContext context) {
    log("Location permission ${Global.locationPermission}");
    final user = Global.savedUserAuthData?.username ?? '';
    final client = Global.savedClientAuthData?.clientName ?? '';

    return StatefulBuilder(
      builder: (BuildContext context, void Function(void Function()) setState) {
        return Drawer(
          backgroundColor: AppUi.pageBg(context),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      AppUi.brandMark(size: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('InfoLocate', style: AppUi.titleStyle(context)),
                            Text(
                              user.isEmpty
                                  ? LocaliazationKey.welcome.tr()
                                  : '${LocaliazationKey.welcome.tr()} $user',
                              style: AppUi.mutedStyle(context),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (client.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppUi.cardColor(context),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppUi.line(context)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.apartment_outlined,
                              size: 16, color: AppUi.muted(context)),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              client,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppUi.ink(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    children: [
                      _DrawerTile(
                        icon: Icons.home_rounded,
                        title: LocaliazationKey.dashboard.tr(),
                        selected: true,
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(context,
                              AppRoutes.dashboardRoute(), (route) => false);
                        },
                      ),
                      _DrawerTile(
                        icon: Icons.notifications_outlined,
                        title: LocaliazationKey.alerts.tr(),
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed(AlertDashboardScreen.routeName);
                        },
                      ),
                      _DrawerTile(
                        icon: Icons.dynamic_form_outlined,
                        title: LocaliazationKey.dynamic_status.tr(),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const DynamicStatusScreen(),
                            ),
                          );
                        },
                      ),
                      _DrawerTile(
                        icon: Icons.local_taxi_outlined,
                        title: LocaliazationKey.live_vehicle.tr(),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (context) =>
                                    const LiveVehicleList()),
                          );
                        },
                      ),
                      _DrawerTile(
                        icon: Icons.map_outlined,
                        title: LocaliazationKey.track_on_map.tr(),
                        onTap: () async {
                          if (Global.locationPermission == true) {
                            navigateToTrackOnMap(context);
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: AppUi.cardColor(context),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(AppUi.radius),
                                  ),
                                  title: Text('Grant Permission',
                                      style: AppUi.titleStyle(context)),
                                  content: Text(
                                    'Infolocate app collects location information for the loading of the map to view vehicle locations.',
                                    style: AppUi.body(context),
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('DENY',
                                          style: TextStyle(
                                              color: AppUi.muted(context))),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('ACCEPT',
                                          style: TextStyle(
                                              color: AppUi.accent,
                                              fontWeight: FontWeight.w700)),
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
                      _DrawerTile(
                        icon: Icons.videocam_outlined,
                        title: LocaliazationKey.video_playback.tr(),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const VideoPlayBackScreen(),
                            ),
                          );
                        },
                      ),
                      _DrawerTile(
                        icon: Icons.settings_outlined,
                        title: LocaliazationKey.setting.tr(),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SettingsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _DrawerTile(
                        icon: Icons.logout_rounded,
                        title: isLoading
                            ? LocaliazationKey.logout.tr()
                            : LocaliazationKey.logout.tr(),
                        danger: true,
                        loading: isLoading,
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    '${LocaliazationKey.version.tr()} 1.0.0',
                    style: AppUi.mutedStyle(context),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  logout({required BuildContext context}) async {
    try {
      await Global.box.delete(userAuthBoxKey);
      await AppHelper.getHiveBoxData();

      Navigator.pushNamedAndRemoveUntil(
          context, UserLoginScreen.routeName, (route) => false);
    } catch (err) {
      log(err.toString());
    }
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.title,
    this.onTap,
    this.selected = false,
    this.danger = false,
    this.loading = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final bool selected;
  final bool danger;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final color = danger
        ? const Color(0xFFDC2626)
        : selected
            ? AppUi.accent
            : AppUi.ink(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected
            ? AppUi.accent.withValues(alpha: 0.12)
            : AppUi.cardColor(context),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppUi.accent : AppUi.line(context),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                if (loading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppUi.accent,
                    ),
                  )
                else
                  Icon(Icons.chevron_right_rounded,
                      size: 18, color: AppUi.muted(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
