// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get searchLocation => 'Search Location';

  @override
  String get searchHint => 'Enter city name (e.g. London)...';

  @override
  String get searchHistory => 'Search History';

  @override
  String get favorites => 'Favorites';

  @override
  String get emptySearchHint => 'Please enter a city name!';

  @override
  String get noHistory => 'No search history';

  @override
  String get historyInstructions =>
      'Search for cities to view weather information.';

  @override
  String get recent => 'Recent';

  @override
  String get clearAll => 'Clear All';

  @override
  String get clearHistoryDialogTitle => 'Clear history?';

  @override
  String get clearHistoryDialogContent =>
      'Are you sure you want to clear your entire search history?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get noFavorites => 'No favorite locations';

  @override
  String get favoritesInstructions =>
      'Star cities to quickly track their weather here.';

  @override
  String get saved => 'Saved';

  @override
  String get loadingWeather => 'Loading weather...';
}
