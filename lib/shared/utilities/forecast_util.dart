import 'package:intl/intl.dart';
// tiện ích
// chứa function dùng chung cho việc format date và 
//tìm icon dựa trên tên thời tiết
class Util {
  static String getFormattedDate(DateTime dateTime) 
  // Nghĩa là không cần tạo đối tượng vẫn gọi được.
  {
    return DateFormat('EEE, MMM d').format(dateTime); //Tue, May 5, 2026
  }

  static String findIcon(String name, bool type) {
    // chọn icon thời tiết 
    if (type) {
      switch (name) {
        case "Clouds":
          return "assets/sunny.png";
        case "Rain":
          return "assets/rainy.png";
        case "Drizzle":
          return "assets/rainy.png";
        case "Thunderstorm":
          return "assets/thunder.png";
        case "Snow":
          return "assets/snow.png";
        default:
          return "assets/sunny.png";
      }
    } else {
      switch (name) {
        case "Clouds":
          return "assets/sunny_2d.png";
        case "Rain":
          return "assets/rainy_2d.png";
        case "Drizzle":
          return "assets/rainy_2d.png";
        case "Thunderstorm":
          return "assets/thunder_2d.png";
        case "Snow":
          return "assets/snow_2d.png";
        default:
          return "assets/sunny_2d.png";
      }
    }
  }
}
