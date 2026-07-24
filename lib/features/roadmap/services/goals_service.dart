import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/goal.dart';

class GoalsService {
  GoalsService._();

  static const _key = 'navi_goals';

  static Future<List<Goal>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((g) => Goal.fromJson(g as Map<String, dynamic>)).toList();
  }

  static Future<void> save(List<Goal> goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(goals.map((g) => g.toJson()).toList()));
  }

  static Future<void> add(Goal goal) async {
    final goals = await load();
    goals.add(goal);
    await save(goals);
  }

  static Future<void> update(Goal updated) async {
    final goals = await load();
    final idx = goals.indexWhere((g) => g.id == updated.id);
    if (idx != -1) {
      goals[idx] = updated;
      await save(goals);
    }
  }

  static Future<void> remove(String id) async {
    final goals = await load();
    goals.removeWhere((g) => g.id == id);
    await save(goals);
  }
}
