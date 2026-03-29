class DeviceItem {
  const DeviceItem({
    required this.id,
    required this.name,
    required this.location,
    required this.status,
    required this.mqttUrl,
    required this.topic,
    this.lastPayload = '',
  });

  final String id;
  final String name;
  final String location;
  final String status;
  final String mqttUrl;
  final String topic;
  final String lastPayload;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'status': status,
      'mqttUrl': mqttUrl,
      'topic': topic,
      'lastPayload': lastPayload,
    };
  }

  DeviceItem copyWith({
    String? name,
    String? location,
    String? status,
    String? mqttUrl,
    String? topic,
    String? lastPayload,
  }) {
    return DeviceItem(
      id: id,
      name: name ?? this.name,
      location: location ?? this.location,
      status: status ?? this.status,
      mqttUrl: mqttUrl ?? this.mqttUrl,
      topic: topic ?? this.topic,
      lastPayload: lastPayload ?? this.lastPayload,
    );
  }

  static DeviceItem? fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final location = json['location'];
    final status = json['status'];
    final mqttUrl = json['mqttUrl'];
    final topic = json['topic'];
    final lastPayload = json['lastPayload'];

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
      mqttUrl: mqttUrl is String ? mqttUrl : '',
      topic: topic is String ? topic : '',
      lastPayload: lastPayload is String ? lastPayload : '',
    );
  }
}
