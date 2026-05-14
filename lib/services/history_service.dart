import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QrHistoryItem {
  final String data;
  final DateTime timestamp;
  final bool isScanned; // true = scanned, false = generated

  QrHistoryItem({
    required this.data,
    required this.timestamp,
    required this.isScanned,
  });

  Map<String, dynamic> toJson() => {
    'data': data,
    'timestamp': timestamp.toIso8601String(),
    'isScanned': isScanned,
  };

  factory QrHistoryItem.fromJson(Map<String, dynamic> json) => QrHistoryItem(
    data: json['data'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    isScanned: json['isScanned'] as bool,
  );
}

class HistoryService {
  static const String _historyKey = 'qr_history';
  static const int _maxHistoryItems = 50;

  static Future<List<QrHistoryItem>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList(_historyKey) ?? [];
    return historyJson
        .map((item) => QrHistoryItem.fromJson(jsonDecode(item) as Map<String, dynamic>))
        .toList();
  }

  static Future<void> addToHistory(String data, bool isScanned) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    // Remove duplicate entries with same data
    history.removeWhere((item) => item.data == data);
    
    // Add new item at the beginning
    history.insert(0, QrHistoryItem(
      data: data,
      timestamp: DateTime.now(),
      isScanned: isScanned,
    ));

    // Keep only the most recent items
    while (history.length > _maxHistoryItems) {
      history.removeLast();
    }

    final historyJson = history.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_historyKey, historyJson);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  static Future<void> removeFromHistory(String data) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    history.removeWhere((item) => item.data == data);
    final historyJson = history.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_historyKey, historyJson);
  }
}
