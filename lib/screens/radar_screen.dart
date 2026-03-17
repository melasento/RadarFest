import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/friend.dart';
import '../models/pin.dart';
import '../services/location_service.dart';
import '../services/mqtt_service.dart';
import '../services/storage_service.dart';
import '../services/firebase_service.dart';
import '../widgets/radar_painter.dart';
import 'friends_screen.dart';

class RadarScreen extends StatefulWidget {
  final StorageService storage;
  const RadarScreen({super.key, required this.storage});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen>
    with TickerProviderStateMixin {
  late LocationService _locationService;
  late MqttService _mqttService;
  late AnimationController _sweepController;

  final Map<String, Friend> _friends = {};
  final List<Pin> _pins = [];
  Friend? _me;
  bool _mqttConnected = false;
  double _radarRange = 500;
  bool _showNames = true;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _initServices();
  }

  Future<void> _initServices() async {
    _locationService = LocationService();
    _mqttService = MqttService();

    await FirebaseService.getAndSaveFcmToken(widget.storage);

    _pins.addAll(widget.storage.loadPins());

    _mqttService.onFriendUpdate = (friend) {
      setState(() => _friends[friend.id] = friend);
    };
    _mqttService.onPinUpdate = (pin) {
      setState(() {
        _pins.removeWhere((p) => p.id == pin.id);
        _pins.add(pin);
        widget.storage.savePins(_pins);
      });
    };
    _mqttService.onPinDelete = (pinId) {
      setState(() {
        _pins.removeWhere((p) => p.id == pinId);
        widget.storage.savePins(_pins);
      });
    };
    _mqttService.onSos = (senderId, senderName) {
      _showSosAlert(senderName);
    };
    _mqttService.onConnectionChanged = (connected) {
      setState(() => _mqttConnected = connected);
    };

    await _locationService.startTracking();

    _locationService.locationStream.listen((data) {
      if (!mounted) return;
      final newMe = Friend(
        id: widget.storage.userId!,
        name: widget.storage.userName!,
        shape: widget.storage.userShape,
        color: widget.storage.userColor,
        lat: data['lat']!,
        lon: data['lon']!,
        heading: data['heading']!,
        lastSeen: DateTime.now(),
      );
      setState(() => _me = newMe);
      _mqttService.publishLocation(newMe);
    });

    await _mqttService.connect(
      groupId: widget.storage.groupId!,
      userId: widget.storage.userId!,
    );

    _mqttService.startLocationBroadcast(() => _me ?? Friend(
      id: widget.storage.userId!,
      name: widget.storage.userName!,
      shape: widget.storage.userShape,
      color: widget.storage.userColor,
      lat: _locationService.lat,
      lon: _locationService.lon,
      heading: _locationService.heading,
      lastSeen: DateTime.now(),
    ));
  }

  void _showSosAlert(String senderName) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1a0000),
        title: const Text('SOS!', style: TextStyle(color: Colors.red, fontSize: 28)),
        content: Text(
          '$senderName ha bisogno di aiuto!',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _sendSos() {
    _mqttService.publishSos(
      widget.storage.userId!,
      widget.storage.userName!,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SOS inviato al gruppo!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final radarSize = screenSize.width * 0.9;

    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a0a1a),
        title: Row(
          children: [
            const Text('RadarFest', style: TextStyle(color: Color(0xFF00aaff))),
            const Spacer(),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _mqttConnected ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _mqttConnected ? 'Online' : 'Offline',
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people, color: Colors.white70),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FriendsScreen(
                  friends: _friends.values.toList(),
                  me: _me,
                  locationService: _locationService,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTapUp: (details) => _onRadarTap(details, radarSize),
                child: AnimatedBuilder(
                  animation: _sweepController,
                  builder: (_, __) => CustomPaint(
                    size: Size(radarSize, radarSize),
                    painter: RadarPainter(
                      me: _me,
                      friends: _friends.values.toList(),
                      pins: _pins,
                      sweepAngle: _sweepController.value * 2 * pi,
                      radarRange: _radarRange,
                      showNames: _showNames,
                      heading: _locationService.heading,
                    ),
                  ),
                ),
              ),
            ),
          ),
          _buildControls(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _sendSos,
        backgroundColor: Colors.red,
        icon: const Icon(Icons.sos),
        label: const Text('SOS'),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF0f0f20),
      child: Row(
        children: [
          const Icon(Icons.radar, color: Colors.white54, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Slider(
              value: _radarRange,
              min: 100,
              max: 5000,
              divisions: 49,
              activeColor: const Color(0xFF00aaff),
              label: _radarRange < 1000
                  ? '${_radarRange.toInt()}m'
                  : '${(_radarRange / 1000).toStringAsFixed(1)}km',
              onChanged: (v) => setState(() => _radarRange = v),
            ),
          ),
          IconButton(
            icon: Icon(
              _showNames ? Icons.label : Icons.label_off,
              color: Colors.white54,
              size: 20,
            ),
            onPressed: () => setState(() => _showNames = !_showNames),
          ),
        ],
      ),
    );
  }

  void _onRadarTap(TapUpDetails details, double radarSize) {
    // Future: add pin on tap
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _sweepController.dispose();
    _locationService.dispose();
    _mqttService.disconnect();
    super.dispose();
  }
}
