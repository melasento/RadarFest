import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/storage_service.dart';
import 'radar_screen.dart';

class HomeScreen extends StatefulWidget {
  final StorageService storage;
  const HomeScreen({super.key, required this.storage});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameController = TextEditingController();
  final _groupController = TextEditingController();
  String _selectedShape = 'circle';
  String _selectedColor = '#00aaff';

  final List<Map<String, String>> _shapes = [
    {'id': 'circle', 'label': 'Cerchio'},
    {'id': 'square', 'label': 'Quadrato'},
    {'id': 'triangle', 'label': 'Triangolo'},
    {'id': 'star', 'label': 'Stella'},
    {'id': 'diamond', 'label': 'Diamante'},
  ];

  final List<String> _colors = [
    '#00aaff', '#ff4444', '#44ff44', '#ffaa00',
    '#ff00ff', '#00ffff', '#ffffff', '#ffff00',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.storage.userName ?? '';
    _groupController.text = widget.storage.groupId ?? '';
    _selectedShape = widget.storage.userShape;
    _selectedColor = widget.storage.userColor;
  }

  Future<void> _join() async {
    final name = _nameController.text.trim();
    final group = _groupController.text.trim();
    if (name.isEmpty || group.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci nome e gruppo')),
      );
      return;
    }

    String userId = widget.storage.userId ?? const Uuid().v4();
    await widget.storage.saveUserId(userId);
    await widget.storage.saveUserName(name);
    await widget.storage.saveGroupId(group);
    await widget.storage.saveUserShape(_selectedShape);
    await widget.storage.saveUserColor(_selectedColor);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RadarScreen(storage: widget.storage),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'RadarFest',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00aaff),
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Trova i tuoi amici al festival',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Il tuo nome'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _groupController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Codice gruppo'),
              ),
              const SizedBox(height: 24),
              const Text('Forma', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _shapes.map((s) {
                  final selected = s['id'] == _selectedShape;
                  return ChoiceChip(
                    label: Text(s['label']!),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedShape = s['id']!),
                    selectedColor: const Color(0xFF00aaff),
                    backgroundColor: const Color(0xFF1a1a2e),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.white54,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Colore', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _colors.map((c) {
                  final color = _hexToColor(c);
                  final selected = c == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = c),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _join,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00aaff),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'ENTRA',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF1a1a2e),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }
}
