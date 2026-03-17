class Friend {
  final String id;
  String name;
  String color;
  String shape;
  double? lat;
  double? lon;
  double? acc;
  double? heading;
  int ts;
  int joinTs;
  bool isSOS;

  Friend({
    required this.id,
    required this.name,
    required this.color,
    this.shape = 'circle',
    this.lat,
    this.lon,
    this.acc,
    this.heading,
    int? ts,
    int? joinTs,
    DateTime? lastSeen,
    this.isSOS = false,
  })  : ts = ts ?? lastSeen?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch,
        joinTs = joinTs ?? DateTime.now().millisecondsSinceEpoch;

  factory Friend.fromJson(Map<String, dynamic> j) => Friend(
        id: j['id'] as String,
        name: (j['name'] as String?) ?? '?',
        color: (j['color'] as String?) ?? '00c0ff',
        shape: (j['shape'] as String?) ?? 'circle',
        lat: (j['lat'] as num?)?.toDouble(),
        lon: (j['lon'] as num?)?.toDouble(),
        acc: (j['acc'] as num?)?.toDouble(),
        heading: (j['heading'] as num?)?.toDouble(),
        ts: (j['ts'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
        joinTs: (j['joinTs'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'shape': shape,
        'lat': lat,
        'lon': lon,
        'acc': acc,
        'heading': heading,
        'ts': ts,
        'joinTs': joinTs,
      };

  bool get isStale =>
      DateTime.now().millisecondsSinceEpoch - ts > 90000;

  DateTime get lastSeen =>
      DateTime.fromMillisecondsSinceEpoch(ts);

  double? get headingValue => heading;

  String get shape_ => shape;

  String get initial => name.isNotEmpty ? name[0].toUpperCase() : '?';
}
