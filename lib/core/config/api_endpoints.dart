import 'api_config.dart';

/// REST endpoint path segments and URL builders for the TownTrek API.
abstract final class ApiEndpoints {
  static const String apiVersion = 'api';

  static const String businessesEndpoint = 'businesses';
  static const String servicesEndpoint = 'services';
  static const String creativeSpacesEndpoint = 'creativespaces';
  static const String townsEndpoint = 'towns';
  static const String eventsEndpoint = 'events';
  static const String statsEndpoint = 'stats';
  static const String propertiesEndpoint = 'properties';

  static String buildUrl(String endpoint, [Map<String, dynamic>? queryParams]) {
    final uri = Uri.parse('${ApiConfig.baseUrl}/$apiVersion/$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri
          .replace(
            queryParameters: queryParams.map(
              (key, value) => MapEntry(key, value.toString()),
            ),
          )
          .toString();
    }
    return uri.toString();
  }

  static String businessesUrl([Map<String, dynamic>? queryParams]) =>
      buildUrl(businessesEndpoint, queryParams);

  static String businessSearchUrl([Map<String, dynamic>? queryParams]) =>
      buildUrl('$businessesEndpoint/search', queryParams);

  static String servicesUrl([Map<String, dynamic>? queryParams]) =>
      buildUrl(servicesEndpoint, queryParams);

  static String serviceSearchUrl([Map<String, dynamic>? queryParams]) =>
      buildUrl('$servicesEndpoint/search', queryParams);

  static String serviceCategoriesUrl([Map<String, dynamic>? queryParams]) =>
      buildUrl('$servicesEndpoint/categories', queryParams);

  static String serviceDetailUrl(int serviceId, [Map<String, dynamic>? queryParams]) =>
      buildUrl('$servicesEndpoint/$serviceId', queryParams);

  static String serviceSubCategoriesUrl(int categoryId, [Map<String, dynamic>? queryParams]) =>
      buildUrl('$servicesEndpoint/categories/$categoryId/subcategories', queryParams);

  static String creativeSpacesUrl([Map<String, dynamic>? queryParams]) =>
      buildUrl(creativeSpacesEndpoint, queryParams);

  static String creativeSpacesSearchUrl([Map<String, dynamic>? queryParams]) =>
      buildUrl('$creativeSpacesEndpoint/search', queryParams);

  static String creativeSpaceCategoriesUrl([Map<String, dynamic>? queryParams]) =>
      buildUrl('$creativeSpacesEndpoint/categories', queryParams);

  static String creativeSpaceCategoriesWithCountsUrl(int townId, [Map<String, dynamic>? queryParams]) =>
      buildUrl('$creativeSpacesEndpoint/categories/town/$townId', queryParams);

  static String creativeSpaceDetailUrl(int creativeSpaceId, [Map<String, dynamic>? queryParams]) =>
      buildUrl('$creativeSpacesEndpoint/$creativeSpaceId', queryParams);

  static String creativeSpaceSubCategoriesUrl(int categoryId, [Map<String, dynamic>? queryParams]) =>
      buildUrl('$creativeSpacesEndpoint/categories/$categoryId/subcategories', queryParams);

  static String serviceCategoriesWithCountsUrl(int townId, [Map<String, dynamic>? queryParams]) =>
      buildUrl('$servicesEndpoint/categories/town/$townId', queryParams);

  static String categoriesUrl([Map<String, dynamic>? queryParams]) =>
      buildUrl('$businessesEndpoint/categories', queryParams);

  static String categoriesWithCountsUrl(int townId, [Map<String, dynamic>? queryParams]) =>
      buildUrl('$businessesEndpoint/categories/town/$townId', queryParams);

  static String businessDetailUrl(int businessId, [Map<String, dynamic>? queryParams]) =>
      buildUrl('$businessesEndpoint/$businessId', queryParams);

  static String townsUrl([Map<String, dynamic>? queryParams]) =>
      buildUrl(townsEndpoint, queryParams);

  static String townDetailUrl(int townId, [Map<String, dynamic>? queryParams]) =>
      buildUrl('$townsEndpoint/$townId', queryParams);

  static String eventsUrl([Map<String, dynamic>? queryParams]) =>
      buildUrl(eventsEndpoint, queryParams);

  static String eventSearchUrl([Map<String, dynamic>? queryParams]) =>
      buildUrl('$eventsEndpoint/search', queryParams);

  static String currentEventsUrl([Map<String, dynamic>? queryParams]) =>
      buildUrl('$eventsEndpoint/current', queryParams);

  static String eventTypesUrl([Map<String, dynamic>? queryParams]) =>
      buildUrl('$eventsEndpoint/types', queryParams);

  static String eventDetailUrl(int eventId, [Map<String, dynamic>? queryParams]) =>
      buildUrl('$eventsEndpoint/$eventId', queryParams);

  static String townAdminProfileUrl(int townId) =>
      buildUrl('$townsEndpoint/$townId/town-admin');

  static String townNoticesUrl(int townId, {int page = 1, int pageSize = ApiConfig.defaultPageSize}) =>
      buildUrl('$townsEndpoint/$townId/town-notices', {'page': page, 'pageSize': pageSize});

  static String statsSummaryUrl([Map<String, dynamic>? queryParams]) =>
      buildUrl('$statsEndpoint/summary', queryParams);

  static String propertiesUrl([Map<String, dynamic>? queryParams]) =>
      buildUrl(propertiesEndpoint, queryParams);

  static String propertyDetailUrl(int propertyListingId, [Map<String, dynamic>? queryParams]) =>
      buildUrl('$propertiesEndpoint/$propertyListingId', queryParams);
}
