class ReviewModel {
  final String userName;
  final String comment;
  final int rating;
  final DateTime date;
  String? sellerReply;

  ReviewModel({
    required this.userName,
    required this.comment,
    required this.rating,
    required this.date,
    this.sellerReply,
  });
}
List<ReviewModel> dummyReviews = [
  ReviewModel(
    userName: "Ahmad",
    comment: "Barangnya segar, pengiriman cepat!",
    rating: 5,
    date: DateTime(2025, 11, 20),
    sellerReply: "Terima kasih, ditunggu order selanjutnya 😊",
  ),
  ReviewModel(
    userName: "Siti",
    comment: "Sayuran bagus tapi packing kurang rapi.",
    rating: 4,
    date: DateTime(2025, 11, 22),
  ),

  ReviewModel(
    userName: "Budi",
    comment: "Harga terjangkau dan kualitas oke.",
    rating: 5,
    date: DateTime(2025, 11, 25),
    sellerReply: "Senang mendengarnya, Budi! 😊",
  ),
  ReviewModel(
    userName: "Dewi",
    comment: "Pengiriman lama, tapi barang sesuai deskripsi.",
    rating: 3,
    date: DateTime(2025, 11, 28),
  ),
];