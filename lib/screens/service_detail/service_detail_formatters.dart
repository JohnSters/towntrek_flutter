import '../../models/models.dart';

/// Short summary plus full description when both exist and differ.
String combinedServiceDescription(ServiceDetailDto service) {
  final short = service.shortDescription?.trim();
  final long = service.description.trim();
  if (long.isNotEmpty) {
    if (short != null && short.isNotEmpty && short != long) {
      return '$short\n\n$long';
    }
    return long;
  }
  if (short != null && short.isNotEmpty) return short;
  return '';
}

List<String> serviceFeatureTagList(ServiceDetailDto service) {
  return [
    if (service.serviceArea?.trim().isNotEmpty == true) service.serviceArea!.trim(),
    if (service.priceRange?.trim().isNotEmpty == true) service.priceRange!.trim(),
    if (service.hourlyRate != null) 'R${service.hourlyRate!.toStringAsFixed(0)}/hr',
    if (service.offersQuotes) 'Quotes',
    if (service.mobileService) 'Mobile',
    if (service.onSiteService) 'On-site',
    if (service.availableWeekends) 'Weekends',
    if (service.availableAfterHours) 'After Hours',
    if (service.emergencyService) 'Emergency',
  ];
}
