// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ready_flights/utility/colors.dart';
import 'package:ready_flights/views/home/booking_card.dart';
import 'package:ready_flights/views/users/login/login.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:url_launcher/url_launcher.dart';
import 'featured_items.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showBookingCard = true;

  void _toggleBookingCard() {
    setState(() {
      _showBookingCard = !_showBookingCard;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // This will dismiss the keyboard when tapping anywhere on the screen
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: const CustomAppBar(),
        body: Container(
          color: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                HomeBanner(
                  showBookingCard: _showBookingCard,
                  onToggleBooking: _toggleBookingCard,
                ),
                const SizedBox(height: 60),
                const CustomerServiceSection(),
                const SizedBox(height: 24),
                const FeatureCarousel(),
                const SizedBox(height: 24),
                const StatsSection(),
                const SizedBox(height: 24),
                const FeaturedPartners(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CurrencySelector extends StatelessWidget {
  const CurrencySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Row(
        children: [
          Text('PKR'),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down),
        ],
      ),
    );
  }
}

class HomeBanner extends StatelessWidget {
  final bool showBookingCard;
  final VoidCallback onToggleBooking;

  const HomeBanner({
    super.key,
    required this.showBookingCard,
    required this.onToggleBooking,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: showBookingCard ? 450 : 300,
          decoration: const BoxDecoration(
            color: TColors.primary,
            image: DecorationImage(
              image: AssetImage('assets/img/banner_bg.png'),
              fit: BoxFit.cover,
            ),
          ),
          // Add gradient overlay
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.5),
                  TColors.primary.withOpacity(0.8),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
        ),
        // Content based on booking card visibility
        if (showBookingCard) ...[
          // Close button when booking card is shown
          Positioned(
            top: 25,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              onPressed: onToggleBooking,
              backgroundColor: Colors.white,
              foregroundColor: TColors.primary,
              child: const Icon(Icons.close, size: 20),
            ),
          ),
          // Booking card
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: BookingCard(),
          ),
        ] else ...[
          // Welcome content and buttons container when hidden
          Container(
            margin: EdgeInsets.only(top: 265, left: 20, right: 20),
            width: double.infinity,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onToggleBooking,
                    icon: const Icon(Icons.flight_land_sharp, size: 20),
                    label: const Text(
                      'Create New Booking',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: TColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                      shadowColor: Colors.transparent,
                    ),
                  ),
                ),
                FloatingActionButton(
                  mini: true,
                  onPressed: onToggleBooking,
                  backgroundColor: Colors.white,
                  foregroundColor: TColors.primary,
                  elevation: 0,
                  child: const Icon(Icons.add, size: 20),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
class CustomerServiceSection extends StatelessWidget {
  const CustomerServiceSection({super.key});

  final String mobileNumber = "923007240421";

  Future<void> launchWhatsApp() async {
    String message = "Ready FLights ";
    final url = "https://wa.me/$mobileNumber?text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> launchCall() async {
    final url = "tel:$mobileNumber";

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TColors.primary.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: AssetImage('assets/img/help-desk.png'),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '24/7 Customer Service',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Speak to Asma or another travel expert',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => launchCall(),
                  icon: const Icon(Icons.phone),
                  label: const Text('Call'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => launchWhatsApp(),
                  icon: Icon(MdiIcons.whatsapp),
                  label: const Text('WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: AppColors.primary.withOpacity(0.1),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          StatItem(
            icon: Icons.flight,
            number: '700k+',
            label: 'Flights booked',
          ),
          StatItem(
            icon: Icons.directions_bus,
            number: '300k+',
            label: 'Buses booked',
          ),
          StatItem(
            icon: Icons.route,
            number: '20m+',
            label: 'Kilometres traveled',
          ),
        ],
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final IconData icon;
  final String number;
  final String label;

  const StatItem({
    required this.icon,
    required this.number,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 32),
        const SizedBox(height: 8),
        Text(
          number,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double logoHeight;

  const CustomAppBar({super.key, this.logoHeight = 35.0});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Image.asset("assets/images/logo.png", height: logoHeight),
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(() => Login());
                },
                child: Icon(Icons.person_outline, color: TColors.primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
