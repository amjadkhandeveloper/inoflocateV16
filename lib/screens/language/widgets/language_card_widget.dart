import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_ui.dart';

class LanguageSelectWidget extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final bool isEnglish;
  final TextTheme textTheme;

  final bool isFirstItem;
  final bool isLastItem;

  const LanguageSelectWidget({
    super.key,
    required this.textTheme,
    required this.title,
    required this.subTitle,
    required this.isEnglish,
    this.isFirstItem = false,
    this.isLastItem = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppUi.card(
      context: context,
      fill: isEnglish
          ? AppUi.accent.withValues(alpha: 0.12)
          : AppUi.cardColor(context),
      borderColor: isEnglish ? AppUi.accent : AppUi.line(context),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          AppUi.iconChip(
            icon: Icons.translate_rounded,
            color: isEnglish ? AppUi.accent : AppUi.muted(context),
            size: 36,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? '',
                  style: AppUi.body(context).copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppUi.ink(context),
                  ),
                ),
                if ((subTitle ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(subTitle!, style: AppUi.mutedStyle(context)),
                ],
              ],
            ),
          ),
          if (isEnglish)
            const Icon(
              Icons.check_circle_rounded,
              size: 22,
              color: AppUi.accent,
            ),
        ],
      ),
    );
  }
}
