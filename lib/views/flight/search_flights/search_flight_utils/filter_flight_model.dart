class FlightFilter {
  final Set<String> selectedAirlines;
  final String? sortType;
  final int? maxStops;

  FlightFilter({
    this.selectedAirlines = const {},
    this.sortType,
    this.maxStops,
  });

  FlightFilter copyWith({
    Set<String>? selectedAirlines,
    String? sortType,
    int? maxStops,
  }) {
    return FlightFilter(
      selectedAirlines: selectedAirlines ?? this.selectedAirlines,
      sortType: sortType ?? this.sortType,
      maxStops: maxStops ?? this.maxStops,
    );
  }
}