import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/tx.dart';

/// Saves and loads transactions with shared_preferences.
/// Each logged-in email has its own list, so two users on the same
/// device never see each other's data.
class StorageService {
  static String _key(String email) =>
      'transactions_${email.trim().toLowerCase()}';

  static Future<List<Tx>> load(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(email));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => Tx.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Corrupted data: start clean instead of crashing.
      return [];
    }
  }

  static Future<void> save(String email, List<Tx> txs) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(txs.map((t) => t.toJson()).toList());
    await prefs.setString(_key(email), raw);
  }
}
