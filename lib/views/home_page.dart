import 'package:flutter/material.dart';
import 'package:bluetooth/controllers/bluetoothController.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BluetoothController>(
      init: BluetoothController(),
      builder: (controller) {
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.blue,
                  child: const Center(
                    child: Text(
                      "Bluetooth App",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Obx(() {
                    return ElevatedButton(
                      onPressed:
                          controller.isScanning.value
                              ? null
                              : () => controller.scanDevices(),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(350, 55),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                      ),
                      child:
                          controller.isScanning.value
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                "Buscar",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                StreamBuilder<List<ScanResult>>(
                  stream: controller.scanResults,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final data = snapshot.data![index];
                          return Card(
                            elevation: 2,
                            child: ListTile(
                              title: Text(
                                data.device.name.isEmpty
                                    ? "Sem nome"
                                    : data.device.name,
                              ),
                              subtitle: Text(data.device.id.id),
                              trailing: Text("${data.rssi} dBm"),
                            ),
                          );
                        },
                      );
                    } else if (controller.isScanning.value) {
                      return const Center(
                        child: Text("Buscando dispositivos..."),
                      );
                    } else {
                      return const Center(
                        child: Text("Nenhum dispositivo encontrado."),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
