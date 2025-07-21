// Model class for airline information (add this to your models file or at the top of controller)
class FilterAirline {
  final String code;
  final String name;
  final String logoPath;

  FilterAirline({
    required this.code,
    required this.name,
    required this.logoPath,
  });

  @override
  String toString() {
    return 'AirlineInfo{code: $code, name: $name, logoPath: $logoPath}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FilterAirline && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}