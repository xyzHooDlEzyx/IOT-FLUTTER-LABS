import 'package:my_project/data/repositories/device_repository.dart';
import 'package:my_project/data/repositories/local_device_repository.dart';
import 'package:my_project/data/storage/shared_prefs_storage.dart';
import 'package:my_project/domain/models/device_item.dart';

class DeviceStore {
  DeviceStore(this._repository);

  static final DeviceStore instance = DeviceStore(
    LocalDeviceRepository(SharedPrefsStorage()),
  );

  final DeviceRepository _repository;

  Future<List<DeviceItem>> getDevices() async {
    return _repository.getDevices();
  }

  Future<void> saveDevices(List<DeviceItem> devices) async {
    await _repository.saveDevices(devices);
  }
}
