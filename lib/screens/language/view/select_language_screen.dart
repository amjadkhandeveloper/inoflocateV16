// ignore_for_file: use_build_context_synchronously
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/screens/intro/view/intro_view.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_routes.dart';
import 'package:infolocate/utils/app_ui.dart';
import 'package:infolocate/widgets/custom_toast.dart';
import 'package:provider/provider.dart';

import '../../../utils/app_globals.dart';
import '../../../utils/enums.dart';
import '../../../widgets/error_widget.dart';
import '../controller/language_provider.dart';
import '../widgets/language_card_widget.dart';

/// Onboarding language picker (also reachable from drawer when [inDrawer] is true).
///
/// On first launch: country list → language list → save to Hive → client login.
class SelectLanguageScreen extends StatefulWidget {
  static String routeName = '/languageRoute';
  final bool inDrawer;

  const SelectLanguageScreen({Key? key, required this.inDrawer})
      : super(key: key);

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () => getLanguageData());
    super.initState();
  }

  getLanguageData() async {
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    await languageProvider.getCountries();

    print("Language Provider list ${languageProvider.langaugeList!}");

    if (Global.savedContryCode != null) {
      selectedCountry = languageProvider.countryList.firstWhere(
        (element) => element.countryCode == Global.savedContryCode,
      );

      if (selectedCountry != null) {
        await languageProvider.getLanguages(
          countryId: selectedCountry!.countryCode,
        );
        languageProvider.setCurrentLanguage();
      } else {
        print("No matching country found for code: ${Global.savedContryCode}");
      }
    }
  }

  CustomCountry? selectedCountry;

  Future<void> _confirm(LanguageProvider languageProvider) async {
    if (selectedCountry == null) {
      customToast(message: LocaliazationKey.please_select_country.tr());
      return;
    }
    if (languageProvider.langaugeList!.any(
      (language) => language!.isSelected == true,
    )) {
      print("lang");
      print(
          "🗣 Available Languages: ${languageProvider.currentLanguage!.langCode!}");
      print("🔤 Selected Language: ${selectedCountry!.countryCode}");
      print("🏳️ Selected Country: $selectedCountry");

      if (languageProvider.currentLanguage != null) {
        await context
            .setLocale(Locale(languageProvider.currentLanguage!.langCode!));
      } else {
        await context.setLocale(const Locale('ar'));
      }
      if (selectedCountry != null) {
        await Global.box
            .put(countryCodeKey, selectedCountry!.countryCode);
      } else {
        print("⚠️ Error: No selected country found.");
      }

      await AppHelper.getHiveBoxData();

      AppHelper().setCustomTheme(
          context: context,
          primaryColor: Theme.of(context).colorScheme.primary,
          fontFamily: languageProvider.currentLanguage!.langCode == 'ja'
              ? meiryo
              : montserrat);
    } else {
      customToast(message: LocaliazationKey.please_select_language.tr());
      return;
    }
    widget.inDrawer
        ? Navigator.of(context).pushNamedAndRemoveUntil(
            AppRoutes.dashboardRoute(), (route) => false)
        : Navigator.of(context).pushNamedAndRemoveUntil(
            IntroScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider = Provider.of<LanguageProvider>(context);
    final data = languageProvider.countryList;
    print("Data $data, ${languageProvider.currentLanguage}");
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppUi.pageBg(context),
      body: SafeArea(
        child: Column(
          children: [
            AppUi.pageHeader(
              context: context,
              title: LocaliazationKey.select_language.tr(),
              subtitle: LocaliazationKey.select_country.tr(),
              onBack: widget.inDrawer
                  ? () => Navigator.of(context).pop()
                  : null,
            ),
            Expanded(
              child: languageProvider.state == NotifierState.loading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppUi.accent),
                    )
                  : languageProvider.state == NotifierState.error
                      ? CustomErrorWidget(
                          onPressed: getLanguageData,
                          errorMsg: languageProvider.failure.message,
                        )
                      : data.isEmpty
                          ? CustomErrorWidget(
                              onPressed: getLanguageData,
                              errorMsg:
                                  LocaliazationKey.bad_response_format.tr(),
                            )
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              children: [
                                Text(
                                  LocaliazationKey.select_country.tr(),
                                  style: AppUi.sectionLabel(context),
                                ),
                                const SizedBox(height: 8),
                                AppUi.card(
                                  context: context,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<CustomCountry>(
                                      hint: Text(
                                        LocaliazationKey.select_country_hint
                                            .tr(),
                                        style: AppUi.subtitle(context),
                                      ),
                                      isExpanded: true,
                                      value: selectedCountry,
                                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                                          color: AppUi.ink(context)),
                                      dropdownColor: AppUi.cardColor(context),
                                      onChanged:
                                          (CustomCountry? newValue) async {
                                        selectedCountry = newValue!;
                                        setState(() {});

                                        await languageProvider.getLanguages(
                                            countryId:
                                                selectedCountry!.countryCode);
                                        languageProvider.setCurrentLanguage();
                                      },
                                      style: AppUi.body(context),
                                      items: languageProvider.countryList
                                          .map<DropdownMenuItem<CustomCountry>>(
                                              (CustomCountry item) {
                                        return DropdownMenuItem<CustomCountry>(
                                          value: item,
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                item.imageUrl,
                                                height: 24,
                                              ),
                                              const SizedBox(width: 10),
                                              Flexible(
                                                child: Text(
                                                  item.countryName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                if (languageProvider
                                    .langaugeList!.isNotEmpty) ...[
                                  const SizedBox(height: 20),
                                  Text(
                                    LocaliazationKey.available_languages.tr(),
                                    style: AppUi.sectionLabel(context),
                                  ),
                                  const SizedBox(height: 8),
                                  ...List.generate(
                                    languageProvider.langaugeList!.length,
                                    (index) {
                                      final language = languageProvider
                                          .langaugeList![index];
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: GestureDetector(
                                          onTap: () {
                                            languageProvider.selectLanguage(
                                                langaugeCode: kLangaugeCode[
                                                    language.Language]);
                                          },
                                          child: LanguageSelectWidget(
                                            textTheme: textTheme,
                                            title: language!.Language,
                                            subTitle:
                                                language.Langconvert ?? "",
                                            isEnglish: language.isSelected!,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                                const SizedBox(height: 16),
                                AppUi.primaryButton(
                                  title: LocaliazationKey.confirm.tr(),
                                  onPressed: () => _confirm(languageProvider),
                                ),
                              ],
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
