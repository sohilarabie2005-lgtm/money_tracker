import 'package:flutter/material.dart';

const Color navy = Color(0xFF0B1F4B);
const Color pageBg = Color(0xFFF4F6FB);
const Color incomeGreen = Color(0xFF1E8E5A);
const Color expenseRed = Color(0xFFD64545);

const List<String> expenseCategories = [
  'Food',
  'Transport',
  'Shopping',
  'Bills',
  'Other',
];

IconData iconFor(String category) {
  switch (category) {
    case 'Food':
      return Icons.restaurant;
    case 'Transport':
      return Icons.directions_car;
    case 'Shopping':
      return Icons.shopping_bag;
    case 'Bills':
      return Icons.receipt_long;
    case 'Income':
      return Icons.account_balance_wallet;
    default:
      return Icons.category;
  }
}
