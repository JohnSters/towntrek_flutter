import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/utils/business_utils.dart';

class BusinessStatusIndicator extends StatelessWidget {
  final BusinessDetailDto business;

  const BusinessStatusIndicator({
    super.key,
    required this.business,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrentlyOpen = business.isOpenNow ?? BusinessUtils.isBusinessCurrentlyOpen(business.operatingHours);
    final openNowText = business.openNowText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      color: isCurrentlyOpen 
          ? const Color(0xFFE8F5E9) // Light green background
          : const Color(0xFFFFEBEE), // Light red background
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.access_time_filled,
            size: 18,
            color: isCurrentlyOpen
                ? const Color(0xFF2E7D32) // Dark green
                : const Color(0xFFC62828), // Dark red
          ),
          const SizedBox(width: 8),
          Text(
            isCurrentlyOpen ? 'Open Now' : 'Closed',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isCurrentlyOpen
                  ? const Color(0xFF1B5E20) // Darker green text
                  : const Color(0xFFB71C1C), // Darker red text
              letterSpacing: 0.5,
            ),
          ),
          if (isCurrentlyOpen && (openNowText?.isNotEmpty ?? false)) ...[
             const SizedBox(width: 8),
             Container(
               width: 4,
               height: 4,
               decoration: BoxDecoration(
                 color: const Color(0xFF1B5E20).withValues(alpha: 0.4),
                 shape: BoxShape.circle,
               ),
             ),
             const SizedBox(width: 8),
             Text(
               openNowText!,
               style: theme.textTheme.labelMedium?.copyWith(
                 fontWeight: FontWeight.w600,
                 color: const Color(0xFF2E7D32),
               ),
             ),
          ] else if (isCurrentlyOpen && business.operatingHours.isNotEmpty) ...[
             const SizedBox(width: 8),
             Container(
               width: 4,
               height: 4,
               decoration: BoxDecoration(
                 color: const Color(0xFF1B5E20).withValues(alpha: 0.4),
                 shape: BoxShape.circle,
               ),
             ),
             const SizedBox(width: 8),
             Text(
               BusinessUtils.getClosingTime(business.operatingHours),
               style: theme.textTheme.labelMedium?.copyWith(
                 fontWeight: FontWeight.w600,
                 color: const Color(0xFF2E7D32),
               ),
             ),
          ],
        ],
      ),
    );
  }
}

