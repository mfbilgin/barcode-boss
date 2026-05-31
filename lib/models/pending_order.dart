/// Toptancıya verilen ama henüz depoya inmemiş sipariş (GDD §3.5).
///
/// `placedShiftNumber`'dan sonraki vardiya başında otomatik teslim edilir
/// (warehouse += quantity). B-Coin sipariş anında düşülür.
class PendingOrder {
  const PendingOrder({
    required this.productId,
    required this.quantity,
    required this.placedShiftNumber,
    required this.costPaidKurus,
  });

  final String productId;
  final int quantity;
  final int placedShiftNumber;
  final int costPaidKurus;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'placedShiftNumber': placedShiftNumber,
    'costPaidKurus': costPaidKurus,
  };

  factory PendingOrder.fromJson(Map json) {
    return PendingOrder(
      productId: json['productId'] as String,
      quantity: json['quantity'] as int,
      placedShiftNumber: json['placedShiftNumber'] as int,
      costPaidKurus: json['costPaidKurus'] as int,
    );
  }
}
