class AppPreferences {
  final bool useMetric; // true = Celsius/kg/cm, false = Fahrenheit/lbs/inches
  final bool hapticsEnabled;
  final bool soundEnabled;
  final bool notificationsEnabled;
  final String theme; // 'light', 'dark', 'system'

  const AppPreferences({
    this.useMetric = false, // Default to Imperial (Fahrenheit)
    this.hapticsEnabled = true,
    this.soundEnabled = true,
    this.notificationsEnabled = true,
    this.theme = 'light',
  });

  AppPreferences copyWith({
    bool? useMetric,
    bool? hapticsEnabled,
    bool? soundEnabled,
    bool? notificationsEnabled,
    String? theme,
  }) {
    return AppPreferences(
      useMetric: useMetric ?? this.useMetric,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      theme: theme ?? this.theme,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'useMetric': useMetric,
      'hapticsEnabled': hapticsEnabled,
      'soundEnabled': soundEnabled,
      'notificationsEnabled': notificationsEnabled,
      'theme': theme,
    };
  }

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    return AppPreferences(
      useMetric: json['useMetric'] ?? false,
      hapticsEnabled: json['hapticsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      theme: json['theme'] ?? 'light',
    );
  }

  // Helper methods for unit conversion
  String formatTemperature(double celsius) {
    if (useMetric) {
      return '${celsius.toStringAsFixed(1)}°C';
    } else {
      final fahrenheit = celsius * 9 / 5 + 32;
      return '${fahrenheit.toStringAsFixed(1)}°F';
    }
  }

  String formatWeight(double kg) {
    if (useMetric) {
      return '${kg.toStringAsFixed(2)} kg';
    } else {
      final lbs = kg * 2.20462;
      return '${lbs.toStringAsFixed(2)} lbs';
    }
  }

  String formatLength(double cm) {
    if (useMetric) {
      return '${cm.toStringAsFixed(1)} cm';
    } else {
      final inches = cm / 2.54;
      return '${inches.toStringAsFixed(1)} in';
    }
  }

  String formatSpeed(double kmh) {
    if (useMetric) {
      return '${kmh.toStringAsFixed(1)} km/h';
    } else {
      final mph = kmh * 0.621371;
      return '${mph.toStringAsFixed(1)} mph';
    }
  }
}
