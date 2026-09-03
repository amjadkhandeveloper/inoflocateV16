import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import '../../../utils/app_helper.dart';

class ThemeScreen extends StatelessWidget {
  static String routeName = '/themeRoute';
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaliazationKey.set_theme.tr(),
            style:
                TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Theme.of(context).brightness == Brightness.dark
                ? Theme.of(context).cardColor
                : Colors.black12,
            height: 1.0,
          ),
        ),
        iconTheme: IconThemeData(color: Theme.of(context).iconTheme.color),
        centerTitle: true,
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              leading: Icon(
                CupertinoIcons.moon_circle_fill,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
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
            const Divider(
              thickness: 1,
            ),
            ListTile(
              leading: Icon(
                Icons.color_lens,
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
              title: Text(LocaliazationKey.appearance.tr()),
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
            const Divider(
              thickness: 1,
            ),
            // ElevatedButton(
            // ListTile(
            //   leading: Icon(
            //     CupertinoIcons.moon_circle_fill,
            //     color: Theme.of(context).colorScheme.primary,
            //     size: 30,
            //   ),
            //   title: const Text('Dark Mode'),
            //   trailing: CupertinoSwitch(
            //       value: isDark,
            //       onChanged: (value) {
            //         if (!isDark) {
            //           AdaptiveTheme.of(context).setDark();
            //         } else {
            //           AdaptiveTheme.of(context).setLight();
            //         }
            //       }),
            // ),
            //   onPressed: () => AdaptiveTheme.of(context).setDark(),
            //   style: ElevatedButton.styleFrom(
            //     visualDensity: const VisualDensity(horizontal: 4, vertical: 2),
            //   ),
            //   child: const Text('Set Dark'),
            // ),
            // const SizedBox(height: 8),
            // ElevatedButton(
            //   onPressed: () => AdaptiveTheme.of(context).setLight(),
            //   style: ElevatedButton.styleFrom(
            //     visualDensity: const VisualDensity(horizontal: 4, vertical: 2),
            //   ),
            //   child: const Text('Set Light'),
            // ),
            // ElevatedButton(
            //   onPressed: () async {
            //     final _pickedColor =
            //         await AppHelper.showColorPicker(context: context);
            //     if (_pickedColor == null) return;
            //     // ignore: use_build_context_synchronously
            //     AppHelper().setCustomTheme(
            //         context: context, primaryColor: _pickedColor);
            //   },
            //   style: ElevatedButton.styleFrom(
            //     visualDensity: const VisualDensity(horizontal: 4, vertical: 2),
            //   ),
            //   child: const Text('Set Custom Theme'),
            // ),
            // Text(
            //   'InfoLocate',
            //   style: AppStyles.infoLocateTextStyle(context: context),
            // ),
          ],
        ),
      ),
    );
  }
}
