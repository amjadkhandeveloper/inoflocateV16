// ignore_for_file: use_build_context_synchronously
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:infolocate/screens/intro/view/intro_view.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import 'package:infolocate/utils/app_routes.dart';
import 'package:infolocate/widgets/custom_toast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../utils/app_globals.dart';
import '../../../utils/app_styles.dart';
import '../../../utils/enums.dart';
import '../../../widgets/buttons/custom_button.dart';
import '../../../widgets/error_widget.dart';
import '../controller/language_provider.dart';
import '../widgets/language_card_widget.dart';

/// Onboarding language picker (also reachable from drawer when [inDrawer] is true).
///
/// On first launch: country list → language list → save to Hive → client login.
class SelectLanguageScreen extends StatefulWidget {
  static String routeName = '/languageRoute';
  final bool inDrawer;

  const SelectLanguageScreen({Key? key, required this.inDrawer}) : super(key: key);

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
    LanguageProvider languageProvider = Provider.of<LanguageProvider>(context, listen: false);

    // Fetch countries
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

  @override
  Widget build(BuildContext context) {
    LanguageProvider languageProvider = Provider.of<LanguageProvider>(context);
    final data = languageProvider.countryList;
    print("Data $data, ${languageProvider.currentLanguage}");
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 24,
        elevation: 0,
        leading: widget.inDrawer == true
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
            : Container(
                width: 1,
              ),
        title: Text(LocaliazationKey.select_language.tr(),
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color)),
        backgroundColor: Colors.transparent,
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
      body: languageProvider.state == NotifierState.loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : languageProvider.state != NotifierState.error
              ? data.isEmpty
                  ? CustomErrorWidget(
                      onPressed: getLanguageData,
                      errorMsg: LocaliazationKey.bad_response_format.tr(),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    LocaliazationKey.select_country.tr(),
                                    style: AppStyles.textStyle4(context: context, size: 18),
                                  ),
                                  SizedBox(
                                    height: 2.h,
                                  ),
                                  Container(
                                    // height: 50,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.black26
                                              : Colors.grey.withOpacity(0.2),
                                          spreadRadius: 5,
                                          blurRadius: 10,
                                          offset: const Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    width: 100.w,
                                    child: DropdownButton<CustomCountry>(
                                      hint: Text(LocaliazationKey.select_country_hint.tr()),
                                      underline: Container(),
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      isExpanded: true,
                                      value: selectedCountry,
                                      onChanged: (CustomCountry? newValue) async {
                                        // When the user selects a different item, update the selectedItem
                                        selectedCountry = newValue!;
                                        setState(() {});

                                        await languageProvider.getLanguages(
                                            countryId: selectedCountry!.countryCode);
                                        languageProvider.setCurrentLanguage();
                                      },
                                      style: textTheme.titleMedium,
                                      items: languageProvider.countryList
                                          .map<DropdownMenuItem<CustomCountry>>(
                                              (CustomCountry item) {
                                        return DropdownMenuItem<CustomCountry>(
                                          value: item,
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                item.imageUrl,
                                                // width: 40,
                                                height: 28,
                                                // fit: BoxFit.cover,
                                              ),
                                              const SizedBox(width: 10),
                                              Text(item.countryName),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              if (languageProvider.langaugeList!.isNotEmpty)
                                Text(
                                  LocaliazationKey.available_languages.tr(),
                                  style: AppStyles.textStyle4(context: context, size: 18),
                                ),
                              if (languageProvider.langaugeList!.isNotEmpty)
                                SizedBox(
                                  height: 2.h,
                                ),
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.black26
                                          : Colors.grey.withOpacity(0.2),
                                      spreadRadius: 5,
                                      blurRadius: 10,
                                      offset: const Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: ListView.separated(
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      var language = languageProvider.langaugeList![index];
                                      return GestureDetector(
                                        onTap: () {
                                          languageProvider.selectLanguage(
                                              langaugeCode: kLangaugeCode[language.Language]);
                                        },
                                        child: LanguageSelectWidget(
                                          isFirstItem: index == 0,
                                          isLastItem:
                                              index == languageProvider.langaugeList!.length - 1,
                                          key: UniqueKey(),
                                          textTheme: textTheme,
                                          title: language!.Language,
                                          subTitle: language.Langconvert ?? "",
                                          isEnglish: language.isSelected!,
                                          // imageUrl: language.image!,
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) => const Divider(
                                          thickness: 1,
                                          height: 0,
                                        ),
                                    itemCount: languageProvider.langaugeList!.length),
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CustomButton(
                                  key: UniqueKey(),
                                  title: LocaliazationKey.confirm.tr(),
                                  onPressed: () async {
                                    if (selectedCountry == null) {
                                      customToast(
                                          message: LocaliazationKey.please_select_country.tr());
                                      return;
                                    }
                                    if (languageProvider.langaugeList!.any(
                                      (language) => language!.isSelected == true,
                                    )) {
                                      // log("**************************************");
                                      // log(languageProvider
                                      //     .currentLanguage!.langCode!);

                                      print("lang");
                                      print("🗣 Available Languages: ${languageProvider.currentLanguage!.langCode!}");
                                      print("🔤 Selected Language: ${selectedCountry!.countryCode}");
                                      print("🏳️ Selected Country: $selectedCountry");

                                      if (languageProvider.currentLanguage != null) {
                                        await context.setLocale(Locale(languageProvider.currentLanguage!.langCode!));
                                      } else {
                                        await context.setLocale(Locale('ar'));
                                      }
                                      if (selectedCountry != null) {
                                        await Global.box.put(countryCodeKey, selectedCountry!.countryCode);
                                      } else {
                                        print("⚠️ Error: No selected country found.");
                                      }

                                      await AppHelper.getHiveBoxData();

                                      // print(languageProvider.currentLanguage!.langCode!);
                                      // print(languageCodeKey);
                                      // print(languageCodeKey);
                                      // print(countryCodeKey);

                                      AppHelper().setCustomTheme(
                                          context: context,
                                          primaryColor: Theme.of(context).colorScheme.primary,
                                          fontFamily:
                                              languageProvider.currentLanguage!.langCode == 'ja'
                                                  ? meiryo
                                                  : montserrat);
                                    } else {
                                      customToast(
                                          message: LocaliazationKey.please_select_language.tr());
                                      return;
                                    }
                                    // if (isEnglish) {
                                    //   await context.setLocale(const Locale('en', 'US'));

                                    //   languageProvider.onLanguagesChanged();
                                    // } else {
                                    //   await context.setLocale(const Locale('ja', 'JA'));
                                    //   languageProvider.onLanguagesChanged();
                                    // }
                                    widget.inDrawer
                                        ? Navigator.of(context).pushNamedAndRemoveUntil(
                                            AppRoutes.dashboardRoute(), (route) => false)
                                        : Navigator.of(context).pushNamedAndRemoveUntil(
                                            IntroScreen.routeName, (route) => false);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
              : CustomErrorWidget(
                  onPressed: () {
                    getLanguageData();
                  },
                  errorMsg: languageProvider.failure.message,
                ),
    );
  }
}
