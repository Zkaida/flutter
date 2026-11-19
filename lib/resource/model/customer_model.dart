import 'dart:convert';
class CustomerModel {
  final int? id;
  final String? image;
  final String? name;
  final String? email;
  CustomerModel({this.id, this.image, this.name, this.email});
  factory CustomerModel.fromJson(String str) => CustomerModel.fromMap(json.decode(str));
  factory CustomerModel.fromMap(Map<String, dynamic> json) => CustomerModel(
    id: json["id"], image: json["image"], name: json["name"], email: json["email"],
  );
  Map<String, dynamic> toMap() => {"id": id, "image": image, "name": name, "email": email};
}
