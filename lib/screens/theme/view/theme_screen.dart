import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_ui.dart';
import '../../../utils/app_helper.dart';

class ThemeScreen extends StatelessWidget {
  static String routeName = '/themeRoute';
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppUi.pageBg(context),
      appBar: AppUi.appBar(
        context: context,
        title: LocaliazationKey.set_theme.tr(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          AppUi.card(
            context: context,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
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
                Divider(height: 1, color: AppUi.line(context)),
                ListTile(
                  leading: AppUi.iconChip(
                    icon: Icons.color_lens_outlined,
                    size: 36,
                  ),
                  title: Text(LocaliazationKey.appearance.tr(),
                      style: AppUi.body(context)),
                  trailing: Icon(Icons.chevron_right_rounded,
                      color: AppUi.muted(context)),
                  onTap: () async {
                    final pickedColor =
                        await AppHelper.showColorPicker(context: context);
                    if (pickedColor == null) return;
                    // ignore: use_build_context_synchronously
                    AppHelper().setCustomTheme(
                      context: context,
                      primaryColor: pickedColor,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
