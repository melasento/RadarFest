import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pin.dart';

class StorageService {
  static const String _keyUserId = 'userId';
  static const String _keyUserName = 'userName';
  static const String _keyGroupId = 'groupId';
  static const String _keyUserShape = 'userShape';
  static const String _keyUserColor = 'userColor';
  static const String _keyPins = 'pins';
  static const String _keyFcmToken = 'fcmToken';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? get userId => _prefs?.getString(_keyUserId);
  String? get userName => _prefs?.getString(_keyUserName);
  String? get groupId => _prefs?.getString(_keyGroupId);
  String get userShape => _prefs?.getString(_keyUserShape) ?? 'circle';
  String get userColor => _prefs?.getString(_keyUserColor) ?? '#00aaff';
  String? get fcmToken => _prefs?.getString(_keyFcmToken);

  Future<void> saveUserId(String id) async {
    await _prefs?.setString(_keyUserId, id);
  }

  Future<void> saveUserName(String name) async {
    await _prefs?.setString(_keyUserName, name);
  }

  Future<void> saveGroupId(String id) async {
    await _prefs?.setString(_keyGroupId, id);
  }

  Future<void> saveUserShape(String shape) async {
    await _prefs?.setString(_keyUserShape, shape);
  }

  Future<void> saveUserColor(String color) async {
    await _prefs?.setString(_keyUserColor, color);
  }

  Future<void> saveFcmToken(String token) async {
    await _prefs?.setString(_keyFcmToken, token);
  }

  Future<void> savePins(List<Pin> pins) async {
    final json = pins.map((p) => p.toJson()).toList();
    await _prefs?.setString(_keyPins, jsonEncode(json));
  }

  List<Pin> loadPins() {
    final raw = _prefs?.getString(_keyPins);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((j) => Pin.fromJson(j as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  bool get isSetupComplete =>
      userId != null && userName != null && groupId != null;

  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
