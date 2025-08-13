import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/features/pos/data/data_sources/failure.dart';
import 'package:pos/features/pos/data/data_sources/printer_local_data_source.dart';
import 'package:pos/features/pos/data/repo/pos_repo.dart';
import 'package:pos/features/pos/domain/enitity/print_data.dart';

abstract class PosEvent extends Equatable {
  const PosEvent();

  @override
  List<Object> get props => [];
}

class ConnectPrinterEvent extends PosEvent {
  final String ip;
  final int port;
  const ConnectPrinterEvent({required this.ip, required this.port});
}

class PrintReceiptEvent extends PosEvent {
  final PrintData printData;
  const PrintReceiptEvent(this.printData);
}

class CheckConnectionEvent extends PosEvent {}

abstract class PosState extends Equatable {
  const PosState();

  @override
  List<Object> get props => [];
}

class PosInitial extends PosState {}

class PrinterConnecting extends PosState {}

class PrinterConnected extends PosState {}

class PrinterDisconnected extends PosState {}

class PrintingInProgress extends PosState {}

class PrintingSuccess extends PosState {}

class PrintingError extends PosState {
  final String message;
  const PrintingError(this.message);
}

class PosBloc extends Bloc<PosEvent, PosState> {
  final PosRepository repository;
  final PrinterLocalDataSource localDataSource;

  PosBloc({required this.repository, required this.localDataSource})
    : super(PosInitial()) {
    on<ConnectPrinterEvent>(_onConnectPrinter);
    on<PrintReceiptEvent>(_onPrintReceipt);
    on<CheckConnectionEvent>(_onCheckConnection);
  }

  Future<void> _onConnectPrinter(
    ConnectPrinterEvent event,
    Emitter<PosState> emit,
  ) async {
    emit(PrinterConnecting());
    try {
      final connected = await localDataSource.connect(
        ip: event.ip,
        port: event.port,
      );
      if (connected) {
        emit(PrinterConnected());
      } else {
        emit(PrinterDisconnected());
      }
    } catch (e) {
      emit(PrintingError('Failed to connect: ${e.toString()}'));
    }
  }

  Future<void> _onPrintReceipt(
    PrintReceiptEvent event,
    Emitter<PosState> emit,
  ) async {
    emit(PrintingInProgress());
    try {
      final result = await repository.printReceipt(event.printData);

      result.fold(
        (l) {
          emit(PrintingError('Printing failed'));
          return NetworkFailure();
        },
        (r) {
          emit(PrintingSuccess());
        },
      );
    } catch (e) {
      emit(PrintingError('Printing error: ${e.toString()}'));
    }
  }

  Future<void> _onCheckConnection(
    CheckConnectionEvent event,
    Emitter<PosState> emit,
  ) async {
    try {
      final connected = await localDataSource.checkConnection();
      emit(connected ? PrinterConnected() : PrinterDisconnected());
    } catch (e) {
      emit(PrinterDisconnected());
    }
  }
}
