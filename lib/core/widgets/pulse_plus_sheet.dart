import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

Future<void> showPulsePlusSheet(
  BuildContext context, {
  required String feature,
  required IconData icon,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(28),
      ),
    ),
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              const SizedBox(height: 24),

              CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.royalPurple.withOpacity(.12),
                child: Icon(
                  icon,
                  color: AppColors.royalPurple,
                  size: 34,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Pulse Plus",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "$feature is coming soon.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Unlock premium ways to communicate with nearby Pulses.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Got it"),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
