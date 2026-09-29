import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final VoidCallback onTap;
  final double iconSize;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final Color? cardColor;
  final Widget? trailing;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    required this.onTap,
    this.iconSize = 22,
    this.iconColor,
    this.iconBackgroundColor,
    this.cardColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveIconColor = iconColor ?? scheme.primary;
    final effectiveIconBg =
        iconBackgroundColor ?? scheme.primaryContainer.withOpacity(0.35);
    final effectiveCardColor = cardColor ?? Colors.white;

    return Card(
      color: effectiveCardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: effectiveIconBg,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: effectiveIconColor,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
