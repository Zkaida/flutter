import 'package:flutter_foodstore/resource/model/customer_model.dart';
class RatingModel {
  final int? id;
  final int? rating;
  final String? review;
  final DateTime? createdAt;
  final CustomerModel? customer;
  RatingModel({this.id, this.rating, this.review, this.createdAt, this.customer});
  factory RatingModel.fromMap(Map<String, dynamic> json) => RatingModel(
    id: json["id"],
    rating: json["rating"] is int ? json["rating"] : int.tryParse(json["rating"]?.toString() ?? '0'),
    review: json["review"],
    createdAt: json["created_at"] == null ? null : DateTime.tryParse(json["created_at"].toString()),
    customer: json["customer"] == null ? null : CustomerModel.fromMap(json["customer"]),
  );
}
