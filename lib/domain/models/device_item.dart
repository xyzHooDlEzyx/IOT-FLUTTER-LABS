class DeviceItem {
  const DeviceItem({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
  });

  final String id;
  final String name;
  final String location;
  final String status;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'status': status,
    };
  }

  DeviceItem copyWith({
    String? name,
    String? location,
    String? status,
  }) {
    return DeviceItem(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      status: status ?? this.status,
    );
  }

  static DeviceItem? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final location = json['location'];
    final status = json['status'];

    if (id is! String ||
        name is! String ||
        location is! String ||
        status is! String) {
      return null;
    }

    return DeviceItem(
      id: id,
      name: name,
      location: location,
      status: status,
    );
  }
}
