import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // Pastikan kamu sudah mengimpor flutter_blue_plus
import 'package:permission_handler/permission_handler.dart';
import 'bluetooth_device_page.dart';

class BluetoothScanPage extends StatefulWidget {
  @override
  _BluetoothScanPageState createState() => _BluetoothScanPageState();
}

class _BluetoothScanPageState extends State<BluetoothScanPage> {
  List<BluetoothDevice> devicesList = [];
  late BluetoothDevice selectedDevice;
  bool isScanning = false;

  @override
  void initState() {
    super.initState();
    requestPermissions(); // Meminta izin Bluetooth sebelum mulai pemindaian
  }

  Future<void> requestPermissions() async {
    if (await Permission.bluetoothScan.request().isGranted &&
        await Permission.bluetoothConnect.request().isGranted &&
        await Permission.locationWhenInUse.request().isGranted) {
      startScan();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bluetooth permissions are required')),
      );
    }
  }

  void startScan() {
    setState(() {
      isScanning = true;
    });

    FlutterBluePlus.startScan(timeout: Duration(seconds: 5)); // Perbaikan akses anggota statis

    FlutterBluePlus.scanResults.listen((results) { // Perbaikan akses anggota statis
      setState(() {
        for (ScanResult result in results) {
          if (!devicesList.contains(result.device)) {
            devicesList.add(result.device);
          }
        }
      });
    }).onDone(() {
      setState(() {
        isScanning = false;
      });
    });
  }

  void connectToDevice(BluetoothDevice device) {
    setState(() {
      selectedDevice = device;
    });
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BluetoothDevicePage(device: selectedDevice),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan Bluetooth Devices'),
      ),
      body: Column(
        children: [
          isScanning
              ? LinearProgressIndicator()
              : ElevatedButton(
                  onPressed: startScan,
                  child: Text('Rescan'),
                ),
          Expanded(
            child: ListView.builder(
              itemCount: devicesList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(devicesList[index].name.isNotEmpty
                      ? devicesList[index].name
                      : 'Unknown Device'),
                  subtitle: Text(devicesList[index].id.toString()),
                  onTap: () => connectToDevice(devicesList[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
