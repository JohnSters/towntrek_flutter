import 'package:flutter/material.dart';
import '../../../core/widgets/page_header.dart';
import '../../../core/constants/service_detail_constants.dart';

/// Error view for service detail page
class ServiceDetailErrorView extends StatelessWidget {
  final String serviceName;
  final String? error;

  const ServiceDetailErrorView({
    super.key,
    required this.serviceName,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        PageHeader(
          title: serviceName,
          subtitle: ServiceDetailConstants.errorSubtitle,
          height: ServiceDetailConstants.pageHeaderHeight,
          headerType: HeaderType.service,
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(ServiceDetailConstants.errorViewPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    ServiceDetailConstants.errorIcon,
                    size: ServiceDetailConstants.errorIconSize,
                    color: colorScheme.error.withValues(
                      alpha: ServiceDetailConstants.errorIconOpacity,
                    ),
                  ),
                  SizedBox(height: ServiceDetailConstants.errorSpacing),
                  Text(
                    error ?? 'Unable to load service details',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface.withValues(
                        alpha: ServiceDetailConstants.errorTextOpacity,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: ServiceDetailConstants.errorButtonSpacing),
                  ElevatedButton(
                    onPressed: () {
                      // Retry functionality would be handled by parent widget
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}