import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/screens/forgot_password/view/forgot_password_screen.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:provider/provider.dart';

import '../../card_types_screen/controller/card_type_provider.dart';
import '../../card_types_screen/view/card_type_screen.dart';
import '../../language/view/select_language_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppUi.pageBg(context),
      appBar: AppUi.appBar(
        context: context,
        title: LocaliazationKey.setting.tr(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Text(LocaliazationKey.general.tr(),
              style: AppUi.sectionLabel(context)),
          const SizedBox(height: 8),
          AppUi.card(
            context: context,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.dashboard_customize_outlined,
                  title: LocaliazationKey.select_custom_card.tr(),
                  onTap: () async {
                    var res = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CardTypesScreen(),
                        ));
                    if (res == null) {
                      final cardTypeProvider =
                          // ignore: use_build_context_synchronously
                          Provider.of<CardTypeProvider>(context, listen: false);
                      cardTypeProvider
                        ..setCurrentVehicleStatusCard()
                        ..setCurrentAlertStatusCard();
                    }
                  },
                ),
                Divider(height: 1, color: AppUi.line(context)),
                _SettingsTile(
                  icon: Icons.translate_rounded,
                  title: LocaliazationKey.language.tr(),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SelectLanguageScreen(
                          inDrawer: true,
                        ),
                      ),
                    );
                  },
                ),
                Divider(height: 1, color: AppUi.line(context)),
                _SettingsTile(
                  icon: Icons.password_rounded,
                  title: LocaliazationKey.reset_password.tr(),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(
                          isForgotPassword: false,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(LocaliazationKey.theme.tr(),
              style: AppUi.sectionLabel(context)),
          const SizedBox(height: 8),
          AppUi.card(
            context: context,
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: AppUi.iconChip(
                icon: CupertinoIcons.moon_fill,
                size: 36,
              ),
              title: Text(LocaliazationKey.dark_mode.tr(),
                  style: AppUi.body(context)),
              trailing: CupertinoSwitch(
                  activeColor: AppUi.accent,
                  value: isDark,
                  onChanged: (value) {
                    if (!isDark) {
                      AdaptiveTheme.of(context).setDark();
                    } else {
                      AdaptiveTheme.of(context).setLight();
                    }
                  }),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: AppUi.iconChip(icon: icon, size: 36),
      title: Text(title, style: AppUi.body(context)),
      trailing: Icon(Icons.chevron_right_rounded, color: AppUi.muted(context)),
    );
  }
}
