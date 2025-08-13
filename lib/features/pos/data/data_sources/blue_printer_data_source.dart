import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:pos/features/pos/data/data_sources/failure.dart';
import 'package:pos/features/pos/data/data_sources/network_printer.dart';
import 'package:pos/features/pos/data/data_sources/printer_local_data_source.dart';
import 'package:pos/features/pos/domain/enitity/print_data.dart';

class NetworkPrinterDataSource implements PrinterLocalDataSource {
  final NetworkPrinter _printer = NetworkPrinter();
  String? _printerIp;
  int? _printerPort;

  @override
  Future<bool> connect({String? ip, int? port}) async {
    try {
      _printerIp = ip ?? '192.168.1.190';
      _printerPort = port ?? 9100;

      final connected = await _printer.connect(
        _printerIp!,
        port: _printerPort!,
      );

      if (!connected) {
        throw PrinterConnectionFailure(
          'Failed to connect to printer at $_printerIp:$_printerPort',
        );
      }

      return true;
    } catch (e) {
      throw PrinterConnectionFailure(e.toString());
    }
  }

  @override
  Future<bool> printReceipt(PrintData printData) async {
    try {
      if (!(await checkConnection())) {
        await connect(ip: _printerIp, port: _printerPort);
      }

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);

      final List<int> bytes = [];
      bytes.addAll(generator.reset());
      bytes.addAll(
        generator.text(
          printData.placeName,
          styles: PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
          ),
        ),
      );
      bytes.addAll(
        generator.text(
          DateTime.now().toString(),
          styles: PosStyles(align: PosAlign.center),
        ),
      );
      bytes.addAll(generator.hr());

      for (final item in printData.items) {
        bytes.addAll(
          generator.row([
            PosColumn(text: '${item.name} x${item.quantity}', width: 8),
            PosColumn(
              text: '\$${item.price.toStringAsFixed(2)}',
              width: 4,
              styles: PosStyles(align: PosAlign.right),
            ),
          ]),
        );
      }

      bytes.addAll(generator.hr());
      bytes.addAll(
        generator.text(
          'Total: \$${printData.total.toStringAsFixed(2)}',
          styles: PosStyles(align: PosAlign.right, bold: true),
        ),
      );
      bytes.addAll(generator.feed(2));
      bytes.addAll(generator.cut());

      await _printer.writeBytes(bytes);
      return true;
    } catch (e) {
      throw PrintFailure(e.toString());
    }
  }

  @override
  Future<bool> checkConnection() async {
    return _printer.isConnected;
  }

  @override
  Future<void> disconnect() async {
    await _printer.disconnect();
  }
}
