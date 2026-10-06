import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_ui.dart';

class PoweredByTextWidget extends StatelessWidget {
  const PoweredByTextWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '© 2026 Infotrack Telematics Pvt. Ltd.',
          style: AppUi.mutedStyle(context),
        ),
        Text(
          'All rights reserved.',
          style: AppUi.mutedStyle(context),
        ),
      ],
    );
  }
}
