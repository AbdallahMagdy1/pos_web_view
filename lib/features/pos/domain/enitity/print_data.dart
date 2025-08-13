class PrintData {
  final String placeName;
  final List<PrintItem> items;
  final double total;

  const PrintData({
    required this.placeName,
    required this.items,
    required this.total,
  });
}

class PrintItem {
  final String name;
  final int quantity;
  final double price;

  const PrintItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}
