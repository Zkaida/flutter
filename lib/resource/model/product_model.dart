import 'package:flutter_foodstore/resource/model/category_model.dart';
import 'package:flutter_foodstore/resource/model/rating_model.dart';
class ProductModel {
  final int? id;
  final int? categoryId;
  final String? image;
  final String? title;
  final String? slug;
  final String? description;
  final int? price;
  final int? weight;
  final String? ratingsAvgRating;
  final CategoryModel? category;
  final List<RatingModel>? ratings;
  ProductModel({this.id, this.categoryId, this.image, this.title, this.slug, this.description, this.price, this.weight, this.ratingsAvgRating, this.category, this.ratings});
  factory ProductModel.fromMap(Map<String, dynamic> json) => ProductModel(
    id: json["id"],
    categoryId: json["category_id"],
    image: json["image"],
    title: json["title"],
    slug: json["slug"],
    description: json["description"],
    price: json["price"] is int ? json["price"] : int.tryParse(json["price"]?.toString() ?? '0'),
    weight: json["weight"] is int ? json["weight"] : int.tryParse(json["weight"]?.toString() ?? '0'),
    ratingsAvgRating: json["ratings_avg_rating"]?.toString(),
    category: json["category"] == null ? null : CategoryModel.fromMap(json["category"]),
    ratings: json["ratings"] == null ? [] : List<RatingModel>.from((json["ratings"] as List).map((x) => RatingModel.fromMap(x))),
  );
  Map<String, dynamic> toMap() => {"id": id, "title": title, "slug": slug, "price": price, "image": image};
}
