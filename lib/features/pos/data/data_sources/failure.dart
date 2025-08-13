abstract class Failure {
  final String message;
  final int? code;

  const Failure(this.message, {this.code});

  @override
  String toString() =>
      '$runtimeType: $message${code != null ? ' (code: $code)' : ''}';
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error']) : super(message);
}

class PrintFailure extends Failure {
  const PrintFailure([String message = 'Printing error']) : super(message);
}

class PrinterConnectionFailure extends Failure {
  const PrinterConnectionFailure([String message = 'Printer connection error'])
    : super(message);
}
