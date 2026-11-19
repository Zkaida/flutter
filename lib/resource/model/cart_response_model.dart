import 'package:flutter_foodstore/resource/model/product_model.dart';
class CartResponseModel {
  final int? totalWeight;
  final int? totalPrice;
  final List<Cart>? carts;
  CartResponseModel({this.totalWeight, this.totalPrice, this.carts});
  factory CartResponseModel.fromMap(Map<String, dynamic> json) => CartResponseModel(
    totalWeight: json["total_weight"] is int ? json["total_weight"] : int.tryParse(json["total_weight"]?.toString() ?? '0'),
    totalPrice: json["total_price"] is int ? json["total_price"] : int.tryParse(json["total_price"]?.toString() ?? '0'),
    carts: json["carts"] == null ? [] : List<Cart>.from((json["carts"] as List).map((x) => Cart.fromMap(x))),
  );
}
class Cart {
  final int? id;
  final int? productId;
  final int? qty;
  final ProductModel? product;
  Cart({this.id, this.productId, this.qty, this.product});
  factory Cart.fromMap(Map<String, dynamic> json) => Cart(
    id: json["id"],
    productId: json["product_id"],
    qty: json["qty"] is int ? json["qty"] : int.tryParse(json["qty"]?.toString() ?? '1'),
    product: json["product"] == null ? null : ProductModel.fromMap(json["product"]),
  );
}
