import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/features/pos/data/repo/pos_repo.dart';
import 'package:pos/features/pos/domain/enitity/print_data.dart';

abstract class PosEvent extends Equatable {
  const PosEvent();

  @override
  List<Object> get props => [];
}

class ConnectPrinterEvent extends PosEvent {}

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

  PosBloc({required this.repository}) : super(PosInitial()) {
    on<ConnectPrinterEvent>(_onConnectPrinter);
    on<PrintReceiptEvent>(_onPrintReceipt);
    on<CheckConnectionEvent>(_onCheckConnection);
  }

  Future<void> _onConnectPrinter(
    ConnectPrinterEvent event,
    Emitter<PosState> emit,
  ) async {
    emit(PrinterConnecting());
    final result = await repository.connectToPrinter();
    result.fold(
      (failure) => emit(PrinterDisconnected()),
      (connected) =>
          emit(connected ? PrinterConnected() : PrinterDisconnected()),
    );
  }

  Future<void> _onPrintReceipt(
    PrintReceiptEvent event,
    Emitter<PosState> emit,
  ) async {
    emit(PrintingInProgress());
    final result = await repository.printZPLReceipt(event.printData);
    result.fold(
      (failure) => emit(PrintingError('Printing failed')),
      (success) => emit(PrintingSuccess()),
    );
  }

  Future<void> _onCheckConnection(
    CheckConnectionEvent event,
    Emitter<PosState> emit,
  ) async {
    final result = await repository.isPrinterConnected();
    result.fold(
      (failure) => emit(PrinterDisconnected()),
      (connected) =>
          emit(connected ? PrinterConnected() : PrinterDisconnected()),
    );
  }
}
