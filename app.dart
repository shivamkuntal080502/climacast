import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(WeatherApp());

class WeatherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClimaCast',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  String city = 'London'; // Default city
  double? temperature;
  String? description;
  bool isLoading = false;
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cityController.text = city;
    fetchWeather(city);
  }

  Future<void> fetchWeather(String city) async {
    setState(() {
      isLoading = true;
    });

    final apiKey = ''; // Replace with your OpenWeatherMap API key
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperature = data['main']['temp'];
          description = data['weather'][0]['description'];
          this.city = city;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('City not found!')));
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
    }
  }

  /// Returns a widget (weather icon) based on the description.
  Widget _buildWeatherIcon() {
    if (description == null) return Container();
    String lowerDesc = description!.toLowerCase();
    if (lowerDesc.contains('rain') || lowerDesc.contains('thunderstorm')) {
      return Image.network(
        'https://w7.pngwing.com/pngs/270/45/png-transparent-cloud-heavy-rain-rain-weather-weather-flat-icon-thumbnail.png',
        width: 100,
        height: 100,
      );
    } else if (lowerDesc.contains('fog') ||
        lowerDesc.contains('haze') ||
        lowerDesc.contains('smoke')) {
      return Image.network(
        'https://cdn3.iconfinder.com/data/icons/flat-main-weather-conditions-2/842/fog-512.png',
        width: 100,
        height: 100,
      );
    } else if (lowerDesc.contains('clear') || lowerDesc.contains('sunny')) {
      return Image.network(
        'https://cdn-icons-png.flaticon.com/512/7084/7084512.png',
        width: 100,
        height: 100,
      );
    } else if (lowerDesc.contains('cloud')) {
      // Default cloud icon if description contains "cloud" (e.g. "overcast clouds")
      return Image.network(
        'https://cdn-icons-png.flaticon.com/512/3222/3222808.png',
        width: 100,
        height: 100,
      );
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('ClimaCast'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.deepPurple.shade300,
              Colors.deepPurple.shade900,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              children: [
                // City input field
                TextField(
                  controller: _cityController,
                  style: TextStyle(color: Colors.white, fontSize: 20),
                  decoration: InputDecoration(
                    hintText: 'Enter City Name',
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white24,
                    prefixIcon:
                    Icon(Icons.location_city, color: Colors.white),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        final inputCity = _cityController.text.trim();
                        if (inputCity.isNotEmpty) {
                          fetchWeather(inputCity);
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Display weather info or a loading indicator
                isLoading
                    ? CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : temperature != null
                    ? Expanded(
                  child: Center(
                    child: Card(
                      color: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              city,
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            SizedBox(height: 10),
                            // Show the weather icon based on the description
                            _buildWeatherIcon(),
                            SizedBox(height: 10),
                            Text(
                              '${temperature?.toStringAsFixed(1)} °C',
                              style: TextStyle(
                                fontSize: 32,
                                color: Colors.deepPurple,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              description ?? '',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.deepPurple.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
