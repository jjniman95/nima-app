import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  int? selectedIndex;

  Color _dotColor(int index) {
    switch (index % 4) {
      case 0:
        return Colors.greenAccent;
      case 1:
        return Colors.yellowAccent;
      case 2:
        return Colors.orangeAccent;
      default:
        return Colors.redAccent;
    }
  }

  String _proximityText(int index) {
    switch (index % 4) {
      case 0:
        return 'Very Close';
      case 1:
        return 'Nearby';
      case 2:
        return 'Far';
      default:
        return 'Edge of Range';
    }
  }
