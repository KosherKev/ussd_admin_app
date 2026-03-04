import 'package:flutter/material.dart';
import 'package:ussd_admin/app/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// FilterChipsRow — Horizontal scrollable chip row for status/period filters
// ---------------------------------------------------------------------------
class FilterChipsRow extends StatelessWidget {
  const FilterChipsRow({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelect,
    this.includeAll = true,
    this.allLabel = 'All',
  });

  /// Chip labels to display.
  final List<String> items;

  /// Currently selected item. Null means "All" is selected.
  final String? selected;

  /// Called when a chip is tapped. Passes null when "All" is tapped.
  final ValueChanged<String?> onSelect;

  /// Whether to prepend an "All" chip.
  final bool includeAll;

  /// Label for the "All" chip.
  final String allLabel;

  @override
  Widget build(BuildContext context) {
    final c    = context.appColors;
    final text = Theme.of(context).textTheme;

    final chips = [
      if (includeAll) allLabel,
      ...items,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: chips.asMap().entries.map((entry) {
          final label  = entry.value;
          final isAll  = includeAll && entry.key == 0;
          final active = isAll ? selected == null : selected == label;

          return Padding(
            padding: EdgeInsets.only(right: entry.key < chips.length - 1 ? AppSpacing.xs : 0),
            child: GestureDetector(
              onTap: () => onSelect(isAll ? null : label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? c.primaryAmber : c.bgRaised,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: active ? c.primaryAmber : c.borderMid,
                    width: 1,
                  ),
                ),
                child: Text(
                  label,
                  style: text.labelSmall?.copyWith(
                    color: active
                        ? (Theme.of(context).brightness == Brightness.dark
                            ? AppColors.black
                            : AppColors.white)
                        : c.textSecondary,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
