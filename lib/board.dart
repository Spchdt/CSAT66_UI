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

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class __ChartData {
  __ChartData(this.country, this.sales);
  final int country;
  final num sales;
}

class _BoardState extends State<Board> with TickerProviderStateMixin {
  List<__ChartData>? accXList;
  List<__ChartData>? accYList;
  List<__ChartData>? accZList;

  List<__ChartData>? gyroXList;
  List<__ChartData>? gyroYList;
  List<__ChartData>? agyroZList;

  late int count;
  ChartSeriesController? _chartSeriesController;

  @override
  void dispose() {
    accXList!.clear();
    _chartSeriesController = null;
    super.dispose();
  }

  @override
  void initState() {
    count = 19;
    accXList = <__ChartData>[
      __ChartData(0, 42),
      __ChartData(1, 47),
      __ChartData(2, 33),
      __ChartData(3, 49),
      __ChartData(4, 54),
      __ChartData(5, 41),
    ];

    accYList = <__ChartData>[
      __ChartData(2, 47),
      __ChartData(3, 33),
      __ChartData(4, 49),
      __ChartData(5, 54),
      __ChartData(6, 41),
      __ChartData(7, 58),
      __ChartData(8, 51),
    ];

    accZList = <__ChartData>[
      __ChartData(3, 47),
      __ChartData(4, 33),
      __ChartData(5, 49),
      __ChartData(6, 54),
      __ChartData(7, 41),
      __ChartData(8, 58),
      __ChartData(9, 51),
    ];
    super.initState();
  }

  //Web socket source
  final channel =
      WebSocketChannel.connect(Uri.parse('wss://echo.websocket.events'));

  //Map Animation
  late final _animatedMapController = AnimatedMapController(vsync: this);

  //List of past LatLng points
  List<LatLng> latLngPoints = const [
    LatLng(30, 40),
    LatLng(20, 50),
    LatLng(25, 45),
  ];

  //Base secondary background color
  Color mainTheme = const Color.fromARGB(40, 255, 255, 255);

  double accX = 341.45;
  double accY = 334.234;
  double accZ = 324.234;
  double gyroX = 324.453;
  double gyroY = 657.24;
  double gyroZ = 45.45;
  double temp = 37;
  double alt = 3243;
  double lng = 435;
  double lat = 435;
  int heading = 240;
  String img = "Hello";

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

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
                    glowColor: const Color.fromARGB(34, 255, 69, 7),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(1000),
                  ),
                ),
                Transform.rotate(
                  angle: -0.6,
                  child: GlowContainer(
                    width: 50.w,
                    height: 10.w,
                    spreadRadius: 100,
                    blurRadius: 1000,
                    glowColor: const Color.fromARGB(34, 189, 7, 255),
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
                                  color: mainTheme,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
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
                                                axisLine:
                                                    const AxisLine(width: 0),
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
                                                      sales.country,
                                              yValueMapper:
                                                  (__ChartData sales, _) =>
                                                      sales.sales,
                                              width: 2),
                                          LineSeries<__ChartData, num>(
                                            dataSource: accYList!,
                                            color: Colors.red,
                                            width: 2,
                                            xValueMapper:
                                                (__ChartData sales, _) =>
                                                    sales.country,
                                            yValueMapper:
                                                (__ChartData sales, _) =>
                                                    sales.sales,
                                          ),
                                          LineSeries<__ChartData, num>(
                                            dataSource: accZList!,
                                            color: Colors.green,
                                            width: 2,
                                            xValueMapper:
                                                (__ChartData sales, _) =>
                                                    sales.country,
                                            yValueMapper:
                                                (__ChartData sales, _) =>
                                                    sales.sales,
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
                                              Text("X: $accX"),
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
                                              Text("Y: $accY"),
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
                                              Text("Z: $accZ"),
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
                                  color: mainTheme,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Center(
                                    child: Text(
                                      'Gyrometer',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 12.sp),
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
                                              axisLine:
                                                  const AxisLine(width: 0),
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
                                                    sales.country,
                                            yValueMapper:
                                                (__ChartData sales, _) =>
                                                    sales.sales,
                                            width: 2),
                                        LineSeries<__ChartData, num>(
                                          dataSource: accYList!,
                                          color: Colors.red,
                                          width: 2,
                                          xValueMapper:
                                              (__ChartData sales, _) =>
                                                  sales.country,
                                          yValueMapper:
                                              (__ChartData sales, _) =>
                                                  sales.sales,
                                        ),
                                        LineSeries<__ChartData, num>(
                                          dataSource: accZList!,
                                          color: Colors.green,
                                          width: 2,
                                          xValueMapper:
                                              (__ChartData sales, _) =>
                                                  sales.country,
                                          yValueMapper:
                                              (__ChartData sales, _) =>
                                                  sales.sales,
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
                                            Text("X: $gyroX"),
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
                                            Text("Y: $gyroY"),
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
                                            Text("Z: $gyroZ"),
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
                                  dimension: 32.h,
                                  child: ClipOval(
                                    child: Container(
                                      color: mainTheme,
                                      //TODO: Update framing, oreintation, roll pitch yaw
                                      child: const ModelViewer(
                                          cameraControls: false,
                                          orientation: "0 0 -0.5",
                                          backgroundColor: Colors.transparent,
                                          src: 'assets/CubeSat.glb',
                                          alt: 'A 3D model of an astronaut',
                                          disableZoom: true),
                                    ),
                                  ),
                                ),
                                // SizedBox(height: 10.w / 3),
                                Spacer(),
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
                                          color: mainTheme,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      height: 10.h,
                                      width: 10.w,
                                      child: Center(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Icon(
                                            Icons.battery_charging_full_rounded,
                                            size: 17.sp,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            "100%",
                                            style: TextStyle(fontSize: 17.sp),
                                          ),
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
                                    color: mainTheme,
                                    borderRadius: BorderRadius.circular(15)),
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
                                            height: 30.h,
                                            width: 20,
                                            backgroundColor: Colors.white,
                                            foregrondColor:
                                                const Color.fromARGB(
                                                    255, 29, 134, 182),
                                            ratio: 0.5,
                                            direction: Axis.vertical,
                                            curve:
                                                Curves.fastLinearToSlowEaseIn,
                                            duration:
                                                const Duration(seconds: 3),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            '$alt ft.',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: SizedBox(
                            height: screenHeight * 0.45,
                            width: screenWidth * 0.45,
                            child: FlutterMap(
                              mapController:
                                  _animatedMapController.mapController,
                              options: MapOptions(
                                center: const LatLng(25, 45),
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
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        CupertinoButton(
                                            child: const Icon(
                                              CupertinoIcons.delete_solid,
                                              color: Colors.black54,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                latLngPoints = [];
                                              });
                                            }),
                                        const Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.all(15),
                                          child: Container(
                                            padding: EdgeInsets.only(left: 2.w),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: const Color.fromARGB(
                                                    200, 4, 3, 17)),
                                            width: 250,
                                            height: 80,
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                      "LAT: ${latLngPoints.isEmpty ? "--" : latLngPoints[0].latitude}"),
                                                  Text(
                                                      "LNG: ${latLngPoints.isEmpty ? "--" : latLngPoints[0].longitude}"),
                                                ]),
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
                                  userAgentPackageName: 'com.example.app',
                                ),
                                PolylineLayer(
                                  polylines: [
                                    Polyline(
                                      strokeWidth: 3,
                                      points: latLngPoints.isEmpty
                                          ? []
                                          : latLngPoints,
                                      color: Color.fromARGB(255, 63, 13, 116),
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
                                          color: mainTheme,
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 4.h),
                                        child: DashedCircularProgressBar
                                            .aspectRatio(
                                          aspectRatio: 1,
                                          progress: 37,
                                          startAngle: 300,
                                          sweepAngle: 120,
                                          foregroundColor: Colors.green,
                                          backgroundColor:
                                              const Color(0xffeeeeee),
                                          foregroundStrokeWidth: 20,
                                          backgroundStrokeWidth: 20,
                                          animation: true,
                                          corners: StrokeCap.butt,
                                          child: Column(
                                            children: [
                                              SizedBox(height: 6.h),
                                              Text(
                                                '$temp°C',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
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
                                        color: mainTheme,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            '283°',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700,
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
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.asset(
                                "assets/example1.jpg",
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
  }
}

                        // Column(
                        //   children: [
                        //     StreamBuilder(
                        //       stream: channel.stream,
                        //       builder: (context, snapshot) {
                        //         return Text(snapshot.hasData
                        //             ? '${snapshot.data}'
                        //             : 'NO DATA');
                        //       },
                        //     ),
                        //     CupertinoButton.filled(
                        //         child: const Text("Send"),
                        //         onPressed: () {
                        //           channel.sink.add('Hello! dah');

                        //           setState(() {
                        //             points.add(LatLng(
                        //                 points[points.length - 1].latitude + 1,
                        //                 points[points.length - 1].latitude +
                        //                     1));
                        //             _animatedMapController.animateTo(
                        //                 dest: points[points.length - 1]);
                        //           });
                        //         }),
                        //   ],
                        // ),