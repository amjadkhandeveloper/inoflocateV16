import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_styles.dart';

import '../../../utils/app_colors.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            CustomNotificationWidget(
              notificaitonType: "Update Available",
              title: "App update",
              time: "22-05-2023 12:00:00",
              description: "Update the app to get the latest features!",
            ),
            CustomNotificationWidget(
              notificaitonType: "Alert Notification",
              title: "Over Speed",
              time: "25-05-2023 12:45:00",
              description: " 〒870-0823 大分県大分市東大道２丁目２−１５",
            ),
            CustomNotificationWidget(
              notificaitonType: "Vehicle Notification",
              title: "Moving",
              time: "27-05-2023 16:23:00",
              description: "Vehicle Changed from Idle to Moving",
            ),
            CustomNotificationWidget(
              notificaitonType: "Video Notificaiton",
              title: "Live Video",
              time: "28-05-202315:22:00",
              description:
                  "Now live video is available for Vehicle MCTEST-6270",
            ),
            CustomNotificationWidget(
              notificaitonType: "Vehicle Notification",
              title: "Ignition",
              time: "31-05-2023 16:23:00",
              description: "Now the Ignition is OFF for vehicle MCTEST-6270",
            ),
          ],
        ),
      ),
    );
  }
}

class CustomNotificationWidget extends StatelessWidget {
  final String notificaitonType;
  final String title;
  final String time;
  final String description;
  const CustomNotificationWidget({
    super.key,
    required this.notificaitonType,
    required this.title,
    required this.time,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.customGrey)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Icon(
                  Icons.notifications,
                  size: 32,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Expanded(
                flex: 6,
                child: Text(
                  notificaitonType,
                  style: AppStyles.textStyle3(context: context)
                      .copyWith(fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 18),
                  child: Text(
                    title,
                    style: AppStyles.textStyle2(context: context, fontSize: 16)
                        .copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  // mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.watch_later_outlined,
                      size: 15,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Expanded(
                      child: Text(
                        time,
                        style: AppStyles.textStyle5(
                          context: context,
                        ).copyWith(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? AppColors.darkGrey
                                    : null),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              description,
              style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.darkGrey
                      : Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
