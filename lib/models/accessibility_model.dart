class AccessibilityModel {
  final Map<String, List<AccessibilityItem>> accessibilityData;

  AccessibilityModel({required this.accessibilityData});

  // Construtor para criar a partir de um JSON
  factory AccessibilityModel.fromJson(Map<String, dynamic> json) {
    return AccessibilityModel(
      accessibilityData: json.map((key, value) => MapEntry(
        key,
        (value as List).map((item) => AccessibilityItem.fromJson(item)).toList(),
      )),
    );
  }

  // Converte para JSON
  Map<String, dynamic> toJson() => accessibilityData.map((key, items) => MapEntry(
        key,
        items.map((item) => item.toJson()).toList(),
      ));
}

class AccessibilityItem {
  final String type;
  final bool status;

  AccessibilityItem({required this.type, required this.status});

  // Construtor para criar a partir de um JSON
  factory AccessibilityItem.fromJson(Map<String, dynamic> json) {
    return AccessibilityItem(
      type: json['tipo'] as String,
      status: json['status'] as bool,
    );
  }

  // Converte para JSON
  Map<String, dynamic> toJson() => {
        'tipo': type,
        'status': status,
      };
}
