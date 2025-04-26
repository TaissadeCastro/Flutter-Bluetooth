import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController extends GetxController {
  var isScanning = false.obs;

  Future<void> scanDevices() async {
    // Solicita permissões
    await _requestPermissions();

    try {
      isScanning.value = true;
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    } catch (e) {
      print("Erro ao iniciar scan: $e");
    } finally {
      isScanning.value = false;
    }
  }

  Future<void> _requestPermissions() async {
    final statuses =
        await [
          Permission.bluetooth,
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
          Permission.locationWhenInUse,
        ].request();

    if (statuses.values.any((status) => status.isDenied)) {
      Get.snackbar(
        "Permissões",
        "Permissões Bluetooth/localização são necessárias.",
      );
    }
  }

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
}
