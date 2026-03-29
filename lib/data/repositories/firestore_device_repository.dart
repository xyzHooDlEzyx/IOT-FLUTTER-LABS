import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:my_project/data/repositories/device_repository.dart';
import 'package:my_project/data/repositories/local_device_repository.dart';
import 'package:my_project/domain/models/device_item.dart';

class FirestoreDeviceRepository implements DeviceRepository {
  FirestoreDeviceRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required LocalDeviceRepository local,
  })  : _auth = auth,
        _firestore = firestore,
        _local = local;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final LocalDeviceRepository _local;

  @override
  Future<List<DeviceItem>> getDevices() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      return _local.getDevices();
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .collection('devices')
          .get();
      final devices = snapshot.docs
          .map((doc) => _fromDoc(doc.id, doc.data()))
          .whereType<DeviceItem>()
          .toList();
      await _local.saveDevices(devices);
      return devices;
    } catch (_) {
      return _local.getDevices();
    }
  }

  @override
  Future<void> saveDevices(List<DeviceItem> devices) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      await _local.saveDevices(devices);
      return;
    }

    final batch = _firestore.batch();
    final collection = _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .collection('devices');
    for (final device in devices) {
      batch.set(collection.doc(device.id), _toDoc(device));
    }
    await batch.commit();
    await _local.saveDevices(devices);
  }

  Map<String, dynamic> _toDoc(DeviceItem device) {
    return {
      'name': device.name,
      'location': device.location,
      'status': device.status,
      'mqttUrl': device.mqttUrl,
      'topic': device.topic,
      'lastPayload': device.lastPayload,
    };
  }

  DeviceItem? _fromDoc(String id, Map<String, dynamic> data) {
    final name = data['name'];
    final location = data['location'];
    final status = data['status'];
    final mqttUrl = data['mqttUrl'];
    final topic = data['topic'];
    final lastPayload = data['lastPayload'];

    if (name is! String || location is! String || status is! String) {
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
