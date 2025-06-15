import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'editarEjercicio.dart';

class HistorialScreen extends StatefulWidget {

  const HistorialScreen({super.key});

  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  String selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  List<Map<String, dynamic>> _datos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final datos = await DatabaseHelper.instance.getEjerciciosPorFecha(
      selectedDate,
    );
    setState(() {
      _datos = datos;
    });
  }

  @override
  Widget build(BuildContext context) {

    // 1️⃣ Agrupar los datos por "musculo-ejercicio"
    Map<String, Map<String,List<Map<String, dynamic>>>> datosAgrupados = {};

    for (var registro in _datos) {
      String musculo = registro['musculo'];
      String ejercicio = registro['nombre'];

      if (!datosAgrupados.containsKey(musculo)) {
        datosAgrupados[musculo] = {};
      }
      if (!datosAgrupados[musculo]!.containsKey(ejercicio)) {
        datosAgrupados[musculo]![ejercicio] = [];
      }

      datosAgrupados[musculo]![ejercicio]!.add(registro);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('ENTRENAMIENTOS'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 5),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = DateFormat(
                          'yyyy-MM-dd',
                        ).format(pickedDate);
                      });
                      _cargarDatos();
                    }
                  },
                  child: Text('FECHA'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Center(
                    child: Text(
                      selectedDate ?? 'Seleccione una fecha',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 120),
              ],
            ),
          ),
          SizedBox(height: 20),
          if (_datos.isEmpty)
            const Center(child:
            Text('NO HAY DATOS GUARDADOS'))
          else
            Expanded(
              child: ListView.builder(
                itemCount: datosAgrupados.length,
                itemBuilder: (context, index) {
                  String musculo = datosAgrupados.keys.elementAt(index);
                  Map<String, List<Map<String, dynamic>>> ejercicios = datosAgrupados[musculo]!;

                  return Card(
                    color: Colors.grey[900],
                    margin: EdgeInsets.all(8.0),
                    child: ExpansionTile(
                      title: Text(musculo, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      children: ejercicios.keys.map((ejercicio) {
                        List<Map<String, dynamic>> registros = ejercicios[ejercicio]!;
                        return Card(
                          color: Colors.grey[900],
                          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ExpansionTile(
                            title: Text(ejercicio, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            children: registros.map((registro) {
                              return ListTile(
                                title: Text('Reps: ${registro['repeticiones']} - Peso: ${registro['peso']} Kgs'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit, color: Colors.white),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EditarEntrenoScreen(
                                              registro: registro,
                                              onUpdate: () async {
                                                await _cargarDatos();
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Colors.red),
                                      onPressed: () async {
                                        await _eliminarRegistro(registro['id']);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _eliminarRegistro(int id) async {
    bool confirmacion = await _mostrarDialogoConfirmacion();
    if (confirmacion) {
      await DatabaseHelper.instance.deleteEntreno(id);
      _cargarDatos();
    }
  }

  Future<bool> _mostrarDialogoConfirmacion() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirmar eliminación"),
        content: Text("¿Estás seguro de que quieres eliminar este registro?"),
        actions: [
          TextButton(
            child: Text("Cancelar"),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text("Eliminar", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ??
        false; // Devuelve false si el usuario cierra el diálogo
  }

}
