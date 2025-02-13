import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather_sasat/module/home/home_bloc.dart';
import 'package:weather_sasat/module/home/home_state.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    context.read<WeatherCubit>().fetchWeatherByLocation();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      context.read<WeatherCubit>().fetchWeatherByLocation();
    } else {
      print("Izin lokasi ditolak");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg.png"),
                fit: BoxFit.cover, // Supaya gambar menutupi seluruh layar
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!_isSearching)
                        IconButton(
                          icon: const FaIcon(FontAwesomeIcons.searchLocation,
                              size: 40),
                          onPressed: () {
                            setState(() {
                              _isSearching = true;
                            });
                          },
                        )
                      else
                        Expanded(
                          child: TextField(
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelStyle: const TextStyle(color: Colors.black),
                              hintStyle: const TextStyle(color: Colors.black54),
                              hintText: "Cari kota",
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (query) {
                              context
                                  .read<WeatherCubit>()
                                  .fetchWeatherByCity(query);
                              setState(() {
                                _isSearching = false;
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: BlocBuilder<WeatherCubit, WeatherState>(
                      builder: (context, state) {
                        if (state is WeatherLoading) {
                          return Container(
                            height: MediaQuery.of(context).size.height - 100,
                            child: Center(
                              child: Text("Data Sedang Dimuat..."),
                            ),
                          );
                        } else if (state is WeatherLoaded) {
                          final formattedDate =
                              DateFormat('dd MMMM yyyy').format(DateTime.now());
                          final weather = state.weather;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  weather.cityName,
                                  style: const TextStyle(
                                      fontSize: 38,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 20),
                                child: Text(
                                  formattedDate,
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black54),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _getWeatherAnimation(
                                      weather.weatherDescription),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${weather.temperature.toStringAsFixed(1)}°C",
                                        style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        translateWeatherDescription(
                                            weather.weatherDescription),
                                        style: const TextStyle(
                                            fontSize: 22,
                                            color: Colors.black54),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 30),
                              _weatherInfoColumn(weather),
                              const SizedBox(height: 20),
                              _weeklyForecast(),
                            ],
                          );
                        } else if (state is WeatherError) {
                          return Center(child: Text(state.message));
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, Widget icon, Color iconColor) {
    return Container(
      width: double.infinity,
      height: 80,
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.white
            .withOpacity(0.50), // Efek kaca tidak terlalu transparan
        border: Border.all(
            color: Colors.white.withOpacity(0)), // Border halus untuk efek kaca
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter:
              ImageFilter.blur(sigmaX: 15, sigmaY: 10), // Blur untuk efek kaca
          child: Padding(
            padding: const EdgeInsets.only(right: 5, left: 15),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: icon, // Gambar atau ikon dinamis
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style:
                            const TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Text(
                          value,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _weatherInfoColumn(weather) {
    return Column(
      children: [
        _infoCard(
          "Curah Hujan",
          "${weather.rainfall} cm",
          Image.asset(
            'assets/images/umbrella.png', // Path ke gambar payung Anda
            width: 20,
            height: 20,
          ),
          Colors.green,
        ), // Gambar payung dari aset
        _infoCard(
          "Angin",
          "${weather.windSpeed} km/h",
          const Icon(FontAwesomeIcons.wind, size: 30, color: Colors.red),
          Colors.red,
        ), // Ikon angin dengan warna merah
        _infoCard(
          "Kelembaban",
          "${weather.humidity}%",
          const Icon(Icons.water_drop, size: 30, color: Colors.blue),
          Colors.blue,
        ), // Ikon air dengan warna biru
      ],
    );
  }

  Widget _hourlyForecast() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Text("${index + 12}:00"),
                const Icon(FontAwesomeIcons.cloudSun, size: 30),
                Text("${20 + index}°C"),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _weeklyForecast() {
    return Container(
      height: 105,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          String timeLabel =
              (index == 0) ? "Now" : "${DateTime.now().hour + index}:00";
          bool isNow = index == 0;
          String weatherCondition = _getWeatherConditionForTime(
              index); // Simulasi cuaca berdasarkan waktu
          IconData weatherIcon = _getWeatherIcon(weatherCondition);

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
              color: isNow
                  ? Colors.white
                  : Colors.white
                      .withOpacity(0.5), // Transparansi untuk efek kaca
              elevation: isNow ? 0 : 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 90,
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          timeLabel,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 5),
                        Icon(
                          weatherIcon,
                          color: Colors.orange,
                          size: 25,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${22 + index}°",
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Simulasi fungsi mendapatkan kondisi cuaca berdasarkan waktu
  String _getWeatherConditionForTime(int index) {
    List<String> conditions = [
      "sunny",
      "rain",
      "cloud",
      "thunder",
      "sunny",
      "cloud",
      "rain"
    ];
    return conditions[index % conditions.length];
  }

  // Mendapatkan ikon cuaca berdasarkan kondisi
  IconData _getWeatherIcon(String condition) {
    switch (condition) {
      case "rain":
        return FontAwesomeIcons.umbrella;
      case "cloud":
        return FontAwesomeIcons.cloudSun;
      case "thunder":
        return FontAwesomeIcons.thunderstorm;
      default:
        return FontAwesomeIcons.sun;
    }
  }

  Widget _getWeatherAnimation(String description) {
    if (description.toLowerCase().contains("cloud")) {
      return Lottie.asset('assets/lottie/angin.json', height: 200);
    } else if (description.toLowerCase().contains("rain")) {
      return Lottie.asset('assets/lottie/rain_cloud.json', height: 200);
    } else if (description.toLowerCase().contains("thunder")) {
      return Lottie.asset('assets/lottie/hujan.json', height: 200);
    } else {
      return const SizedBox.shrink();
    }
  }

  String translateWeatherDescription(String description) {
    return weatherDescriptions[description.toLowerCase()] ?? description;
  }

  final Map<String, String> weatherDescriptions = {
    "light rain": "Hujan Ringan",
    "moderate rain": "Hujan Sedang",
    "heavy rain": "Hujan Lebat",
    "clear sky": "Langit Cerah",
    "few clouds": "Sedikit Berawan",
    "scattered clouds": "Berawan Tipis",
    "broken clouds": "Berawan Tebal",
    "thunderstorm": "Badai Petir",
    "snow": "Salju",
    "mist": "Berkabut",
    'overcast clouds': 'Langit Mendung',
  };
}
