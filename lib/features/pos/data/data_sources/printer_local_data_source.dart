import 'package:pos/features/pos/domain/enitity/print_data.dart';

abstract class PrinterLocalDataSource {
  Future<bool> connect({String? ip, int? port});
  Future<bool> printReceipt(PrintData printData);
  Future<bool> checkConnection();
  Future<void> disconnect();
}
