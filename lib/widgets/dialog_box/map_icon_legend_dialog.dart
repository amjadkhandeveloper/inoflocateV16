import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_styles.dart';

Future<void> showMapIconLegendDialog(BuildContext context) {
  final primary = Theme.of(context).colorScheme.primary;
  final items = <_LegendItem>[
    _LegendItem(
      icon: SvgPicture.asset(
        'assets/icons/new_icons/green.svg',
        height: 22,
        colorFilter: const ColorFilter.mode(Colors.green, BlendMode.srcIn),
      ),
      label: LocaliazationKey.speed.tr(),
    ),
    _LegendItem(
      icon: SvgPicture.asset(
        'assets/icons/ignition.svg',
        height: 22,
        colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
      ),
      label: LocaliazationKey.ignition.tr(),
    ),
    _LegendItem(
      icon: SvgPicture.asset(
        'assets/icons/odometer.svg',
        height: 22,
        colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
      ),
      label: LocaliazationKey.odometer.tr(),
    ),
    _LegendItem(
      icon: SvgPicture.asset(
        'assets/icons/enginedelay.svg',
        height: 22,
        colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
      ),
      label: LocaliazationKey.engine_delay.tr(),
    ),
    _LegendItem(
      icon: SvgPicture.asset(
        'assets/icons/idle-duration.svg',
        height: 22,
        colorFilter: ColorFilter.mode(primary, BlendMode.srcIn),
      ),
      label: LocaliazationKey.idle_duration.tr(),
    ),
    _LegendItem(
      icon: Icon(Icons.power_off_rounded, size: 22, color: primary),
      label: LocaliazationKey.stop_duration.tr(),
    ),
  ];

  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          LocaliazationKey.map_status_icons.tr(),
          style: AppStyles.textStyle4(
            context: dialogContext,
            isBold: true,
            size: 18,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in items)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(width: 28, child: Center(child: item.icon)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.label,
                          style: AppStyles.textStyle4(
                            context: dialogContext,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              LocaliazationKey.done.tr(),
              style: AppStyles.textStyle4(context: dialogContext),
            ),
          ),
        ],
      );
    },
  );
}

class _LegendItem {
  const _LegendItem({required this.icon, required this.label});

  final Widget icon;
  final String label;
}

/// Compact info control for vehicle cards / icon rows.
class MapIconLegendButton extends StatelessWidget {
  const MapIconLegendButton({
    super.key,
    this.color,
    this.size = 22,
    this.padding = const EdgeInsets.all(8),
  });

  final Color? color;
  final double size;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Theme.of(context).colorScheme.primary;
    return Tooltip(
      message: LocaliazationKey.map_status_icons.tr(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showMapIconLegendDialog(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: padding,
            child: Icon(
              Icons.info_outline,
              color: iconColor,
              size: size,
            ),
          ),
        ),
      ),
    );
  }
}
