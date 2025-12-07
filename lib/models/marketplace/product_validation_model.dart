class ProductValidation {
  final String id;
  final String productName;
  final String sellerName;
  final String category;
  final String imageUrl;
  final String timeUploaded;
  final String cvResult;
  final double cvConfidence;
  final String status;
  final String description;

  const ProductValidation({
    required this.id,
    required this.productName,
    required this.sellerName,
    required this.category,
    required this.imageUrl,
    required this.timeUploaded,
    required this.cvResult,
    required this.cvConfidence,
    required this.status,
    this.description = '',
  });

  ProductValidation copyWith({String? status}) {
    return ProductValidation(
      id: id,
      productName: productName,
      sellerName: sellerName,
      category: category,
      imageUrl: imageUrl,
      timeUploaded: timeUploaded,
      cvResult: cvResult,
      cvConfidence: cvConfidence,
      status: status ?? this.status,
      description: description,
    );
  }
}
