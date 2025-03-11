import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

/// A simple localization class supporting English and Spanish.
class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'enterCity': 'Enter City Name',
      'useLocation': 'Use My Location',
      'addFavorite': 'Add to Favorites',
      'cityNotFound': 'City not found!',
      'error': 'Error',
      'weather': 'Weather',
      'favorites': 'Favorites',
      'temperature': 'Temperature',
      'settings': 'Settings',
      'language': 'Language',
      'units': 'Units',
      'celsius': 'Celsius',
      'fahrenheit': 'Fahrenheit',
      'darkMode': 'Dark Mode',
    },
    'es': {
      'enterCity': 'Ingresa el nombre de la ciudad',
      'useLocation': 'Usar mi ubicación',
      'addFavorite': 'Agregar a Favoritos',
      'cityNotFound': '¡Ciudad no encontrada!',
      'error': 'Error',
      'weather': 'Clima',
      'favorites': 'Favoritos',
      'temperature': 'Temperatura',
      'settings': 'Ajustes',
      'language': 'Idioma',
      'units': 'Unidades',
      'celsius': 'Celsius',
      'fahrenheit': 'Fahrenheit',
      'darkMode': 'Modo Oscuro',
    },
  };

  String get enterCity => _localizedValues[locale.languageCode]!['enterCity']!;
  String get useLocation => _localizedValues[locale.languageCode]!['useLocation']!;
  String get addFavorite => _localizedValues[locale.languageCode]!['addFavorite']!;
  String get cityNotFound => _localizedValues[locale.languageCode]!['cityNotFound']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get weather => _localizedValues[locale.languageCode]!['weather']!;
  String get favorites => _localizedValues[locale.languageCode]!['favorites']!;
  String get temperature => _localizedValues[locale.languageCode]!['temperature']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get units => _localizedValues[locale.languageCode]!['units']!;
  String get celsius => _localizedValues[locale.languageCode]!['celsius']!;
  String get fahrenheit => _localizedValues[locale.languageCode]!['fahrenheit']!;
  String get darkMode => _localizedValues[locale.languageCode]!['darkMode']!;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();
  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}

/// Main app widget managing theme, language, and unit settings.
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  Locale _locale = Locale('en');
  bool isCelsius = true;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void toggleUnit() {
    setState(() {
      isCelsius = !isCelsius;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClimaCast',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: _locale,
      supportedLocales: [Locale('en'), Locale('es')],
      localizationsDelegates: [
        const AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: WeatherHomePage(
        toggleTheme: toggleTheme,
        isDarkMode: isDarkMode,
        changeLanguage: changeLanguage,
        isCelsius: isCelsius,
        toggleUnit: toggleUnit,
      ),
    );
  }
}

/// Home page widget for weather information.
class WeatherHomePage extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;
  final Function(Locale) changeLanguage;
  final bool isCelsius;
  final VoidCallback toggleUnit;

  WeatherHomePage({
    required this.toggleTheme,
    required this.isDarkMode,
    required this.changeLanguage,
    required this.isCelsius,
    required this.toggleUnit,
  });

  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}
class _WeatherHomePageState extends State<WeatherHomePage> {
  String city = 'London';
  double? temperature;
  String? description;
  bool isLoading = false;
  final TextEditingController _cityController = TextEditingController();
  final String apiKey = ''; // <-- Insert your API key here
  List<String> favorites = [];
  Map<String, dynamic>? cachedWeather;

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
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        cacheWeatherData(data);
        setState(() {
          temperature = data['main']['temp'];
          description = data['weather'][0]['description'];
          this.city = city;
          _cityController.text = city;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).cityNotFound)),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      // Load cached data if available.
      if (cachedWeather != null) {
        setState(() {
          temperature = cachedWeather!['main']['temp'];
          description = cachedWeather!['weather'][0]['description'];
          city = cachedWeather!['name'];
          _cityController.text = city;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Loaded cached weather data')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context).error}: $error')),
        );
      }
    }
  }

  Future<void> cacheWeatherData(Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cachedWeather', json.encode(data));
    cachedWeather = data;
  }

  Future<void> fetchWeatherByLocation() async {
    bool hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    setState(() {
      isLoading = true;
    });
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      final url =
          'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&appid=$apiKey&units=metric';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        cacheWeatherData(data);
        setState(() {
          temperature = data['main']['temp'];
          description = data['weather'][0]['description'];
          city = data['name'];
          _cityController.text = city;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to fetch weather for location')),
        );
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context).error}: $error')),
      );
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled. Please enable them.')),
      );
      return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return false;
    }
    return true;
  }

  /// Returns a widget with a weather icon based on the description.
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
      return Image.network(
        'https://cdn-icons-png.flaticon.com/512/3222/3222808.png',
        width: 100,
        height: 100,
      );
    } else {
      return Container();
    }
  }

  /// Adds the current city to the favorites list.
  void addFavorite() {
    String currentCity = city;
    if (!favorites.contains(currentCity)) {
      setState(() {
        favorites.add(currentCity);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$currentCity added to favorites')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$currentCity is already in favorites')),
      );
    }
  }

  /// Opens the settings bottom sheet.
  void _openSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final localizations = AppLocalizations.of(context);
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(localizations.settings,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Divider(),
              ListTile(
                title: Text(localizations.language),
                trailing: DropdownButton<Locale>(
                  value: Localizations.localeOf(context),
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      widget.changeLanguage(newLocale);
                      Navigator.pop(context);
                    }
                  },
                  items: [
                    DropdownMenuItem(value: Locale('en'), child: Text('English')),
                    DropdownMenuItem(value: Locale('es'), child: Text('Español')),
                  ],
                ),
              ),
              ListTile(
                title: Text(localizations.units),
                trailing: Switch(
                  value: widget.isCelsius,
                  onChanged: (value) {
                    widget.toggleUnit();
                    Navigator.pop(context);
                  },
                ),
              ),
              ListTile(
                title: Text(localizations.darkMode),
                trailing: Switch(
                  value: widget.isDarkMode,
                  onChanged: (value) {
                    widget.toggleTheme();
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('ClimaCast'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _openSettings,
          ),
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: fetchWeatherByLocation,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDarkMode
                ? [Colors.black54, Colors.black87]
                : [Colors.deepPurple.shade300, Colors.deepPurple.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              children: [
                // City input and search.
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                        decoration: InputDecoration(
                          hintText: localizations.enterCity,
                          hintStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white24,
                          prefixIcon: Icon(Icons.location_city, color: Colors.white),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.white),
                      onPressed: () {
                        final inputCity = _cityController.text.trim();
                        if (inputCity.isNotEmpty) {
                          fetchWeather(inputCity);
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Buttons for location and favorites.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurpleAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(Icons.my_location),
                      label: Text(localizations.useLocation),
                      onPressed: fetchWeatherByLocation,
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: Icon(Icons.favorite),
                      label: Text(localizations.addFavorite),
                      onPressed: addFavorite,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Favorites horizontal list.
                favorites.isNotEmpty
                    ? Container(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final favCity = favorites[index];
                      return GestureDetector(
                        onTap: () => fetchWeather(favCity),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              favCity,
                              style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
                    : Container(),
                SizedBox(height: 30),
                // Display weather info or loading indicator.
                isLoading
                    ? CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                    : temperature != null
                    ? Expanded(
                  child: Center(
                    child: Card(
                      color: Colors.white.withOpacity(0.8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 8,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              city,
                              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                            ),
                            SizedBox(height: 10),
                            _buildWeatherIcon(),
                            SizedBox(height: 10),
                            // Convert Celsius to Fahrenheit if needed.
                            Text(
                              '${(widget.isCelsius ? temperature! : (temperature! * 9/5 + 32)).toStringAsFixed(1)} ${widget.isCelsius ? "°C" : "°F"}',
                              style: TextStyle(fontSize: 32, color: Colors.deepPurple),
                            ),
                            SizedBox(height: 10),
                            Text(
                              description ?? '',
                              style: TextStyle(fontSize: 24, color: Colors.deepPurple.shade700),
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
