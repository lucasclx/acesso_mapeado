class CompanyModel {
  String name;
  double latitude;
  double longitude;
  String endereco;
  String? fotoBase64;

  CompanyModel(
      {required this.name,
      required this.latitude,
      required this.longitude,
      required this.endereco,
      this.fotoBase64});

  //fromJson
  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
        name: json['name'],
        latitude: json['latitude'],
        longitude: json['longitude'],
        endereco: json['endereco'],
        fotoBase64: json['fotoBase64'],
      );

  //toJson
  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'endereco': endereco,
        'fotoBase64': fotoBase64,
      };
}
