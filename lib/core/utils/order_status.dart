import 'package:flutter/material.dart';

String orderStatusLabel(String status) {
  switch (status) {
    case 'pending':
      return 'قيد الانتظار';
    case 'delivery':
      return 'قيد التوصيل';
    case 'completed':
      return 'مكتمل';
    case 'cancelled':
      return 'ملغي';
    default:
      return status;
  }
}

Color orderStatusBackground(String status) {
  switch (status) {
    case 'pending':
      return Colors.yellow.withOpacity(0.5);
    case 'delivery':
      return Colors.deepOrange.withOpacity(0.5);
    case 'completed':
      return Colors.lightGreenAccent.withOpacity(0.5);
    case 'cancelled':
      return Colors.redAccent.withOpacity(0.5);
    default:
      return Colors.grey.withOpacity(0.3);
  }
}
