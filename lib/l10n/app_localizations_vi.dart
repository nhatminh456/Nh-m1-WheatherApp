// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get searchLocation => 'Tìm kiếm địa điểm';

  @override
  String get searchHint => 'Nhập tên thành phố (ví dụ: Hà Nội)...';

  @override
  String get searchHistory => 'Lịch sử tìm kiếm';

  @override
  String get favorites => 'Yêu thích';

  @override
  String get emptySearchHint => 'Vui lòng nhập tên thành phố!';

  @override
  String get noHistory => 'Chưa có lịch sử tìm kiếm';

  @override
  String get historyInstructions =>
      'Tìm kiếm các thành phố để xem thông tin thời tiết.';

  @override
  String get recent => 'Gần đây';

  @override
  String get clearAll => 'Xóa hết';

  @override
  String get clearHistoryDialogTitle => 'Xóa lịch sử?';

  @override
  String get clearHistoryDialogContent =>
      'Bạn có chắc chắn muốn xóa toàn bộ lịch sử tìm kiếm không?';

  @override
  String get cancel => 'Hủy';

  @override
  String get delete => 'Xóa';

  @override
  String get noFavorites => 'Chưa có địa điểm yêu thích';

  @override
  String get favoritesInstructions =>
      'Đánh dấu sao các thành phố để theo dõi nhanh thời tiết tại đây.';

  @override
  String get saved => 'Đã lưu';

  @override
  String get loadingWeather => 'Đang tải thời tiết...';
}
