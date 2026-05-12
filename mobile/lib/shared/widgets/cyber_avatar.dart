import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class CyberAvatar extends StatelessWidget {
  const CyberAvatar({super.key, required this.name, this.url = '', this.radius = 22});

  final String name;
  final String url;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [AppColors.accent, Colors.transparent]),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surface,
        backgroundImage: url.isNotEmpty ? NetworkImage(url) : null,
        child: url.isEmpty
            ? Text(
                initial,
                style: TextStyle(fontSize: radius * 0.9, color: Colors.white, fontWeight: FontWeight.bold),
              )
            : null,
      ),
    );
  }
}
