import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infolocate/screens/alerts/view/alert_screen.dart';
import 'package:infolocate/screens/card_types_screen/controller/card_type_provider.dart';
import 'package:infolocate/screens/dashboard/controller/sequel_dashboard_provider.dart';
import 'package:infolocate/screens/dashboard/model/dashboard_response_model.dart';
import 'package:infolocate/screens/language/controller/language_provider.dart';
import 'package:infolocate/screens/vehicle_statuswise_list/view/vehicle_status_list.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:infolocate/utils/enums.dart';
import 'package:infolocate/widgets/cards/vehicle_status_card.dart';
import 'package:infolocate/widgets/custom_shimmer_effects.dart';
import 'package:infolocate/widgets/drawer/navigation_drawer.dart';
import 'package:infolocate/widgets/error_widget.dart';
import 'package:infolocate/widgets/google_map/google_map_screen.dart';
import 'package:infolocate/widgets/google_map/map_model.dart';
import 'package:infolocate/widgets/profile_dialog.dart';
import 'package:infolocate/screens/splash/force_update_checker.dart';
import 'package:provider/provider.dart';

const Color _moving = Color(0xFF16A34A);
const Color _stopped = Color(0xFFEA580C);
const Color _inactive = Color(0xFF64748B);
const Color _idle = Color(0xFFD97706);
const Color _critical = Color(0xFFDC2626);

Color sequelStatusColor(String? status) {
  switch ((status ?? '').toLowerCase()) {
    case 'moving':
      return _moving;
    case 'stopped':
      return _stopped;
    case 'inactive':
      return _inactive;
    case 'idle':
      return _idle;
    default:
      return AppHelper.returnIconColor(title: status);
  }
}

IconData sequelStatusIcon(String? status) {
  switch ((status ?? '').toLowerCase()) {
    case 'moving':
      return Icons.near_me_rounded;
    case 'stopped':
      return Icons.pause_circle_outline_rounded;
    case 'inactive':
      return Icons.power_settings_new_rounded;
    case 'idle':
      return Icons.timelapse_rounded;
    default:
      return Icons.directions_car_outlined;
  }
}

bool _isCriticalAlert(String? type) {
  final t = (type ?? '').toLowerCase();
  return t.contains('panic') || t.contains('power');
}

Color _alertColor(String? type, {required bool featured}) {
  if (featured) return _critical;
  final t = (type ?? '').toLowerCase();
  if (t.contains('panic') || t.contains('power')) return _critical;
  if (t.contains('speed')) return const Color(0xFFD97706);
  if (t.contains('geofence')) return AppUi.accent;
  if (t.contains('stop')) return _stopped;
  return const Color(0xFF475569);
}

LatLng? _pinLatLng(String? mapit) {
  if (mapit == null || mapit.trim().isEmpty) return null;
  final parts = mapit.split(',');
  if (parts.length < 2) return null;
  final lat = double.tryParse(parts[0].trim());
  final lng = double.tryParse(parts[1].trim());
  if (lat == null || lng == null) return null;
  return LatLng(lat, lng);
}

/// Sequel fleet dashboard: KPI, donut, alerts, and pinned vehicle list.
class SequelDashboardScreen extends StatefulWidget {
  static String routeName = '/sequelHomeRoute';

  const SequelDashboardScreen({super.key});

  @override
  State<SequelDashboardScreen> createState() => _SequelDashboardScreenState();
}

class _SequelDashboardScreenState extends State<SequelDashboardScreen> {
  Timer? _timer;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchCtl = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      context.read<CardTypeProvider>().setCurrentVehicleStatusCard();
      context.read<CardTypeProvider>().setCurrentAlertStatusCard();
      _loadDashboard(force: true);
      ForceUpdateChecker.checkFromDashboard(context);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchCtl.dispose();
    super.dispose();
  }

  Future<void> _loadDashboard({
    bool showLoader = true,
    bool force = false,
  }) async {
    final dash = context.read<SequelDashboardProvider>();
    try {
      await dash.loadDashboard(showLoader: showLoader, force: force);
      _startRefresh();
    } catch (err) {
      log('Sequel dashboard load error: $err');
    }
  }

  void _startRefresh() {
    if (_timer != null && _timer!.isActive) return;
    _timer?.cancel();
    _timer = Timer.periodic(kSequelDashRefreshInterval, (_) async {
      if (!mounted || Global.savedUserAuthData == null) return;
      await context.read<SequelDashboardProvider>().loadDashboard(
            showLoader: false,
          );
    });
  }

  void _openStatusList({
    required String title,
    required int statusId,
    int? totalCount,
  }) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => VehicleStatusScreen(
              title: title,
              statusId: statusId,
              isLiveVehicle: false,
              totalCount: totalCount,
            ),
          ),
        )
        .then((_) => _loadDashboard(showLoader: false));
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 80) {
      context.read<SequelDashboardProvider>().loadNextPage();
    }
    return false;
  }

  String get _lastUpdatedLabel {
    final lastSynced = context.read<SequelDashboardProvider>().lastFetchAt;
    if (lastSynced == null) return 'Last updated just now';
    final d = DateTime.now().difference(lastSynced);
    if (d.inSeconds < 45) return 'Last updated just now';
    if (d.inMinutes < 60) {
      return 'Last updated ${d.inMinutes} min${d.inMinutes == 1 ? '' : 's'} ago';
    }
    return 'Last updated ${d.inHours}h ago';
  }

  List<DashboardResponseModelDataPinvehicle> _filteredPins(
    List<DashboardResponseModelDataPinvehicle> pins,
  ) {
    final q = _searchCtl.text.trim().toLowerCase();
    return pins.where((v) {
      if (q.isEmpty) return true;
      return (v.VehicleNo ?? '').toLowerCase().contains(q) ||
          (v.DriverName ?? '').toLowerCase().contains(q) ||
          (v.Location ?? '').toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final dash = context.watch<SequelDashboardProvider>();
    final data = dash.data;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppUi.pageBg(context),
      drawer: CustomNavigationDrawer(),
      body: dash.state == NotifierState.loading
          ? const DasboardShimmerEffect()
          : dash.state == NotifierState.error || data == null
              ? CustomErrorWidget(
                  errorMsg: dash.failure.message,
                  onPressed: () => _loadDashboard(force: true),
                )
              : RefreshIndicator(
                  color: AppUi.accent,
                  onRefresh: () =>
                      _loadDashboard(showLoader: false, force: true),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onScroll,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: _buildHeader(dash)),
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            16,
                            12,
                            16,
                            AppUi.bottomInset(context, extra: 24),
                          ),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _sectionLabel(LocaliazationKey.vehicle_overview.tr()),
                              const SizedBox(height: 12),
                              _KpiGrid(
                                total: dash.totalFleetCount,
                                statuses: dash.vehicleStatuses,
                                onTotal: () => _openStatusList(
                                  title: LocaliazationKey.all_vehicles.tr(),
                                  statusId: 6,
                                  totalCount: dash.totalFleetCount,
                                ),
                                onStatus: (s) => _openStatusList(
                                  title: s.status ?? '',
                                  statusId: s.StatusID ?? 6,
                                  totalCount: s.Value,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _AlertsCard(
                                alerts: dash.rankedAlerts,
                                onAlert: (id) {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => AlertDashboardScreen(
                                        alertTypeId: id,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _sectionLabel(
                                LocaliazationKey.favourite_vehicles.tr(),
                                trailing:
                                    '${_filteredPins(dash.pinVehicles).length}',
                              ),
                              const SizedBox(height: 12),
                              _VehicleList(
                                vehicles: _filteredPins(dash.pinVehicles),
                                loadingMore: dash.loadingMore,
                                hasMore: dash.hasMorePins,
                                onMore: dash.loadNextPage,
                                onOpen: _openVehicle,
                              ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader(SequelDashboardProvider dash) {
    final now = DateFormat('EEE, d MMM yyyy  HH:mm').format(DateTime.now());
    final client = Global.savedClientAuthData?.clientName ?? 'Sequel';

    return Column(
      children: [
        Container(
          color: AppUi.cardColor(context),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 8, 12),
              child: Column(
                children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    icon: Icon(Icons.menu_rounded, color: AppUi.ink(context)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaliazationKey.fleet_dashboard.tr(),
                          style: AppUi.titleStyle(context),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => _showSearch = !_showSearch),
                    icon: Icon(
                      _showSearch ? Icons.close : Icons.search_rounded,
                      color: AppUi.ink(context),
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AlertDashboardScreen(),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: AppUi.ink(context),
                        ),
                      ),
                      if (dash.totalAlertCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: _critical,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              dash.totalAlertCount > 99
                                  ? '99+'
                                  : '${dash.totalAlertCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ProfileAvatarButton(
                      selectedLanguage: context
                          .watch<LanguageProvider>()
                          .selectedLanguage,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                child: Row(
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppUi.pageBg(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppUi.line(context)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
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
                    const SizedBox(width: 10),
                    Text(
                      now,
                      style: TextStyle(fontSize: 11, color: AppUi.muted(context)),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: _moving,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _lastUpdatedLabel,
                        style: TextStyle(fontSize: 11, color: AppUi.muted(context)),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showSearch)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                  child: TextField(
                    controller: _searchCtl,
                    onChanged: (_) => setState(() {}),
                    style: AppUi.body(context),
                    decoration: AppUi.inputDecoration(
                      context: context,
                      hintText: 'Search vehicle, driver or location',
                      prefixIcon: Icon(Icons.search_rounded,
                          size: 20, color: AppUi.muted(context)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
        ),
        Container(height: 1, color: AppUi.line(context)),
      ],
    );
  }

  Widget _vehicleStatusStyleGrid(SequelDashboardProvider dash) {
    final statuses = dash.vehicleStatuses;
    if (statuses.isEmpty) return const SizedBox.shrink();
    final cardType = context
            .watch<CardTypeProvider>()
            .currentSelectedVehicleStatusCard
            ?.cardTypeId ??
        1;
    final total = dash.totalFleetCount;
    final width = MediaQuery.sizeOf(context).width;
    return Wrap(
      spacing: 10,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: [
        for (int i = 0; i < statuses.length; i++)
          SizedBox(
            width: (i.isEven && i == statuses.length - 1)
                ? width - 32
                : (width - 42) / 2,
            child: GestureDetector(
              onTap: () => _openStatusList(
                title: AppHelper.returnJapaneseText(
                    title: statuses[i].status ?? ''),
                statusId: statuses[i].StatusID ?? 6,
                totalCount: statuses[i].Value,
              ),
              child: VehicleStatusCard(
                count: '${statuses[i].Value ?? 0}',
                icon: AppHelper.returnIcons(
                    title: statuses[i].status ?? ''),
                title: AppHelper.returnJapaneseText(
                    title: statuses[i].status ?? ''),
                iconColor: AppHelper.returnIconColor(
                    title: statuses[i].status),
                percentage: AppHelper.returnPercentage(
                  value: (statuses[i].Value ?? 0).toInt(),
                  totalcount: total == 0 ? 1 : total,
                ).toString(),
                cardType: cardType,
              ),
            ),
          ),
      ],
    );
  }

  Widget _sectionLabel(String title, {String? trailing}) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppUi.ink(context),
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(trailing, style: TextStyle(fontSize: 12, color: AppUi.muted(context))),
      ],
    );
  }

  void _openVehicle(DashboardResponseModelDataPinvehicle pin) {
    final pos = _pinLatLng(pin.Mapit);
    if (pos != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GoogleMapScreen(
            marker: GoogleMapModel(
              latLng: pos,
              vehicleId: pin.VehicleId,
              vehicleNo: pin.VehicleNo,
              statusName: pin.Status,
              vehicleLocation: pin.Location,
              vehicleTrackTime: pin.TrackingTime,
              speed: '${pin.speed ?? 0}',
              odometer: '${pin.odometer ?? 0}',
              ignition: pin.ignition,
              engineOffdelay: null,
              idleduration: '${pin.Idleduration ?? 0}',
              stopduration: null,
            ),
          ),
        ),
      );
      return;
    }
    _openStatusList(
      title: pin.Status ?? LocaliazationKey.all_vehicles.tr(),
      statusId: 6,
    );
  }
}

class _TightGrid extends StatelessWidget {
  const _TightGrid({
    required this.columns,
    required this.children,
    this.spacing = 10,
  });

  final int columns;
  final List<Widget> children;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final slice = children.sublist(
        i,
        i + columns > children.length ? children.length : i + columns,
      );
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var j = 0; j < columns; j++) ...[
              if (j > 0) SizedBox(width: spacing),
              Expanded(
                child: j < slice.length ? slice[j] : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      );
      if (i + columns < children.length) {
        rows.add(SizedBox(height: spacing));
      }
    }
    return Column(mainAxisSize: MainAxisSize.min, children: rows);
  }
}

class _FleetCard extends StatelessWidget {
  const _FleetCard({required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: AppUi.cardDecoration(context),
      child: child,
    );
  }
}

class _KpiGrid extends StatelessWidget {
  const _KpiGrid({
    required this.total,
    required this.statuses,
    required this.onTotal,
    required this.onStatus,
  });

  final int total;
  final List<DashboardResponseModelDataVehicleStatus> statuses;
  final VoidCallback onTotal;
  final void Function(DashboardResponseModelDataVehicleStatus) onStatus;

  @override
  Widget build(BuildContext context) {
    final cardType = context
            .watch<CardTypeProvider>()
            .currentSelectedVehicleStatusCard
            ?.cardTypeId ??
        1;
    final cards = <Widget>[
      GestureDetector(
        onTap: onTotal,
        child: VehicleStatusCard(
          count: '$total',
          icon: AppHelper.returnIcons(
              title: LocaliazationKey.all_vehicles.tr()),
          title: LocaliazationKey.total_fleet.tr(),
          iconColor: AppUi.accent,
          percentage: '100',
          cardType: cardType,
        ),
      ),
      ...statuses.where((s) {
        final name = (s.status ?? '').toLowerCase();
        return name == moving || name == idle;
      }).map((s) {
        final statusTitle = s.status ?? '';
        final name = statusTitle.toLowerCase();
        return GestureDetector(
          onTap: () => onStatus(s),
          child: VehicleStatusCard(
            count: '${s.Value ?? 0}',
            icon: AppHelper.returnIcons(
                title: name == idle ? 'Idle' : 'Moving'),
            title: AppHelper.returnJapaneseText(title: statusTitle),
            iconColor: sequelStatusColor(statusTitle),
            percentage: AppHelper.returnPercentage(
              value: (s.Value ?? 0).toInt(),
              totalcount: total == 0 ? 1 : total,
            ).toString(),
            cardType: cardType,
          ),
        );
      }),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 720 ? 4 : 2;
        return _TightGrid(
          columns: cols,
          spacing: 10,
          children: cards,
        );
      },
    );
  }
}


class _AlertsCard extends StatelessWidget {
  const _AlertsCard({required this.alerts, required this.onAlert});

  final List<DashboardResponseModelDataStatusCount> alerts;
  final void Function(int? alertTypeId) onAlert;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return _FleetCard(
        child: Text(LocaliazationKey.no_alerts.tr(), style: TextStyle(color: AppUi.muted(context))),
      );
    }
    final featured = alerts.first;
    final rest = alerts.skip(1).toList();
    return _FleetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaliazationKey.alerts_and_events.tr(),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppUi.ink(context),
            ),
          ),
          const SizedBox(height: 12),
          Material(
            color: _isCriticalAlert(featured.AlertType)
                ? (AppUi.isDark(context)
                    ? const Color(0xFF3F1D1D)
                    : const Color(0xFFFEF2F2))
                : (AppUi.isDark(context)
                    ? const Color(0xFF3F2A14)
                    : const Color(0xFFFFF7ED)),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => onAlert(featured.AlertTypeID),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      _isCriticalAlert(featured.AlertType)
                          ? Icons.warning_amber_rounded
                          : Icons.priority_high_rounded,
                      color: _alertColor(featured.AlertType, featured: true),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            featured.AlertType ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppUi.ink(context),
                            ),
                          ),
                          Text(
                            'Highest frequency',
                            style: TextStyle(fontSize: 11, color: AppUi.muted(context)),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${featured.AlertCount ?? 0}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: _alertColor(featured.AlertType, featured: true),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppUi.muted(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...rest.map(
            (a) => InkWell(
              onTap: () => onAlert(a.AlertTypeID),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _alertColor(a.AlertType, featured: false),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        a.AlertType ?? '',
                        style: TextStyle(fontSize: 13, color: AppUi.ink(context)),
                      ),
                    ),
                    Text(
                      '${a.AlertCount ?? 0}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _isCriticalAlert(a.AlertType)
                            ? _critical
                            : AppUi.ink(context),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppUi.muted(context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _AlertSummaryRow extends StatelessWidget {
  const _AlertSummaryRow({
    required this.total,
    required this.critical,
    required this.speed,
    required this.geofence,
  });

  final int total;
  final int critical;
  final int speed;
  final int geofence;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      (LocaliazationKey.total_alerts.tr(), total, AppUi.ink(context)),
      (LocaliazationKey.critical_alerts.tr(), critical, _critical),
      (LocaliazationKey.speed_alerts.tr(), speed, _idle),
      (LocaliazationKey.geofence_alerts.tr(), geofence, AppUi.accent),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 640 ? 4 : 2;
        return _TightGrid(
          columns: cols,
          spacing: 10,
          children: [
            for (final t in tiles)
              _FleetCard(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t.$1,
                        style: TextStyle(fontSize: 11, color: AppUi.muted(context))),
                    Text(
                      '${t.$2}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: t.$3,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _VehicleList extends StatelessWidget {
  const _VehicleList({
    required this.vehicles,
    required this.loadingMore,
    required this.hasMore,
    required this.onMore,
    required this.onOpen,
  });

  final List<DashboardResponseModelDataPinvehicle> vehicles;
  final bool loadingMore;
  final bool hasMore;
  final VoidCallback onMore;
  final void Function(DashboardResponseModelDataPinvehicle) onOpen;

  @override
  Widget build(BuildContext context) {
    if (vehicles.isEmpty) {
      return _FleetCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Center(
            child: Text(
              'No pinned vehicles in this view',
              style: TextStyle(color: AppUi.muted(context)),
            ),
          ),
        ),
      );
    }

    final extra = (loadingMore || hasMore) ? 1 : 0;
    return SizedBox(
      height: 176,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: vehicles.length + extra,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index >= vehicles.length) {
            return _PinMoreCard(
              loading: loadingMore,
              onMore: onMore,
            );
          }
          final vehicle = vehicles[index];
          return _PinVehicleTile(
            vehicle: vehicle,
            onOpen: () => onOpen(vehicle),
          );
        },
      ),
    );
  }
}

class _PinMoreCard extends StatelessWidget {
  const _PinMoreCard({required this.loading, required this.onMore});
  final bool loading;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppUi.cardColor(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: loading ? null : onMore,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          width: 108,
          decoration: BoxDecoration(
            color: AppUi.cardColor(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppUi.line(context)),
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppUi.accent,
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppUi.accent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppUi.accent,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'View more',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppUi.accent,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _PinVehicleTile extends StatelessWidget {
  const _PinVehicleTile({required this.vehicle, required this.onOpen});
  final DashboardResponseModelDataPinvehicle vehicle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final color = sequelStatusColor(vehicle.Status);
    final location = (vehicle.Location ?? '').trim();
    final driver = (vehicle.DriverName ?? '').trim();
    return SizedBox(
      width: 248,
      child: Material(
      color: AppUi.cardColor(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            color: AppUi.cardColor(context),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppUi.line(context)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(14),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              sequelStatusIcon(vehicle.Status),
                              size: 15,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              vehicle.VehicleNo ?? '—',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: AppUi.ink(context),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.push_pin_rounded,
                            size: 16,
                            color: AppUi.accent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          vehicle.Status ?? '',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (driver.isNotEmpty)
                        Text(
                          driver,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppUi.ink(context),
                          ),
                        ),
                      Text(
                        location.isEmpty
                            ? LocaliazationKey.location_unavailable.tr()
                            : location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.3,
                          color: AppUi.muted(context),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.speed_rounded,
                              size: 14, color: AppUi.muted(context)),
                          const SizedBox(width: 4),
                          Text(
                            '${vehicle.speed ?? 0} km/h',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppUi.ink(context),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.power_settings_new_rounded,
                              size: 14, color: AppUi.muted(context)),
                          const SizedBox(width: 2),
                          Text(
                            vehicle.ignition ?? '—',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppUi.muted(context),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vehicle.TrackingTime ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppUi.muted(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
