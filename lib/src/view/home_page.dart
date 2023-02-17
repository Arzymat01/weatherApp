import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:weather_app1/src/constants/api.dart';
import 'package:weather_app1/src/constants/app.colors.dart';
import 'package:weather_app1/src/constants/app_text.dart';
import 'package:weather_app1/src/constants/app_text_style.dart';

import '../controller/weather_controller.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});
  final ctl = Get.put(WeatherController());

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
      body: ctl.weather.value == null
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
                          await ctl.weatherLocation();
                        },
                        iconSize: 50,
                        color: Appcolors.white,
                        icon: const Icon(Icons.near_me),
                      ),
                      IconButton(
                        onPressed: () {
                          ctl.showBottom(context);
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
                      Obx(
                        () => Text(
                          '${(ctl.weather.value!.temp - 273.15).toInt()}',
                          style: ApptextStyles.body1,
                        ),
                      ),
                      Image.network(
                          ApiConst.getIcon(ctl.weather.value!.icon, 4)),
                    ],
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FittedBox(
                          child: Obx(() {
                            return Text(
                              ctl.weather.value!.description
                                  .replaceAll(' ', '\n'),
                              textAlign: TextAlign.end,
                              style: ApptextStyles.body2,
                            );
                          }),
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
                        child: Obx(() {
                          return Text(
                            ctl.weather.value!.city,
                            style: ApptextStyles.city,
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
