import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Using Open-Meteo API (free, no API key required)
  static const String _baseUrl = 'https://api.open-meteo.com/v1';

  // Get current weather for coordinates
  static Future<Map<String, dynamic>?> getCurrentWeather(
    double latitude,
    double longitude,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/forecast?latitude=$latitude&longitude=$longitude&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m&timezone=auto',
      );

      print('Fetching weather from: $url');
      
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Weather API request timed out');
        },
      );

      print('Weather API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final current = data['current'];

        if (current == null) {
          print('Weather API returned null current data');
          return null;
        }

        final weatherData = {
          'temperature': current['temperature_2m']?.toDouble() ?? 0.0,
          'feelsLike': current['apparent_temperature']?.toDouble() ?? 0.0,
          'humidity': current['relative_humidity_2m']?.toInt() ?? 0,
          'windSpeed': current['wind_speed_10m']?.toDouble() ?? 0.0,
          'windDirection': current['wind_direction_10m']?.toInt() ?? 0,
          'precipitation': current['precipitation']?.toDouble() ?? 0.0,
          'weatherCode': current['weather_code'] ?? 0,
          'condition': _getWeatherCondition(current['weather_code'] ?? 0),
          'icon': _getWeatherIcon(current['weather_code'] ?? 0),
        };
        
        print('Weather fetched successfully: ${weatherData['condition']}, ${weatherData['temperature']}°C');
        return weatherData;
      } else {
        print('Weather API error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching weather: $e');
      return null;
    }
  }

  // Convert WMO weather code to readable condition
  static String _getWeatherCondition(int code) {
    switch (code) {
      case 0:
        return 'Clear';
      case 1:
      case 2:
      case 3:
        return 'Partly Cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 77:
        return 'Snow Grains';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 85:
      case 86:
        return 'Snow Showers';
      case 95:
        return 'Thunderstorm';
      case 96:
      case 99:
        return 'Thunderstorm with Hail';
      default:
        return 'Unknown';
    }
  }

  // Get weather emoji icon
  static String _getWeatherIcon(int code) {
    switch (code) {
      case 0:
        return '☀️';
      case 1:
      case 2:
      case 3:
        return '⛅';
      case 45:
      case 48:
        return '🌫️';
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
        return '🌧️';
      case 71:
      case 73:
      case 75:
      case 77:
        return '❄️';
      case 80:
      case 81:
      case 82:
        return '🌦️';
      case 85:
      case 86:
        return '🌨️';
      case 95:
      case 96:
      case 99:
        return '⛈️';
      default:
        return '🌤️';
    }
  }

  // Get wind direction as string
  static String getWindDirection(int degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((degrees + 22.5) / 45).floor() % 8;
    return directions[index];
  }

  // Get fishing tips based on weather conditions
  static List<String> getFishingTips(Map<String, dynamic> weatherData) {
    final List<String> tips = [];
    final temperature = weatherData['temperature'] as double;
    final windSpeed = weatherData['windSpeed'] as double;
    final condition = weatherData['condition'] as String;
    final precipitation = weatherData['precipitation'] as double;

    // Temperature-based tips
    if (temperature >= 15 && temperature <= 25) {
      tips.add('🌡️ Perfect temperature for active fish! Prime fishing conditions.');
    } else if (temperature < 10) {
      tips.add('🥶 Cold water - fish are less active. Try slow presentations and deeper waters.');
    } else if (temperature > 30) {
      tips.add('🔥 Hot weather - fish early morning or late evening when it\'s cooler.');
    }

    // Wind-based tips
    if (windSpeed >= 5 && windSpeed <= 15) {
      tips.add('💨 Light to moderate wind - great for fishing! Wind breaks up surface and hides your presence.');
    } else if (windSpeed > 20) {
      tips.add('⚠️ Strong winds - be cautious! Fish may move to sheltered areas.');
    } else if (windSpeed < 3) {
      tips.add('😌 Calm conditions - fish can be more wary. Use stealthy approaches.');
    }

    // Weather condition tips
    switch (condition.toLowerCase()) {
      case 'clear':
        tips.add('☀️ Clear skies - fish may go deeper. Try shaded areas or use bright lures.');
        break;
      case 'partly cloudy':
        tips.add('⛅ Overcast conditions are excellent! Fish are more active and less cautious.');
        break;
      case 'rain':
      case 'drizzle':
        if (precipitation < 5) {
          tips.add('🌧️ Light rain is perfect! Fish feed actively before and during light rain.');
        } else {
          tips.add('⚠️ Heavy rain - water may be murky. Use noisy or bright lures.');
        }
        break;
      case 'thunderstorm':
        tips.add('⛈️ Thunderstorm nearby - prioritize safety! Fish bite well before storms.');
        break;
      case 'foggy':
        tips.add('🌫️ Foggy conditions - fish are less spooked. Great for surface baits!');
        break;
    }

    // Pressure-based general tip (assuming stable conditions if no precipitation)
    if (precipitation == 0 && condition.toLowerCase().contains('clear')) {
      tips.add('📊 Stable conditions - fish feeding patterns are predictable. Stick to proven spots.');
    }

    // If no specific tips, add a general one
    if (tips.isEmpty) {
      tips.add('🎣 Good luck out there! Remember to match your bait to the conditions.');
    }

    return tips;
  }

  // Determine if conditions are favorable for fishing (simple scoring)
  static String getFishingConditionRating(Map<String, dynamic> weatherData) {
    int score = 50; // Start at neutral
    
    final temperature = weatherData['temperature'] as double;
    final windSpeed = weatherData['windSpeed'] as double;
    final condition = weatherData['condition'] as String;
    
    // Temperature scoring
    if (temperature >= 15 && temperature <= 25) {
      score += 20;
    } else if (temperature < 5 || temperature > 35) {
      score -= 20;
    }
    
    // Wind scoring
    if (windSpeed >= 5 && windSpeed <= 15) {
      score += 15;
    } else if (windSpeed > 25) {
      score -= 15;
    }
    
    // Condition scoring
    if (condition.toLowerCase().contains('cloudy') || condition.toLowerCase().contains('drizzle')) {
      score += 15;
    } else if (condition.toLowerCase().contains('thunderstorm')) {
      score -= 30;
    }
    
    // Return rating
    if (score >= 70) {
      return 'Excellent';
    } else if (score >= 50) {
      return 'Good';
    } else if (score >= 30) {
      return 'Fair';
    } else {
      return 'Poor';
    }
  }
}
