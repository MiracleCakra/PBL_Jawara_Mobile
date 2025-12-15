class KegiatanImageModel {
  final int? id;
  final int idKegiatan;
  final String img;

  KegiatanImageModel({
    this.id,
    required this.idKegiatan,
    required this.img,
  });

  factory KegiatanImageModel.fromMap(Map<String, dynamic> map) {
    return KegiatanImageModel(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id'].toString()),
      idKegiatan: map['id_kegiatan'] is int 
          ? map['id_kegiatan'] 
          : int.tryParse(map['id_kegiatan'].toString()) ?? 0,
      img: map['img']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'id_kegiatan': idKegiatan,
      'img': img,
    };
  }
}
