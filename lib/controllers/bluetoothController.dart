import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothController extends GetxController {
  var isScanning = false.obs;
  var connectedDevice = Rx<BluetoothDevice?>(null);
  var services = <BluetoothService>[].obs;

  Future<void> scanDevices() async {
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

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await FlutterBluePlus.stopScan();

      if (await device.connectionState.first ==
          BluetoothConnectionState.disconnected) {
        await device.connect(timeout: const Duration(seconds: 10));
      }

      connectedDevice.value = device;

      device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.connected) {
          print("Aparelho conectado: ${device.advName}");
          Get.snackbar(
            "Conectado",
            "Dispositivo ${device.advName} conectado com sucesso!",
          );
        } else if (state == BluetoothConnectionState.disconnected) {
          print("Aparelho desconectado!");
          Get.snackbar("Desconectado", "Dispositivo desconectado.");
          connectedDevice.value = null;
          services.clear();
        }
      });

      List<BluetoothService> discoveredServices =
          await device.discoverServices();
      services.value = discoveredServices;
    } catch (e) {
      print("Erro ao conectar ou descobrir serviços: $e");
      Get.snackbar("Erro", "Erro ao conectar: $e");
    }
  }

  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;
}
