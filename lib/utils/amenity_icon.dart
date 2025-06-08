import 'package:flutter/material.dart';

IconData getAmenityIcon(String amenity) {
  switch (amenity.toLowerCase()) {
    case 'wifi':
      return Icons.wifi;
    case 'tv':
      return Icons.tv;
    case 'free parking':
      return Icons.local_parking;
    case 'kitchen':
      return Icons.restaurant_rounded;
    case 'pool':
      return Icons.pool;
    case 'air conditioning':
      return Icons.ac_unit;
    case 'washer':
      return Icons.local_laundry_service;
    case 'beach access':
      return Icons.beach_access;
    case 'exercise equipment':
      return Icons.fitness_center;
    case 'lake view':
      return Icons.waves;
    case 'workspace':
      return Icons.computer_rounded;
    case 'security camera':
      return Icons.camera_indoor_outlined;
    case 'fire pit':
      return Icons.local_fire_department_sharp;
    case 'bbq grill':
      return Icons.outdoor_grill;
    case 'first aid kit':
      return Icons.medical_services_rounded;
    case 'outdoor area':
      return Icons.park_rounded;
    case 'outdoor shower':
      return Icons.shower;
    case 'bathtub':
      return Icons.bathtub_rounded;
    case 'city view':
      return Icons.location_city;
    case 'fire extinguisher':
      return Icons.fire_extinguisher_rounded;
    case 'refrigerator':
      return Icons.kitchen_sharp;
    case 'microwave':
      return Icons.microwave_outlined;
    case 'water front':
      return Icons.water;
    case 'breakfast':
      return Icons.dining;
    default:
      return Icons.check_circle_outline;
  }
}