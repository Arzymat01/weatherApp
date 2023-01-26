import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app1/constants/api.dart';
import 'package:weather_app1/constants/app.colors.dart';
import 'package:weather_app1/constants/app_text.dart';
import 'package:weather_app1/constants/app_text_style.dart';
import 'package:weather_app1/model/weather.dart';

List<String> cities = [
  'bishkek',
  'osh',
  'talas',
  'naryn',
  'jalal-abad',
  'batken',
  'bosteri',
];

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Weather? weather;
  Future<void> weatherLocation() async {
    setState(() {
      weather = null;
    });
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always &&
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition();
        final dio = Dio();
        final response = await dio.get(ApiConst.getLocator(
            lat: position.latitude, long: position.longitude));
        if (response.statusCode == 200) {
          weather = Weather(
            id: response.data['current']['weather'][0]['id'],
            main: response.data['current']['weather'][0]['main'],
            description: response.data['current']['weather'][0]['description'],
            icon: response.data['current']['weather'][0]['icon'],
            city: response.data['timezone'],
            temp: response.data['current']['temp'],
          );
        }
        setState(() {});
      }
    } else {
      Position position = await Geolocator.getCurrentPosition();
      final dio = Dio();
      final response = await dio.get(ApiConst.getLocator(
          lat: position.latitude, long: position.longitude));
      if (response.statusCode == 200) {
        weather = Weather(
          id: response.data['current']['weather'][0]['id'],
          main: response.data['current']['weather'][0]['main'],
          description: response.data['current']['weather'][0]['description'],
          icon: response.data['current']['weather'][0]['icon'],
          city: response.data['timezone'],
          temp: response.data['current']['temp'],
        );
      }
      setState(() {});
    }
  }

  Future<void> weatherName([String? name]) async {
    final dio = Dio();
    final response = await dio.get(ApiConst.address(name ?? 'bishkek'));

    if (response.statusCode == 200) {
      weather = Weather(
        id: response.data['weather'][0]['id'],
        main: response.data['weather'][0]['main'],
        description: response.data['weather'][0]['description'],
        icon: response.data['weather'][0]['icon'],
        city: response.data['name'],
        temp: response.data['main']['temp'],
      );
    }
    setState(() {});
  }

  @override
  void initState() {
    weatherName();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Appcolors.white,
        title: const Text(
          AppText.appBarTitle,
          style: ApptextStyles.appBarStyle,
        ),
        centerTitle: true,
      ),
      body: weather == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/weather.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () async {
                          await weatherLocation();
                        },
                        iconSize: 50,
                        color: Appcolors.white,
                        icon: const Icon(Icons.near_me),
                      ),
                      IconButton(
                        onPressed: () {
                          showBottom();
                        },
                        iconSize: 50,
                        color: Appcolors.white,
                        icon: const Icon(Icons.location_city),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const SizedBox(width: 14),
                      Text(
                        '${(weather!.temp - 273.15).toInt()}',
                        style: ApptextStyles.body1,
                      ),
                      Image.network(ApiConst.getIcon(weather!.icon, 4)),
                    ],
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FittedBox(
                          child: Text(
                            weather!.description.replaceAll(' ', '\n'),
                            textAlign: TextAlign.end,
                            style: ApptextStyles.body2,
                          ),
                        ),
                        const SizedBox(width: 60),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          weather!.city,
                          style: ApptextStyles.city,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  void showBottom() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 19, 15, 2),
                border: Border.all(color: Color.fromARGB(255, 194, 11, 181)),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                )),
            height: MediaQuery.of(context).size.height * 0.8,
            child: ListView.builder(
                itemCount: cities.length,
                itemBuilder: (context, index) {
                  final city = cities[index];
                  return Card(
                    child: ListTile(
                      onTap: () {
                        setState(() {
                          weather = null;
                        });
                        weatherName(city);
                        Navigator.pop(context);
                      },
                      title: Text(city),
                    ),
                  );
                }));
      },
    );
  }
}
