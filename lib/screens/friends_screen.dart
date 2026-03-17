import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../services/location_service.dart';

class FriendsScreen extends StatelessWidget {
  final List<Friend> friends;
  final Friend? me;
  final LocationService locationService;

  const FriendsScreen({
    super.key,
    required this.friends,
    required this.me,
    required this.locationService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0a1a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0a0a1a),
        title: const Text(
          'Amici nel gruppo',
          style: TextStyle(color: Color(0xFF00aaff)),
        ),
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: friends.isEmpty
          ? const Center(
              child: Text(
                'Nessun amico online',
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                final distance = me != null
                    ? LocationService.distanceBetween(
                        me!.lat, me!.lon, friend.lat, friend.lon)
                    : null;
                final isRecent = DateTime.now()
                        .difference(
                            DateTime.fromMillisecondsSinceEpoch(friend.ts))
                        .inSeconds <
                    30;

                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _hexToColor(friend.color),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        friend.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    friend.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    distance != null
                        ? distance < 1000
                            ? '${distance.toInt()} m di distanza'
                            : '${(distance / 1000).toStringAsFixed(1)} km di distanza'
                        : 'Posizione sconosciuta',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isRecent ? Colors.green : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  }
}
