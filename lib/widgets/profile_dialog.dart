import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/animation/custom_fade_animation.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_styles.dart';
import 'package:infolocate/utils/app_ui.dart';

/// Shared user profile dialog used by Home and Sequel dashboards.
Future<void> showUserProfileDialog(
  BuildContext context,
  String selectedLanguage,
) {
  final username = Global.savedUserAuthData?.username ?? '';
  final initials = AppHelper.usernameInitials(username, spaced: true);

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
                  const SizedBox(height: 28),
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: AppUi.toolbarLight,
                    child: Text(
                      initials.isEmpty ? '?' : initials,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppUi.toolbarFg,
                        fontWeight: FontWeight.w700,
                        fontSize: initials.length > 3 ? 16 : 22,
                        letterSpacing: initials.contains(' ') ? 1.5 : 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
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
                        child: Text(username),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          LocaliazationKey.last_login.tr(),
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
                          AppHelper.formatLastLogin(Global.savedLastLoginTime),
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
    final initials = AppHelper.usernameInitials(user);
    return GestureDetector(
      onTap: () => showUserProfileDialog(context, selectedLanguage),
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: CircleAvatar(
          radius: 16,
          backgroundColor: AppUi.toolbarFg,
          child: initials.isNotEmpty
              ? Text(
                  initials,
                  style: TextStyle(
                    color: AppUi.toolbarLight,
                    fontWeight: FontWeight.w700,
                    fontSize: initials.length >= 3 ? 9 : 12,
                    height: 1,
                  ),
                )
              : const Icon(
                  Icons.person_outline_rounded,
                  color: AppUi.toolbarLight,
                  size: 18,
                ),
        ),
      ),
    );
  }
}
