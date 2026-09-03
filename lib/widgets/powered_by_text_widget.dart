import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

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
        Text.rich(TextSpan(children: [
          TextSpan(text: '${LocaliazationKey.powered_by.tr()}\t'),
          TextSpan(
            text: 'InfoTrack',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Theme.of(context).colorScheme.primary,),
          ),
        ])),
        const Text(
          '@2025 copyright',
          style: TextStyle(fontSize: 14),
        ),
        // const   Text(
        //     '${LocaliazationKey.version} 1.0',
        //     style: TextStyle(color: Colors.grey),
        //   ),
      ],
    );
  }
}
