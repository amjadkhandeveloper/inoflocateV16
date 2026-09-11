import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../screens/dashboard/model/dashboard_response_model.dart';
import '../utils/app_helper.dart';
import '../utils/app_ui.dart';

class CustomPieChart extends StatelessWidget {
  const CustomPieChart({
    super.key,
    this.data,
  });

  final List<DashboardResponseModelDataVehicleStatus?>? data;

  @override
  Widget build(BuildContext context) {
    final axisColor = AppUi.muted(context);
    final line = AppUi.line(context);
    return SfCartesianChart(
      backgroundColor: Colors.transparent,
      plotAreaBackgroundColor: Colors.transparent,
      plotAreaBorderWidth: 0,
      primaryXAxis: CategoryAxis(
        labelIntersectAction: AxisLabelIntersectAction.trim,
        labelStyle: TextStyle(color: axisColor, fontSize: 11),
        axisLine: AxisLine(color: line),
        majorGridLines: MajorGridLines(color: line.withValues(alpha: 0.4)),
        majorTickLines: MajorTickLines(color: line),
      ),
      primaryYAxis: NumericAxis(
        labelStyle: TextStyle(color: axisColor, fontSize: 11),
        axisLine: AxisLine(color: line),
        majorGridLines: MajorGridLines(color: line.withValues(alpha: 0.4)),
        majorTickLines: MajorTickLines(color: line),
      ),
      series: <ColumnSeries<DashboardResponseModelDataVehicleStatus?, String>>[
        ColumnSeries<DashboardResponseModelDataVehicleStatus?, String>(
          width: 0.5,
          dataSource: data!,
          xValueMapper: (DashboardResponseModelDataVehicleStatus? sales, _) {
            return AppHelper.returnJapaneseText(title: sales!.status);
          },
          yValueMapper: (DashboardResponseModelDataVehicleStatus? sales, _) =>
              sales!.Value,
          pointColorMapper:
              (DashboardResponseModelDataVehicleStatus? sales, _) =>
                  sales!.color,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            textStyle: TextStyle(fontSize: 10, color: AppUi.ink(context)),
          ),
        ),
      ],
    );
  }
}

  // SfCircularChart(legend: Legend(isVisible: true), series: <CircularSeries>[
    //   // Render pie chartl
    //   PieSeries<DashboardResponseModelDataVehicleStatus?, String>(
    //     dataSource: data,
    //     explode: false,
    //     // explodeAll: true,
    //     radius: "65",
    //     pointColorMapper: (DashboardResponseModelDataVehicleStatus? data, _) =>
    //         data!.color,
    //     xValueMapper: (DashboardResponseModelDataVehicleStatus? data, _) =>
    //         data!.status,
    //     yValueMapper: (DashboardResponseModelDataVehicleStatus? data, _) =>
    //         data!.Value,
    //     startAngle: 90,
    //     endAngle: 90,
    //     dataLabelSettings: const DataLabelSettings(
    //         isVisible: true, labelPosition: ChartDataLabelPosition.outside),
    //   ),
    // ]);

    // Padding(
    //   padding: const EdgeInsets.all(8.0),
    //   child: PieChart(
    //     dataMap: pieChartMap,
    //     animationDuration: const Duration(milliseconds: 800),
    //     chartLegendSpacing: 32,
    //     colorList: colorList,
    //     initialAngleInDegree: 0,
    //     chartType: ChartType.disc,
    //     ringStrokeWidth: 32,
    //     // centerText: LocaliazationKey.data.tr(),
    //     chartRadius: 120,
    //     legendOptions: const LegendOptions(
    //       showLegendsInRow: false,
    //       legendPosition: LegendPosition.right,
    //       showLegends: true,
    //       legendShape: BoxShape.circle,
    //       legendTextStyle: TextStyle(
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //     chartValuesOptions: const ChartValuesOptions(
    //       showChartValueBackground: true,
    //       showChartValues: true,
    //       showChartValuesInPercentage: false,
    //       showChartValuesOutside: true,
    //       decimalPlaces: 1,
    //     ),
    //   ),
    // );