import 'package:all_bluetooth/all_bluetooth.dart';
import 'package:flutter/material.dart';
import 'screens/message.dart';
import 'screens/home.dart';

void main() {
  runApp(const MyApp());
}

final allBluetooth = AllBluetooth();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
          stream: allBluetooth.listenForConnection,
          builder: (context, snapshot) {
            final result = snapshot.data;
            if (result?.state == true) {
              return const ChatScreen();
            }
            print(result);
            return const HomeScreen();
          }),
      theme: ThemeData(
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}