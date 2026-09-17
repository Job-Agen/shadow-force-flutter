import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressStore extends ChangeNotifier {
  static const _key = 'completed_days';
  Set<int> completedDays = {};
  bool loaded = false;

  int get completedCount => completedDays.length;
  int get nextDay {
    for (var day = 1; day <= 30; day++) {
      if (!completedDays.contains(day)) return day;
    }
    return 30;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    completedDays = prefs.getStringList(_key)?.map(int.parse).toSet() ?? {};
    loaded = true;
    notifyListeners();
  }

  Future<void> complete(int day) async {
    completedDays.add(day);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, completedDays.map((e) => '$e').toList());
    notifyListeners();
  }

  Future<void> reset() async {
    completedDays.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    notifyListeners();
  }
}
