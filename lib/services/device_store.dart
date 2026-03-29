import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_project/data/repositories/device_repository.dart';
import 'package:my_project/data/repositories/firestore_device_repository.dart';
import 'package:my_project/data/repositories/local_device_repository.dart';
import 'package:my_project/data/storage/shared_prefs_storage.dart';
import 'package:my_project/domain/models/device_item.dart';

class DeviceStore {
  DeviceStore(this._repository);

  static final DeviceStore instance = DeviceStore(
    FirestoreDeviceRepository(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instanceFor(
        app: Firebase.app(),
        databaseId: 'data-db-mob',
      ),
      local: LocalDeviceRepository(SharedPrefsStorage()),
    ),
  );

  final DeviceRepository _repository;

  Future<List<DeviceItem>> getDevices() async {
    return _repository.getDevices();
  }

  Future<void> saveDevices(List<DeviceItem> devices) async {
    await _repository.saveDevices(devices);
  }
}
