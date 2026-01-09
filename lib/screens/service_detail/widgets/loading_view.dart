import 'package:flutter/material.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/constants/service_detail_constants.dart';

/// Loading view for service detail page
class ServiceDetailLoadingView extends StatelessWidget {
  final String serviceName;

  const ServiceDetailLoadingView({
    super.key,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PageHeader(
          title: serviceName,
          subtitle: ServiceDetailConstants.loadingSubtitle,
          height: ServiceDetailConstants.pageHeaderHeight,
          headerType: HeaderType.service,
        ),
        const Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }
}