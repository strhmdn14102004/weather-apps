import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_sasat/api/endpoint/weather_model.dart';
import 'package:weather_sasat/module/home/home_state.dart';


class WeatherCubit extends Cubit<WeatherState> {
  final Dio dio;
  final String apiKey = 'f0bda0d2e6b6b88a1eafae8a87c2f12f'; // Ganti dengan API Key OpenWeatherMap

  WeatherCubit(this.dio) : super(WeatherInitial());

  Future<void> fetchWeatherByLocation() async {
    try {
      emit(WeatherLoading());

      Position position = await _determinePosition();
      String url =
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid=$apiKey';

      final response = await dio.get(url);
      WeatherModel weather = WeatherModel.fromJson(response.data);

      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError(e.toString()));
    }
  }

  Future<void> fetchWeatherByCity(String cityName) async {
    try {
      emit(WeatherLoading());
      String url =
          'https://api.openweathermap.org/data/2.5/weather?q=$cityName&units=metric&appid=$apiKey';

      final response = await dio.get(url);
      WeatherModel weather = WeatherModel.fromJson(response.data);

      emit(WeatherLoaded(weather));
    } catch (e) {
      emit(WeatherError("Lokasi Tidak Tersedia"));
    }
  }

  Future<Position> _determinePosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        throw Exception("Location permissions are permanently denied.");
      }
    }
    return await Geolocator.getCurrentPosition();
  }
}
