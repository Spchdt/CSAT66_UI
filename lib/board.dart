import 'package:flutter/cupertino.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Board extends StatefulWidget {
  const Board({super.key});

  @override
  State<Board> createState() => _BoardState();
}

class _BoardState extends State<Board> {
  final channel = WebSocketChannel.connect(
    Uri.parse('wss://socketsbay.com/wss/v2/1/demo/'),
  );

  // getWeb() {
  //   final wsUrl = Uri.parse('ws://localhost:1234');
  //   var channel = WebSocketChannel.connect(wsUrl);

  //   channel.stream.listen((message) {
  //     print(message.toString());
  //     channel.sink.add('received!');
  //     channel.sink.close(status.goingAway);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        StreamBuilder(
          stream: channel.stream,
          builder: (context, snapshot) {
            return Text(snapshot.hasData ? '${snapshot.data}' : 'NO DATA');
          },
        ),
        CupertinoButton.filled(
            child: Text("hello"),
            onPressed: () {
              print("hi");
              channel.sink.add('Hello!');
            }),
      ]),
    );
  }
}
