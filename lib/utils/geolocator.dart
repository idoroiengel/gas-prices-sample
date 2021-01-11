import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class MyGeolocator {
  static Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      print(
          "Location permissions are permanently denied, we cannot request permissions.");
      return Future.error(
          "Location permissions are permanently denied, we cannot request permissions.");
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        print("Location permissions are denied (actual value: $permission).'");
        return Future.error(
            "Location permissions are denied (actual value: $permission).'");
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  Future<Position> getLastKnownPosition({bool forceLocationManager}) async {
    return await Geolocator.getLastKnownPosition(
      forceAndroidLocationManager: forceLocationManager,
    );
  }

  Stream<Position> getPositionStream(
      {LocationAccuracy desiredAccuracy,
      Duration timeLimit,
      Duration intervalDuration,
      bool forceAndroidLocationManager,
      int distanceFilter}) {
    return Geolocator.getPositionStream(
      forceAndroidLocationManager: forceAndroidLocationManager,
      desiredAccuracy: desiredAccuracy,
      timeLimit: timeLimit,
      distanceFilter: distanceFilter,
      intervalDuration: intervalDuration,
    );
  }

  double distanceBetween(LatLng startPosition, LatLng endPosition) {
    return Geolocator.distanceBetween(
      startPosition.latitude,
      startPosition.longitude,
      endPosition.latitude,
      endPosition.longitude,
    );
  }

  void bearingBetween(LatLng startPosition, LatLng endPosition) {
    Geolocator.bearingBetween(
      startPosition.latitude,
      startPosition.longitude,
      endPosition.latitude,
      endPosition.longitude,
    );
  }
}
