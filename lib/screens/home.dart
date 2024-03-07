import 'package:all_bluetooth/all_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bondedDevices = ValueNotifier(<BluetoothDevice>[]);

  bool isListening = false;
  @override
  void initState() {
    super.initState();
    Future.wait([
      Permission.bluetooth.request(),
      Permission.bluetoothScan.request(),
      Permission.bluetoothConnect.request(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: allBluetooth.streamBluetoothState,
        builder: (context, snapshot) {
          final bluetoothOn = snapshot.data ?? false;
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                "Blutooth Friend",
                style: TextStyle(fontSize: 30, color: Colors.white),
              ),
              backgroundColor: const Color.fromARGB(255, 67, 180, 255),
            ),
            floatingActionButton: switch (isListening) {
              true => null,
              false => FloatingActionButton(
                  onPressed: switch (bluetoothOn) {
                    false => null,
                    true => () {
                        allBluetooth.startBluetoothServer();
                        setState(() => isListening = true);
                      },
                  },
                  backgroundColor: bluetoothOn
                      ? const Color.fromARGB(255, 67, 180, 255)
                      : const Color.fromARGB(255, 95, 145, 179),
                  child: const Icon(
                    Icons.bluetooth,
                    color: Colors.white,
                  ),
                ),
            },
            backgroundColor: const Color.fromARGB(255, 255, 255, 255),
            body: isListening
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text("Searching New Friend",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 67, 180, 255))),
                        ),
                        const CircularProgressIndicator(
                          backgroundColor: Color.fromARGB(255, 255, 255,
                              255), // Background color of the circular track
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blue), // Color of the progress arc
                          strokeWidth: 4.0, // Thickness of the progress arc
                        ),
                        FloatingActionButton(
                          backgroundColor:
                              const Color.fromARGB(255, 67, 180, 255),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            allBluetooth.closeConnection();
                            setState(() {
                              isListening = false;
                            });
                          },
                        )
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              height: double.tryParse('30'),
                              child: Text(
                                switch (bluetoothOn) {
                                  true => "Bluetooth ON",
                                  false => "Bluetooth OFF",
                                },
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: bluetoothOn
                                        ? const Color.fromARGB(
                                            255, 42, 177, 255)
                                        : const Color.fromARGB(
                                            255, 42, 177, 255)),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: switch (bluetoothOn) {
                                false => null,
                                true => () async {
                                    final devices =
                                        await allBluetooth.getBondedDevices();
                                    bondedDevices.value = devices;
                                  },
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                    255, 42, 177, 255), // Text color
                                elevation: 4, // Elevation when pressed
                              ),
                              child: const Text(
                                "Previously Connected Devices",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        if (!bluetoothOn)
                          const Center(
                            child: Text(
                              "Turn bluetooth on",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red),
                            ),
                          ),
                        ValueListenableBuilder(
                            valueListenable: bondedDevices,
                            builder: (context, devices, child) {
                              return Expanded(
                                child: ListView.builder(
                                  itemCount: bondedDevices.value.length,
                                  itemBuilder: (context, index) {
                                    final device = devices[index];
                                    return ListTile(
                                      title: Text(device.name),
                                      subtitle: Text(device.address),
                                      onTap: () {
                                        allBluetooth
                                            .connectToDevice(device.address);
                                      },
                                    );
                                  },
                                ),
                              );
                            })
                      ],
                    ),
                  ),
          );
        });
  }
}
