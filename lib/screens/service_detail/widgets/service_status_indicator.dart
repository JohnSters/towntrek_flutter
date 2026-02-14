import 'package:flutter/material.dart';

import '../../../core/widgets/open_closed_status_banner.dart';
import '../../../core/utils/service_utils.dart';
import '../../../models/models.dart';

class ServiceStatusIndicator extends StatelessWidget {
  final ServiceDetailDto service;

  const ServiceStatusIndicator({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = ServiceUtils.isServiceCurrentlyOpen(service.operatingHours);
    final subtitle = isOpen ? ServiceUtils.getClosingTimeText(service.operatingHours) : null;

    return OpenClosedStatusBanner(
      isOpen: isOpen,
      openText: 'Open Now',
      closedText: 'Closed',
      subtitle: subtitle,
    );
  }
}

