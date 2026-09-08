import 'dart:async';
import 'dart:developer';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:infolocate/screens/alerts/view/alert_screen.dart';
import 'package:infolocate/screens/dashboard/controller/sequel_dashboard_provider.dart';
import 'package:infolocate/screens/dashboard/model/dashboard_response_model.dart';
import 'package:infolocate/screens/vehicle_statuswise_list/view/vehicle_status_list.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/enums.dart';
import 'package:infolocate/widgets/custom_shimmer_effects.dart';
import 'package:infolocate/widgets/drawer/navigation_drawer.dart';
import 'package:infolocate/widgets/error_widget.dart';
import 'package:infolocate/widgets/google_map/google_map_screen.dart';
import 'package:infolocate/widgets/google_map/map_model.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

const Color _pageBg = Color(0xFFF4F6F9);
const Color _ink = Color(0xFF1E293B);
const Color _muted = Color(0xFF64748B);
const Color _line = Color(0xFFE2E8F0);
const Color _moving = Color(0xFF16A34A);
const Color _stopped = Color(0xFFEA580C);
const Color _inactive = Color(0xFF64748B);
const Color _idle = Color(0xFFD97706);
const Color _totalBlue = Color(0xFF2563EB);
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

String sequelStatusHint(String? status) {
  switch ((status ?? '').toLowerCase()) {
    case 'moving':
      return 'On the move';
    case 'stopped':
      return 'Need attention';
    case 'inactive':
      return 'No recent signal';
    case 'idle':
      return 'Ignition on, idle';
    default:
      return 'Fleet status';
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
  if (t.contains('geofence')) return const Color(0xFF2563EB);
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
    Future.delayed(Duration.zero, () => _loadDashboard(force: true));
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

  void _openStatusList({required String title, required int statusId}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => VehicleStatusScreen(
              title: title,
              statusId: statusId,
              isLiveVehicle: false,
            ),
          ),
        )
        .then((_) => _loadDashboard(showLoader: false));
  }

  bool _onScroll(ScrollNotification notification) {
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
      backgroundColor: _pageBg,
      drawer: CustomNavigationDrawer(),
      body: dash.state == NotifierState.loading
          ? const DasboardShimmerEffect()
          : dash.state == NotifierState.error || data == null
              ? CustomErrorWidget(
                  errorMsg: dash.failure.message,
                  onPressed: () => _loadDashboard(force: true),
                )
              : RefreshIndicator(
                  color: _totalBlue,
                  onRefresh: () =>
                      _loadDashboard(showLoader: false, force: true),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: _onScroll,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: _buildHeader(dash)),
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _sectionLabel('Vehicle Overview'),
                              const SizedBox(height: 8),
                              _KpiGrid(
                                total: dash.totalFleetCount,
                                statuses: dash.vehicleStatuses,
                                onTotal: () => _openStatusList(
                                  title: LocaliazationKey.all_vehicles.tr(),
                                  statusId: 6,
                                ),
                                onStatus: (s) => _openStatusList(
                                  title: s.status ?? '',
                                  statusId: s.StatusID ?? 6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final wide = constraints.maxWidth >= 720;
                                  final statusCard = _VehicleStatusCard(
                                    statuses: dash.vehicleStatuses,
                                    total: dash.totalFleetCount,
                                  );
                                  final alertsCard = _AlertsCard(
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
                                  );
                                  if (!wide) {
                                    return Column(
                                      children: [
                                        statusCard,
                                        const SizedBox(height: 8),
                                        alertsCard,
                                      ],
                                    );
                                  }
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(child: statusCard),
                                      const SizedBox(width: 12),
                                      Expanded(child: alertsCard),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              _AlertBarsCard(alerts: dash.rankedAlerts),
                              const SizedBox(height: 8),
                              _AlertSummaryRow(
                                total: dash.totalAlertCount,
                                critical: dash.criticalAlertCount,
                                speed: dash.speedAlertCount,
                                geofence: dash.geofenceAlertCount,
                              ),
                              const SizedBox(height: 8),
                              _sectionLabel(
                                'Vehicles',
                                trailing:
                                    '${_filteredPins(dash.pinVehicles).length}',
                              ),
                              const SizedBox(height: 8),
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
    final user = Global.savedUserAuthData?.username ?? '';

    return Container(
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                    icon: const Icon(Icons.menu_rounded, color: _ink),
                  ),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Fleet Dashboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        setState(() => _showSearch = !_showSearch),
                    icon: Icon(
                      _showSearch ? Icons.close : Icons.search_rounded,
                      color: _ink,
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
                        icon: const Icon(
                          Icons.notifications_outlined,
                          color: _ink,
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
                              style: const TextStyle(
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
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFEEF2FF),
                      child: Text(
                        (user.isNotEmpty ? user : client)
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          color: _totalBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
                          color: _pageBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _line),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.apartment_outlined,
                                size: 16, color: _muted),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                client,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _ink,
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
                      style: const TextStyle(fontSize: 11, color: _muted),
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
                        style: const TextStyle(fontSize: 11, color: _muted),
                      ),
                    ],
                  ),
                ),
              ),
              if (_showSearch)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: TextField(
                    controller: _searchCtl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search vehicle, driver or location',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      filled: true,
                      fillColor: _pageBg,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _line),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: _line),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String title, {String? trailing}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(trailing, style: const TextStyle(fontSize: 12, color: _muted)),
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
    this.spacing = 8,
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
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
    final items = <_KpiItem>[
      _KpiItem(
        label: 'Total Vehicles',
        value: total,
        color: _totalBlue,
        icon: Icons.directions_car_filled_outlined,
        hint: 'Entire fleet',
        onTap: onTotal,
      ),
      ...statuses.map(
        (s) => _KpiItem(
          label: s.status ?? '',
          value: s.Value ?? 0,
          color: sequelStatusColor(s.status),
          icon: sequelStatusIcon(s.status),
          hint: sequelStatusHint(s.status),
          onTap: () => onStatus(s),
        ),
      ),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 720 ? 4 : 2;
        return _TightGrid(
          columns: cols,
          spacing: 8,
          children: items.map((item) => _KpiCard(item: item)).toList(),
        );
      },
    );
  }
}

class _KpiItem {
  const _KpiItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.hint,
    required this.onTap,
  });
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final String hint;
  final VoidCallback onTap;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.item});
  final _KpiItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _line),
          ),
            child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon, size: 14, color: item.color),
                    ),
                    const Spacer(),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TweenAnimationBuilder<double>(
                  key: ValueKey('${item.label}-${item.value}'),
                  tween: Tween(begin: 0, end: item.value.toDouble()),
                  duration: const Duration(milliseconds: 650),
                  builder: (_, v, __) => Text(
                    '${v.round()}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: item.color,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
                Text(
                  item.hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: _muted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VehicleStatusCard extends StatelessWidget {
  const _VehicleStatusCard({
    required this.statuses,
    required this.total,
  });

  final List<DashboardResponseModelDataVehicleStatus> statuses;
  final int total;

  @override
  Widget build(BuildContext context) {
    final dataMap = <String, double>{};
    final colors = <Color>[];
    for (final s in statuses) {
      final label = s.status ?? '';
      if (label.isEmpty) continue;
      dataMap[label] = (s.Value ?? 0).toDouble();
      colors.add(sequelStatusColor(s.status));
    }
    return _FleetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vehicle Status',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 8),
          if (total <= 0 || dataMap.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text('No vehicle status data',
                    style: TextStyle(color: _muted)),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, c) {
                final stacked = c.maxWidth < 340;
                final chart = SizedBox(
                  height: 128,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        dataMap: dataMap,
                        colorList: colors,
                        chartType: ChartType.ring,
                        ringStrokeWidth: 18,
                        chartRadius: 96,
                        centerText: '',
                        legendOptions:
                            const LegendOptions(showLegends: false),
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValues: false,
                        ),
                        animationDuration: const Duration(milliseconds: 700),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$total',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: _ink,
                            ),
                          ),
                          const Text(
                            'Vehicles',
                            style: TextStyle(fontSize: 11, color: _muted),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
                final legend = Column(
                  children: statuses.map((s) {
                    final color = sequelStatusColor(s.status);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              s.status ?? '',
                              style: const TextStyle(
                                  fontSize: 13, color: _ink),
                            ),
                          ),
                          Text(
                            '${s.Value ?? 0}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
                if (stacked) {
                  return Column(children: [chart, legend]);
                }
                return Row(
                  children: [
                    Expanded(child: chart),
                    const SizedBox(width: 12),
                    Expanded(child: legend),
                  ],
                );
              },
            ),
        ],
      ),
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
      return const _FleetCard(
        child: Text('No alerts', style: TextStyle(color: _muted)),
      );
    }
    final featured = alerts.first;
    final rest = alerts.skip(1).toList();
    return _FleetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alerts & Events',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 8),
          Material(
            color: _isCriticalAlert(featured.AlertType)
                ? const Color(0xFFFEF2F2)
                : const Color(0xFFFFF7ED),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                          const Text(
                            'Highest frequency',
                            style: TextStyle(fontSize: 11, color: _muted),
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
                        style: const TextStyle(fontSize: 13, color: _ink),
                      ),
                    ),
                    Text(
                      '${a.AlertCount ?? 0}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _isCriticalAlert(a.AlertType)
                            ? _critical
                            : _ink,
                      ),
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

class _AlertBarsCard extends StatelessWidget {
  const _AlertBarsCard({required this.alerts});
  final List<DashboardResponseModelDataStatusCount> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();
    final max = alerts
        .map((e) => e.AlertCount ?? 0)
        .fold<int>(0, (a, b) => a > b ? a : b);
    return _FleetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alert frequency',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
          const SizedBox(height: 8),
          ...alerts.map((a) {
            final count = a.AlertCount ?? 0;
            final pct = max <= 0 ? 0.0 : count / max;
            final color = _alertColor(a.AlertType, featured: a == alerts.first);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Text(
                          a.AlertType ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: _ink),
                        ),
                      ),
                      Text(
                        '$count',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF1F5F9),
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          }),
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
      ('Total Alerts', total, _ink),
      ('Critical Alerts', critical, _critical),
      ('Speed Alerts', speed, _idle),
      ('Geofence Alerts', geofence, _totalBlue),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 640 ? 4 : 2;
        return _TightGrid(
          columns: cols,
          spacing: 8,
          children: [
            for (final t in tiles)
              _FleetCard(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(t.$1,
                        style: const TextStyle(fontSize: 11, color: _muted)),
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
      return const _FleetCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Center(
            child: Text(
              'No pinned vehicles in this view',
              style: TextStyle(color: _muted),
            ),
          ),
        ),
      );
    }
    return Column(
      children: [
        ...vehicles.map(
          (v) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _VehicleRow(vehicle: v, onOpen: () => onOpen(v)),
          ),
        ),
        if (loadingMore)
          const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        else if (hasMore)
          TextButton(onPressed: onMore, child: const Text('View more')),
      ],
    );
  }
}

class _VehicleRow extends StatelessWidget {
  const _VehicleRow({required this.vehicle, required this.onOpen});
  final DashboardResponseModelDataPinvehicle vehicle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final color = sequelStatusColor(vehicle.Status);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _line),
          ),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            vehicle.VehicleNo ?? '—',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _ink,
                            ),
                          ),
                        ),
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
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if ((vehicle.DriverName ?? '').isNotEmpty)
                          'Driver: ${vehicle.DriverName}',
                        if ((vehicle.Location ?? '').isNotEmpty)
                          vehicle.Location,
                      ].join('  ·  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${vehicle.speed ?? 0} km/h  ·  ${vehicle.TrackingTime ?? ''}',
                      style: const TextStyle(fontSize: 11, color: _muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _muted),
            ],
          ),
        ),
      ),
    );
  }
}
