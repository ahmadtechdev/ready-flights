import 'package:flutter/material.dart';

import '../utility/colors.dart';

class LoadingDialog extends StatefulWidget {
  final String message;

  const LoadingDialog({
    super.key,
    this.message = 'Please wait while we are loading best hotel deals for you.',
  });

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _countdown = 20;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Slower animation for better visual effect
    )..repeat(reverse: true); // Reverse animation to create bouncing effect

    // Start countdown
    _startCountdown();
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _countdown > 0) {
        setState(() {
          _countdown--;
        });
        _startCountdown();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Custom animated loading indicator with vertical movement
            Container(
              width: 100,
              height: 100,
              // margin: const EdgeInsets.only(bottom: 20),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (_, child) {
                  return Transform.translate(
                    offset: Offset(0, -20 * _controller.value), // Move from bottom to top
                    child: child,
                  );
                },
                child: Image.asset(
                  'assets/images/loder.png', // Add a hotel or travel related icon
                  width: 80,
                  height: 80,
                ),
              ),
            ),

            // Loading message
            Text(
              widget.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 15),

            // Progress indicators
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_countdown / 20),
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(TColors.primary),
                minHeight: 6,
              ),
            ),

            const SizedBox(height: 10),

            // Countdown text
            Text(
              'Estimated time: $_countdown seconds',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 20),

            // Tips or additional information
          ],
        ),
      ),
    );
  }
}