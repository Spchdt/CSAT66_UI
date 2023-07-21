import 'dart:async';
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
  Timer? timer;

  void initState() {
    super.initState();
    timer = Timer.periodic(
        Duration(seconds: 1), (Timer t) => channel.sink.add("DC"));
  }

  //Web socket source
  final channel = WebSocketChannel.connect(Uri.parse('ws:192.168.0.149:7890'));

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
    //lat,lng,alt,accX,accY,accZ,gyroX,gyroY,gyroZ,heading,temp

    List<String> inputDataList = inputData.split(",");

    double tempLat =
        double.parse(double.parse(inputDataList[0]).toStringAsFixed(8));
    double tempLng =
        double.parse(double.parse(inputDataList[1]).toStringAsFixed(8));
    double tempAlt =
        double.parse(double.parse(inputDataList[2]).toStringAsFixed(3));
    double tempAccX = double.parse(inputDataList[3]);
    double tempAccY = double.parse(inputDataList[4]);
    double tempAccZ = double.parse(inputDataList[5]);
    double tempGyroX = double.parse(inputDataList[6]);
    double tempGyroY = double.parse(inputDataList[7]);
    double tempGyroZ = double.parse(inputDataList[8]);
    int tempHeading = int.parse(inputDataList[9]);
    double tempTemp = double.parse(inputDataList[10]);

    // int tempBat = 0;
    // String tempImg = "";

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
    // bat = tempBat;
    // img = tempImg;

    latLngPoints.add(LatLng(tempLat, tempLng));
    _animatedMapController.centerOnPoint(LatLng(tempLat, tempLng));
    accXList!.add(__ChartData(accXList!.length, tempAccX));
    accYList!.add(__ChartData(accYList!.length, tempAccY));
    accZList!.add(__ChartData(accZList!.length, tempAccZ));

    gyroXList!.add(__ChartData(gyroXList!.length, tempGyroX));
    gyroYList!.add(__ChartData(gyroYList!.length, tempGyroY));
    gyroZList!.add(__ChartData(gyroZList!.length, tempGyroZ));

    js.context
        .callMethod("updateOrientation", [tempGyroX, tempGyroY, tempGyroZ]);
  }

  double findProgressBarRatio(alt) {
    if (alt < 0) {
      return 0;
    } else {
      return alt! / 30000;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    return StreamBuilder(
        stream: channel.stream,
        builder: (context, snapshot) {
          String? inputData = snapshot.data;
          // print(inputData);
          if (inputData != null) {
            // print(inputData);
            update(inputData);
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
                                              child: ModelViewer(
                                                disablePan: true,
                                                id: "transform",
                                                cameraControls: false,
                                                orientation:
                                                    "$gyroX $gyroY $gyroZ",
                                                backgroundColor:
                                                    Colors.transparent,
                                                src:
                                                    'assets/assets/CubeSat.glb',
                                                alt:
                                                    'A 3D model of an Cube Sat',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      // SizedBox(height: 10.w / 3),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          CupertinoButton(
                                            child: Image.asset(
                                              "assets/BccLogo.png",
                                              height: 10.h,
                                            ),
                                            onPressed: () {
                                              channel.sink.add("DC");
                                            },
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
                                                      Text("30 km. - "),
                                                      Text("15 km. - "),
                                                      Text("0 km. - "),
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
                                                  ratio: alt != null
                                                      ? findProgressBarRatio(
                                                          alt)
                                                      : 0,
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
                                                  '${alt ?? "--"} m.',
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
                                        center: LatLng(13.720958, 100.523164),
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
                                                progress:
                                                    temp != null ? temp! : 0,
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
