import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:dashed_circular_progress_bar/dashed_circular_progress_bar.dart';
import 'package:ditredi/ditredi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_animation_progress_bar/simple_animation_progress_bar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:watcher/watcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:camera/camera.dart';

import 'camera.dart';

class Board extends StatefulWidget {
  const Board({super.key, required this.channel, required this.port});
  final WebSocketChannel channel;
  final String port;

  @override
  State<Board> createState() => _BoardState();
}

class __ChartData {
  __ChartData(this.x, this.y);
  final int x;
  final double y;
}

class _BoardState extends State<Board> with TickerProviderStateMixin {
  final modelController = DiTreDiController();
  late Future<List<Face3D>> cubeSatModel;
  Timer? timer;
  var watcher = DirectoryWatcher("C:/RX-SSTV/History");
  int count = 1;
  List<String> images = [];
  int imagesIndex = 0;
  late CameraController controller;
  String? error;
  bool toggleCamera = false;
  String runTime = "00:00";

  @override
  void initState() {
    super.initState();
    cubeSatModel = ObjParser().loadFromResources("assets/CubeSat.obj");
    getImages();
    controller =
        CameraController(CameraDevice.cameras[0], ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            error = e.description;
            break;
          default:
            error = e.description;
            break;
        }
      }
    });

    timer = Timer.periodic(
        const Duration(seconds: 1), (Timer t) => widget.channel.sink.add("DC"));

    watcher.events.listen((event) {
      print(event);
      getImages();
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

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

    lat = double.parse(double.parse(inputDataList[0]).toStringAsFixed(8));
    lng = double.parse(double.parse(inputDataList[1]).toStringAsFixed(8));
    alt = double.parse(double.parse(inputDataList[2]).toStringAsFixed(3));
    accX = double.parse(inputDataList[3]);
    accY = double.parse(inputDataList[4]);
    accZ = double.parse(inputDataList[5]);
    gyroX = double.parse(inputDataList[6]);
    gyroY = double.parse(inputDataList[7]);
    gyroZ = double.parse(inputDataList[8]);
    heading = int.parse(inputDataList[9]);
    temp = double.parse(inputDataList[10]);

    // bat = 0;
    // img = "";

    // if (latLngPoints.length > 20) {
    //   latLngPoints.removeAt(0);
    // }
    if (accXList!.length > 20) {
      accXList!.removeAt(0);
    }
    if (accYList!.length > 20) {
      accYList!.removeAt(0);
    }
    if (accZList!.length > 20) {
      accZList!.removeAt(0);
    }
    if (gyroXList!.length > 20) {
      gyroXList!.removeAt(0);
    }
    if (gyroYList!.length > 20) {
      gyroYList!.removeAt(0);
    }
    if (gyroZList!.length > 20) {
      gyroZList!.removeAt(0);
    }

    latLngPoints.add(LatLng(lat!, lng!));
    _animatedMapController.centerOnPoint(LatLng(lat!, lng!));
    accXList!.add(__ChartData(count, accX!));
    accYList!.add(__ChartData(count, accY!));
    accZList!.add(__ChartData(count, accZ!));

    gyroXList!.add(__ChartData(count, gyroX!));
    gyroYList!.add(__ChartData(count, gyroY!));
    gyroZList!.add(__ChartData(count, gyroZ!));

    count += 1;
    getTime(count);
    modelController.update(
        rotationX: gyroX, rotationY: gyroY, rotationZ: gyroZ);
  }

  void getTime(time) {
    int sec = time % 60;
    int min = (time / 60).floor();
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    runTime = "$minute:$second";
  }

  void getImages() async {
    // final dir = await getApplicationDocumentsDirectory();
    // String imgDir = ("${dir.path}/CubeSat");
    images = [];

    Directory("C:/RX-SSTV/History").listSync().forEach((e) {
      if (p.extension(e.path) == ".jpg") {
        images.add(e.path);
        images.sort((a, b) => a.compareTo(b));
        imagesIndex = images.length - 1;
        setState(() {});
      }
    });
  }

  double findProgressBarRatio(alt) {
    if (alt < 0) {
      return 0;
    } else {
      return alt! / 30000;
    }
  }

  double findTempProgress(temp) {
    if (temp > 0) {
      return temp;
    } else {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    return StreamBuilder(
        stream: widget.channel.stream,
        builder: (context, snapshot) {
          String? inputData = snapshot.data;
          print("recieved");
          if (inputData != null) {
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
                                    height: screenHeight * 0.35,
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
                                    height: screenHeight * 0.35,
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
                                            'Accelerometer',
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Column(
                                    crossAxisAlignment: toggleCamera
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (toggleCamera)
                                        Expanded(
                                          child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: AspectRatio(
                                                aspectRatio: 640 / 512,
                                                child: CupertinoButton(
                                                    padding: EdgeInsets.zero,
                                                    onPressed: () {
                                                      showCupertinoModalPopup<
                                                          void>(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            CupertinoActionSheet(
                                                          actions: <CupertinoActionSheetAction>[
                                                            CupertinoActionSheetAction(
                                                                isDefaultAction:
                                                                    true,
                                                                onPressed:
                                                                    () {},
                                                                child: CameraPreview(
                                                                    controller)),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                      child: CameraPreview(
                                                          controller),
                                                    )),
                                              )),
                                        )
                                      else
                                        SizedBox.square(
                                          dimension: screenHeight * 0.35,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: const Color.fromARGB(
                                                      80, 255, 255, 255)),
                                            ),
                                            child: ClipOval(
                                              child: Container(
                                                  color: mainTheme,
                                                  child: FutureBuilder(
                                                    future: cubeSatModel,
                                                    builder:
                                                        (context, snapshot) {
                                                      if (snapshot
                                                              .connectionState ==
                                                          ConnectionState
                                                              .done) {
                                                        return DiTreDi(
                                                          controller:
                                                              modelController,
                                                          figures: [
                                                            Mesh3D(
                                                                snapshot.data!),
                                                          ],
                                                        );
                                                      } else {
                                                        return Container();
                                                      }
                                                    },
                                                  )),
                                            ),
                                          ),
                                        ),
                                      if (toggleCamera)
                                        SizedBox(height: 10.w / 3)
                                      else
                                        const Spacer(),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              showCupertinoModalPopup<void>(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        CupertinoActionSheet(
                                                  actions: <CupertinoActionSheetAction>[
                                                    CupertinoActionSheetAction(
                                                      isDefaultAction: true,
                                                      onPressed: () {},
                                                      child: Text(
                                                          "PORT: ${widget.port}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                    ),
                                                    CupertinoActionSheetAction(
                                                      isDefaultAction: true,
                                                      onPressed: () {},
                                                      child: Text(
                                                          "${CameraDevice.cameras}",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                    ),
                                                    CupertinoActionSheetAction(
                                                      isDefaultAction: true,
                                                      onPressed: () {},
                                                      child: Text("$error",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                    ),
                                                    CupertinoActionSheetAction(
                                                      isDefaultAction: true,
                                                      onPressed: () {},
                                                      child: Text(
                                                          "Runtime: $runTime",
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Image.asset(
                                              "assets/BccLogo.png",
                                              height: screenHeight * 0.1,
                                            ),
                                          ),
                                          SizedBox(width: 1.5.w),
                                          CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              setState(() {
                                                if (toggleCamera == true) {
                                                  toggleCamera = false;
                                                } else {
                                                  toggleCamera = true;
                                                }
                                              });
                                            },
                                            child: Image.asset(
                                              "assets/SpaceLogo.png",
                                              height: screenHeight * 0.1,
                                            ),
                                          ),
                                          SizedBox(width: 3.5.w),
                                          CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () {},
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          const Color.fromARGB(
                                                              50,
                                                              255,
                                                              255,
                                                              255)),
                                                  color: mainTheme,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              height: screenHeight * 0.1,
                                              width: 12.w,
                                              child: Center(
                                                  child: Row(
                                                children: [
                                                  const Spacer(),
                                                  Icon(
                                                    Icons.timer_outlined,
                                                    size: 17.sp,
                                                    color: Colors.white,
                                                  ),
                                                  Text(
                                                    runTime,
                                                    style: TextStyle(
                                                        fontSize: 15.sp,
                                                        color: Colors.white),
                                                  ),
                                                  const Spacer(),
                                                ],
                                              )),
                                            ),
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
                                                  height: screenHeight * 0.3,
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
                                                  height: screenHeight * 0.3,
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
                                        center:
                                            const LatLng(13.720958, 100.523164),
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
                                                        width:
                                                            screenWidth * 0.2,
                                                        height:
                                                            screenHeight * 0.1,
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
                                              width: 40,
                                              height: 40,
                                              builder: (context) {
                                                return Image.asset(
                                                    "assets/CubeSat_icon.png");
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
                                              padding: EdgeInsets.only(
                                                  top: screenHeight * 0.04),
                                              child: DashedCircularProgressBar
                                                  .aspectRatio(
                                                aspectRatio: 1,
                                                progress: temp != null
                                                    ? findTempProgress(temp!)
                                                    : 0,
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
                                                    SizedBox(
                                                        height: screenHeight *
                                                            0.08),
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
                                          height: screenHeight * 0.12,
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
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: imagesIndex == 0
                                                ? null
                                                : () {
                                                    setState(() {
                                                      imagesIndex -= 1;
                                                    });
                                                  },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: mainTheme,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: const Color.fromARGB(
                                                        50, 255, 255, 255)),
                                              ),
                                              height: screenHeight * 0.05,
                                              width: screenHeight * 0.05,
                                              child: Icon(
                                                Icons.chevron_left_rounded,
                                                color: Colors.white,
                                                size: 17.sp,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenHeight * 0.01),
                                          CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: imagesIndex ==
                                                        images.length - 1 ||
                                                    images.isEmpty
                                                ? null
                                                : () {
                                                    setState(() {
                                                      imagesIndex += 1;
                                                    });
                                                  },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: mainTheme,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: const Color.fromARGB(
                                                        50, 255, 255, 255)),
                                              ),
                                              height: screenHeight * 0.05,
                                              width: screenHeight * 0.05,
                                              child: Icon(
                                                Icons.chevron_right_rounded,
                                                color: Colors.white,
                                                size: 17.sp,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: screenHeight * 0.02),
                                          CupertinoButton(
                                            padding: EdgeInsets.zero,
                                            onPressed: () {
                                              getImages();
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: mainTheme,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    color: const Color.fromARGB(
                                                        50, 255, 255, 255)),
                                              ),
                                              height: screenHeight * 0.05,
                                              width: screenWidth * 0.1,
                                              child: Center(
                                                child: Text(
                                                  "${images.isEmpty ? imagesIndex : imagesIndex + 1} OF ${images.length}",
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: const Color.fromARGB(
                                                    50, 255, 255, 255)),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Stack(
                                              children: [
                                                ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    child: AspectRatio(
                                                      aspectRatio: 640 / 512,
                                                      child: Container(
                                                          color: mainTheme,
                                                          width: 640.sp,
                                                          height: 512.sp),
                                                    )),
                                                if (images.isNotEmpty)
                                                  CupertinoButton(
                                                    padding: EdgeInsets.zero,
                                                    onPressed: () {
                                                      showCupertinoModalPopup<
                                                          void>(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            CupertinoActionSheet(
                                                          actions: <CupertinoActionSheetAction>[
                                                            CupertinoActionSheetAction(
                                                              isDefaultAction:
                                                                  true,
                                                              onPressed: () {},
                                                              child: Image.file(
                                                                File(images[
                                                                    imagesIndex]),
                                                                scale: 1 / 2,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                        child: Image.file(
                                                          File(images[
                                                              imagesIndex]),
                                                          scale: 1 / 2,
                                                        )),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
