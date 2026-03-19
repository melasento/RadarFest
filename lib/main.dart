import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const RadarFestApp());
}

class RadarFestApp extends StatelessWidget {
  const RadarFestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Radar Fest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00aaff),
        scaffoldBackgroundColor: const Color(0xFF050813),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00aaff),
          secondary: Color(0xFF00c0ff),
          surface: Color(0xFF07111f),
        ),
      ),
      home: const LandingScreen(),
    );
  }
}

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final TextEditingController _createNameController = TextEditingController();
  final TextEditingController _joinCodeController = TextEditingController();

  void _createGroup() {
    final name = _createNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci un nome per il gruppo')),
      );
      return;
    }
    // Per ora facciamo solo un passaggio a una schermata mock o print
    print('Creazione gruppo: $name');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RadarScreen(title: name, code: 'GNL8U7')),
    );
  }

  void _joinGroup() {
    final code = _joinCodeController.text.trim().toUpperCase();
    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci un codice valido')),
      );
      return;
    }
    print('Unione al gruppo: $code');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RadarScreen(title: 'Gruppo $code', code: code)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050813),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const Text(
                '\uD83D\uDCE1',
                style: TextStyle(fontSize: 56),
              ),
              const SizedBox(height: 16),
              const Text(
                'Radar Fest',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Trova i tuoi amici in tempo reale',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF4a7a99),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF07111f),
                  border: Border.all(color: const Color(0xFF1a3a4a)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '\u2728 Crea un gruppo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00c0ff),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _createNameController,
                      decoration: InputDecoration(
                        hintText: 'Nome gruppo (es. Gita Roma)',
                        hintStyle: const TextStyle(color: Color(0xFF4a7a99)),
                        filled: true,
                        fillColor: const Color(0xFF050813),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF1a3a4a)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF1a3a4a)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00e87a),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Crea gruppo'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF07111f),
                  border: Border.all(color: const Color(0xFF1a3a4a)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '\uD83D\uDD17 Entra con codice',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00c0ff),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _joinCodeController,
                      decoration: InputDecoration(
                        hintText: 'Codice (es. GNL8U7)',
                        hintStyle: const TextStyle(color: Color(0xFF4a7a99)),
                        filled: true,
                        fillColor: const Color(0xFF050813),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF1a3a4a)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFF1a3a4a)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 14),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _joinGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0077cc),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Unisciti al gruppo'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Nessun account \u00B7 Dati eliminati all\'uscita',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF4a7a99),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RadarScreen extends StatelessWidget {
  final String title;
  final String code;

  const RadarScreen({super.key, required this.title, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF02040A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07111f),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Codice: $code', style: const TextStyle(fontSize: 12, color: Color(0xFF00c0ff))),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF00c0ff)),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Radar Placeholder
UI in fase di sviluppo',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF4a7a99)),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 8, left: 12, right: 12, top: 8),
        color: const Color(0xFF050A14),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF3344),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 1),
          ),
          child: const Text('\u26A0 EMERGENZA SOS'),
        ),
      ),
    );
  }
}
