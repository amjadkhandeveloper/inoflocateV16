import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/screens/forgot_password/view/forgot_password_screen.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_styles.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_helper.dart';
import '../../card_types_screen/controller/card_type_provider.dart';
import '../../card_types_screen/view/card_type_screen.dart';
import '../../language/view/select_language_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaliazationKey.setting.tr()),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaliazationKey.general.tr(),
                style: AppStyles.textStyle2(context: context),
              ),
              const SizedBox(
                height: 8,
              ),
              ListTile(
                leading: Icon(
                  Icons.mobile_screen_share_sharp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  LocaliazationKey.select_custom_card.tr(),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.primary,
                ),
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
                    // cardTypeProvider.initialiseCardSettings();
                    cardTypeProvider
                      ..setCurrentVehicleStatusCard()
                      ..setCurrentAlertStatusCard();
                  }
                },
              ),
              const Divider(
                thickness: 1,
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SelectLanguageScreen(
                        inDrawer: true,
                      ),
                    ),
                  );
                },
                leading: Icon(
                  Icons.translate,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(LocaliazationKey.language.tr()),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Divider(
                thickness: 1,
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(
                        isForgotPassword: false,
                      ),
                    ),
                  );
                },
                leading: Icon(
                  Icons.password,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  LocaliazationKey.reset_password.tr(),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(
                height: 24,
              ),
              Text(
                LocaliazationKey.theme.tr(),
                style: AppStyles.textStyle2(context: context),
              ),
              const SizedBox(
                height: 8,
              ),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListTile(
                      leading: Icon(
                        CupertinoIcons.moon_circle_fill,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24,
                      ),
                      title: Text(LocaliazationKey.dark_mode.tr()),
                      trailing: CupertinoSwitch(
                          value: isDark,
                          onChanged: (value) {
                            if (!isDark) {
                              AdaptiveTheme.of(context).setDark();
                            } else {
                              AdaptiveTheme.of(context).setLight();
                            }
                          }),
                    ),
                    // const Divider(
                    //   thickness: 1,
                    // ),
                    // ListTile(
                    //   leading: Icon(
                    //     Icons.color_lens,
                    //     color: Theme.of(context).colorScheme.primary,
                    //     size: 24,
                    //   ),
                    //   title: Text(LocaliazationKey.appearance.tr()),
                    //   onTap: () async {
                    //     final pickedColor =
                    //         await AppHelper.showColorPicker(context: context);
                    //     if (pickedColor == null) return;
                    //     // ignore: use_build_context_synchronously
                    //     AppHelper().setCustomTheme(
                    //       context: context,
                    //       primaryColor: pickedColor,
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
