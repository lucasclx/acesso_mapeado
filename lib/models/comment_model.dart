class CommentModel {
  final String userName;
  final String? userImage;
  final String text;
  final String date;
  final double? rate;
  final List<String>? photos; 

  CommentModel({
    required this.userName,
    this.userImage,
    required this.text,
    required this.date,
    this.rate = 0.0,
    this.photos, 
  });

  // Método factory para criar instâcias de CommentModel a partir de um Json
  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      userName: json["userName"],
      userImage: json["userImage"],
      text: json["text"],
      date: json["date"],
      rate: (json["rate"] ?? 0.0).toDouble(),
      photos: json["photos"] as List<String>?,
    );
  }

  // Método para converter as instâncias CommentModel para um Json
  Map<String, dynamic> toJson() {
    return {
      "userName": userName,
      "userImage": userImage,
      "text": text,
      "date": date,
      "rate": rate,
      "photos": photos,
    };
  }
}
