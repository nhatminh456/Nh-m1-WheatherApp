import 'dart:developer';

import 'package:geolocator/geolocator.dart';
// Lấy vị trí hiện tại của GPS, xin quyền truy cập và lấy tọa độ 
// người dùng.
// Ta dùng Geolocator package để lấy vị trí hiện tại của người dùng.
class Location {
  double? latitude; // vĩ độ
  double? longitude; // kinh độ

  Future<void> getCurrentLocation() async {
    try {
      // xin quyền 
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception('Location services are disabled.');
      }
      // hỏi người dùng cho truy cập tọa độ ko
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }
     // nếu không cho vĩnh viễn thì báo lỗi 
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }
      // lấy vị trí hiện tại của người dùng 
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      ).timeout(const Duration(seconds: 15));

      latitude = position.latitude;
      longitude = position.longitude;
    } catch (e) {
      log('Something goes wrong: $e');
    }
  }
}
