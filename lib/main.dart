import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ground_station/board.dart';
import 'package:ground_station/camera.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  CameraDevice.cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return CupertinoApp(
        theme: CupertinoThemeData(
            brightness: Brightness.light,
            textTheme: CupertinoTextThemeData(
              textStyle: GoogleFonts.spaceGrotesk(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.white),
            )),
        debugShowCheckedModeBanner: false,
        title: 'CubeSat Station',
        home: const MyHomePage(title: "Cube Sat Ground Station"),
      );
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? port;
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();
    getPort();
  }

  void getPort() async {
    port = await rootBundle.loadString('assets/port.txt');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (port != null) {
      channel = WebSocketChannel.connect(Uri.parse('ws://localhost:$port'));
      return Board(channel: channel, port: port!);
    } else {
      return Container();
    }
  }
}
