import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/ph_career.dart';

class CareerDataService {
  CareerDataService._();

  static PhCareerData? _cached;

  static Future<PhCareerData> load() async {
    if (_cached != null) return _cached!;

    final raw = await rootBundle.loadString('assets/data/ph_careers.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cached = PhCareerData.fromJson(json);
    return _cached!;
  }

  static PhCareerData? get cached => _cached;

  static Future<PhCareer?> careerById(String id) async {
    final data = await load();
    return data.byId(id);
  }

  static Future<List<PhCareer>> allCareers() async {
    final data = await load();
    return data.careers;
  }
}
