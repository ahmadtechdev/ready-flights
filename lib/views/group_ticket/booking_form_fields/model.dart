// passenger_model.dart
class Passenger {
  String title;
  String firstName;
  String lastName;
  String passportNumber;
  DateTime? dateOfBirth;
  DateTime? passportExpiry;

  Passenger({
    this.title = '',
    this.firstName = '',
    this.lastName = '',
    this.passportNumber = '',
    this.dateOfBirth,
    this.passportExpiry,
  });
}

// booking_data_model.dart
class BookingData {
  int groupId;
  String groupName;
  String sector;
  int availableSeats;
  int adults;
  int children;
  int infants;
  double adultPrice;
  double childPrice;
  double infantPrice;
  int groupPriceDetailId;
  List<Passenger> passengers = [];

  BookingData({
    required this.groupId,
    required this.groupName,
    required this.sector,
    required this.availableSeats,
    required this.adults,
    required this.children,
    required this.infants,
    required this.adultPrice,
    required this.childPrice,
    required this.infantPrice,
    required this.groupPriceDetailId,
  }) {
    // Initialize passenger list
    passengers = List.generate(adults, (_) => Passenger(title: 'Mr'))
      ..addAll(List.generate(children, (_) => Passenger(title: 'Mstr')))
      ..addAll(List.generate(infants, (_) => Passenger(title: 'INF')));
  }

  int get totalPassengers => adults + children + infants;
  double get totalPrice => (adults * adultPrice) + (children * childPrice) + (infants * infantPrice);
}