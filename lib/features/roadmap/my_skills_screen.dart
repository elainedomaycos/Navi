import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import './models/tracked_skill.dart';
import '../../providers/app_providers.dart';

class MySkillsScreen extends ConsumerStatefulWidget {
  final List<String> suggestedSkills;

  const MySkillsScreen({
    super.key,
    this.suggestedSkills = const [],
  });

  @override
  ConsumerState<MySkillsScreen> createState() => _MySkillsScreenState();
}

class _MySkillsScreenState extends ConsumerState<MySkillsScreen> {
  @override
  Widget build(BuildContext context) {
    final skills = ref.watch(trackedSkillsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'My Skills',
                  style: NaviTextStyles.heading2.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _AddSkillButton(onAdd: _showAddSkillSheet),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${skills.length} tracked skill${skills.length == 1 ? '' : 's'}',
            style: NaviTextStyles.bodyMedium.copyWith(
              color: NaviColors.textMid,
            ),
          ),
          const SizedBox(height: 16),
          if (skills.isEmpty)
            _EmptySkills(onAdd: _showAddSkillSheet)
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: skills.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _SkillCard(
                  skill: skills[i],
                  onLevelChanged: (lvl) => _updateLevel(skills[i], lvl),
                  onStatusChanged: (st) => _updateStatus(skills[i], st),
                  onEdit: () => _showEditSkillSheet(skills[i]),
                  onDelete: () => _confirmDeleteSkill(skills[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showAddSkillSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8F4FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => _AddSkillForm(
        suggestedSkills: widget.suggestedSkills,
      ),
    );
  }

  void _showEditSkillSheet(TrackedSkill skill) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8F4FF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => _EditSkillForm(skill: skill),
    );
  }

  void _confirmDeleteSkill(TrackedSkill skill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Skill'),
        content: Text('Remove "${skill.name}" from your tracked skills?'),
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
              _deleteSkill(skill);
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

  Future<void> _updateLevel(TrackedSkill skill, int level) async {
    await ref
        .read(trackedSkillsProvider.notifier)
        .update(skill.copyWith(level: level));
  }

  Future<void> _updateStatus(TrackedSkill skill, SkillStatus status) async {
    await ref
        .read(trackedSkillsProvider.notifier)
        .update(skill.copyWith(status: status));
  }

  Future<void> _deleteSkill(TrackedSkill skill) async {
    await ref.read(trackedSkillsProvider.notifier).remove(skill.id);
  }
}

class _AddSkillButton extends StatelessWidget {
  final VoidCallback onAdd;

  const _AddSkillButton({required this.onAdd});

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

class _EmptySkills extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptySkills({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_border_rounded,
              size: 48,
              color: NaviColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'No skills tracked',
              style: NaviTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: NaviColors.textMid,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Track your skill proficiency to see how\nthey boost your career match.',
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
              child: const Text('Track a Skill'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final TrackedSkill skill;
  final ValueChanged<int> onLevelChanged;
  final ValueChanged<SkillStatus> onStatusChanged;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SkillCard({
    required this.skill,
    required this.onLevelChanged,
    required this.onStatusChanged,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(skill.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: NaviColors.sparkPink,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFEAE4F8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    skill.name,
                    style: NaviTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _StatusChip(status: skill.status),
                const SizedBox(width: 6),
                _CircleIcon(
                  icon: Icons.edit_rounded,
                  onTap: onEdit,
                ),
                const SizedBox(width: 4),
                _CircleIcon(
                  icon: Icons.delete_outline_rounded,
                  color: NaviColors.sparkPink,
                  onTap: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (int i = 1; i <= 5; i++)
                  GestureDetector(
                    onTap: () => onLevelChanged(i),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        i <= skill.level
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 26,
                        color: i <= skill.level
                            ? NaviColors.sparkYellow
                            : NaviColors.textMuted.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  _levelLabel(skill.level),
                  style: NaviTextStyles.label.copyWith(
                    color: NaviColors.textMid,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: SkillStatus.values
                  .map(
                    (st) => Expanded(
                      child: GestureDetector(
                        onTap: () => onStatusChanged(st),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: skill.status == st
                                ? NaviColors.primary.withValues(alpha: 0.12)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: skill.status == st
                                ? Border.all(
                                    color: NaviColors.primary
                                        .withValues(alpha: 0.3))
                                : null,
                          ),
                          child: Text(
                            _statusLabel(st),
                            textAlign: TextAlign.center,
                            style: NaviTextStyles.label.copyWith(
                              color: skill.status == st
                                  ? NaviColors.primary
                                  : NaviColors.textMuted,
                              fontSize: 11,
                              fontWeight: skill.status == st
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _levelLabel(int level) => switch (level) {
        1 => 'Beginner',
        2 => 'Basic',
        3 => 'Intermediate',
        4 => 'Advanced',
        5 => 'Expert',
        _ => '',
      };

  String _statusLabel(SkillStatus st) => switch (st) {
        SkillStatus.learning => 'Learning',
        SkillStatus.proficient => 'Proficient',
        SkillStatus.mastered => 'Mastered',
      };
}

class _StatusChip extends StatelessWidget {
  final SkillStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      SkillStatus.learning => (NaviColors.sparkBlue, 'Learning'),
      SkillStatus.proficient => (NaviColors.sparkGreen, 'Proficient'),
      SkillStatus.mastered => (NaviColors.sparkPurple, 'Mastered'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: NaviTextStyles.label.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final VoidCallback onTap;

  const _CircleIcon({
    required this.icon,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: (color ?? NaviColors.textMuted).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color ?? NaviColors.textMid,
          ),
        ),
      ),
    );
  }
}

class _EditSkillForm extends ConsumerStatefulWidget {
  final TrackedSkill skill;

  const _EditSkillForm({required this.skill});

  @override
  ConsumerState<_EditSkillForm> createState() => _EditSkillFormState();
}

class _EditSkillFormState extends ConsumerState<_EditSkillForm> {
  late final TextEditingController _nameCtrl;
  late int _level;
  late SkillStatus _status;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.skill.name);
    _level = widget.skill.level;
    _status = widget.skill.status;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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
            'Edit Skill',
            style:
                NaviTextStyles.heading2.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            onChanged: (_) => setState(() {}),
            style: NaviTextStyles.bodyLarge.copyWith(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Skill name',
              hintStyle: NaviTextStyles.bodyMedium
                  .copyWith(color: NaviColors.textMuted),
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
                borderSide:
                    const BorderSide(color: NaviColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Proficiency level',
            style: NaviTextStyles.label.copyWith(color: NaviColors.textMuted),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => _level = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    i < _level ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 32,
                    color: i < _level
                        ? NaviColors.sparkYellow
                        : NaviColors.textMuted.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: SkillStatus.values
                .map(
                  (st) => Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _status = st),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _status == st
                              ? NaviColors.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: _status == st
                              ? Border.all(
                                  color: NaviColors.primary
                                      .withValues(alpha: 0.3))
                              : Border.all(color: const Color(0xFFEAE4F8)),
                        ),
                        child: Text(
                          st.name[0].toUpperCase() + st.name.substring(1),
                          textAlign: TextAlign.center,
                          style: NaviTextStyles.label.copyWith(
                            color: _status == st
                                ? NaviColors.primary
                                : NaviColors.textMuted,
                            fontSize: 12,
                            fontWeight: _status == st
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _nameCtrl.text.trim().isEmpty
                  ? null
                  : () async {
                      final updated = widget.skill.copyWith(
                        name: _nameCtrl.text.trim(),
                        level: _level,
                        status: _status,
                      );
                      await ref
                          .read(trackedSkillsProvider.notifier)
                          .update(updated);
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
    );
  }
}

class _AddSkillForm extends ConsumerStatefulWidget {
  final List<String> suggestedSkills;

  const _AddSkillForm({this.suggestedSkills = const []});

  @override
  ConsumerState<_AddSkillForm> createState() => _AddSkillFormState();
}

class _AddSkillFormState extends ConsumerState<_AddSkillForm> {
  final _nameCtrl = TextEditingController();
  int _level = 1;
  SkillStatus _status = SkillStatus.learning;

  static const _defaultSuggestions = [
    'Python',
    'SQL',
    'JavaScript',
    'Figma',
    'Excel',
    'Project Management',
    'Communication',
    'Agile/Scrum',
    'Data Analysis',
    'Requirements Analysis',
    'Test Automation',
    'Machine Learning',
    'UI/UX Design',
    'Process Mapping',
  ];

  List<String> get _suggestions {
    if (widget.suggestedSkills.isNotEmpty) {
      return widget.suggestedSkills;
    }
    return _defaultSuggestions;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
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
            'Track a Skill',
            style:
                NaviTextStyles.heading2.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            onChanged: (_) => setState(() {}),
            style: NaviTextStyles.bodyLarge.copyWith(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Skill name',
              hintStyle: NaviTextStyles.bodyMedium
                  .copyWith(color: NaviColors.textMuted),
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
                borderSide:
                    const BorderSide(color: NaviColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Quick add',
            style: NaviTextStyles.label.copyWith(color: NaviColors.textMuted),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _suggestions
                .where((s) =>
                    s.toLowerCase().contains(_nameCtrl.text.toLowerCase()) ||
                    _nameCtrl.text.isEmpty)
                .take(8)
                .map(
                  (s) => GestureDetector(
                    onTap: () {
                      _nameCtrl.text = s;
                      setState(() {});
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: NaviColors.primaryPale.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        s,
                        style: NaviTextStyles.label.copyWith(
                          color: NaviColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 14),
          Text(
            'Proficiency level',
            style: NaviTextStyles.label.copyWith(color: NaviColors.textMuted),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => setState(() => _level = i + 1),
                child: Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    i < _level ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 32,
                    color: i < _level
                        ? NaviColors.sparkYellow
                        : NaviColors.textMuted.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: SkillStatus.values
                .map(
                  (st) => Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _status = st),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _status == st
                              ? NaviColors.primary.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: _status == st
                              ? Border.all(
                                  color:
                                      NaviColors.primary.withValues(alpha: 0.3))
                              : Border.all(color: const Color(0xFFEAE4F8)),
                        ),
                        child: Text(
                          st.name[0].toUpperCase() + st.name.substring(1),
                          textAlign: TextAlign.center,
                          style: NaviTextStyles.label.copyWith(
                            color: _status == st
                                ? NaviColors.primary
                                : NaviColors.textMuted,
                            fontSize: 12,
                            fontWeight: _status == st
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _nameCtrl.text.trim().isEmpty
                  ? null
                  : () async {
                      final skill = TrackedSkill(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        name: _nameCtrl.text.trim(),
                        level: _level,
                        status: _status,
                      );
                      await ref.read(trackedSkillsProvider.notifier).add(skill);
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
              child: const Text('Track Skill'),
            ),
          ),
        ],
      ),
    );
  }
}
