import 'package:flutter_foodstore/resource/model/product_model.dart';
class OrderModel {
  final int? id;
  final String? provinceName;
  final String? cityName;
  final String? districtName;
  final String? subdistrictName;
  final String? zipCode;
  final String? fullAddress;
  final String? invoice;
  final int? weight;
  final String? total;
  final String? status;
  final String? snapToken;
  final ShippingModel? shipping;
  final List<TransactionDetailModel>? transactionDetails;
  final DateTime? createdAt;

  OrderModel({
    this.id, this.provinceName, this.cityName, this.districtName, this.subdistrictName,
    this.zipCode, this.fullAddress, this.invoice, this.weight, this.total,
    this.status, this.snapToken, this.shipping, this.transactionDetails, this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> json) => OrderModel(
    id: json["id"],
    provinceName: json["province_name"],
    cityName: json["city_name"],
    districtName: json["district_name"],
    subdistrictName: json["subdistrict_name"],
    zipCode: json["zip_code"]?.toString(),
    fullAddress: json["full_address"],
    invoice: json["invoice"],
    weight: json["weight"] is int ? json["weight"] : int.tryParse(json["weight"]?.toString() ?? '0'),
    total: json["total"]?.toString(),
    status: json["status"],
    snapToken: json["snap_token"],
    shipping: json["shipping"] == null ? null : ShippingModel.fromMap(json["shipping"]),
    transactionDetails: json["transaction_details"] == null ? [] : List<TransactionDetailModel>.from(
      (json["transaction_details"] as List).map((x) => TransactionDetailModel.fromMap(x)),
    ),
    createdAt: json["created_at"] == null ? null : DateTime.tryParse(json["created_at"].toString()),
  );
}
class ShippingModel {
  final String? shippingCourier;
  final String? shippingService;
  final String? shippingCost;
  ShippingModel({this.shippingCourier, this.shippingService, this.shippingCost});
  factory ShippingModel.fromMap(Map<String, dynamic> json) => ShippingModel(
    shippingCourier: json["shipping_courier"],
    shippingService: json["shipping_service"],
    shippingCost: json["shipping_cost"]?.toString(),
  );
}
class TransactionDetailModel {
  final int? id;
  final int? productId;
  final int? qty;
  final String? price;
  final ProductModel? product;
  TransactionDetailModel({this.id, this.productId, this.qty, this.price, this.product});
  factory TransactionDetailModel.fromMap(Map<String, dynamic> json) => TransactionDetailModel(
    id: json["id"],
    productId: json["product_id"],
    qty: json["qty"] is int ? json["qty"] : int.tryParse(json["qty"]?.toString() ?? '1'),
    price: json["price"]?.toString(),
    product: json["product"] == null ? null : ProductModel.fromMap(json["product"]),
  );
}
