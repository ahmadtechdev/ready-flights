// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:oneroof/utility/colors.dart';

// // MODELS
// class Passenger {
//   String title;
//   String firstName;
//   String lastName;
//   String passportNumber;
//   DateTime? dateOfBirth;
//   DateTime? passportExpiry;

//   Passenger({
//     this.title = '',
//     this.firstName = '',
//     this.lastName = '',
//     this.passportNumber = '',
//     this.dateOfBirth,
//     this.passportExpiry,
//   });
// }

// class BookingData {
//   String groupName;
//   String sector;
//   int availableSeats;
//   int adults;
//   int children;
//   int infants;
//   double adultPrice;
//   double childPrice;
//   double infantPrice;
//   List<Passenger> passengers = [];

//   BookingData({
//     required this.groupName,
//     required this.sector,
//     required this.availableSeats,
//     required this.adults,
//     required this.children,
//     required this.infants,
//     required this.adultPrice,
//     required this.childPrice,
//     required this.infantPrice,
//   }) {
//     // Initialize passenger list based on counts
//     for (int i = 0; i < adults; i++) {
//       passengers.add(Passenger(title: 'Mr'));
//     }
//     for (int i = 0; i < children; i++) {
//       passengers.add(Passenger(title: 'Mstr'));
//     }
//     for (int i = 0; i < infants; i++) {
//       passengers.add(Passenger(title: 'INF'));
//     }
//   }

//   int get totalPassengers => adults + children + infants;

//   double get totalPrice =>
//       (adults * adultPrice) + (children * childPrice) + (infants * infantPrice);

//   bool isValidSeatCount() {
//     return totalPassengers <= availableSeats;
//   }
// }

// // CONTROLLERS
// class BookingController extends GetxController {
//   final bookingData =
//       BookingData(
//         groupName: 'saudi airline-LAHORE-RIYADH',
//         sector: 'KSA',
//         availableSeats: 8,
//         adults: 1, // Default: 1 adult
//         children: 0,
//         infants: 0,
//         adultPrice: 92500,
//         childPrice: 92500,
//         infantPrice: 92500,
//       ).obs;

//   List<String> adultTitles = ['Mr', 'Mrs', 'Ms'];
//   List<String> childTitles = ['Mstr', 'Miss'];
//   List<String> infantTitles = ['INF'];

//   void incrementAdults() {
//     if (bookingData.value.totalPassengers < bookingData.value.availableSeats) {
//       var updatedData = BookingData(
//         groupName: bookingData.value.groupName,
//         sector: bookingData.value.sector,
//         availableSeats: bookingData.value.availableSeats,
//         adults: bookingData.value.adults + 1,
//         children: bookingData.value.children,
//         infants: bookingData.value.infants,
//         adultPrice: bookingData.value.adultPrice,
//         childPrice: bookingData.value.childPrice,
//         infantPrice: bookingData.value.infantPrice,
//       );
//       bookingData.value = updatedData;
//     } else {
//       Get.snackbar(
//         'Error',
//         'Cannot add more passengers. Available seats limit reached.',
//         backgroundColor: TColors.red.withOpacity(0.1),
//         colorText: TColors.red,
//       );
//     }
//   }

//   void decrementAdults() {
//     if (bookingData.value.adults > 1) {
//       // At least one adult required
//       var updatedData = BookingData(
//         groupName: bookingData.value.groupName,
//         sector: bookingData.value.sector,
//         availableSeats: bookingData.value.availableSeats,
//         adults: bookingData.value.adults - 1,
//         children: bookingData.value.children,
//         infants: bookingData.value.infants,
//         adultPrice: bookingData.value.adultPrice,
//         childPrice: bookingData.value.childPrice,
//         infantPrice: bookingData.value.infantPrice,
//       );
//       bookingData.value = updatedData;
//     }
//   }

//   void incrementChildren() {
//     if (bookingData.value.totalPassengers < bookingData.value.availableSeats) {
//       var updatedData = BookingData(
//         groupName: bookingData.value.groupName,
//         sector: bookingData.value.sector,
//         availableSeats: bookingData.value.availableSeats,
//         adults: bookingData.value.adults,
//         children: bookingData.value.children + 1,
//         infants: bookingData.value.infants,
//         adultPrice: bookingData.value.adultPrice,
//         childPrice: bookingData.value.childPrice,
//         infantPrice: bookingData.value.infantPrice,
//       );
//       bookingData.value = updatedData;
//     } else {
//       Get.snackbar(
//         'Error',
//         'Cannot add more passengers. Available seats limit reached.',
//         backgroundColor: TColors.red.withOpacity(0.1),
//         colorText: TColors.red,
//       );
//     }
//   }

//   void decrementChildren() {
//     if (bookingData.value.children > 0) {
//       var updatedData = BookingData(
//         groupName: bookingData.value.groupName,
//         sector: bookingData.value.sector,
//         availableSeats: bookingData.value.availableSeats,
//         adults: bookingData.value.adults,
//         children: bookingData.value.children - 1,
//         infants: bookingData.value.infants,
//         adultPrice: bookingData.value.adultPrice,
//         childPrice: bookingData.value.childPrice,
//         infantPrice: bookingData.value.infantPrice,
//       );
//       bookingData.value = updatedData;
//     }
//   }

//   void incrementInfants() {
//     if (bookingData.value.totalPassengers < bookingData.value.availableSeats) {
//       var updatedData = BookingData(
//         groupName: bookingData.value.groupName,
//         sector: bookingData.value.sector,
//         availableSeats: bookingData.value.availableSeats,
//         adults: bookingData.value.adults,
//         children: bookingData.value.children,
//         infants: bookingData.value.infants + 1,
//         adultPrice: bookingData.value.adultPrice,
//         childPrice: bookingData.value.childPrice,
//         infantPrice: bookingData.value.infantPrice,
//       );
//       bookingData.value = updatedData;
//     } else {
//       Get.snackbar(
//         'Error',
//         'Cannot add more passengers. Available seats limit reached.',
//         backgroundColor: TColors.red.withOpacity(0.1),
//         colorText: TColors.red,
//       );
//     }
//   }

//   void decrementInfants() {
//     if (bookingData.value.infants > 0) {
//       var updatedData = BookingData(
//         groupName: bookingData.value.groupName,
//         sector: bookingData.value.sector,
//         availableSeats: bookingData.value.availableSeats,
//         adults: bookingData.value.adults,
//         children: bookingData.value.children,
//         infants: bookingData.value.infants - 1,
//         adultPrice: bookingData.value.adultPrice,
//         childPrice: bookingData.value.childPrice,
//         infantPrice: bookingData.value.infantPrice,
//       );
//       bookingData.value = updatedData;
//     }
//   }

//   // VALIDATION AND SUBMISSION
//   final formKey = GlobalKey<FormState>();
//   final isFormValid = false.obs;

//   void validateForm() {
//     isFormValid.value = formKey.currentState?.validate() ?? false;
//   }

//   void submitBooking() {
//     Get.to(() => BookingSuccessScreen());
//     if (formKey.currentState?.validate() ?? false) {
//       // Process booking data
//       Get.snackbar(
//         'Success',
//         'Booking submitted successfully!',
//         backgroundColor: Colors.green.withOpacity(0.1),
//         colorText: Colors.green,
//       );
//       // Navigate to confirmation page or payment
//       // Get.to(() => ConfirmationPage());
//     } else {
//       Get.snackbar(
//         'Error',
//         'Please fill in all required fields correctly.',
//         backgroundColor: TColors.red.withOpacity(0.1),
//         colorText: TColors.red,
//       );
//     }
//   }
// }

// // UI COMPONENTS

// // SCREENS
// class BookingSummaryScreen extends StatelessWidget {
//   final BookingController controller = Get.put(BookingController());

//   BookingSummaryScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: TColors.primary,
//         title: Text('Book Seats', style: TextStyle(color: TColors.white)),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.close, color: TColors.white),
//             onPressed: () => Get.back(),
//           ),
//         ],
//       ),
//       body: Obx(
//         () => Column(
//           children: [
//             Container(
//               padding: EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
//               ),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: RichText(
//                       text: TextSpan(
//                         style: TextStyle(color: TColors.text),
//                         children: [
//                           TextSpan(text: 'Group Name: '),
//                           TextSpan(
//                             text: controller.bookingData.value.groupName,
//                             style: TextStyle(
//                               color: Colors.blue,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   RichText(
//                     text: TextSpan(
//                       style: TextStyle(color: TColors.text),
//                       children: [
//                         TextSpan(text: 'Available Seats: '),
//                         TextSpan(
//                           text:
//                               controller.bookingData.value.availableSeats
//                                   .toString(),
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   RichText(
//                     text: TextSpan(
//                       style: TextStyle(color: TColors.text),
//                       children: [
//                         TextSpan(text: 'Sector: '),
//                         TextSpan(
//                           text: controller.bookingData.value.sector,
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           flex: 1,
//                           child: Container(
//                             padding: EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: TColors.primary,
//                               borderRadius: BorderRadius.only(
//                                 topLeft: Radius.circular(8),
//                                 bottomLeft: Radius.circular(8),
//                               ),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'Passengers',
//                                 style: TextStyle(
//                                   color: TColors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 1,
//                           child: Container(
//                             padding: EdgeInsets.all(12),
//                             decoration: BoxDecoration(color: TColors.primary),
//                             child: Center(
//                               child: Text(
//                                 'Price/Seat',
//                                 style: TextStyle(
//                                   color: TColors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           flex: 1,
//                           child: Container(
//                             padding: EdgeInsets.all(12),
//                             decoration: BoxDecoration(
//                               color: TColors.primary,
//                               borderRadius: BorderRadius.only(
//                                 topRight: Radius.circular(8),
//                                 bottomRight: Radius.circular(8),
//                               ),
//                             ),
//                             child: Center(
//                               child: Text(
//                                 'Total Price',
//                                 style: TextStyle(
//                                   color: TColors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 2),
//                     _buildPassengerRow(
//                       'Adults',
//                       controller.bookingData.value.adults,
//                       'PKR ${controller.bookingData.value.adultPrice.toStringAsFixed(0)}',
//                       'PKR ${(controller.bookingData.value.adults * controller.bookingData.value.adultPrice).toStringAsFixed(0)}',
//                       () => controller.incrementAdults(),
//                       () => controller.decrementAdults(),
//                     ),
//                     SizedBox(height: 2),
//                     _buildPassengerRow(
//                       'Child',
//                       controller.bookingData.value.children,
//                       'PKR ${controller.bookingData.value.childPrice.toStringAsFixed(0)}',
//                       'PKR ${(controller.bookingData.value.children * controller.bookingData.value.childPrice).toStringAsFixed(0)}',
//                       () => controller.incrementChildren(),
//                       () => controller.decrementChildren(),
//                     ),
//                     SizedBox(height: 2),
//                     _buildPassengerRow(
//                       'Infants',
//                       controller.bookingData.value.infants,
//                       'PKR ${controller.bookingData.value.infantPrice.toStringAsFixed(0)}',
//                       'PKR ${(controller.bookingData.value.infants * controller.bookingData.value.infantPrice).toStringAsFixed(0)}',
//                       () => controller.incrementInfants(),
//                       () => controller.decrementInfants(),
//                     ),
//                     SizedBox(height: 2),
//                     _buildTotalRow(
//                       controller.bookingData.value.totalPassengers,
//                       'PKR ${controller.bookingData.value.totalPrice.toStringAsFixed(0)}',
//                     ),
//                     Spacer(),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: TColors.secondary,
//                           padding: EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                         ),
//                         onPressed: () {
//                           if (controller.bookingData.value.totalPassengers <=
//                               controller.bookingData.value.availableSeats) {
//                             Get.to(() => PassengerDetailsScreen());
//                           } else {
//                             Get.snackbar(
//                               'Error',
//                               'Number of passengers exceeds available seats',
//                               backgroundColor: TColors.red.withOpacity(0.1),
//                               colorText: TColors.red,
//                             );
//                           }
//                         },
//                         child: Text(
//                           'Continue',
//                           style: TextStyle(
//                             color: TColors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildPassengerRow(
//     String label,
//     int count,
//     String pricePerSeat,
//     String totalPrice,
//     VoidCallback onIncrement,
//     VoidCallback onDecrement,
//   ) {
//     return Row(
//       children: [
//         Expanded(
//           flex: 1,
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('$label:', style: TextStyle(fontWeight: FontWeight.w500)),
//                 Row(
//                   children: [
//                     InkWell(
//                       onTap: onDecrement,
//                       child: Container(
//                         padding: EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: TColors.secondary,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(
//                           Icons.remove,
//                           size: 16,
//                           color: TColors.white,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 12),
//                     Text(
//                       '$count',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     SizedBox(width: 12),
//                     InkWell(
//                       onTap: onIncrement,
//                       child: Container(
//                         padding: EdgeInsets.all(4),
//                         decoration: BoxDecoration(
//                           color: TColors.secondary,
//                           shape: BoxShape.circle,
//                         ),
//                         child: Icon(Icons.add, size: 16, color: TColors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Expanded(
//           flex: 1,
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Center(
//               child: Text(
//                 pricePerSeat,
//                 style: TextStyle(fontWeight: FontWeight.w500),
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           flex: 1,
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Center(
//               child: Text(
//                 totalPrice,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: label == 'Adults' ? Colors.green : TColors.text,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTotalRow(int totalPassengers, String totalPrice) {
//     return Row(
//       children: [
//         Expanded(
//           flex: 1,
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               border: Border.all(color: Colors.grey.shade200),
//               borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
//                 Text(
//                   '$totalPassengers',
//                   style: TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Expanded(
//           flex: 1,
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Center(
//               child: Text(
//                 'Total Price',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         ),
//         Expanded(
//           flex: 1,
//           child: Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               border: Border.all(color: Colors.grey.shade200),
//               borderRadius: BorderRadius.only(bottomRight: Radius.circular(8)),
//             ),
//             child: Center(
//               child: Text(
//                 totalPrice,
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.green,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class PassengerDetailsScreen extends StatelessWidget {
//   final BookingController controller = Get.find<BookingController>();
//   final dateFormat = DateFormat('dd-MM-yyyy');

//   PassengerDetailsScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: TColors.primary,
//         title: Text(
//           'Passenger Details',
//           style: TextStyle(color: TColors.white),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: TColors.white),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: Obx(
//         () => Form(
//           key: controller.formKey,
//           onChanged: controller.validateForm,
//           child: Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       for (
//                         int i = 0;
//                         i < controller.bookingData.value.adults;
//                         i++
//                       )
//                         _buildPassengerForm('Adults ${i + 1}', i, 'adult'),
//                       for (
//                         int i = 0;
//                         i < controller.bookingData.value.children;
//                         i++
//                       )
//                         _buildPassengerForm(
//                           'Child ${i + 1}',
//                           controller.bookingData.value.adults + i,
//                           'child',
//                         ),
//                       for (
//                         int i = 0;
//                         i < controller.bookingData.value.infants;
//                         i++
//                       )
//                         _buildPassengerForm(
//                           'Infants ${i + 1}',
//                           controller.bookingData.value.adults +
//                               controller.bookingData.value.children +
//                               i,
//                           'infant',
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.2),
//                       spreadRadius: 1,
//                       blurRadius: 3,
//                       offset: Offset(0, -1),
//                     ),
//                   ],
//                 ),
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: TColors.secondary,
//                       padding: EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     onPressed:
//                         controller.isFormValid.value
//                             ? controller.submitBooking
//                             : null,
//                     child: Text(
//                       'Submit',
//                       style: TextStyle(
//                         color: TColors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildPassengerForm(String title, int index, String type) {
//     List<String> titles =
//         type == 'adult'
//             ? controller.adultTitles
//             : type == 'child'
//             ? controller.childTitles
//             : controller.infantTitles;

//     return Card(
//       margin: EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//         side: BorderSide(color: Colors.grey.shade200),
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: TColors.primary,
//               ),
//             ),
//             SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   flex: 1,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Title',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w500,
//                           color: TColors.grey,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       Container(
//                         padding: EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey.shade300),
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: DropdownButtonFormField<String>(
//                           decoration: InputDecoration(
//                             border: InputBorder.none,
//                             contentPadding: EdgeInsets.zero,
//                           ),
//                           items:
//                               titles
//                                   .map(
//                                     (title) => DropdownMenuItem(
//                                       value: title,
//                                       child: Text(title),
//                                     ),
//                                   )
//                                   .toList(),
//                           value:
//                               type == 'adult'
//                                   ? 'Mr'
//                                   : type == 'child'
//                                   ? 'Mstr'
//                                   : 'INF',
//                           onChanged: (value) {
//                             if (value != null) {
//                               controller
//                                   .bookingData
//                                   .value
//                                   .passengers[index]
//                                   .title = value;
//                             }
//                           },
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Required';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   flex: 2,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Given Name',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w500,
//                           color: TColors.grey,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       TextFormField(
//                         decoration: InputDecoration(
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 12,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(4),
//                             borderSide: BorderSide(color: Colors.grey.shade300),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(4),
//                             borderSide: BorderSide(color: Colors.grey.shade300),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Required';
//                           }
//                           return null;
//                         },
//                         onChanged: (value) {
//                           controller
//                               .bookingData
//                               .value
//                               .passengers[index]
//                               .firstName = value;
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   flex: 2,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Sur Name',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w500,
//                           color: TColors.grey,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       TextFormField(
//                         decoration: InputDecoration(
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 12,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(4),
//                             borderSide: BorderSide(color: Colors.grey.shade300),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(4),
//                             borderSide: BorderSide(color: Colors.grey.shade300),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Required';
//                           }
//                           return null;
//                         },
//                         onChanged: (value) {
//                           controller
//                               .bookingData
//                               .value
//                               .passengers[index]
//                               .lastName = value;
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Passport#',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w500,
//                           color: TColors.grey,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       TextFormField(
//                         decoration: InputDecoration(
//                           contentPadding: EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 12,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(4),
//                             borderSide: BorderSide(color: Colors.grey.shade300),
//                           ),
//                           enabledBorder: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(4),
//                             borderSide: BorderSide(color: Colors.grey.shade300),
//                           ),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Required';
//                           }
//                           return null;
//                         },
//                         onChanged: (value) {
//                           controller
//                               .bookingData
//                               .value
//                               .passengers[index]
//                               .passportNumber = value;
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   flex: 2,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Date of birth',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w500,
//                           color: TColors.grey,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       InkWell(
//                         onTap: () async {
//                           final DateTime? picked = await showDatePicker(
//                             context: Get.context!,
//                             initialDate: DateTime.now().subtract(
//                               Duration(
//                                 days:
//                                     type == 'adult'
//                                         ? 365 * 18
//                                         : type == 'child'
//                                         ? 365 * 5
//                                         : 180,
//                               ),
//                             ),
//                             firstDate: DateTime.now().subtract(
//                               Duration(days: 365 * 100),
//                             ),
//                             lastDate: DateTime.now(),
//                             builder: (context, child) {
//                               return Theme(
//                                 data: ThemeData.light().copyWith(
//                                   colorScheme: ColorScheme.light(
//                                     primary: TColors.primary,
//                                   ),
//                                 ),
//                                 child: child!,
//                               );
//                             },
//                           );
//                           if (picked != null) {
//                             controller
//                                 .bookingData
//                                 .value
//                                 .passengers[index]
//                                 .dateOfBirth = picked;
//                             controller.bookingData.refresh();
//                           }
//                         },
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 12,
//                           ),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 controller
//                                             .bookingData
//                                             .value
//                                             .passengers[index]
//                                             .dateOfBirth !=
//                                         null
//                                     ? dateFormat.format(
//                                       controller
//                                           .bookingData
//                                           .value
//                                           .passengers[index]
//                                           .dateOfBirth!,
//                                     )
//                                     : 'DD-MM-YYYY',
//                                 style: TextStyle(
//                                   color:
//                                       controller
//                                                   .bookingData
//                                                   .value
//                                                   .passengers[index]
//                                                   .dateOfBirth !=
//                                               null
//                                           ? TColors.text
//                                           : TColors.placeholder,
//                                 ),
//                               ),
//                               Icon(
//                                 Icons.calendar_today,
//                                 size: 16,
//                                 color: TColors.grey,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 Expanded(
//                   flex: 2,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Passport Expiry',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w500,
//                           color: TColors.grey,
//                         ),
//                       ),
//                       SizedBox(height: 8),
//                       InkWell(
//                         onTap: () async {
//                           final DateTime? picked = await showDatePicker(
//                             context: Get.context!,
//                             initialDate: DateTime.now().add(
//                               Duration(days: 365),
//                             ),
//                             firstDate: DateTime.now(),
//                             lastDate: DateTime.now().add(
//                               Duration(days: 365 * 10),
//                             ),
//                             builder: (context, child) {
//                               return Theme(
//                                 data: ThemeData.light().copyWith(
//                                   colorScheme: ColorScheme.light(
//                                     primary: TColors.primary,
//                                   ),
//                                 ),
//                                 child: child!,
//                               );
//                             },
//                           );
//                           if (picked != null) {
//                             controller
//                                 .bookingData
//                                 .value
//                                 .passengers[index]
//                                 .passportExpiry = picked;
//                             controller.bookingData.refresh();
//                           }
//                         },
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 12,
//                             vertical: 12,
//                           ),
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.grey.shade300),
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 controller
//                                             .bookingData
//                                             .value
//                                             .passengers[index]
//                                             .passportExpiry !=
//                                         null
//                                     ? dateFormat.format(
//                                       controller
//                                           .bookingData
//                                           .value
//                                           .passengers[index]
//                                           .passportExpiry!,
//                                     )
//                                     : 'DD-MM-YYYY',
//                                 style: TextStyle(
//                                   color:
//                                       controller
//                                                   .bookingData
//                                                   .value
//                                                   .passengers[index]
//                                                   .passportExpiry !=
//                                               null
//                                           ? TColors.text
//                                           : TColors.placeholder,
//                                 ),
//                               ),
//                               Icon(
//                                 Icons.calendar_today,
//                                 size: 16,
//                                 color: TColors.grey,
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // SUCCESS PAGE
// class BookingSuccessScreen extends StatelessWidget {
//   final BookingController controller = Get.find<BookingController>();

//   BookingSuccessScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: EdgeInsets.all(24),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.check_circle, size: 80, color: Colors.green),
//                 SizedBox(height: 24),
//                 Text(
//                   'Booking Confirmed!',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: TColors.primary,
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 Text(
//                   'Your booking has been confirmed. A confirmation email will be sent to you shortly.',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 16, color: TColors.grey),
//                 ),
//                 SizedBox(height: 32),
//                 Card(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Column(
//                       children: [
//                         _buildInfoRow(
//                           'Flight',
//                           controller.bookingData.value.groupName,
//                         ),
//                         Divider(),
//                         _buildInfoRow(
//                           'Sector',
//                           controller.bookingData.value.sector,
//                         ),
//                         Divider(),
//                         _buildInfoRow(
//                           'Passengers',
//                           controller.bookingData.value.totalPassengers
//                               .toString(),
//                         ),
//                         Divider(),
//                         _buildInfoRow(
//                           'Total Amount',
//                           'PKR ${controller.bookingData.value.totalPrice.toStringAsFixed(0)}',
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 32),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: TColors.secondary,
//                       padding: EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     onPressed: () {
//                       Get.offAll(() => BookingSummaryScreen());
//                     },
//                     child: Text(
//                       'Book Another Flight',
//                       style: TextStyle(
//                         color: TColors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(fontWeight: FontWeight.w500, color: TColors.grey),
//           ),
//           Text(
//             value,
//             style: TextStyle(fontWeight: FontWeight.bold, color: TColors.text),
//           ),
//         ],
//       ),
//     );
//   }
// }
