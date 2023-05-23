import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MapController controller = MapController.withPosition(
    initPosition: GeoPoint(
      latitude: 29.32127,
      longitude: 30.83571,
    ),
  );
  // ValueNotifier<GeoPoint?> notifier = ValueNotifier(null);
  List<GeoPoint> geoPoints = [];
  double distanceEnMetres = 0;
  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height / 1.4,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                OSMFlutter(
                  controller: controller,
                  trackMyPosition: false,
                  initZoom: 18,
                  minZoomLevel: 5,
                  maxZoomLevel: 18,
                  stepZoom: 1.0,
                  userLocationMarker: UserLocationMaker(
                    personMarker: const MarkerIcon(
                      icon: Icon(
                        Icons.location_on,
                        color: Colors.teal,
                        size: 60,
                      ),
                    ),
                    directionArrowMarker: const MarkerIcon(
                      icon: Icon(
                        Icons.double_arrow,
                        color: Colors.red,
                        size: 60,
                      ),
                    ),
                  ),
                  roadConfiguration: const RoadOption(
                    roadColor: Colors.yellowAccent,
                  ),
                  markerOption: MarkerOption(
                      defaultMarker: const MarkerIcon(
                    icon: Icon(
                      Icons.push_pin,
                      color: Colors.amber,
                      size: 60,
                    ),
                  )),
                  onLocationChanged: (value) async {
                    Timer.periodic(const Duration(seconds: 3), (Timer t) async {
                      trackuser();
                    });
                  },
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 15,
                    ),
                    CircleAvatar(
                      child: IconButton(
                          onPressed: () async {
                            await controller.zoomIn();
                          },
                          icon: const Icon(
                            Icons.zoom_in,
                          )),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    CircleAvatar(
                      child: IconButton(
                          onPressed: () async {
                            await controller.zoomOut();
                          },
                          icon: const Icon(
                            Icons.zoom_out,
                          )),
                    ),
                  ],
                )
              ],
            ),
          ),
          bottonsview(),
          ShowDistance()
        ],
      ),
    ));
  }

  Widget ShowDistance() => Center(
        child: Container(
          margin: const EdgeInsets.all(10.0),
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor),
          ),
          child: Text("$distanceEnMetres"),
        ),
      );

  Future<void> trackuser() async {
    GeoPoint geoPoint = await controller.myLocation();
    geoPoints.add(geoPoint);
    //here
    try {
      if (geoPoints.length == 1) {
      } else if (geoPoints.length > 30) //50
      {
        // geoPoints.removeRange(1, 31);
        Calculatedistanceinmetter(len: 25);
        geoPoints.removeRange(0, 25);
      } else {
        if (await distance2point(geoPoints[geoPoints.length - 2],
                geoPoints[geoPoints.length - 1]) <
            .001) {
          geoPoints.removeLast();
        }
      }
      if (geoPoints.length > 1) {
        await controller.drawRoad(geoPoints[0], geoPoints[geoPoints.length - 1],
            roadType: RoadType.foot,
            roadOption: const RoadOption(
              roadWidth: 10,
              roadColor: Colors.teal,
            ),
            intersectPoint: geoPoints);
      }
    } catch (e) {
      print(e);
    }
  }

  Widget bottonsview() => Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () async {
                      GeoPoint? p = await showSimplePickerLocation(
                        context: context,
                        title: "location picker",
                        isDismissible: true,
                        textConfirmPicker: "pick",
                        initCurrentUserPosition: false,
                        initZoom: 15,
                        initPosition: GeoPoint(
                          latitude: 29.32127,
                          longitude: 30.83571,
                        ),
                        radius: 8.0,
                      );
                      if (p != null) {
                        // notifier.value = p;
                        geoPoints.add(p);
                      }
                    },
                    child: const Text("dialog picker")),
                // TextButton(
                //     onPressed: () async {
                //       // for (int i = 0; i < geoPoints.length - 1; i++) {
                //       //   if (await distance2point(
                //       //         geoPoints[i],
                //       //         geoPoints[i + 1],
                //       //       ) <
                //       //       .5) {
                //       //     // distanceEnMetres = 0;
                //       //     print("maybe the same location");
                //       //   } else {
                //       //     await controller.drawRoad(
                //       //       geoPoints[i],
                //       //       geoPoints[i + 1],
                //       //       roadType: RoadType.foot,
                //       //       roadOption: const RoadOption(
                //       //         roadWidth: 10,
                //       //         roadColor: Colors.teal,
                //       //       ),
                //       //     );
                //       //   }
                //       // }
                //       if (geoPoints.length <= 1 ||
                //           await distance2point(geoPoints[geoPoints.length - 2],
                //                   geoPoints[geoPoints.length - 1]) <
                //               .001) {
                //         print("The Same Location");
                //       } else {
                //         await controller.drawRoad(
                //             geoPoints[0], geoPoints[geoPoints.length - 1],
                //             roadType: RoadType.foot,
                //             roadOption: const RoadOption(
                //               roadWidth: 10,
                //               roadColor: Colors.teal,
                //             ),
                //             intersectPoint: geoPoints);
                //       }
                //     },
                //     child: const Text("Draw road")),
                TextButton(
                    onPressed: () async {
                      geoPoints = [];
                      await controller.removeLastRoad();
                    },
                    child: const Text("Delete road")),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () async {
                      // distanceEnMetres = 0;
                      await controller.enableTracking(
                        enableStopFollow: false,
                      );
                      await controller.currentLocation();
                      trackuser();
                    },
                    child: const Text("Track user")),
                TextButton(
                    onPressed: () async {
                      await controller.enableTracking(
                        enableStopFollow: false,
                      );
                      geoPoints = [];
                      // GeoPoint geoPoint = await controller.myLocation();
                      // geoPoints.add(geoPoint);
                      setState(() {
                        distanceEnMetres = 0;
                      });
                      print(geoPoints);
                      await controller.disabledTracking();
                    },
                    child: const Text("Disable tracking")),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                    onPressed: () async {
                      await controller.enableTracking(
                        enableStopFollow: false,
                      );
                      await controller.disabledTracking();
                      await controller.changeLocation(
                          GeoPoint(latitude: 29.32127, longitude: 30.83571));
                    },
                    child: const Text("location of Fayoum University")),
                TextButton(
                    onPressed: () async {
                      distanceEnMetres = 0;
                      GeoPoint geoPoint = await controller.myLocation();
                      geoPoints.add(geoPoint);
                      if (geoPoints.isNotEmpty) {
                        Calculatedistanceinmetter(len: geoPoints.length - 1);
                      }
                      setState(() {});
                      print(distanceEnMetres);
                    },
                    child: const Text("Calculate distance")),
              ],
            ),
          ],
        ),
      );

  Future<void> Calculatedistanceinmetter({required int len}) async {
    for (int i = 0; i < len; i++) {
      if (await distance2point(
            geoPoints[i],
            geoPoints[i + 1],
          ) <
          .01) {
        print("maybe the same location");
      } else {
        distanceEnMetres += await distance2point(
          geoPoints[i],
          geoPoints[i + 1],
        );
        print(distanceEnMetres);
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    timer?.cancel();
    super.dispose();
  }
}
