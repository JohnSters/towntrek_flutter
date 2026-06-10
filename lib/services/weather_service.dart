import 'dart:convert';
import 'package:http/http.dart' as http;

/// Current weather snapshot returned by [WeatherService].
///
/// Pure data: the [weatherCode] is a WMO interpretation code. Presentation
/// (icon mapping) lives in the UI layer, not here.
class WeatherData {
  final double temperature;
  final int weatherCode;
  final String description;

  const WeatherData({
    required this.temperature,
    required this.weatherCode,
    required this.description,
  });
}

/// Fetches the current weather for a coordinate.
abstract class WeatherService {
  Future<WeatherData> getCurrentWeather(double latitude, double longitude);
}

/// [WeatherService] backed by the Open-Meteo API (free, no API key).
class WeatherServiceImpl implements WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const Duration _timeout = Duration(seconds: 8);

  @override
  Future<WeatherData> getCurrentWeather(
    double latitude,
    double longitude,
  ) async {
    final url = Uri.parse(
      '$_baseUrl?latitude=$latitude&longitude=$longitude'
      '&current=temperature_2m,weather_code&timezone=auto',
    );

    final response = await http.get(url).timeout(_timeout);
    if (response.statusCode != 200) {
      throw Exception('Weather API returned ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;

    final temp = (current['temperature_2m'] as num).toDouble();
    final code = (current['weather_code'] as num).toInt();

    return WeatherData(
      temperature: temp,
      weatherCode: code,
      description: _describeCode(code),
    );
  }

  /// Maps WMO weather interpretation codes to human-readable labels.
  static String _describeCode(int code) {
    return switch (code) {
      0 => 'Clear sky',
      1 => 'Mainly clear',
      2 => 'Partly cloudy',
      3 => 'Overcast',
      45 || 48 => 'Foggy',
      51 || 53 || 55 => 'Drizzle',
      56 || 57 => 'Freezing drizzle',
      61 || 63 || 65 => 'Rainy',
      66 || 67 => 'Freezing rain',
      71 || 73 || 75 => 'Snowy',
      77 => 'Snow grains',
      80 || 81 || 82 => 'Rain showers',
      85 || 86 => 'Snow showers',
      95 => 'Thunderstorm',
      96 || 99 => 'Thunderstorm',
      _ => 'Unknown',
    };
  }
}
