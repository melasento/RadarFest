import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

class LocationService {
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<MagnetometerEvent>? _magnetometerSub;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSub;

  double _lat = 0;
  double _lon = 0;
  double _heading = 0;
  double _magnetometerX = 0;
  double _magnetometerY = 0;
  double _gyroZ = 0;
  double _tiltLR = 0;
  double _tiltFB = 0;

  final _locationController = StreamController<Map<String, double>>.broadcast();
  Stream<Map<String, double>> get locationStream => _locationController.stream;

  double get lat => _lat;
  double get lon => _lon;
  double get heading => _heading;
  double get tiltLR => _tiltLR;
  double get tiltFB => _tiltFB;

  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }
    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  Future<void> startTracking() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return;

    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2,
    );

    _positionSub = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _lat = position.latitude;
      _lon = position.longitude;
      _notifyListeners();
    });

    _magnetometerSub = magnetometerEventStream().listen((MagnetometerEvent event) {
      _magnetometerX = event.x;
      _magnetometerY = event.y;
      _heading = _calculateHeading(event.x, event.y);
      _notifyListeners();
    });

    _gyroscopeSub = gyroscopeEventStream().listen((GyroscopeEvent event) {
      _gyroZ = event.z;
      _tiltLR = _clamp(event.x * (180 / pi), -90, 90);
      _tiltFB = _clamp(event.y * (180 / pi), -90, 90);
    });
  }

  double _calculateHeading(double x, double y) {
    double heading = atan2(y, x) * (180 / pi);
    heading = (heading + 360) % 360;
    return heading;
  }

  double _clamp(double value, double min, double max) {
    return value < min ? min : (value > max ? max : value);
  }

  void _notifyListeners() {
    if (!_locationController.isClosed) {
      _locationController.add({
        'lat': _lat,
        'lon': _lon,
        'heading': _heading,
      });
    }
  }

  void stopTracking() {
    _positionSub?.cancel();
    _magnetometerSub?.cancel();
    _gyroscopeSub?.cancel();
    _positionSub = null;
    _magnetometerSub = null;
    _gyroscopeSub = null;
  }

  void dispose() {
    stopTracking();
    _locationController.close();
  }

  static double distanceBetween(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  static double bearingBetween(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.bearingBetween(lat1, lon1, lat2, lon2);
  }
}
