import 'dart:developer';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:infolocate/common_models/failure_model.dart';
import 'package:infolocate/screens/language/model/language_model.dart';
import 'package:infolocate/screens/language/repository/language_service.dart';
import 'package:infolocate/utils/app_constants.dart';
import 'package:infolocate/utils/app_globals.dart';
import 'package:infolocate/utils/app_helper.dart';
import 'package:infolocate/utils/app_localization_key.dart';
import '../../../utils/enums.dart';
import '../../../widgets/custom_toast.dart';
import '../language_fallback.dart';

/// State for country/language selection and persistence to Hive.
///
/// - [getCountries] loads dropdown on language screen open.
/// - [getLanguages] loads languages after country is picked.
/// - Selected codes are saved via screen → [Global.box] ([languageCodeKey], [countryCodeKey]).
class LanguageProvider extends ChangeNotifier with StateInterface {
  NotifierState _state = NotifierState.initial;
  Failure? _failure;

  NotifierState get state => _state;

  Failure get failure => _failure ?? Failure('');

  @override
  void setState(NotifierState state) {
    _state = state;
    notifyListeners();
  }

  @override
  void setFailure(Failure failure) {
    _countryList = [];
    setState(NotifierState.error);
    final msg = (failure.message ?? '').trim().isEmpty
        ? LocaliazationKey.no_internet_connection.tr()
        : failure.message!;
    customToast(message: msg);
    _failure = Failure(msg);
    notifyListeners();
  }

  List<LanguageResponseModelDataLangListData?>? _langaugeList = [];

  List<CustomCountry> _countryList = [];
  bool _offlineLists = false;

  String _selectedLanguage = "English";

  String get selectedLanguage => _selectedLanguage;

  List<LanguageResponseModelDataLangListData?>? get langaugeList => [..._langaugeList ?? []];

  List<CustomCountry> get countryList => [..._countryList];

  /// Fetches countries from [getCountryListUrl] and maps flags via [AppHelper.returnCountryFlag].
  ///
  /// The gateway on port 7009 is often unreachable. A bundled list is shown
  /// instead of leaving the screen on the server-error state.
  Future<void> getCountries() async {
    setState(NotifierState.loading);
    try {
      final result = await LanguageService().getCountriesList();
      final apiCountries = result?.countryList;
      if (apiCountries != null && apiCountries.isNotEmpty) {
        _countryList = [
          for (final country in apiCountries)
            if (country != null)
              CustomCountry(
                imageUrl: AppHelper.returnCountryFlag(
                    title: country.CountryName.toString()),
                countryName: country.CountryName.toString(),
                countryCode: country.id,
              ),
        ];
        if (_countryList.isNotEmpty) {
          _offlineLists = false;
          setState(NotifierState.loaded);
          return;
        }
      }
    } catch (err) {
      log('Country list unavailable, using offline list: $err');
    }
    _offlineLists = true;
    _countryList = [
      for (final country in LanguageFallback.countries)
        CustomCountry(
          imageUrl: AppHelper.returnCountryFlag(
              title: country.CountryName.toString()),
          countryName: country.CountryName.toString(),
          countryCode: country.id,
        ),
    ];
    setState(NotifierState.loaded);
  }

  /// Fetches languages for [countryId] from [getLanguageListUrl].
  /// Falls back to the bundled list for that country when the API fails.
  Future<void> getLanguages({required int? countryId}) async {
    setState(NotifierState.loading);
    if (_offlineLists) {
      _langaugeList = LanguageFallback.languagesFor(countryId);
      setState(NotifierState.loaded);
      return;
    }
    try {
      final result =
          await LanguageService().getLanguageList(countryId: countryId);
      final apiLanguages = result?.langListData;
      if (apiLanguages != null && apiLanguages.isNotEmpty) {
        _langaugeList = apiLanguages;
        setState(NotifierState.loaded);
        return;
      }
    } catch (err) {
      log('Language list unavailable, using offline list: $err');
    }
    _langaugeList = LanguageFallback.languagesFor(countryId);
    setState(NotifierState.loaded);
  }

  Language? get currentLanguage {
    try {
      _langaugeList!.forEach((element) {
        // log(element!.isSelected.toString());
      });
      final lang = _langaugeList!.firstWhere(
        (element) {
          // log(element!.isSelected.toString());
          //  log(element.isSelected.toString());
          return element!.isSelected == true;
        },
        // orElse: () => _langaugeList!.first,
      );
      return Language(langCode: kLangaugeCode[lang!.Language]);
    } catch (err) {
      log(err.toString());
      return null;
    }
  }

  setCurrentLanguage() {
    if (Global.savedLanguageCode == null) return;
    for (var _lang in _langaugeList!) {
      if (kLangaugeCode[_lang!.Language] == Global.savedLanguageCode) {
        _lang.isSelected = true;
        _selectedLanguage = _lang.Language.toString();
        notifyListeners();
      } else {
        _lang.isSelected = false;
        notifyListeners();
      }
    }
  }

  onLanguagesChanged() {
    notifyListeners();
  }

  selectLanguage({required String? langaugeCode}) async {
    for (var langauge in _langaugeList!) {
      langauge!.isSelected = false;
      if (kLangaugeCode[langauge.Language] == langaugeCode) {
        langauge.isSelected = true;
        _selectedLanguage = langauge.Language.toString();
      } else {
        langauge.isSelected = false;
      }
    }

    notifyListeners();
  }
}

/// Country row model for the language screen dropdown (flag + name + API id).
class CustomCountry {
  final String imageUrl;
  final String countryName;
  final int? countryCode;

  CustomCountry({required this.imageUrl, required this.countryName, required this.countryCode});
}
