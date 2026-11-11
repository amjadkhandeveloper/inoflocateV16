import 'model/get_countries_response_model.dart';
import 'model/language_model.dart';

/// Used when `{clientGatewayBaseUrl}/cntList` or `/lngList` cannot be reached.
///
/// Country ids here are only stored on the device for the language screen.
/// Login does not send them. India keeps the documented API id `104`.
class LanguageFallback {
  static const int india = 104;
  static const int japan = 392;
  static const int unitedStates = 840;
  static const int bangladesh = 50;
  static const int spain = 724;

  static List<GetCountriesResponseModelDataCountryList> get countries => [
        GetCountriesResponseModelDataCountryList(
            id: india, CountryName: 'India', isActive: true),
        GetCountriesResponseModelDataCountryList(
            id: japan, CountryName: 'Japan', isActive: true),
        GetCountriesResponseModelDataCountryList(
            id: unitedStates, CountryName: 'United States', isActive: true),
        GetCountriesResponseModelDataCountryList(
            id: bangladesh, CountryName: 'Bangladesh', isActive: true),
        GetCountriesResponseModelDataCountryList(
            id: spain, CountryName: 'Spain', isActive: true),
      ];

  static List<LanguageResponseModelDataLangListData> languagesFor(
      int? countryId) {
    switch (countryId) {
      case japan:
        return _langs(countryId, const ['Japanese', 'English']);
      case spain:
        return _langs(countryId, const ['Spanish', 'English']);
      case unitedStates:
        return _langs(countryId, const ['English', 'Spanish']);
      case bangladesh:
        return _langs(countryId, const ['Bangla', 'English']);
      case india:
        return _langs(countryId, const [
          'English',
          'Hindi',
          'Kannada',
          'Tamil',
          'Telugu',
          'Urdu',
          'Bangla',
        ]);
      default:
        return _langs(countryId, const [
          'English',
          'Hindi',
          'Kannada',
          'Tamil',
          'Telugu',
          'Urdu',
          'Bangla',
          'Japanese',
          'Spanish',
        ]);
    }
  }

  static List<LanguageResponseModelDataLangListData> _langs(
    int? countryId,
    List<String> names,
  ) {
    return [
      for (var i = 0; i < names.length; i++)
        LanguageResponseModelDataLangListData(
          languageId: (countryId ?? 0) * 100 + i,
          CountryId: countryId,
          Language: names[i],
          Langconvert: names[i],
          isActive: true,
        ),
    ];
  }
}
