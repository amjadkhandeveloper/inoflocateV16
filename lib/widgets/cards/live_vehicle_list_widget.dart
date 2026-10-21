import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:infolocate/widgets/custom_toast.dart';

import '../custom_webview.dart';

class LiveVehicleListWidget extends StatelessWidget {
  final String vehicleNo;
  final String location;
  final String tracktime;
  final String? liveUrl;
  /// Kept for callers; availability is driven by [liveUrl] when non-empty.
  final bool enableVideo;
  const LiveVehicleListWidget({
    super.key,
    required this.vehicleNo,
    required this.location,
    required this.tracktime,
    this.liveUrl,
    this.enableVideo = false,
  });

  bool get _canPlayVideo => (liveUrl ?? '').trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final muted = AppUi.muted(context);
    final chipColor = _canPlayVideo
        ? AppUi.accent.withValues(alpha: 0.12)
        : muted.withValues(alpha: 0.12);
    final contentColor = _canPlayVideo ? AppUi.accent : muted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppUi.card(
        context: context,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppUi.iconChip(
                  icon: Icons.local_taxi_outlined,
                  size: 32,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    vehicleNo,
                    style: AppUi.body(context).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (!_canPlayVideo) {
                      customToast(
                          message: LocaliazationKey.video_unavailable.tr());
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(
                          title: vehicleNo,
                          url: liveUrl,
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.play_circle_fill_rounded,
                            size: 16, color: contentColor),
                        const SizedBox(width: 4),
                        Text(
                          LocaliazationKey.play_video.tr(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: contentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(location, style: AppUi.body(context)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 14, color: AppUi.muted(context)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(tracktime, style: AppUi.mutedStyle(context)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
