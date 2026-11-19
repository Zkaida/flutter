import 'package:flutter_foodstore/resource/model/customer_model.dart';
class AuthResponseModel {
  final bool? success;
  final CustomerModel? customer;
  final String? token;
  AuthResponseModel({this.success, this.customer, this.token});
  factory AuthResponseModel.fromMap(Map<String, dynamic> json) => AuthResponseModel(
    success: json["success"],
    customer: json["customer"] == null ? null : CustomerModel.fromMap(json["customer"]),
    token: json["token"],
  );
}
