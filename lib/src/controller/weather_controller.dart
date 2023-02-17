import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../constants/api.dart';
import '../model/weather.dart';

class WeatherController extends GetxController {
  Rx<Weather?> weather = Rxn();
  final dio = Dio();
  RxInt san = 10.obs;

  @override
  void onInit() {
    super.onInit();
    weatherName();
  }

  Future<void> weatherLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.always &&
          permission == LocationPermission.whileInUse) {
        Position position = await Geolocator.getCurrentPosition();

        final response = await dio.get(ApiConst.getLocator(
            lat: position.latitude, long: position.longitude));
        if (response.statusCode == 200) {
          weather.value = Weather(
            id: response.data['current']['weather'][0]['id'],
            main: response.data['current']['weather'][0]['main'],
            description: response.data['current']['weather'][0]['description'],
            icon: response.data['current']['weather'][0]['icon'],
            city: response.data['timezone'],
            temp: response.data['current']['temp'],
          );
        }
      }
    } else {
      Position position = await Geolocator.getCurrentPosition();
      final dio = Dio();
      final response = await dio.get(ApiConst.getLocator(
          lat: position.latitude, long: position.longitude));
      if (response.statusCode == 200) {
        weather.value = Weather(
          id: response.data['current']['weather'][0]['id'],
          main: response.data['current']['weather'][0]['main'],
          description: response.data['current']['weather'][0]['description'],
          icon: response.data['current']['weather'][0]['icon'],
          city: response.data['timezone'],
          temp: response.data['current']['temp'],
        );
      }
    }
  }

  Future<void> weatherName([String? name]) async {
    final dio = Dio();
    final response = await dio.get(ApiConst.address(name ?? 'bishkek'));

    if (response.statusCode == 200) {
      weather.value = Weather(
        id: response.data['weather'][0]['id'],
        main: response.data['weather'][0]['main'],
        description: response.data['weather'][0]['description'],
        icon: response.data['weather'][0]['icon'],
        city: response.data['name'],
        temp: response.data['main']['temp'],
      );
    }
  }

  List<String> cities = [
    'bishkek',
    'osh',
    'talas',
    'naryn',
    'jalal-abad',
    'batken',
    'bosteri',
  ];
  void showBottom(BuildContext context) {
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
                        ;
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
