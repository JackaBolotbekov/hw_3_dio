/// ======================= MODEL =======================

class HPCharacter {
  final String fullName;
  final String? nickname;
  final String? hogwartsHouse;
  final String? interpretedBy;
  final List<String> children;
  final String? image;
  final String? birthdate;

  const HPCharacter({
    required this.fullName,
    this.nickname,
    this.hogwartsHouse,
    this.interpretedBy,
    this.children = const [],
    this.image,
    this.birthdate,
  });

  factory HPCharacter.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    return HPCharacter(
      fullName: (json['fullName'] ?? '').toString(),
      nickname: _opt(json['nickname']),
      hogwartsHouse: _opt(json['hogwartsHouse']),
      interpretedBy: _opt(json['interpretedBy']),
      children: rawChildren is List
          ? rawChildren.map((e) => e.toString()).toList()
          : const <String>[],
      image: _opt(json['image']),
      birthdate: _opt(json['birthdate']),
    );
  }

  static String? _opt(dynamic v) => v == null || (v is String && v.trim().isEmpty) ? null : v.toString();
}