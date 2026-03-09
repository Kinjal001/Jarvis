import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jarvis/core/theme/app_colors.dart';

/// Shell widget for the main bottom navigation.
///
/// Used as the [ShellRoute] builder. Receives [child] (the currently active
/// tab's screen) and [location] (current matched path, e.g. '/goals') to
/// highlight the correct nav item.
///
/// Navigation structure:
///   [ Today ]  [ Goals ]  [ ◆ Add ]  [ Tasks ]  [ Profile ]
///
/// The diamond FAB in the center is a Habitica-inspired touch — it opens a
/// quick-add bottom sheet for creating tasks or goals without navigating away.
class BottomNavShell extends StatelessWidget {
  const BottomNavShell({
    super.key,
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  static const _routes = ['/today', '/goals', '/tasks', '/profile'];

  int get _currentIndex {
    if (location.startsWith('/goals')) return 1;
    if (location.startsWith('/tasks')) return 2;
    if (location.startsWith('/profile')) return 3;
    return 0; // /today (default)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      // extendBody lets the tab content scroll behind the semi-transparent
      // nav bar for a more immersive look (screens add bottom padding in PR 6).
      extendBody: true,
      body: child,
      floatingActionButton: _DiamondFab(onTap: () => _showQuickAdd(context)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => context.go(_routes[i]),
      ),
    );
  }

  void _showQuickAdd(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => _QuickAddSheet(location: location),
    );
  }
}

// ── Diamond FAB ──────────────────────────────────────────────────────────────

/// A rotated square container that looks like a diamond, matching the
/// Habitica-style center FAB aesthetic.
///
/// [Transform.rotate] is a visual-only transform — the 56×56 bounding box is
/// preserved so [FloatingActionButtonLocation.centerDocked] positions it
/// correctly (center aligned with the top edge of [BottomAppBar]).
class _DiamondFab extends StatelessWidget {
  const _DiamondFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: math.pi / 4, // 45° → square becomes a diamond
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            gradient: AppColors.fabGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Transform.rotate(
              angle: -math.pi / 4, // counter-rotate so the + icon is upright
              child: const Icon(Icons.add, color: Colors.white, size: 26),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    // BottomAppBar + FloatingActionButtonLocation.centerDocked: Flutter docks
    // the FAB so its center aligns with the top edge of this bar.
    return BottomAppBar(
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            filledIcon: Icons.home_rounded,
            label: 'Today',
            index: 0,
            current: currentIndex,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.flag_outlined,
            filledIcon: Icons.flag_rounded,
            label: 'Goals',
            index: 1,
            current: currentIndex,
            onTap: onTap,
          ),
          // Gap for the diamond FAB
          const Expanded(flex: 2, child: SizedBox()),
          _NavItem(
            icon: Icons.checklist_outlined,
            filledIcon: Icons.checklist,
            label: 'Tasks',
            index: 2,
            current: currentIndex,
            onTap: onTap,
          ),
          _NavItem(
            icon: Icons.person_outline_rounded,
            filledIcon: Icons.person_rounded,
            label: 'Profile',
            index: 3,
            current: currentIndex,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.filledIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  final IconData icon;
  final IconData filledIcon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    final color = isActive ? AppColors.primaryLight : AppColors.textSecondary;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? filledIcon : icon,
                  key: ValueKey(isActive),
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quick-add bottom sheet ────────────────────────────────────────────────────

/// Minimal quick-add sheet for PR 5.
///
/// In Phase 2 this will open inline create forms for each type.
/// For now it navigates to the relevant tab so the user can use the tab's FAB.
class _QuickAddSheet extends StatelessWidget {
  const _QuickAddSheet({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add New', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'What would you like to create?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            _SheetOption(
              icon: Icons.checklist,
              color: AppColors.cyan,
              label: 'New Task',
              subtitle: 'Add a standalone task',
              onTap: () {
                Navigator.pop(context);
                context.go('/tasks');
              },
            ),
            const SizedBox(height: 12),
            _SheetOption(
              icon: Icons.flag_rounded,
              color: AppColors.pink,
              label: 'New Goal',
              subtitle: 'Set a goal with projects',
              onTap: () {
                Navigator.pop(context);
                context.go('/goals');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.titleSmall),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}
