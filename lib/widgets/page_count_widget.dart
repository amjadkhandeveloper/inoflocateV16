import 'package:flutter/material.dart';
import '../utils/app_ui.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppUi.cardColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppUi.line(context)),
      ),
      child: Text(
        pageCount ?? '',
        style: AppUi.mutedStyle(context).copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}
