class SliderModel {
  final int? id;
  final String? image;
  final String? link;
  SliderModel({this.id, this.image, this.link});
  factory SliderModel.fromMap(Map<String, dynamic> json) => SliderModel(id: json["id"], image: json["image"], link: json["link"]);
}
