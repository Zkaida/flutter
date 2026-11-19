class LocationModel {
  final int? id;
  final String? label;
  final String? provinceName;
  final String? cityName;
  final String? districtName;
  final String? subdistrictName;
  final String? zipCode;
  LocationModel({this.id, this.label, this.provinceName, this.cityName, this.districtName, this.subdistrictName, this.zipCode});
  factory LocationModel.fromMap(Map<String, dynamic> json) => LocationModel(
    id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? '0'),
    label: json["label"],
    provinceName: json["province_name"],
    cityName: json["city_name"],
    districtName: json["district_name"],
    subdistrictName: json["subdistrict_name"],
    zipCode: json["zip_code"]?.toString(),
  );
}
