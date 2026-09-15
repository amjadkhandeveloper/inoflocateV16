import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/animation/custom_fade_animation.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_styles.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:lottie/lottie.dart';

/// Shared user profile dialog used by Home and Sequel dashboards.
Future<void> showUserProfileDialog(
  BuildContext context,
  String selectedLanguage,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CustomFadeScaleTransition(
        duration: const Duration(milliseconds: 400),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LottieBuilder.asset(
                    'assets/animation/user_animation.json',
                    repeat: false,
                    width: 120,
                    height: 120,
                    fit: BoxFit.fill,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          LocaliazationKey.user_name.tr(),
                          style: AppStyles.textStyle5(
                              context: context, isBold: false),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          Global.savedUserAuthData?.username ?? '',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          LocaliazationKey.selected_language.tr(),
                          style: AppStyles.textStyle5(
                              context: context, isBold: false),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(selectedLanguage),
                      ),
                    ],
                  ),
                  const SizedBox(height: 38),
                ],
              ),
              Positioned(
                right: 2,
                top: 0,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.cancel_outlined,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class ProfileAvatarButton extends StatelessWidget {
  const ProfileAvatarButton({super.key, required this.selectedLanguage});
  final String selectedLanguage;

  @override
  Widget build(BuildContext context) {
    final user = Global.savedUserAuthData?.username ?? '';
    return GestureDetector(
      onTap: () => showUserProfileDialog(context, selectedLanguage),
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: AppUi.accent.withValues(alpha: 0.12),
          child: user.isNotEmpty
              ? Text(
                  user.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppUi.accent,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : const Icon(
                  Icons.person_outline_rounded,
                  color: AppUi.accent,
                  size: 18,
                ),
        ),
      ),
    );
  }
}
