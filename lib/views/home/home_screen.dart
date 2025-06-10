import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';

import '../../utility/colors.dart';
import '../flight/form/flight_form.dart';
import '../group_ticket/airline/data_controller.dart';
import '../group_ticket/group_ticket.dart';
import '../hotel/hotel/hotel_form.dart';
import '../users/login/login.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Text(
                    'Balance: PKR 0',
                    style: TextStyle(color: Colors.black, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: TColors.secondary),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.login, color: TColors.primary),
            onPressed: () {
              Get.to(() => Login());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Section - Main Travel Options (highlighted in green in image 1)
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(() => FlightBookingScreen());
                    },
                    child: _buildTravelOption(
                      'Flights',
                      Icons.flight,
                      TColors.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(() => HotelFormScreen());
                    },
                    child: _buildTravelOption(
                      'Hotels',
                      Icons.hotel,
                      TColors.primary,
                    ),
                  ),
                  // GestureDetector(
                  //   onTap: () {
                  //     TravelDataController().loadAirlines();
                  //     // TravelDataController().loadSectors();
                  //     Get.to(() => GroupTicket());
                  //   },
                  //   child: _buildTravelOption(
                  //     'Group Tickets',
                  //     Icons.train,
                  //     TColors.primary,
                  //   ),
                  // ),
                ],
              ),
            ),

            // Second Section - 8 Options Grid (shown in image 1 below main options)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                childAspectRatio: 1.0,
                children: [
                  _buildGridItem('Flight + Hotel', Icons.card_travel),
                  _buildGridItem('Bus', Icons.directions_bus),
                  _buildGridItem('Activities', Icons.local_activity),
                  _buildGridItem('Forex', Icons.currency_exchange),
                  _buildGridItem('Activities', Icons.celebration),
                  _buildGridItem('Gift Card', Icons.card_giftcard),
                  _buildGridItem('Trains', Icons.train),
                  _buildGridItem('Experiences', Icons.explore),
                ],
              ),
            ),

            // Third Section - Holy Days Banner (shown in image 1 at bottom)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TColors.secondary.withOpacity(0.4),
                    TColors.secondary.withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Holi Days',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'SALE EXTENDED',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Image.asset(
                      'assets/images/pkg.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            // Fourth Section - Special Offers with TabBar (as shown in image 2)
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Special Offer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: TColors.secondary,
                          ),
                        ],
                      ),
                      Text(
                        'View All',
                        style: TextStyle(fontSize: 14, color: TColors.primary),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TabBar(
                      dividerColor: Colors.transparent,
                      controller: _tabController,
                      padding: EdgeInsets.zero,
                      indicatorPadding: EdgeInsets.zero,
                      labelPadding: EdgeInsets.zero,
                      indicator: BoxDecoration(
                        color: TColors.primary,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: TColors.secondary,
                      labelStyle: TextStyle(fontSize: 12), // Smaller text size
                      tabs: [
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text('Top Offers'),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text('Bank Offers'),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text('Flights'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Top Offers Tab
                        _buildSpecialOfferContent('Top'),

                        // App Offers Tab
                        _buildSpecialOfferContent('App'),

                        // Flights Tab
                        _buildSpecialOfferContent('Flight'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Fifth Section - Recently Search (as shown in image 2)
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Recently Search',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 5),
                          Icon(
                            Icons.arrow_forward,
                            size: 18,
                            color: TColors.secondary,
                          ),
                        ],
                      ),
                      Text(
                        'Clear All',
                        style: TextStyle(fontSize: 14, color: TColors.primary),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRecentSearchCard(
                          'Mumbai - Baku',
                          'Economy • 20 Dec 2025 - 31 Dec 2025',
                          TColors.primary,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildRecentSearchCard(
                          'Hyderabad - Baku',
                          'Economy • 25 Nov 2025 - 30 Nov 2025',
                          TColors.third,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Sixth Section - Daily Travel Blogs
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your Daily Travel Blogs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'View All >',
                        style: TextStyle(fontSize: 14, color: TColors.primary),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBlogCard(
                          'assets/images/pkg.png',
                          'Top 5 Winter Destinations Every Traveller must Explore',
                          '2 weeks ago',
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildBlogCard(
                          'assets/images/pkg.png',
                          'Top 5 Places to Visit in India to Experience Rural Life',
                          '3 weeks ago',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Seventh Section - Why Book With Us (as shown in image 3)
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why Book With Us?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  _buildReasonCard(
                    Icons.headset_mic,
                    '24/7 Customer Support',
                    'Our concierge team is on standby to help you out in any situation',
                  ),
                  SizedBox(height: 16),
                  _buildReasonCard(
                    Icons.security,
                    'Secure Booking Process',
                    'Feel safe during your booking process using the latest encryption',
                  ),
                  SizedBox(height: 16),
                  _buildReasonCard(
                    Icons.verified_user,
                    'Trusted by Members',
                    'Over millions of people worldwide trust us as their travel partner',
                  ),
                  SizedBox(height: 16),
                  _buildReasonCard(
                    Icons.people,
                    '20 Million Happy Members',
                    'Join our family of travelers for a friendly flight experience',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTravelOption(String title, IconData icon, Color color) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(String title, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: TColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: TColors.primary, size: 24),
        ),
        SizedBox(height: 4),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildSpecialOfferContent(String offerType) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      height: 400,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5, // Number of cards you want to show
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: EdgeInsets.only(right: 16),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    child: Image.asset(
                      'assets/images/pkg.png',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.local_offer,
                              color: TColors.primary,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              offerType == 'Flight'
                                  ? 'Holi Day Travel Deals'
                                  : 'New User Offer',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Register and get discount on booking your first trip',
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Use code: EASYTRIP',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TColors.primary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Valid till 30 Apr 2025',
                          style: TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentSearchCard(String route, String details, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flight, color: color, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  route,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            details,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogCard(String imageUrl, String title, String date) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
            child: Image.asset(
              imageUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Text(date, style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: TColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: TColors.primary, size: 24),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
