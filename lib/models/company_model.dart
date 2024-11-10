import 'package:acesso_mapeado/models/accessibility_model.dart';
import 'package:acesso_mapeado/models/comment_model.dart';
import 'package:uuid/uuid.dart';

class CompanyModel {
  String uuid;
  String name;
  double latitude;
  double longitude;
  String address;
  String? imageUrl;
  double? rating;
  String? phoneNumber;
  String? workingHours;
  AccessibilityModel? accessibilityData;
  List<CommentModel>? commentsData;
  List<double>? ratings;
  String cnpj;
  String? registrationDate;
  String? about;

  static const _uuid = Uuid();

  CompanyModel({
    String? uuid,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.imageUrl,
    this.rating,
    this.phoneNumber,
    this.workingHours,
    this.accessibilityData,
    this.commentsData,
    this.ratings,
    required this.cnpj,
    this.registrationDate,
    this.about,
  }) : uuid = uuid ?? _uuid.v4();

  // Método factory para criar instâncias de CompanyModel a partir de um JSON
  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      uuid: json["uuid"] ?? _uuid.v4(),
      name: json['name'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] ?? '',
      imageUrl: json['imageUrl'],
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      phoneNumber: json['phoneNumber'],
      workingHours: json['workingHours'],
      accessibilityData: json['accessibilityData'] != null &&
              json['accessibilityData'] is Map<String, dynamic> &&
              json['accessibilityData']['accessibilityData']
                  is Map<String, dynamic>
          ? AccessibilityModel.fromJson(
              json['accessibilityData']['accessibilityData'])
          : null,
      commentsData: json['commentsData'] != null && json['commentsData'] is List
          ? (json['commentsData'] as List)
              .map((item) => CommentModel.fromJson(item))
              .toList()
          : null,
      ratings: json['ratings'] != null && json['ratings'] is List
          ? (json['ratings'] as List)
              .map((item) => (item as num).toDouble())
              .toList()
          : [],
      cnpj: json['cnpj'] ?? '',
      registrationDate: json['registrationDate'],
      about: json['about'],
    );
  }

  // Método para converter instâncias de CompanyModel para JSON
  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'imageUrl': imageUrl,
        'rating': rating,
        'phoneNumber': phoneNumber,
        'workingHours': workingHours,
        'accessibilityData': accessibilityData?.toJson(),
        'commentsData':
            commentsData?.map((comment) => comment.toJson()).toList(),
        'ratings': ratings,
        'cnpj': cnpj,
        'registrationDate': registrationDate,
        'about': about,
      };
}
