import 'package:dartz/dartz.dart';
import 'package:pos/features/pos/data/data_sources/failure.dart';
import 'package:pos/features/pos/data/data_sources/printer_local_data_source.dart';
import 'package:pos/features/pos/data/repo/pos_repo.dart';
import 'package:pos/features/pos/domain/enitity/print_data.dart';

class PosRepositoryImpl implements PosRepository {
  final PrinterLocalDataSource localDataSource;

  PosRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, bool>> connectToPrinter() async {
    try {
      final result = await localDataSource.connect();
      return Right(result);
    } catch (e) {
      return Left(NetworkFailure());
    }
  }

  @override
  Future<Either<Failure, bool>> printZPLReceipt(PrintData printData) async {
    try {
      final zplCode = _generateZPL(printData);
      final result = await localDataSource.printZPL(zplCode);
      return Right(result);
    } catch (e) {
      return Left(PrintFailure());
    }
  }

  String _generateZPL(PrintData data) {
    // Simple ZPL generation
    final items = data.items
        .map((item) => '${item.name} x${item.quantity} \$${item.price}')
        .join('\n');

    return '''
^XA
^FO50,50^A0N,50,50^FD${data.placeName}^FS
^FO50,120^A0N,30,30^FD${DateTime.now().toString()}^FS
^FO50,180^A0N,30,30^FD${items}^FS
^FO50,400^A0N,40,40^FDTotal: \$${data.total}^FS
^XZ
''';
  }

  @override
  Future<Either<Failure, bool>> isPrinterConnected() async {
    try {
      final result = await localDataSource.checkConnection();
      return Right(result);
    } catch (e) {
      return Left(NetworkFailure());
    }
  }
}
