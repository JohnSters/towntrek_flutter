import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/utils/business_utils.dart';
import '../../../core/widgets/open_closed_status_banner.dart';

class BusinessStatusIndicator extends StatelessWidget {
  final BusinessDetailDto business;

  const BusinessStatusIndicator({
    super.key,
    required this.business,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentlyOpen = business.isOpenNow ?? BusinessUtils.isBusinessCurrentlyOpen(business.operatingHours);
    final openNowText = business.openNowText;
    final closingText = BusinessUtils.getClosingTime(business.operatingHours);
    final subtitle = (isCurrentlyOpen && (openNowText?.isNotEmpty ?? false))
        ? openNowText
        : (isCurrentlyOpen && closingText.isNotEmpty ? closingText : null);

    return OpenClosedStatusBanner(
      isOpen: isCurrentlyOpen,
      openText: 'Open Now',
      closedText: 'Closed',
      subtitle: subtitle,
    );
  }
}

