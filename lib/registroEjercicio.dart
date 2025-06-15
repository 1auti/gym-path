import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper.dart';

class RegistrarEntrenoScreen extends StatefulWidget {
  
  final String nombreEjercicio;
  final String musculo;

  RegistrarEntrenoScreen({super.key, required this.nombreEjercicio, required this.musculo});

  @override
  _RegistrarEntrenoScreenState createState() => _RegistrarEntrenoScreenState();
}

class _RegistrarEntrenoScreenState extends State<RegistrarEntrenoScreen> {
  
  final TextEditingController _repeticionesController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  final TextEditingController _pesoExtraController = TextEditingController();
  final TextEditingController _segundosController = TextEditingController();
  final TextEditingController _observacionesController = TextEditingController();

  // Opciones para los desplegables
  final List<String> _tiposDeAgarre = ['Prono', 'Supino', 'Neutro','Estandar'];
  final List<String> _tiposDeAmplitud = ['Cerrado', 'Medio', 'Abierto'];
  final List<String> _tiposDeEquipo = ['Bodyweight','Mancuernas', 'Máquina', 'Barra', 'Polea'];

  // Valores seleccionados por defecto
  String _tipoDeAgarreSeleccionado = 'Prono';
  String _tipoDeAmplitudSeleccionado='Cerrado';
  String _tipoDeEquipoSeleccionado='Bodyweight';
  bool _esIsometrico = false; // Estado del checkbox

  Future<void> _guardarDatos() async {

    String repeticiones = _repeticionesController.text;
    String peso = _pesoController.text;
    String pesoExtra = _pesoExtraController.text;
    String segundos = _segundosController.text;
    String observaciones = _observacionesController.text;

    if ((_esIsometrico && segundos.isNotEmpty)||((repeticiones.isNotEmpty && peso.isNotEmpty) && (!_esIsometrico))||((repeticiones.isNotEmpty && pesoExtra.isNotEmpty) && (_tipoDeEquipoSeleccionado=='Bodyweight'))||(_tipoDeEquipoSeleccionado=='Bodyweight' && _esIsometrico&& pesoExtra.isNotEmpty && segundos.isNotEmpty)) {
      // Aquí luego se insertaría en la base de datos
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        int? usuarioId = prefs.getInt('userId'); // Obtener el userId de sesión
        double pesoCorrecto=peso.isNotEmpty ? double.tryParse(peso)??0.0:0.0;
        if (_tipoDeEquipoSeleccionado == "Bodyweight") {
          pesoCorrecto = await DatabaseHelper.instance.getPesoUsuario(usuarioId!) ?? 0.0; // Si no hay datos, usa 0.0
        }

        await DatabaseHelper.instance.insertarEjercicio(
            widget.nombreEjercicio,
            _esIsometrico ? 0 :int.tryParse(repeticiones)??0,
            pesoCorrecto,
            widget.musculo,
            _tipoDeAgarreSeleccionado,
            _tipoDeEquipoSeleccionado,
            _esIsometrico ? int.tryParse(segundos) ?? 0 : 0,// Si no es isométrico, tiempo = 0
            _esIsometrico ? 0 : double.tryParse(pesoExtra)?? 0,// Si es isométrico, peso = 0
            _esIsometrico ? 1 : 0,
            _tipoDeAmplitudSeleccionado,
            observaciones,
            usuarioId// Guarda si es isométrico como 1 o 0
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('REGISTRO DE EJERCICIO GUARDADO')),
        );
        Navigator.pop(context);
      }catch(e) {
        print('ERROR AL GUARDAR EN LA BASE DE DATOS: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ERROR AL GUARDAR EN LA BASE DE DATOS: $e')),
        );
      }
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('COMPLETA TODOS LOS CAMPOS')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: Text('${widget.nombreEjercicio}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:SingleChildScrollView(
          child:Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  TextField(
                    controller: _repeticionesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Repeticiones'),
                    enabled: !_esIsometrico,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _pesoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Peso (kg)'),
                    enabled: !((_tipoDeEquipoSeleccionado=='Bodyweight')||_esIsometrico)  ,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _pesoExtraController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Peso Extra(kg)'),
                    enabled: (_tipoDeEquipoSeleccionado=='Bodyweight') || _esIsometrico ,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _segundosController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Tiempo (segundos)'),
                    enabled: _esIsometrico, // Se activa solo si es isométrico
                  ),
                  // Checkbox para definir si es isométrico
                  Row(
                    children: [
                      Checkbox(
                        value: _esIsometrico,
                        onChanged: (valor) {
                          setState(() {
                            _esIsometrico = valor!;
                          });
                        },
                      ),
                      const Text('Isométrico'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Desplegable Tipo de Agarre
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Tipo de Agarre'),
                    value: _tipoDeAgarreSeleccionado,
                    items: _tiposDeAgarre.map((tipo) {
                      return DropdownMenuItem<String>(
                        value: tipo,
                        child: Text(tipo),
                      );
                    }).toList(),
                    onChanged: (valor) {
                      setState(() {
                        _tipoDeAgarreSeleccionado = valor!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  // Desplegable Tipo de Agarre
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Amplitud'),
                    value: _tipoDeAmplitudSeleccionado,
                    items: _tiposDeAmplitud.map((tipo) {
                      return DropdownMenuItem<String>(
                        value: tipo,
                        child: Text(tipo),
                      );
                    }).toList(),
                    onChanged: (valor) {
                      setState(() {
                        _tipoDeAmplitudSeleccionado = valor!;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  // Desplegable Tipo de Equipo
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Tipo de Equipo'),
                    value: _tipoDeEquipoSeleccionado,
                    items: _tiposDeEquipo.map((tipo) {
                      return DropdownMenuItem<String>(
                        value: tipo,
                        child: Text(tipo),
                      );
                    }).toList(),
                    onChanged: (valor) {
                      setState(() {
                        _tipoDeEquipoSeleccionado = valor!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _observacionesController,
                    maxLines: 5,
                    decoration: InputDecoration(
                        labelText: 'Observaciones',
                    border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _guardarDatos,
                    child: const Text('GUARDAR'),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}
