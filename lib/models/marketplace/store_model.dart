class StoreModel {
  String name;
  String description;
  String phone;
  String address;
  final String? imageUrl;

  StoreModel({
    required this.name,
    required this.description,
    required this.phone,
    required this.address,
    this.imageUrl,
  });
}
