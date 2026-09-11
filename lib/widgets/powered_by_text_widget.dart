import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_ui.dart';

import '../utils/app_localization_key.dart';

class PoweredByTextWidget extends StatelessWidget {
  const PoweredByTextWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: '${LocaliazationKey.powered_by.tr()} ',
              style: AppUi.mutedStyle(context),
            ),
            const TextSpan(
              text: 'InfoTrack',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppUi.accent,
              ),
            ),
          ]),
        ),
        const SizedBox(height: 4),
        Text(
          '@2025 copyright',
          style: AppUi.mutedStyle(context),
        ),
      ],
    );
  }
}
