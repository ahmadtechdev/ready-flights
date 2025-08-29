import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../services/api_service_hotel.dart';
import '../../../../utility/colors.dart';
import '../../hotel/guests/guests_controller.dart';
import '../../hotel/hotel_date_controller.dart';
import '../booking_hotel/booking_hotel.dart';
import '../booking_hotel/booking_controller.dart';
import '../search_hotel_controller.dart';
import 'controller/select_room_controller.dart';
import 'widgets/room_card.dart';

class SelectRoomScreen extends StatefulWidget {
  const SelectRoomScreen({super.key});

  @override
  State<SelectRoomScreen> createState() => _SelectRoomScreenState();
}

class _SelectRoomScreenState extends State<SelectRoomScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final controller = Get.find<SearchHotelController>();
  final dateController = Get.find<HotelDateController>();
  final Map<int, dynamic> selectedRooms = {};
  final guestsController = Get.find<GuestsController>();
  final selectRoomController = Get.put(SelectRoomController());
  final bookingController = Get.put(BookingController());
  final apiService = ApiServiceHotel();
  bool isLoading = false;
  int? loadingRoomIndex; // Track which room is currently loading

  Future<void> 
  
  
  
  
  
  
  handleBookNow() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Extract rate keys from selected rooms
      List<String> rateKeys =
          selectedRooms.values
              .map((room) => room['rateKey'].toString())
              .toList();

      // Get the group code from the first selected room
      int groupCode = selectedRooms.values.first['groupCode'] as int;

      // Make the prebook API call
      var response = await apiService.prebook(
        sessionId: controller.sessionId.value,
        hotelCode: controller.hotelCode.value,
        groupCode: groupCode,
        currency: "AED",
        rateKeys: rateKeys,
      );

      // Store the response in the controller
      if (response != null) {
        selectRoomController.storePrebookResponse(response);

        bool isSoldOut = response['isSoldOut'] ?? false;
        bool isPriceChanged = response['isPriceChanged'] ?? false;
        bool isBookable = response['isBookable'] ?? false;

        if (isSoldOut) {
          _showErrorDialog(
            'Sorry, one or more selected rooms are no longer available.',
          );
        } else if (isPriceChanged) {
          _showErrorDialog(
            'The price for one or more rooms has changed. Please review the updated prices.',
          );
        } else if (!isBookable) {
          _showErrorDialog(
            'One or more rooms are not currently bookable. Please try different rooms.',
          );
        } else {
          // All validations passed, proceed to booking
          Get.to(() => BookingHotelScreen());
        }
      } else {
        _showErrorDialog(
          'Failed to validate room availability. Please try again.',
        );
      }
    } catch (e) {
      _showErrorDialog(
        'An error occurred while processing your booking. Please try again.',
      );
      print('Booking error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // New method for single room booking
  void bookSingleRoom(dynamic room) async {
    // First select the room
    selectRoom(0, room);

    // Set the loading state for this specific room
    setState(() {
      // Store the actual index of the room in the controller's roomsdata list
      loadingRoomIndex = controller.roomsdata.indexOf(room);
      isLoading = true;
    });

    try {
      // Extract rate key from selected room
      List<String> rateKeys = [room['rateKey'].toString()];

      if (rateKeys.isEmpty) {
        _showErrorDialog('No valid rate key found for selected room.');
        return;
      }

      // Get the group code from the room
      int groupCode = room['groupCode'] as int;

      // Make the prebook API call
      var response = await apiService.prebook(
        sessionId: controller.sessionId.value,
        hotelCode: controller.hotelCode.value,
        groupCode: groupCode,
        currency: "AED",
        rateKeys: rateKeys,
      );

      if (response != null) {
        selectRoomController.storePrebookResponse(response);

        bool isSoldOut = response['isSoldOut'] ?? false;
        bool isPriceChanged = response['isPriceChanged'] ?? false;
        bool isBookable = response['isBookable'] ?? false;

        if (isSoldOut) {
          _showErrorDialog('Sorry, this room is no longer available.');
        } else if (isPriceChanged) {
          _showErrorDialog(
            'The price for this room has changed. Please review the updated price.',
          );
        } else if (!isBookable) {
          _showErrorDialog(
            'This room is not currently bookable. Please try a different room.',
          );
        } else {
          // All validations passed, proceed to booking
          Get.to(() => BookingHotelScreen());
        }
      } else {
        _showErrorDialog(
          'Failed to validate room availability. Please try again.',
        );
      }
    } catch (e) {
      _showErrorDialog(
        'An error occurred while processing your booking. Please try again.',
      );
      print('Booking error: $e');
    } finally {
      setState(() {
        loadingRoomIndex = null;
        isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Booking Error'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: guestsController.roomCount.value,
      vsync: this,
    );

    // Listen to tab changes
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void selectRoom(int roomIndex, dynamic room) {
  setState(() {
    selectedRooms[roomIndex] = room;
    // Update the selected room data in the controller WITH THE CORRECT INDEX
    Get.find<SelectRoomController>().updateSelectedRoom(roomIndex, room);
    if (roomIndex < guestsController.roomCount.value - 1) {
      _tabController.animateTo(roomIndex + 1);
    }
  });
}

  bool get allRoomsSelected =>
      selectedRooms.length == guestsController.roomCount.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        elevation: 0,
        backgroundColor: TColors.primary,
        title: const Text(
          "Select Room",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      
     
        bottom:
            guestsController.roomCount.value > 1
                ? TabBar(
                  controller: _tabController,
                  tabs: List.generate(
                    guestsController.roomCount.value,
                    (index) => Tab(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Room ${index + 1}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            if (selectedRooms.containsKey(index))
                              const Icon(Icons.check_circle, size: 10),
                          ],
                        ),
                      ),
                    ),
                  ),
                  labelColor: TColors.white,
                  unselectedLabelColor: TColors.white,
                  indicatorColor: TColors.primary,
                )
                : null,
      ),
      body: Obx(() {
        if (controller.roomsdata.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: TColors.primary),
          );
        }

        // Group rooms by roomName
        Map<String, List<dynamic>> groupedRooms = {};
        for (var room in controller.roomsdata) {
          String roomName = room['roomName'] ?? 'Unknown Room';
          if (!groupedRooms.containsKey(roomName)) {
            groupedRooms[roomName] = [];
          }
          groupedRooms[roomName]!.add(room);
        }

        if (guestsController.roomCount.value > 1) {
          return Column(
            children: [
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: List.generate(
                    guestsController.roomCount.value,
                    (roomIndex) => SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHotelInfo(),
                          ...groupedRooms.entries.map(
                            (entry) => RoomTypeSection(
                              roomTypeName: entry.key,
                              rooms: entry.value,
                              nights: dateController.nights.value,
                              onRoomSelected:
                                  (room) => selectRoom(roomIndex, room),
                              isSelected:
                                  (room) => selectedRooms[roomIndex] == room,
                              isSingleRoom: false,
                              loadingRoomIndex: loadingRoomIndex,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          // Single room view with "Book Now" buttons directly on rooms
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHotelInfo(),
                ...groupedRooms.entries.map(
                  (entry) => RoomTypeSection(
                    roomTypeName: entry.key,
                    rooms: entry.value,
                    nights: dateController.nights.value,
                    onRoomSelected: (room) => bookSingleRoom(room),
                    isSelected: (room) => selectedRooms[0] == room,
                    isSingleRoom: true,
                    loadingRoomIndex: loadingRoomIndex,
                  ),
                ),
              ],
            ),
          );
        }
      }),
      bottomNavigationBar:
          guestsController.roomCount.value > 1 && allRoomsSelected
              ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: Get.width,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : handleBookNow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isLoading ? '' : 'Book Now',
                          style: const TextStyle(
                            color: TColors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    if (isLoading)
                      const Positioned.fill(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: TColors.secondary,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                  ],
                ),
              )
              : null,
    );
  }

 Widget _buildHotelInfo() {
  return Container(
    padding: const EdgeInsets.all(16),
    color: TColors.background,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hotel Image - Small on left side
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: TColors.background3, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: _buildSmallHotelImage(),
          ),
        ),
        const SizedBox(width: 12),
        // Hotel Information
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.hotelName.value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: TColors.text,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.star, color: TColors.primary, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${controller.ratingstar.value.toString()} Star Hotel',
                    style: const TextStyle(
                      color: TColors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSmallHotelImage() {
  String imageUrl = controller.image.value;
  
  if (imageUrl.isNotEmpty) {
    // Handle network images
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        height: 60,
        width: 60,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 60,
          width: 60,
          color: TColors.background2,
          child: const Center(
            child: CircularProgressIndicator(
              color: TColors.primary,
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildSmallPlaceholderImage(),
      );
    }
    // Handle relative paths
    else if (imageUrl.startsWith('/')) {
      String fullImageUrl = 'https://static.giinfotech.ae/medianew$imageUrl';
      return CachedNetworkImage(
        imageUrl: fullImageUrl,
        height: 60,
        width: 60,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: 60,
          width: 60,
          color: TColors.background2,
          child: const Center(
            child: CircularProgressIndicator(
              color: TColors.primary,
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildSmallPlaceholderImage(),
      );
    }
    // Handle local assets
    else {
      return Image.asset(
        imageUrl,
        height: 60,
        width: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildSmallPlaceholderImage(),
      );
    }
  } else {
    return _buildSmallPlaceholderImage();
  }
}

Widget _buildSmallPlaceholderImage() {
  return Container(
    height: 60,
    width: 60,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          TColors.primary.withOpacity(0.8),
          TColors.third.withOpacity(0.6),
        ],
      ),
    ),
    child: Center(
      child: Icon(
        Icons.hotel_rounded,
        size: 24,
        color: TColors.white.withOpacity(0.8),
      ),
    ),
  );
}}
class RoomTypeSection extends StatefulWidget {
  final String roomTypeName;
  final List<dynamic> rooms;
  final int nights;
  final Function(dynamic) onRoomSelected;
  final Function(dynamic) isSelected;
  final bool isSingleRoom;
  final int? loadingRoomIndex;

  const RoomTypeSection({
    super.key,
    required this.roomTypeName,
    required this.rooms,
    required this.nights,
    required this.onRoomSelected,
    required this.isSelected,
    this.isSingleRoom = false,
    this.loadingRoomIndex,
  });

  @override
  State<RoomTypeSection> createState() => _RoomTypeSectionState();
}

class _RoomTypeSectionState extends State<RoomTypeSection> {
  bool isExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: TColors.secondary.withOpacity(0.3),
          child: Row(
            children: [
              InkWell(
                onTap: () => setState(() => isExpanded = !isExpanded),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TColors.background4,
                    border: Border.all(color: TColors.background3),
                  ),
                  child: Center(
                    child: Icon(
                      isExpanded ? Icons.remove : Icons.add,
                      size: 16,
                      color: TColors.background3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.roomTypeName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isExpanded)
          ...widget.rooms.map((room) {
            // Calculate the global room index from controller's roomsdata list
            final SearchHotelController controller =
                Get.find<SearchHotelController>();
            final int globalRoomIndex = controller.roomsdata.indexOf(room);

            // Check if this specific room is being loaded
            bool isRoomLoading = widget.loadingRoomIndex == globalRoomIndex;

            return RoomCard(
              room: room,
              nights: widget.nights,
              onSelect: widget.onRoomSelected,
              isSelected: widget.isSelected(room),
              showBookNowButton: widget.isSingleRoom,
              isLoading: isRoomLoading,
              roomIndex: globalRoomIndex,
            );
          }),
      ],
    );
  }
}
