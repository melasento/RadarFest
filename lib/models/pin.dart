class PinShape {
  final String id;
  final String emoji;
  final String label;
  const PinShape({required this.id, required this.emoji, required this.label});
}

const List<PinShape> kPinShapes = [
  PinShape(id: 'star',  emoji: '⭐', label: 'Ritrovo'),
  PinShape(id: 'tent',  emoji: '⛺', label: 'Tenda'),
  PinShape(id: 'wc',    emoji: '🚻', label: 'WC'),
  PinShape(id: 'bar',   emoji: '🍺', label: 'Bar'),
  PinShape(id: 'food',  emoji: '🍔', label: 'Cibo'),
  PinShape(id: 'music', emoji: '🎵', label: 'Palco'),
  PinShape(id: 'medic', emoji: '🏥', label: 'Primo soccorso'),
  PinShape(id: 'pin',   emoji: '📍', label: 'Generico'),
];

class Pin {
  final String id;
  String name;
  String shape;
  String color;
  double lat;
  double lon;
  String ownerId;
  String ownerName;
  String visibility; // 'public' | 'private'

  Pin({
    required this.id,
    required this.name,
    required this.shape,
    required this.color,
    required this.lat,
    required this.lon,
    required this.ownerId,
    required this.ownerName,
    this.visibility = 'public',
  });

  factory Pin.fromJson(Map<String, dynamic> j) => Pin(
        id: j['id'] as String,
        name: (j['name'] as String?) ?? '',
        shape: (j['shape'] as String?) ?? 'pin',
        color: (j['color'] as String?) ?? '#ffa040',
        lat: (j['lat'] as num).toDouble(),
        lon: (j['lon'] as num).toDouble(),
        ownerId: (j['ownerId'] as String?) ?? '',
        ownerName: (j['ownerName'] as String?) ?? '',
        visibility: (j['visibility'] as String?) ?? 'public',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'shape': shape,
        'color': color,
        'lat': lat,
        'lon': lon,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'visibility': visibility,
      };

  PinShape get shapeObj =>
      kPinShapes.firstWhere((s) => s.id == shape,
          orElse: () => kPinShapes.last);
}
