import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:bluetooth/controllers/bluetoothController.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  final BluetoothController controller = Get.put(BluetoothController());

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Bluetooth App"),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Dispositivos"),
              Tab(text: "Características"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [_buildDispositivosTab(), _buildCaracteristicasTab()],
        ),

        //Botão de desconectar, exibido sempre que a conexão for sucesso;
        floatingActionButton:
            controller.connectedDevice.value != null
                ? FloatingActionButton(
                  onPressed: () async {
                    await controller.connectedDevice.value?.disconnect();
                    controller.connectedDevice.value = null;
                    controller.services.clear();
                    Get.snackbar(
                      "Desconectado",
                      "Dispositivo foi desconectado.",
                    );
                  },
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.bluetooth_disabled),
                  tooltip: "Desconectar",
                )
                : null,
      );
    });
  }

  Widget _buildDispositivosTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed:
                controller.isScanning.value
                    ? null
                    : () => controller.scanDevices(),
            child:
                controller.isScanning.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Buscar Dispositivos"),
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
                        onTap: () => controller.connectToDevice(data.device),
                      ),
                    );
                  },
                );
              } else if (controller.isScanning.value) {
                return const Center(child: Text("Buscando dispositivos..."));
              } else {
                return const Center(
                  child: Text("Nenhum dispositivo encontrado."),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCaracteristicasTab() {
    return controller.connectedDevice.value == null
        ? const Center(
          child: Text(
            "Conecte-se a um dispositivo para ver as características.",
          ),
        )
        : ListView.builder(
          itemCount: controller.services.length,
          itemBuilder: (context, index) {
            final service = controller.services[index];
            return ExpansionTile(
              title: Text(service.uuid.toString()),
              children:
                  service.characteristics
                      .map(
                        (char) => ListTile(
                          title: Text(char.uuid.toString()),
                          subtitle: Text(char.properties.toString()),
                          onTap: () {
                            _showCharacteristicDialog(char);
                          },
                        ),
                      )
                      .toList(),
            );
          },
        );
  }

  void _showCharacteristicDialog(BluetoothCharacteristic characteristic) {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Característica"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Digite o valor"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () async {
                await characteristic.write(
                  List<int>.from(controller.text.codeUnits),
                  withoutResponse: true,
                );
                Get.snackbar("Sucesso", "Valor escrito com sucesso.");
                Navigator.pop(context);
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }
}
