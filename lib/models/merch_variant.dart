class MerchVariant {
  final String id;
  final String skuId;
  final String size;
  final String? color;
  final int stock;

  MerchVariant({
    required this.id,
    required this.skuId,
    required this.size,
    this.color,
    required this.stock,
  });

  factory MerchVariant.fromJson(Map<String, dynamic> json) {
    return MerchVariant(
      id: json['id'],
      skuId: json['sku_id'],
      size: json['size'],
      color: json['color'],
      stock: json['stock'],
    );
  }
}