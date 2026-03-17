import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/storage_service.dart';
import 'services/firebase_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'screens/radar_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await FirebaseService.init();
  await NotificationService.init();

  final storage = StorageService();
  await storage.init();

  runApp(RadarFestApp(storage: storage));
}

class RadarFestApp extends StatelessWidget {
  final StorageService storage;
  const RadarFestApp({super.key, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RadarFest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00aaff),
        scaffoldBackgroundColor: const Color(0xFF0a0a1a),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00aaff),
          secondary: Color(0xFF00aaff),
          surface: Color(0xFF1a1a2e),
        ),
        fontFamily: 'Roboto',
      ),
      home: storage.isSetupComplete
          ? RadarScreen(storage: storage)
          : HomeScreen(storage: storage),
    );
  }
}
