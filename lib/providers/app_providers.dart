import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/quiz/quiz_session.dart';
import '../features/results/recommendation_result.dart';
import '../features/roadmap/models/goal.dart';
import '../features/roadmap/models/goal_task.dart';
import '../features/roadmap/models/tracked_skill.dart';
import '../features/roadmap/services/goals_service.dart';
import '../features/roadmap/services/skills_service.dart';

const _soundsEnabledKey = 'settings.soundsEnabled';
const _animationsEnabledKey = 'settings.animationsEnabled';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

class AppPreferences {
  final bool soundsEnabled;
  final bool animationsEnabled;

  const AppPreferences({
    required this.soundsEnabled,
    required this.animationsEnabled,
  });

  AppPreferences copyWith({
    bool? soundsEnabled,
    bool? animationsEnabled,
  }) {
    return AppPreferences(
      soundsEnabled: soundsEnabled ?? this.soundsEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
    );
  }
}

class AppPreferencesNotifier extends StateNotifier<AppPreferences> {
  final SharedPreferences _prefs;

  AppPreferencesNotifier(this._prefs)
      : super(
          AppPreferences(
            soundsEnabled: _prefs.getBool(_soundsEnabledKey) ?? true,
            animationsEnabled: _prefs.getBool(_animationsEnabledKey) ?? true,
          ),
        );

  Future<void> setSoundsEnabled(bool value) async {
    state = state.copyWith(soundsEnabled: value);
    await _prefs.setBool(_soundsEnabledKey, value);
  }

  Future<void> setAnimationsEnabled(bool value) async {
    state = state.copyWith(animationsEnabled: value);
    await _prefs.setBool(_animationsEnabledKey, value);
  }
}

final appPreferencesProvider =
    StateNotifierProvider<AppPreferencesNotifier, AppPreferences>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppPreferencesNotifier(prefs);
});

class QuizSessionNotifier extends StateNotifier<QuizSession?> {
  QuizSessionNotifier() : super(null);

  void setSession(QuizSession? session) => state = session;
  void clear() => state = null;
}

final quizSessionProvider =
    StateNotifierProvider<QuizSessionNotifier, QuizSession?>((ref) {
  return QuizSessionNotifier();
});

class RecommendationResultNotifier
    extends StateNotifier<RecommendationResult?> {
  RecommendationResultNotifier() : super(null);

  void setResult(RecommendationResult? result) => state = result;
  void clear() => state = null;
}

final recommendationResultProvider =
    StateNotifierProvider<RecommendationResultNotifier, RecommendationResult?>(
        (ref) {
  return RecommendationResultNotifier();
});

// ── Goals ──────────────────────────────────────────────────────────────────

class GoalsNotifier extends StateNotifier<List<Goal>> {
  GoalsNotifier() : super(const []) {
    _load();
  }

  Future<void> _load() async {
    state = await GoalsService.load();
  }

  Future<void> add(Goal goal) async {
    state = [...state, goal];
    await GoalsService.add(goal);
  }

  Future<void> update(Goal updated) async {
    state = [for (final g in state) if (g.id == updated.id) updated else g];
    await GoalsService.update(updated);
  }

  Future<void> remove(String id) async {
    state = state.where((g) => g.id != id).toList();
    await GoalsService.remove(id);
  }

  Future<void> toggleTask(String goalId, String taskId) async {
    state = [
      for (final g in state)
        if (g.id == goalId)
          g.copyWith(
            tasks: [
              for (final t in g.tasks)
                if (t.id == taskId) t.copyWith(completed: !t.completed) else t,
            ],
          )
        else
          g,
    ];
    final updated = state.firstWhere((g) => g.id == goalId);
    await GoalsService.update(updated);
  }

  Future<void> addTask(String goalId, GoalTask task) async {
    state = [
      for (final g in state)
        if (g.id == goalId)
          g.copyWith(tasks: [...g.tasks, task])
        else
          g,
    ];
    final updated = state.firstWhere((g) => g.id == goalId);
    await GoalsService.update(updated);
  }

  Future<void> removeTask(String goalId, String taskId) async {
    state = [
      for (final g in state)
        if (g.id == goalId)
          g.copyWith(tasks: g.tasks.where((t) => t.id != taskId).toList())
        else
          g,
    ];
    final updated = state.firstWhere((g) => g.id == goalId);
    await GoalsService.update(updated);
  }
}

final goalsProvider =
    StateNotifierProvider<GoalsNotifier, List<Goal>>((ref) {
  return GoalsNotifier();
});

// ── Tracked Skills ─────────────────────────────────────────────────────────

class TrackedSkillsNotifier extends StateNotifier<List<TrackedSkill>> {
  TrackedSkillsNotifier() : super(const []) {
    _load();
  }

  Future<void> _load() async {
    state = await SkillsService.load();
  }

  Future<void> add(TrackedSkill skill) async {
    state = [...state, skill];
    await SkillsService.add(skill);
  }

  Future<void> update(TrackedSkill updated) async {
    state = [for (final s in state) if (s.id == updated.id) updated else s];
    await SkillsService.update(updated);
  }

  Future<void> remove(String id) async {
    state = state.where((s) => s.id != id).toList();
    await SkillsService.remove(id);
  }
}

final trackedSkillsProvider =
    StateNotifierProvider<TrackedSkillsNotifier, List<TrackedSkill>>((ref) {
  return TrackedSkillsNotifier();
});
