// lib/models/merch_variant.dart
class MerchVariant {
  final String id;
  final String skuId;        // este es el nombre que usas en tu base de datos
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

  /// Convierte un JSON de Supabase a un objeto MerchVariant
  factory MerchVariant.fromJson(Map<String, dynamic> json) {
    return MerchVariant(
      id: json['id'] as String,
      skuId: json['sku_id'] as String,     // ← nombre exacto de la columna en Supabase
      size: json['size'] as String,
      color: json['color'] as String?,
      stock: json['stock'] as int,
    );
  }

  /// Opcional: para debugging o mostrar en logs
  @override
  String toString() {
    return 'MerchVariant(id: $id, skuId: $skuId, size: $size, stock: $stock)';
  }
}