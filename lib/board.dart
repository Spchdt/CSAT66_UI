import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> with TickerProviderStateMixin {
  late final _animatedMapController = AnimatedMapController(
    vsync: this,
  );
  final channel = WebSocketChannel.connect(
    Uri.parse('wss://echo.websocket.events'),
  );
  final points = [LatLng(30, 40), LatLng(20, 50), LatLng(25, 45)];
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    double screenHeight = MediaQuery.sizeOf(context).height;

    return CupertinoPageScaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: screenHeight * 0.8,
              width: screenWidth * 0.45,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 100.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                        color: Colors.lightBlue[50],
                        borderRadius: BorderRadius.circular(20)),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("x: 120.235"),
                        Text("y: 345.54"),
                        Text("z: 464.235"),
                        Text("axis: 1200"),
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream: channel.stream,
                    builder: (context, snapshot) {
                      return Text(
                          snapshot.hasData ? '${snapshot.data}' : 'NO DATA');
                    },
                  ),
                  CupertinoButton.filled(
                      child: const Text("Send"),
                      onPressed: () {
                        channel.sink.add('Hello! dah');

                        setState(() {
                          points.add(LatLng(
                              points[points.length - 1].latitude + 1,
                              points[points.length - 1].latitude + 1));
                          _animatedMapController.animateTo(
                              dest: points[points.length - 1]);
                        });
                      }),
                ],
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                  height: screenHeight * 0.9,
                  width: screenWidth * 0.45,
                  child: FlutterMap(
                    mapController: _animatedMapController.mapController,
                    options: MapOptions(
                      center: const LatLng(25, 45),
                      maxZoom: 18,
                      zoom: 10,
                      onMapReady: () {
                        _animatedMapController.mapController.mapEventStream
                            .listen((evt) {});
                        // And any other `MapController` dependent non-movement methods
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            strokeWidth: 2,
                            points: points,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: points[points.length - 1],
                            width: 80,
                            height: 80,
                            builder: (context) {
                              return const Text("hi");
                            },
                          ),
                        ],
                      ),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}
