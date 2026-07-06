import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AboutPulseSharedCard extends StatelessWidget {
  const AboutPulseSharedCard({
    super.key,
    required this.sharerName,
    required this.details,
  });

  final String sharerName;
  final Map<String, dynamic> details;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.royalPurple.withOpacity(.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '👤 About Pulse',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Text('$sharerName shared:'),
            const SizedBox(height: 12),
            if (details['age'] != null)
              _Row(label: 'Age', value: details['age'].toString()),
            if (details['gender'] != null)
              _Row(label: 'Gender', value: details['gender'].toString()),
            if (details['interests'] != null)
              _Row(
                label: 'Interests',
                value: (details['interests'] as List).join(' • '),
              ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text('$label: $value'),
    );
  }
}
