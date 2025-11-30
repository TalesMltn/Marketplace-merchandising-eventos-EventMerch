class MerchSku {
  final String id;
  final String eventId;
  final String name;
  final String? description;
  final double price;
  final int remainingStock;

  MerchSku({
    required this.id,
    required this.eventId,
    required this.name,
    this.description,
    required this.price,
    required this.remainingStock,
  });

  factory MerchSku.fromJson(Map<String, dynamic> json) {
    return MerchSku(
      id: json['id'],
      eventId: json['event_id'],
      name: json['name'],
      description: json['description'],
      price: double.parse(json['price'].toString()),
      remainingStock: json['remaining_stock'],
    );
  }
}