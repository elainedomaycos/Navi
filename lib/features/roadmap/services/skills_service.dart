import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/tracked_skill.dart';

class SkillsService {
  SkillsService._();

  static const _key = 'navi_tracked_skills';

  static Future<List<TrackedSkill>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return [];
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((s) => TrackedSkill.fromJson(s as Map<String, dynamic>)).toList();
  }

  static Future<void> save(List<TrackedSkill> skills) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(skills.map((s) => s.toJson()).toList()));
  }

  static Future<void> add(TrackedSkill skill) async {
    final skills = await load();
    skills.add(skill);
    await save(skills);
  }

  static Future<void> update(TrackedSkill updated) async {
    final skills = await load();
    final idx = skills.indexWhere((s) => s.id == updated.id);
    if (idx != -1) {
      skills[idx] = updated;
      await save(skills);
    }
  }

  static Future<void> remove(String id) async {
    final skills = await load();
    skills.removeWhere((s) => s.id == id);
    await save(skills);
  }
}
