class Airline {
  final int id;
  final String airlineName;
  final String shortName;
  final String logoPath;
  final String pathType;
  final String logoUrl;

  Airline({
    required this.id,
    required this.airlineName,
    required this.shortName,
    required this.logoPath,
    required this.pathType,
    required this.logoUrl,
  });

  factory Airline.fromJson(Map<String, dynamic> json) {
    return Airline(
      id: json['id'],
      airlineName: json['airline_name'],
      shortName: json['short_name'],
      logoPath: json['logo_path'],
      pathType: json['path_type'],
      logoUrl: json['logo_url'],
    );
  }
 
 
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'airline_name': airlineName,
      'short_name': shortName,
      'logo_path': logoPath,
      'path_type': pathType,
      'logo_url': logoUrl,
    };
  }
}