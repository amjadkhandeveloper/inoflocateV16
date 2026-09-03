import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';

class PageCountWidget extends StatelessWidget {
  const PageCountWidget({
    super.key,
    this.pageCount,
  });

  final String? pageCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      // height: 20,
      decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.grey
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.customGrey)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
        child: Text(
          pageCount ?? '',
          style: AppStyles.textStyle5(context: context).copyWith(fontSize: 16),
        ),
      ),
    );
  }
}
