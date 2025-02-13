class WeatherModel {
  final String cityName;
  final double temperature;
  final String weatherDescription;
  final String icon;
  final double windSpeed;
  final double humidity;
  final double rainfall;

  WeatherModel({
    required this.cityName,
    required this.temperature,
    required this.weatherDescription,
    required this.icon,
    required this.windSpeed,
    required this.humidity,
    required this.rainfall,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      cityName: json['name'],
      temperature: json['main']['temp'].toDouble(),
      weatherDescription: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      windSpeed: json['wind']['speed'].toDouble(),
      humidity: json['main']['humidity'].toDouble(),
      rainfall: json.containsKey('rain') ? json['rain']['1h'] ?? 0.0 : 0.0,
    );
  }
}
