import 'package:flutter_foodstore/resource/model/product_model.dart';
class CategoryModel {
  final int? id;
  final String? image;
  final String? name;
  final String? slug;
  final List<ProductModel>? products;
  CategoryModel({this.id, this.image, this.name, this.slug, this.products});
  factory CategoryModel.fromMap(Map<String, dynamic> json) => CategoryModel(
    id: json["id"],
    image: json["image"],
    name: json["name"],
    slug: json["slug"],
    products: json["products"] == null ? [] : List<ProductModel>.from((json["products"] as List).map((x) => ProductModel.fromMap(x))),
  );
  Map<String, dynamic> toMap() => {"id": id, "image": image, "name": name, "slug": slug};
}
