// lib/models/room_model.dart
class RoomModel {
  final String id;
  final String name;
  final String status;

  RoomModel({
    required this.id,
    required this.name,
    required this.status,
  });

  factory RoomModel.fromMap(String id, Map<String, dynamic> data) {
    return RoomModel(
      id: id,
      name: data['name'] ?? '',
      status: data['status'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'status': status,
    };
  }
}