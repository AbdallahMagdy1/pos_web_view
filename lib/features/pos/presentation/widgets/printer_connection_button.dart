import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/features/pos/domain/enitity/print_data.dart';
import 'package:pos/features/pos/presentation/bloc/pos_bloc.dart';

class PrinterConnectionButton extends StatelessWidget {
  const PrinterConnectionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PosBloc, PosState>(
      builder: (context, state) {
        return IconButton(
          icon: Icon(
            state is PrinterConnected ? Icons.print : Icons.print_disabled,
            color: state is PrinterConnected ? Colors.green : Colors.red,
          ),
          onPressed: () => _showPrinterDialog(context),
        );
      },
    );
  }

  void _showPrinterDialog(BuildContext context) {
    final bloc = context.read<PosBloc>();
    showDialog(
      context: context,
      builder: (context) {
        return BlocProvider.value(
          value: bloc,
          child: AlertDialog(
            title: const Text('Printer Connection'),
            content: BlocBuilder<PosBloc, PosState>(
              builder: (context, state) {
                if (state is PrinterConnecting || state is PrintingInProgress) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state is PrinterConnected
                          ? 'Printer is connected to 192.168.1.190'
                          : 'Printer is disconnected',
                    ),
                    const SizedBox(height: 20),
                    if (state is PrinterConnected)
                      ElevatedButton(
                        onPressed: () => _printTestReceipt(context),
                        child: const Text('Print Test Receipt'),
                      ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              if (bloc.state is! PrinterConnected)
                TextButton(
                  onPressed: () => bloc.add(
                    ConnectPrinterEvent(ip: '192.168.1.190', port: 9100),
                  ),
                  child: const Text('Connect'),
                ),
            ],
          ),
        );
      },
    );
  }

  void _printTestReceipt(BuildContext context) {
    final printData = PrintData(
      placeName: 'Concha Hotel',
      items: const [
        PrintItem(name: 'wowwowo', quantity: 1, price: 25.99),
        PrintItem(name: 'wopopop', quantity: 2, price: 8.50),
      ],
      total: 42.99,
    );
    context.read<PosBloc>().add(PrintReceiptEvent(printData));
  }
}
