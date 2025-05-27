class BookingModel {
  final int id;
  final String pnr;
  final String bkf;
  final String agt;
  final DateTime createdDate;
  final String airline;
  final String route;
  final String country;
  final DateTime flightDate;
  final PassengerStatus passengerStatus;
  final double price;
  final String status;

  BookingModel({
    required this.id,
    required this.pnr,
    required this.bkf,
    required this.agt,
    required this.createdDate,
    required this.airline,
    required this.route,
    required this.country,
    required this.flightDate,
    required this.passengerStatus,
    required this.price,
    required this.status,
  });
}

// Model for passenger status table
class PassengerStatus {
  final int holdAdults;
  final int holdChild;
  final int holdInfant;
  final int holdTotal;

  final int confirmAdults;
  final int confirmChild;
  final int confirmInfant;
  final int confirmTotal;

  final int cancelledAdults;
  final int cancelledChild;
  final int cancelledInfant;
  final int cancelledTotal;

  PassengerStatus({
    required this.holdAdults,
    required this.holdChild,
    required this.holdInfant,
    required this.holdTotal,
    required this.confirmAdults,
    required this.confirmChild,
    required this.confirmInfant,
    required this.confirmTotal,
    required this.cancelledAdults,
    required this.cancelledChild,
    required this.cancelledInfant,
    required this.cancelledTotal,
  });
}
