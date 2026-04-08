import 'package:flutter/material.dart';
import '../../../models/models.dart';
import '../../../core/utils/operating_hours_open_calc.dart';
import '../../../core/widgets/open_closed_status_banner.dart';

class BusinessStatusIndicator extends StatelessWidget {
  final BusinessDetailDto business;

  const BusinessStatusIndicator({
    super.key,
    required this.business,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentlyOpen = business.isOpenNow ??
        OperatingHoursOpenCalc.businessIsOpenNow(
          business.operatingHours,
          business.specialOperatingHours,
        );

    return OpenClosedStatusBanner(
      isOpen: isCurrentlyOpen,
      openText: 'Open Now',
      closedText: 'Closed',
      subtitle: null,
    );
  }
}

