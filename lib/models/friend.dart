class Friend {
  final String id;
  String name;
  String color;
  double? lat;
  double? lon;
  double? acc;
  int ts;
  int joinTs;
  bool isSOS;

  Friend({
    required this.id,
    required this.name,
    required this.color,
    this.lat,
    this.lon,
    this.acc,
    int? ts,
    int? joinTs,
    this.isSOS = false,
  })  : ts = ts ?? DateTime.now().millisecondsSinceEpoch,
        joinTs = joinTs ?? DateTime.now().millisecondsSinceEpoch;

  factory Friend.fromJson(Map<String, dynamic> j) => Friend(
        id: j['id'] as String,
        name: (j['name'] as String?) ?? '?',
        color: (j['color'] as String?) ?? '00c0ff',
        lat: (j['lat'] as num?)?.toDouble(),
        lon: (j['lon'] as num?)?.toDouble(),
        acc: (j['acc'] as num?)?.toDouble(),
        ts: (j['ts'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
        joinTs: (j['joinTs'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'lat': lat,
        'lon': lon,
        'acc': acc,
        'ts': ts,
        'joinTs': joinTs,
      };

  bool get isStale =>
      DateTime.now().millisecondsSinceEpoch - ts > 90000;
  
  DateTime get lastSeen =>
      DateTime.fromMillisecondsSinceEpoch(ts);

  double? get heading => null;
  String get shape => 'circle';

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}
