class Sector {
  final String name;

  Sector({required this.name});

  factory Sector.fromString(String sectorName) {
    return Sector(name: sectorName);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
    };
  }
}