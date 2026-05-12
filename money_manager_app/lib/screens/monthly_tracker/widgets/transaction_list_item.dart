import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/index.dart';
import '../../../utils/contrast_utils.dart';

class TransactionListItem extends StatelessWidget {
  final Transaction transaction;
  final Tag? tag;
  final bool isExpanded;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.tag,
    required this.isExpanded,
    required this.onTap,
    required this.onLongPress,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == 'income';
    final amountColor = isIncome
        ? AppColors.incomeBlue
        : AppColors.outgoingRed;
    final sign = isIncome ? '+' : '-';
    final formattedDate = DateFormat('d MMM').format(transaction.date);
    final formattedAmount = NumberFormat('#,##0.00').format(transaction.amount);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      transaction.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      '$sign\$$formattedAmount',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: amountColor,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    ),
                  ),
                  if (tag != null)
                    _TagPill(tag: tag!),
                ],
              ),
              if (isExpanded && (transaction.description != null || onEdit != null || onDelete != null))
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 56),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (transaction.description != null &&
                          transaction.description!.isNotEmpty)
                        Text(
                          transaction.description!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      if (onEdit != null || onDelete != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              if (onEdit != null)
                                _ActionChip(
                                  icon: Icons.edit_outlined,
                                  label: 'Edit',
                                  onTap: onEdit!,
                                ),
                              if (onDelete != null)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: _ActionChip(
                                    icon: Icons.delete_outline,
                                    label: 'Delete',
                                    onTap: onDelete!,
                                    isDestructive: true,
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  final Tag tag;

  const _TagPill({required this.tag});

  @override
  Widget build(BuildContext context) {
    final bgColor = ContrastUtils.parseHex(tag.color);
    final textColor = ContrastUtils.getTextColorForBackground(tag.color);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag.name,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red.shade400 : null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class AppColors {
  static const incomeBlue = Color(0xFF4A90D9);
  static const outgoingRed = Color(0xFFE74C3C);
}
