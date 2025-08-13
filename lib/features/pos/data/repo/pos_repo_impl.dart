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
      final result = await localDataSource.connect(
        ip: '192.168.1.190',
        port: 9100,
      );
      return Right(result);
    } catch (e) {
      return Left(PrinterConnectionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> printReceipt(PrintData printData) async {
    // Changed from printZPLReceipt
    try {
      final result = await localDataSource.printReceipt(printData);
      return Right(result);
    } catch (e) {
      return Left(PrintFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isPrinterConnected() async {
    try {
      final result = await localDataSource.checkConnection();
      return Right(result);
    } catch (e) {
      return Left(PrinterConnectionFailure(e.toString()));
    }
  }
}
