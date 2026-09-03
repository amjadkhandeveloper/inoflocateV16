import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class LazyLoadingProgressWidget extends StatelessWidget {
  const LazyLoadingProgressWidget({
    super.key,
    this.hasMoreData = false,
  });

  final bool hasMoreData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Center(
          child: hasMoreData ? const CircularProgressIndicator() : Container()
          // Text(
          //     LocaliazationKey.no_more_data.tr(),
          //     style: AppStyles.textStyle4(context: context),
          //   ),
          ),
    );
  }
}
