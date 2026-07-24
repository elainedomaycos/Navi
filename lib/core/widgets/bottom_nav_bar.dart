import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../services/sound_effect_service.dart';

class NaviBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final VoidCallback onCenterAction;

  const NaviBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.onCenterAction,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFE4DDF2)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x13000000),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 48,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D3EA),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: _NavItem(
                            icon: Icons.home_rounded,
                            label: 'Home',
                            accent: NaviColors.primary,
                            selected: currentIndex == 0,
                            onTap: () => _select(0),
                          ),
                        ),
                        Expanded(
                          child: _NavItem(
                            icon: Icons.timeline_rounded,
                            label: 'Roadmap',
                            accent: NaviColors.sparkBlue,
                            selected: currentIndex == 1,
                            onTap: () => _select(1),
                          ),
                        ),
                        _PrimaryNavAction(
                          onTap: _triggerCenterAction,
                        ),
                        Expanded(
                          child: _NavItem(
                            icon: Icons.explore_rounded,
                            label: 'Explore',
                            accent: NaviColors.sparkPurple,
                            selected: currentIndex == 2,
                            onTap: () => _select(2),
                          ),
                        ),
                        Expanded(
                          child: _NavItem(
                            icon: Icons.person_rounded,
                            label: 'Profile',
                            accent: NaviColors.sparkTeal,
                            selected: currentIndex == 3,
                            onTap: () => _select(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _select(int index) {
    if (index == currentIndex) return;
    SoundEffectService.playTap();
    onChanged(index);
  }

  void _triggerCenterAction() {
    SoundEffectService.playConfirm();
    onCenterAction();
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color accent;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 180),
      scale: selected ? 1.0 : 0.96,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF7F4FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                selected ? accent.withValues(alpha: 0.18) : Colors.transparent,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x0E000000),
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? accent : Colors.white,
                  border: Border.all(
                    color: selected
                        ? accent.withValues(alpha: 0.10)
                        : const Color(0xFFE7E0F3),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: selected ? Colors.white : NaviColors.textMuted,
                  size: 22,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 180),
                style: TextStyle(
                  color: selected ? accent : NaviColors.textMuted,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: selected ? 13 : 12,
                ),
                child:
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrimaryNavAction extends StatelessWidget {
  final VoidCallback onTap;

  const _PrimaryNavAction({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Transform.translate(
        offset: const Offset(0, -16),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 68,
            width: 68,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: NaviColors.primary,
              boxShadow: [
                BoxShadow(
                  color: Color(0x30000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                SizedBox(height: 2),
                Text(
                  'Start',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
