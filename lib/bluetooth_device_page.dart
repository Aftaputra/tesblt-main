import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDevicePage extends StatefulWidget {
  final BluetoothDevice device;

  BluetoothDevicePage({required this.device});

  @override
  _BluetoothDevicePageState createState() => _BluetoothDevicePageState();
}

class _BluetoothDevicePageState extends State<BluetoothDevicePage> {
  bool isConnecting = true;
  bool isConnected = false;
  String voltageData = 'N/A'; // Untuk menampilkan data tegangan
  String currentData = 'N/A'; // Untuk menampilkan data arus

  @override
  void initState() {
    super.initState();
    connectToDevice();
  }

  Future<void> connectToDevice() async {
    try {
      await widget.device.connect();
      setState(() {
        isConnected = true;
        isConnecting = false;
      });

      // Mendapatkan services dan characteristics
      List<BluetoothService> services = await widget.device.discoverServices();
      for (var service in services) {
        // Cek jika service adalah Voltage Service
        if (service.uuid.toString() == "12345678-1234-1234-1234-123456789012") {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == "abcd1234-5678-1234-5678-123456789abc") {
              characteristic.setNotifyValue(true);
              characteristic.value.listen((value) {
                setState(() {
                  voltageData = String.fromCharCodes(value);
                });
              });
            }
          }
        }

        // Cek jika service adalah Current Service
        if (service.uuid.toString() == "87654321-4321-4321-4321-210987654321") {
          for (var characteristic in service.characteristics) {
            if (characteristic.uuid.toString() == "dcba4321-8765-4321-8765-210987654321") {
              characteristic.setNotifyValue(true);
              characteristic.value.listen((value) {
                setState(() {
                  currentData = String.fromCharCodes(value);
                });
              });
            }
          }
        }
      }
    } catch (e) {
      print("Connection failed: $e");
      setState(() {
        isConnecting = false;
      });
    }
  }

  @override
  void dispose() {
    widget.device.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name.isNotEmpty
            ? widget.device.name
            : 'Unknown Device'),
      ),
      body: Center(
        child: isConnecting
            ? CircularProgressIndicator()
            : isConnected
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Connected to ${widget.device.name}"),
                      SizedBox(height: 20),
                      Text("Voltage: $voltageData V"), // Menampilkan data tegangan
                      SizedBox(height: 10),
                      Text("Current: $currentData A"), // Menampilkan data arus
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          widget.device.disconnect();
                          setState(() {
                            isConnected = false;
                          });
                          Navigator.pop(context);
                        },
                        child: Text("Disconnect"),
                      )
                    ],
                  )
                : Text("Failed to connect"),
      ),
    );
  }
}
