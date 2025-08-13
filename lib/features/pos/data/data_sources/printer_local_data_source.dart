abstract class PrinterLocalDataSource {
  Future<bool> connect();
  Future<bool> printZPL(String zplCode);
  Future<bool> checkConnection();
}
