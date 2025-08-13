import 'package:dartz/dartz.dart';
import 'package:pos/features/pos/data/data_sources/failure.dart';
import 'package:pos/features/pos/domain/enitity/print_data.dart';

abstract class PosRepository {
  Future<Either<Failure, bool>> connectToPrinter();
  Future<Either<Failure, bool>> printReceipt(PrintData printData);
  Future<Either<Failure, bool>> isPrinterConnected();
}
