import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            final glow = 8 + _controller.value * 24;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent, width: 1.3),
                boxShadow: [
                  BoxShadow(color: AppColors.accent.withOpacity(0.5), blurRadius: glow),
                ],
              ),
              child: const Text(
                'BLACK RED',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 5,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
