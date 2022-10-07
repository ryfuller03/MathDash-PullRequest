import 'package:flutter/material.dart';
import 'package:math_dash/game_screen.dart';
import 'package:math_dash/request_screen.dart';
import 'package:math_dash/respond_screen.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //

  // why is this important? I'm not sure!
  int ourPort = 8888;
  //

  //

  String? _ipAddress = "";
  late StreamSubscription<Socket> server_sub;

  void initState() {
    super.initState();
    //_nameController = TextEditingController();
    //_ipController = TextEditingController();
    _setupServer();
    _findIPAddress();
  }

  void dispose() {
    server_sub.cancel();
    super.dispose();
  }

  Future<void> _findIPAddress() async {
    // Thank you https://stackoverflow.com/questions/52411168/how-to-get-device-ip-in-dart-flutter
    String? ip = await NetworkInfo().getWifiIP();
    setState(() {
      _ipAddress = ip;
    });
  }

  void openRespond() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RespondPage(),
      ),
    );
  }

  Future<void> sendRequest() async {
    //get opponent ip from text input
    int opponent_IP = 123;
    Socket socket = await Socket.connect(opponent_IP, ourPort);
    socket.write("request");

    //might not want to close
    socket.close();
  }

  void openRequest() {
    //send request to opponent's ip
    sendRequest;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RequestPage(),
      ),
    );
  }

  Future<void> _setupServer() async {
    try {
      ServerSocket server =
          await ServerSocket.bind(InternetAddress.anyIPv4, ourPort);
      server_sub = server.listen(_listenToSocket); // StreamSubscription<Socket>
    } on SocketException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
      ));
    }
  }

  void _listenToSocket(Socket socket) {
    socket.listen((data) {
      setState(() {
        _handleIncomingMessage(socket.remoteAddress.address, data);
      });
    });
  }

  void _handleIncomingMessage(String ip, Uint8List incomingData) {
    String received = String.fromCharCodes(incomingData);
    print("Received '$received' from '$ip'");
    //
    // HERE'S WHERE ONE PHONE WOULD RECEIVE A CHALLENGE I THINK
    //
    openRespond();
  }

  //

  //

  //

  @override
  Widget build(BuildContext context) {
    void openGame() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const GamePage(seed: 123),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("My IP: ${_ipAddress!}"),
              SizedBox(
                width: 300,
                child: TextField(
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: const InputDecoration(hintText: "IP Address"),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                  width: 250,
                  height: 75,
                  child: ElevatedButton(
                      key: const Key("InviteButton"),
                      onPressed: openRequest,
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 40)),
                      child: const Text("Invite"))),
              const SizedBox(height: 10),

              // Button Below will not exist.
              // Button should be replaced with logic code that
              // relates to the network when a play request is sent.

              SizedBox(
                  width: 200,
                  height: 75,
                  child: ElevatedButton(
                      key: const Key("TempRespondButton"),
                      onPressed: openRespond,
                      style: ElevatedButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 15)),
                      child: const Text("Respond Dev Button"))),
            ],
          ),
        ),
      ),
    );
  }
}
