import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/gemini_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import './models/goal.dart';
import './models/goal_task.dart';
import '../../providers/app_providers.dart';

class MyGoalsScreen extends ConsumerStatefulWidget {
  const MyGoalsScreen({super.key});

  @override
  ConsumerState<MyGoalsScreen> createState() => _MyGoalsScreenState();
}

class _MyGoalsScreenState extends ConsumerState<MyGoalsScreen> {
  @override
  Widget build(BuildContext context) {
    final goals = ref.watch(goalsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'My Goals',
                  style: NaviTextStyles.heading2.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _AddGoalButton(onAdd: _showAddGoalSheet),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${goals.length} goal${goals.length == 1 ? '' : 's'}',
            style: NaviTextStyles.bodyMedium.copyWith(
              color: NaviColors.textMid,
            ),
          ),
          const SizedBox(height: 16),
          if (goals.isEmpty)
            _EmptyGoals(onAdd: _showAddGoalSheet)
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: goals.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _GoalCard(
                  goal: goals[i],
                  onToggleTask: (taskId) =>
                      _toggleTask(goals[i], taskId),
                  onEdit: () => _showEditGoalSheet(goals[i]),
                  onDelete: () => _confirmDeleteGoal(goals[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddGoalSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8F4FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => const _AddGoalForm(),
    );
  }

  void _showEditGoalSheet(Goal goal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8F4FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => _EditGoalForm(goal: goal),
    );
  }

  void _confirmDeleteGoal(Goal goal) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Goal'),
        content: Text('Remove "${goal.title}" from your goals?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: NaviTextStyles.label.copyWith(color: NaviColors.textMid),
            ),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteGoal(goal);
            },
            style: FilledButton.styleFrom(
              backgroundColor: NaviColors.sparkPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleTask(Goal goal, String taskId) async {
    await ref.read(goalsProvider.notifier).toggleTask(goal.id, taskId);
  }

  Future<void> _deleteGoal(Goal goal) async {
    await ref.read(goalsProvider.notifier).remove(goal.id);
  }
}

class _AddGoalButton extends StatelessWidget {
  final VoidCallback onAdd;

  const _AddGoalButton({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: NaviColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
      ),
    );
  }
}

class _EmptyGoals extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyGoals({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.flag_rounded,
              size: 48,
              color: NaviColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No goals yet',
              style: NaviTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: NaviColors.textMid,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap a roadmap milestone or add a custom goal\nto start tracking your progress.',
              textAlign: TextAlign.center,
              style: NaviTextStyles.bodyMedium.copyWith(
                color: NaviColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAdd,
              style: FilledButton.styleFrom(
                backgroundColor: NaviColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Add Goal'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;
  final ValueChanged<String> onToggleTask;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.onToggleTask,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.progressFromTasks;
    final isComplete = goal.tasks.isNotEmpty && progress >= 100;
    final completedCount = goal.tasks.where((t) => t.completed).length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isComplete
              ? NaviColors.matchHigh.withValues(alpha: 0.35)
              : const Color(0xFFEAE4F8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isComplete
                        ? NaviColors.matchHigh.withValues(alpha: 0.15)
                        : NaviColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isComplete
                        ? Icons.check_rounded
                        : Icons.flag_rounded,
                    size: 20,
                    color: isComplete
                        ? NaviColors.matchHigh
                        : NaviColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: NaviTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          decoration: isComplete
                              ? TextDecoration.lineThrough
                              : null,
                          color: isComplete
                              ? NaviColors.textMuted
                              : NaviColors.textDark,
                        ),
                      ),
                      if (goal.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          goal.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: NaviTextStyles.bodyMedium.copyWith(
                            color: NaviColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'edit') onEdit();
                    if (val == 'delete') onDelete();
                  },
                  iconSize: 20,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, size: 18),
                          SizedBox(width: 10),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 18, color: NaviColors.sparkPink),
                          SizedBox(width: 10),
                          Text('Delete',
                              style: TextStyle(color: NaviColors.sparkPink)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (goal.tasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress / 100,
                            minHeight: 6,
                            backgroundColor: NaviColors.primaryPale,
                            color: isComplete
                                ? NaviColors.matchHigh
                                : NaviColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$completedCount/${goal.tasks.length}',
                        style: NaviTextStyles.label.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: isComplete
                              ? NaviColors.matchHigh
                              : NaviColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...goal.tasks.map(
              (task) => Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onToggleTask(task.id),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: task.completed
                                ? NaviColors.matchHigh
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: task.completed
                                ? null
                                : Border.all(
                                    color: NaviColors.textMuted
                                        .withValues(alpha: 0.3),
                                    width: 1.5,
                                  ),
                          ),
                          child: task.completed
                              ? const Icon(Icons.check_rounded,
                                  size: 18, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            task.title,
                            style: NaviTextStyles.bodyMedium.copyWith(
                              decoration: task.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.completed
                                  ? NaviColors.textMuted
                                  : NaviColors.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }
}

class _EditGoalForm extends ConsumerStatefulWidget {
  final Goal goal;

  const _EditGoalForm({required this.goal});

  @override
  ConsumerState<_EditGoalForm> createState() => _EditGoalFormState();
}

class _EditGoalFormState extends ConsumerState<_EditGoalForm> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late String _difficulty;
  late String _estimatedTime;
  late List<GoalTask> _tasks;
  final _taskCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.goal.title);
    _descCtrl = TextEditingController(text: widget.goal.description);
    _difficulty = widget.goal.difficulty;
    _estimatedTime = widget.goal.estimatedTime;
    _tasks = List.from(widget.goal.tasks);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _taskCtrl.dispose();
    super.dispose();
  }

  void _addTask() {
    final text = _taskCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _tasks = [
        ..._tasks,
        GoalTask(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: text,
        ),
      ];
      _taskCtrl.clear();
    });
  }

  void _removeTask(String id) {
    setState(() => _tasks = _tasks.where((t) => t.id != id).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: NaviColors.textMuted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Edit Goal',
              style:
                  NaviTextStyles.heading2.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            _input('Goal title', _titleCtrl),
            const SizedBox(height: 10),
            _input('Description (optional)', _descCtrl),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _dropdown(
                    label: 'Difficulty',
                    value: _difficulty,
                    items: const ['Easy', 'Medium', 'Hard'],
                    onChanged: (v) => setState(() => _difficulty = v!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dropdown(
                    label: 'Estimated time',
                    value: _estimatedTime,
                    items: const [
                      '1 week',
                      '2-4 weeks',
                      '1-2 months',
                      '3+ months'
                    ],
                    onChanged: (v) => setState(() => _estimatedTime = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Tasks',
              style: NaviTextStyles.label.copyWith(color: NaviColors.textMuted),
            ),
            const SizedBox(height: 8),
            ..._tasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      task.completed
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 18,
                      color: task.completed
                          ? NaviColors.matchHigh
                          : NaviColors.textMuted.withValues(alpha: 0.5),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: NaviTextStyles.bodyMedium.copyWith(
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.completed
                              ? NaviColors.textMuted
                              : NaviColors.textDark,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _removeTask(task.id),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: NaviColors.sparkPink),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskCtrl,
                    style: NaviTextStyles.bodyMedium.copyWith(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Add a task...',
                      hintStyle: NaviTextStyles.bodyMedium
                          .copyWith(color: NaviColors.textMuted),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFEAE4F8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFEAE4F8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: NaviColors.primary, width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _addTask,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: NaviColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_rounded,
                          size: 20, color: NaviColors.primary),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _titleCtrl.text.trim().isEmpty
                    ? null
                    : () async {
                        final updated = widget.goal.copyWith(
                          title: _titleCtrl.text.trim(),
                          description: _descCtrl.text.trim(),
                          difficulty: _difficulty,
                          estimatedTime: _estimatedTime,
                          tasks: _tasks,
                        );
                        await ref.read(goalsProvider.notifier).update(updated);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: NaviColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String hint, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      onChanged: (_) => setState(() {}),
      style: NaviTextStyles.bodyLarge.copyWith(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            NaviTextStyles.bodyMedium.copyWith(color: NaviColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEAE4F8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEAE4F8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: NaviColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      style: NaviTextStyles.bodyMedium.copyWith(color: NaviColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: NaviTextStyles.label.copyWith(color: NaviColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEAE4F8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEAE4F8)),
        ),
      ),
      items:
          items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
    );
  }
}

class _AddGoalForm extends ConsumerStatefulWidget {
  const _AddGoalForm();

  @override
  ConsumerState<_AddGoalForm> createState() => _AddGoalFormState();
}

class _AddGoalFormState extends ConsumerState<_AddGoalForm> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _difficulty = 'Medium';
  String _estimatedTime = '2-4 weeks';
  bool _submitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: NaviColors.textMuted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Add Goal',
              style:
                  NaviTextStyles.heading2.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Tasks are generated automatically by AI.',
              style: NaviTextStyles.bodyMedium
                  .copyWith(color: NaviColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _input('Goal title', _titleCtrl),
            const SizedBox(height: 10),
            _input('Description (optional)', _descCtrl),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _dropdown(
                    label: 'Difficulty',
                    value: _difficulty,
                    items: const ['Easy', 'Medium', 'Hard'],
                    onChanged: (v) => setState(() => _difficulty = v!),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _dropdown(
                    label: 'Estimated time',
                    value: _estimatedTime,
                    items: const [
                      '1 week',
                      '2-4 weeks',
                      '1-2 months',
                      '3+ months'
                    ],
                    onChanged: (v) => setState(() => _estimatedTime = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _titleCtrl.text.trim().isEmpty || _submitting
                    ? null
                    : () async {
                        setState(() => _submitting = true);
                        try {
                          final taskTitles =
                              await GeminiService.generateGoalTasks(
                            title: _titleCtrl.text.trim(),
                            description: _descCtrl.text.trim(),
                            difficulty: _difficulty,
                          );
                          final tasks = taskTitles
                              .map((t) => GoalTask(
                                    id: DateTime.now()
                                        .microsecondsSinceEpoch
                                        .toString(),
                                    title: t,
                                  ))
                              .toList();
                          final goal = Goal(
                            id: DateTime.now()
                                .microsecondsSinceEpoch
                                .toString(),
                            title: _titleCtrl.text.trim(),
                            description: _descCtrl.text.trim(),
                            difficulty: _difficulty,
                            estimatedTime: _estimatedTime,
                            tasks: tasks,
                          );
                          await ref.read(goalsProvider.notifier).add(goal);
                          if (context.mounted) Navigator.of(context).pop();
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to generate tasks: $e')),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _submitting = false);
                        }
                      },
                style: FilledButton.styleFrom(
                  backgroundColor: NaviColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Add Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(String hint, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      onChanged: (_) => setState(() {}),
      style: NaviTextStyles.bodyLarge.copyWith(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            NaviTextStyles.bodyMedium.copyWith(color: NaviColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEAE4F8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEAE4F8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: NaviColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      onChanged: onChanged,
      style: NaviTextStyles.bodyMedium.copyWith(color: NaviColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: NaviTextStyles.label.copyWith(color: NaviColors.textMuted),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEAE4F8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFEAE4F8)),
        ),
      ),
      items:
          items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
    );
  }
}
