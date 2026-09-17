class Scan {
  final String id;
  final String imagePath;
  final String rawText;
  final String correctedText;
  final DateTime createdAt;

  const Scan({
    required this.id,
    required this.imagePath,
    required this.rawText,
    required this.correctedText,
    required this.createdAt,
  });

  Scan copyWith({String? correctedText}) => Scan(
        id: id,
        imagePath: imagePath,
        rawText: rawText,
        correctedText: correctedText ?? this.correctedText,
        createdAt: createdAt,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'imagePath': imagePath,
        'rawText': rawText,
        'correctedText': correctedText,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Scan.fromMap(Map<String, Object?> map) => Scan(
        id: map['id'] as String,
        imagePath: map['imagePath'] as String,
        rawText: map['rawText'] as String,
        correctedText: map['correctedText'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
