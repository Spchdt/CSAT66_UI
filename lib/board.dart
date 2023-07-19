import 'dart:ui';

import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class __ChartData {
  __ChartData(this.x, this.y);
  final int x;
  final double y;
}

class _BoardState extends State<Board> with TickerProviderStateMixin {
  //Web socket source
  final channel = WebSocketChannel.connect(
      Uri.parse('wss://socketsbay.com/wss/v2/1/demo/0'));

  //Map Animation
  late final _animatedMapController = AnimatedMapController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    curve: Curves.easeInOut,
  );

  //List of past LatLng points
  List<LatLng> latLngPoints = [];

  //Accelerometer graph
  List<__ChartData>? accXList = [__ChartData(0, 0)];
  List<__ChartData>? accYList = [__ChartData(0, 0)];
  List<__ChartData>? accZList = [__ChartData(0, 0)];

  //Gyrometer graph
  List<__ChartData>? gyroXList = [__ChartData(0, 0)];
  List<__ChartData>? gyroYList = [__ChartData(0, 0)];
  List<__ChartData>? gyroZList = [__ChartData(0, 0)];

  //Base secondary background color
  Color mainTheme = const Color.fromARGB(40, 255, 255, 255);

  double? accX;
  double? accY;
  double? accZ;
  double? gyroX;
  double? gyroY;
  double? gyroZ;
  double? temp;
  double? alt;
  double? lng;
  double? lat;
  int? heading;
  int? bat;
  String? img;

  void update(String inputData) {
    List<String> inputDataList = inputData.split(",");

    double tempAccX = 0;
    double tempAccY = 0;
    double tempAccZ = 0;
    double tempGyroX = 0;
    double tempGyroY = 0;
    double tempGyroZ = 0;
    double tempTemp = 0;
    double tempAlt = 0;
    double tempLng = 0;
    double tempLat = 0;
    int tempHeading = 0;
    int tempBat = 0;
    String tempImg = "";

    for (String rawData in inputDataList) {
      List<String> data = rawData.split("=");

      if ("accX" == data[0].trim()) {
        tempAccX = double.parse(data[1]);
      } else if ("accY" == data[0].trim()) {
        tempAccY = double.parse(data[1]);
      } else if ("accZ" == data[0].trim()) {
        tempAccZ = double.parse(data[1]);
      } else if ("gyroX" == data[0].trim()) {
        tempGyroX = double.parse(data[1]);
      } else if ("gyroY" == data[0].trim()) {
        tempGyroY = double.parse(data[1]);
      } else if ("gyroZ" == data[0].trim()) {
        tempGyroZ = double.parse(data[1]);
      } else if ("temp" == data[0].trim()) {
        tempTemp = double.parse(data[1]);
      } else if ("alt" == data[0].trim()) {
        tempAlt = double.parse(data[1]);
      } else if ("lng" == data[0].trim()) {
        tempLng = double.parse(data[1]);
      } else if ("lat" == data[0].trim()) {
        tempLat = double.parse(data[1]);
      } else if ("heading" == data[0].trim()) {
        tempHeading = int.parse(data[1]);
      } else if ("bat" == data[0].trim()) {
        tempBat = int.parse(data[1]);
      } else if ("img" == data[0].trim()) {
        tempImg = data[1];
      }
    }

    accX = tempAccX;
    accY = tempAccY;
    accZ = tempAccZ;
    gyroX = tempGyroX;
    gyroY = tempGyroY;
    gyroZ = tempGyroZ;
    temp = tempTemp;
    alt = tempAlt;
    lng = tempLng;
    lat = tempLat;
    heading = tempHeading;
    bat = tempBat;
    img = tempImg;

    latLngPoints.add(LatLng(tempLat, tempLng));
    _animatedMapController.centerOnPoint(LatLng(tempLat, tempLng));
    accXList!.add(__ChartData(accXList!.length, tempAccX));
    accYList!.add(__ChartData(accYList!.length, tempAccY));
    accZList!.add(__ChartData(accZList!.length, tempAccZ));

    gyroXList!.add(__ChartData(gyroXList!.length, tempGyroX));
    gyroYList!.add(__ChartData(gyroYList!.length, tempGyroY));
    gyroZList!.add(__ChartData(gyroZList!.length, tempGyroZ));

    js.context.callMethod("updateOrientation", [gyroX, gyroY, gyroZ]);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    return StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          String? inputData = snapshot.data;
          if (inputData != null) {
            if (inputData[0] == "a") {
              update(inputData);
            }
          }

          return CupertinoPageScaffold(
            backgroundColor: const Color.fromARGB(255, 4, 3, 17),
            child: Stack(
              children: [
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Transform.rotate(
                        angle: -0.6,
                        child: GlowContainer(
                          width: 50.w,
                          height: 10.w,
                          spreadRadius: 100,
                          blurRadius: 1000,
                          glowColor: const Color.fromARGB(40, 255, 69, 7),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(1000),
                        ),
                      ),
                      Transform.rotate(
                        angle: -0.8,
                        child: GlowContainer(
                          width: 50.w,
                          height: 10.w,
                          spreadRadius: 100,
                          blurRadius: 1000,
                          glowColor: const Color.fromARGB(40, 189, 7, 255),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(1000),
                        ),
                      )
                    ],
                  ),
                ),
                Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.9,
                        width: screenWidth * 0.45,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(1.w),
                                    height: 35.h,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color.fromARGB(
                                                50, 255, 255, 255)),
                                        color: mainTheme,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Center(
                                            child: Text(
                                              'Gyrometer',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12.sp),
                                            ),
                                          ),
                                          Expanded(
                                              child: SfCartesianChart(
                                                  plotAreaBorderWidth: 0,
                                                  primaryXAxis: NumericAxis(
                                                      majorGridLines:
                                                          const MajorGridLines(
                                                              width: 0)),
                                                  primaryYAxis: NumericAxis(
                                                      axisLine: const AxisLine(
                                                          width: 0),
                                                      majorTickLines:
                                                          const MajorTickLines(
                                                              size: 0)),
                                                  series: <LineSeries<
                                                      __ChartData, num>>[
                                                LineSeries<__ChartData, num>(
                                                    dataSource: gyroXList!,
                                                    color: Colors.blue,
                                                    xValueMapper:
                                                        (__ChartData sales,
                                                                _) =>
                                                            sales.x,
                                                    yValueMapper:
                                                        (__ChartData sales,
                                                                _) =>
                                                            sales.y,
                                                    width: 2),
                                                LineSeries<__ChartData, num>(
                                                  dataSource: gyroYList!,
                                                  color: Colors.red,
                                                  width: 2,
                                                  xValueMapper:
                                                      (__ChartData sales, _) =>
                                                          sales.x,
                                                  yValueMapper:
                                                      (__ChartData sales, _) =>
                                                          sales.y,
                                                ),
                                                LineSeries<__ChartData, num>(
                                                  dataSource: gyroZList!,
                                                  color: Colors.green,
                                                  width: 2,
                                                  xValueMapper:
                                                      (__ChartData sales, _) =>
                                                          sales.x,
                                                  yValueMapper:
                                                      (__ChartData sales, _) =>
                                                          sales.y,
                                                )
                                              ])),
                                          Padding(
                                            padding:
                                                EdgeInsets.only(left: 1.5.w),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      color: Colors.blue,
                                                      width: 2.w,
                                                      height: 2,
                                                    ),
                                                    SizedBox(width: 1.w),
                                                    Text("X: ${gyroX ?? "--"}"),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      color: Colors.red,
                                                      width: 2.w,
                                                      height: 2,
                                                    ),
                                                    SizedBox(width: 1.w),
                                                    Text("Y: ${gyroY ?? "--"}"),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Container(
                                                      color: Colors.green,
                                                      width: 2.w,
                                                      height: 2,
                                                    ),
                                                    SizedBox(width: 1.w),
                                                    Text("Z: ${gyroZ ?? "--"}"),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ]),
                                  ),
                                ),
                                SizedBox(width: 10.w / 3),
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(1.w),
                                    height: 35.h,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color.fromARGB(
                                                50, 255, 255, 255)),
                                        color: mainTheme,
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Center(
                                          child: Text(
                                            'Accerelometer',
                                            style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12.sp),
                                          ),
                                        ),
                                        Expanded(
                                            child: SfCartesianChart(
                                                plotAreaBorderWidth: 0,
                                                primaryXAxis: NumericAxis(
                                                    majorGridLines:
                                                        const MajorGridLines(
                                                            width: 0)),
                                                primaryYAxis: NumericAxis(
                                                    axisLine: const AxisLine(
                                                        width: 0),
                                                    majorTickLines:
                                                        const MajorTickLines(
                                                            size: 0)),
                                                series: <LineSeries<__ChartData,
                                                    num>>[
                                              LineSeries<__ChartData, num>(
                                                  dataSource: accXList!,
                                                  color: Colors.blue,
                                                  xValueMapper:
                                                      (__ChartData sales, _) =>
                                                          sales.x,
                                                  yValueMapper:
                                                      (__ChartData sales, _) =>
                                                          sales.y,
                                                  width: 2),
                                              LineSeries<__ChartData, num>(
                                                dataSource: accYList!,
                                                color: Colors.red,
                                                width: 2,
                                                xValueMapper:
                                                    (__ChartData sales, _) =>
                                                        sales.x,
                                                yValueMapper:
                                                    (__ChartData sales, _) =>
                                                        sales.y,
                                              ),
                                              LineSeries<__ChartData, num>(
                                                dataSource: accZList!,
                                                color: Colors.green,
                                                width: 2,
                                                xValueMapper:
                                                    (__ChartData sales, _) =>
                                                        sales.x,
                                                yValueMapper:
                                                    (__ChartData sales, _) =>
                                                        sales.y,
                                              )
                                            ])),
                                        Padding(
                                          padding: EdgeInsets.only(left: 1.5.w),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                    color: Colors.blue,
                                                    width: 2.w,
                                                    height: 2,
                                                  ),
                                                  SizedBox(width: 1.w),
                                                  Text("X: ${accX ?? "--"}"),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    color: Colors.red,
                                                    width: 2.w,
                                                    height: 2,
                                                  ),
                                                  SizedBox(width: 1.w),
                                                  Text("Y: ${accY ?? "--"}"),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Container(
                                                    color: Colors.green,
                                                    width: 2.w,
                                                    height: 2,
                                                  ),
                                                  SizedBox(width: 1.w),
                                                  Text("Z: ${accZ ?? "--"}"),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.w / 3),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    children: [
                                      SizedBox.square(
                                        dimension: screenHeight * 0.35,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                strokeAlign: BorderSide
                                                    .strokeAlignOutside,
                                                color: const Color.fromARGB(
                                                    70, 255, 255, 255)),
                                          ),
                                          child: ClipOval(
                                            child: Container(
                                              color: mainTheme,
                                              child: Padding(
                                                padding: EdgeInsets.all(1.w),
                                                child: ModelViewer(
                                                    id: "transform",
                                                    cameraControls: false,
                                                    orientation:
                                                        "$gyroX $gyroY $gyroZ",
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    src: 'assets/CubeSat.glb',
                                                    alt:
                                                        'A 3D model of an Cube Sat',
                                                    disableZoom: true),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // SizedBox(height: 10.w / 3),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          Image.asset(
                                            "assets/BccLogo.png",
                                            height: 10.h,
                                          ),
                                          SizedBox(width: 1.5.w),
                                          Image.asset(
                                            "assets/SpaceLogo.png",
                                            height: 10.h,
                                          ),
                                          SizedBox(width: 3.5.w),
                                          Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: const Color.fromARGB(
                                                        50, 255, 255, 255)),
                                                color: mainTheme,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            height: 10.h,
                                            width: 12.w,
                                            child: Center(
                                                child: Row(
                                              children: [
                                                const Spacer(),
                                                Icon(
                                                  Icons.battery_full_rounded,
                                                  size: 17.sp,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  "${bat ?? "--"}%",
                                                  style: TextStyle(
                                                      fontSize: 17.sp),
                                                ),
                                                const Spacer(),
                                              ],
                                            )),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(width: 10.w / 3),
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  50, 255, 255, 255)),
                                          color: mainTheme,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: Padding(
                                        padding: EdgeInsets.all(2.w),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  height: 30.h,
                                                  child: const Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text("100 - "),
                                                      Text("50 - "),
                                                      Text("0 - "),
                                                    ],
                                                  ),
                                                ),
                                                SimpleAnimationProgressBar(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  height: 30.h,
                                                  width: 20,
                                                  backgroundColor: Colors.white,
                                                  foregrondColor:
                                                      const Color.fromARGB(
                                                          255, 36, 159, 216),
                                                  ratio: 0.5,
                                                  direction: Axis.vertical,
                                                  curve: Curves
                                                      .fastLinearToSlowEaseIn,
                                                  duration: const Duration(
                                                      seconds: 3),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                Text(
                                                  '${alt ?? "--"} ft.',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 17.sp),
                                                ),
                                                Text(
                                                  'Altitude',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12.sp),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.9,
                        width: screenWidth * 0.45,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                    color: const Color.fromARGB(
                                        50, 255, 255, 255)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: SizedBox(
                                    height: screenHeight * 0.45,
                                    width: screenWidth * 0.45,
                                    child: FlutterMap(
                                      mapController:
                                          _animatedMapController.mapController,
                                      options: MapOptions(
                                        maxZoom: 18,
                                        zoom: 10,
                                        onMapReady: () {
                                          _animatedMapController
                                              .mapController.mapEventStream
                                              .listen((evt) {});
                                          // And any other `MapController` dependent non-movement methods
                                        },
                                      ),
                                      nonRotatedChildren: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                CupertinoButton(
                                                    child: const Icon(
                                                      CupertinoIcons
                                                          .delete_solid,
                                                      color: Colors.black54,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        latLngPoints = [];
                                                      });
                                                    }),
                                                const Spacer(),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(15),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: BackdropFilter(
                                                      filter: ImageFilter.blur(
                                                          sigmaX: 5, sigmaY: 5),
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 2.w),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: const Color
                                                                        .fromARGB(
                                                                    50,
                                                                    255,
                                                                    255,
                                                                    255)),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            color: const Color
                                                                    .fromARGB(
                                                                180, 4, 3, 17)),
                                                        width: 250,
                                                        height: 80,
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Text(
                                                                  "LAT: ${latLngPoints.isEmpty ? "--" : latLngPoints[latLngPoints.length - 1].latitude}"),
                                                              Text(
                                                                  "LNG: ${latLngPoints.isEmpty ? "--" : latLngPoints[latLngPoints.length - 1].longitude}"),
                                                            ]),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      ],
                                      children: [
                                        TileLayer(
                                          urlTemplate:
                                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          userAgentPackageName:
                                              'com.example.app',
                                        ),
                                        PolylineLayer(
                                          polylines: [
                                            Polyline(
                                              strokeWidth: 3,
                                              points: latLngPoints.isEmpty
                                                  ? []
                                                  : latLngPoints,
                                              color: const Color.fromARGB(
                                                  255, 63, 13, 116),
                                            ),
                                          ],
                                        ),
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              point: latLngPoints.isEmpty
                                                  ? const LatLng(0, 0)
                                                  : latLngPoints[
                                                      latLngPoints.length - 1],
                                              width: 50,
                                              height: 50,
                                              builder: (context) {
                                                return Image.asset(
                                                    "assets/satellite.png");
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                              ),
                            ),
                            SizedBox(height: 10.w / 3),
                            Expanded(
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            width: 1000,
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: const Color.fromARGB(
                                                        50, 255, 255, 255)),
                                                color: mainTheme,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child: Padding(
                                              padding:
                                                  EdgeInsets.only(top: 4.h),
                                              child: DashedCircularProgressBar
                                                  .aspectRatio(
                                                aspectRatio: 1,
                                                progress: 37,
                                                startAngle: 300,
                                                sweepAngle: 120,
                                                foregroundColor:
                                                    const Color.fromARGB(
                                                        255, 87, 201, 91),
                                                backgroundColor:
                                                    const Color(0xffeeeeee),
                                                foregroundStrokeWidth: 20,
                                                backgroundStrokeWidth: 20,
                                                animation: true,
                                                corners: StrokeCap.round,
                                                child: Column(
                                                  children: [
                                                    SizedBox(height: 8.h),
                                                    Text(
                                                      '${temp ?? "--"}°C',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 17.sp),
                                                    ),
                                                    Text(
                                                      'Temperature',
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 12.sp),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10.w / 3),
                                        Container(
                                          height: 12.h,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: const Color.fromARGB(
                                                      50, 255, 255, 255)),
                                              color: mainTheme,
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '${heading ?? "--"}°',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 17.sp),
                                                ),
                                                Text(
                                                  'Heading',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 12.sp),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 10.w / 3),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          strokeAlign:
                                              BorderSide.strokeAlignOutside,
                                          color: const Color.fromARGB(
                                              50, 255, 255, 255)),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        "assets/example1.jpg",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }
}
