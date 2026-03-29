import 'package:flutter/material.dart';

/// Body-only loading (hero lives on [ServiceDetailPage]).
class ServiceDetailLoadingView extends StatelessWidget {
  final String serviceName;

  const ServiceDetailLoadingView({
    super.key,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}