import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pos/features/pos/presentation/pages/page_web_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestBluetoothPermissions();
  runApp(const MyApp());
}

Future<void> _requestBluetoothPermissions() async {
  await Permission.bluetooth.request();
  await Permission.bluetoothConnect.request();
  await Permission.bluetoothScan.request();
  await Permission.location.request();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Concha Hotel POS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PosWebViewPage(),
    );
  }
}
