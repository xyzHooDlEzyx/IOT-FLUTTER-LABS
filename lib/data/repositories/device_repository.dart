import 'package:my_project/domain/models/device_item.dart';

abstract class DeviceRepository {
  Future<List<DeviceItem>> getDevices();
  Future<void> saveDevices(List<DeviceItem> devices);
}
