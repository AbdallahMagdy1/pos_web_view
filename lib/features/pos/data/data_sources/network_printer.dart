import 'dart:io';

import 'package:pos/features/pos/data/data_sources/failure.dart';

class NetworkPrinter {
  Socket? _socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  Future<bool> connect(String ip, {int port = 9100}) async {
    try {
      _socket = await Socket.connect(
        ip,
        port,
        timeout: const Duration(seconds: 5),
      );
      _isConnected = true;
      return true;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _isConnected = false;
  }

  Future<void> writeBytes(List<int> bytes) async {
    if (!_isConnected || _socket == null) {
      throw PrinterConnectionFailure('Printer not connected');
    }
    _socket!.add(bytes);
    await _socket!.flush();
  }
}
