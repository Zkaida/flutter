class PagingModel<T> {
  final int? currentPage;
  final List<T> data;
  final int? lastPage;
  final int? total;
  PagingModel({this.currentPage, required this.data, this.lastPage, this.total});
  factory PagingModel.fromMap(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromMapT) {
    return PagingModel<T>(
      currentPage: json["current_page"],
      data: json["data"] == null ? [] : List<T>.from((json["data"] as List).map((x) => fromMapT(x))),
      lastPage: json["last_page"],
      total: json["total"],
    );
  }
}
