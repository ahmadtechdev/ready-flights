// models/hotel_booking_model.dart
class HotelBookingModel {
  final String serialNumber;
  final String bookingNumber;
  final String date;
  final String bookerName;
  final String guestName;
  final String destination;
  final String hotel;
  final String status;
  final String checkinCheckout;
  final String price;
  final String cancellationDeadline;
  final int adultCount;
  final int childCount;
  final String roomType;
  final String boardBasis;

  HotelBookingModel({
    required this.serialNumber,
    required this.bookingNumber,
    required this.date,
    required this.bookerName,
    required this.guestName,
    required this.destination,
    required this.hotel,
    required this.status,
    required this.checkinCheckout,
    required this.price,
    required this.cancellationDeadline,
    this.adultCount = 0,
    this.childCount = 0,
    this.roomType = 'Standard Room',
    this.boardBasis = 'Bed & Breakfast',
  });

  // Create a copy of this model with updated values
  HotelBookingModel copyWith({
    String? serialNumber,
    String? bookingNumber,
    String? date,
    String? bookerName,
    String? guestName,
    String? destination,
    String? hotel,
    String? status,
    String? checkinCheckout,
    String? price,
    String? cancellationDeadline,
    int? adultCount,
    int? childCount,
    String? roomType,
    String? boardBasis,
  }) {
    return HotelBookingModel(
      serialNumber: serialNumber ?? this.serialNumber,
      bookingNumber: bookingNumber ?? this.bookingNumber,
      date: date ?? this.date,
      bookerName: bookerName ?? this.bookerName,
      guestName: guestName ?? this.guestName,
      destination: destination ?? this.destination,
      hotel: hotel ?? this.hotel,
      status: status ?? this.status,
      checkinCheckout: checkinCheckout ?? this.checkinCheckout,
      price: price ?? this.price,
      cancellationDeadline: cancellationDeadline ?? this.cancellationDeadline,
      adultCount: adultCount ?? this.adultCount,
      childCount: childCount ?? this.childCount,
      roomType: roomType ?? this.roomType,
      boardBasis: boardBasis ?? this.boardBasis,
    );
  }
}