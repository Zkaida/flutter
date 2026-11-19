class ShippingCostModel {
  final String? name;
  final String? code;
  final String? service;
  final String? description;
  final int? cost;
  final String? etd;
  ShippingCostModel({this.name, this.code, this.service, this.description, this.cost, this.etd});
  factory ShippingCostModel.fromMap(Map<String, dynamic> json) => ShippingCostModel(
    name: json["name"],
    code: json["code"],
    service: json["service"],
    description: json["description"],
    cost: json["cost"] is int ? json["cost"] : int.tryParse(json["cost"]?.toString() ?? '0'),
    etd: json["etd"]?.toString(),
  );
}
