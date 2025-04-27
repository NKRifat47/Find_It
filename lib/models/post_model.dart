import 'dart:convert';

class PostModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<String> base64Images;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.base64Images,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId,
      "title": title,
      "description": description,
      "base64Images": base64Images,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map) {
    return PostModel(
      id: map["id"] ?? '',
      userId: map["userId"] ?? '',
      title: map["title"] ?? '',
      description: map["description"] ?? '',
      base64Images: List<String>.from(map["base64Images"] ?? []),
      createdAt: DateTime.tryParse(map["createdAt"] ?? '') ?? DateTime.now(),
    );
  }
}
