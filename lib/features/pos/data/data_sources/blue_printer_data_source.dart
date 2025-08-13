import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:pos/features/pos/data/data_sources/failure.dart';
import 'package:pos/features/pos/data/data_sources/printer_local_data_source.dart';

class BluetoothPrinterDataSource implements PrinterLocalDataSource {
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;
  BluetoothDevice? _connectedDevice;

  @override
  Future<bool> connect() async {
    try {
      final devices = await _printer.getBondedDevices();
      if (devices.isEmpty) {
        throw PrinterConnectionFailure('No Bluetooth printers found');
      }

      _connectedDevice = devices.first;
      final connected = await _printer.connect(_connectedDevice!);

      if (!connected) {
        throw PrinterConnectionFailure('Failed to connect to printer');
      }

      return true;
    } catch (e) {
      throw PrinterConnectionFailure(e.toString());
    }
  }

  @override
  Future<bool> printZPL(String zplCode) async {
    try {
      if (_connectedDevice == null || !(await checkConnection())) {
        throw PrinterConnectionFailure('Printer not connected');
      }

      await _printer.writeBytes(
        Uint8List.fromList(_convertZPLToBytes(zplCode)),
      );
      return true;
    } catch (e) {
      throw PrintFailure(e.toString());
    }
  }

  @override
  Future<bool> checkConnection() async {
    try {
      return await _printer.isConnected ?? false;
    } catch (e) {
      throw PrinterConnectionFailure(e.toString());
    }
  }

  List<int> _convertZPLToBytes(String zpl) {
    return zpl.codeUnits;
  }
}
