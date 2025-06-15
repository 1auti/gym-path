import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_helper.dart';

class EditarEntrenoScreen extends StatefulWidget {

  final Map<String,dynamic> registro;
  final Future<void> Function()? onUpdate;

  EditarEntrenoScreen({Key? key, required this.registro, required this.onUpdate}): super(key: key);

  @override
  _EditarEntrenoScreenState createState() => _EditarEntrenoScreenState();
}


class _EditarEntrenoScreenState extends State<EditarEntrenoScreen> {

  late TextEditingController _repeticionesController;
  late TextEditingController _pesoController ;
  late TextEditingController _pesoExtraController ;
  late TextEditingController _segundosController ;
  late TextEditingController _observacionesController;

  @override
  void initState() {
    super.initState();

    _repeticionesController = TextEditingController(
      text: (widget.registro['repeticiones'] != null) ? widget.registro['repeticiones'].toString() : '0',
    );
    _pesoController = TextEditingController(
      text: (widget.registro['peso'] != null) ? widget.registro['peso'].toString() : '0',
    );
    _pesoExtraController = TextEditingController(
      text: (widget.registro['pesoExtra'] != null) ? widget.registro['pesoExtra'].toString() : '0',
    );
    _segundosController = TextEditingController(
      text: (widget.registro['segundos'] != null) ? widget.registro['segundos'].toString() : '0',
    );
    _observacionesController = TextEditingController(
      text: (widget.registro['observaciones'] != null) ? widget.registro['observaciones'].toString() : '',
    );
    _esIsometrico = widget.registro['esIsometrico']==1?true:false;
    _tipoDeAgarreSeleccionado= widget.registro['tipoAgarre']?? _tiposDeAgarre.first;
    _tipoDeAmplitudSeleccionado= widget.registro['tipoAmplitud']?? _tiposDeAmplitud.first;
    _tipoDeEquipoSeleccionado= widget.registro['tipoEquipo']?? _tiposDeEquipo.first;
    _fechaSeleccionada = widget.registro['fechaRegistro'] != null
        ? DateTime.parse(widget.registro['fechaRegistro'])
        : DateTime.now();
  }

  late bool _esIsometrico;
  late String _tipoDeAgarreSeleccionado;
  late String _tipoDeAmplitudSeleccionado;
  late String _tipoDeEquipoSeleccionado;
  DateTime? _fechaSeleccionada;
  final _formatoFecha = DateFormat('yyyy-MM-dd');

  Future<void> _seleccionarFecha(BuildContext context) async {
    DateTime? fechaEscogida = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (fechaEscogida != null && fechaEscogida != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = fechaEscogida;
      });
    }
  }


  // Opciones para los desplegables
  final List<String> _tiposDeAgarre = ['Prono', 'Supino', 'Neutro','Estandar'];
  final List<String> _tiposDeAmplitud = ['Cerrado', 'Medio', 'Abierto'];
  final List<String> _tiposDeEquipo = ['Bodyweight','Mancuernas', 'Máquina', 'Barra', 'Polea'];


  @override
  void dispose() {
    // ✅ Liberamos la memoria de los controladores
    _pesoController.dispose();
    _pesoExtraController.dispose();
    _repeticionesController.dispose();
    _segundosController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  Future<void> _modificarRegistro() async {

    String repeticiones = _repeticionesController.text;
    String peso = _pesoController.text;
    String pesoExtra = _pesoExtraController.text;
    String segundos = _segundosController.text;
    String observaciones = _observacionesController.text;

    if ((_esIsometrico && segundos.isEmpty)||((repeticiones.isEmpty || peso.isEmpty)&&!_esIsometrico)||((repeticiones.isEmpty || pesoExtra.isEmpty)&&_tipoDeEquipoSeleccionado=='Bodyweight')||(_tipoDeEquipoSeleccionado=='Bodyweight'&&_esIsometrico&(segundos.isEmpty||pesoExtra.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('COMPLETA TODOS LOS CAMPOS')),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? usuarioId = prefs.getInt('userId'); // Obtener el userId de sesión
    double pesoCorrecto=peso.isNotEmpty ? double.tryParse(peso)??0.0:0.0;
    if (_tipoDeEquipoSeleccionado == "Bodyweight") {
      pesoCorrecto = await DatabaseHelper.instance.getPesoUsuario(usuarioId!) ?? 0.0; // Si no hay datos, usa 0.0
    }

    Map<String,dynamic> nuevoRegistro = {
      'id': widget.registro['id'],  // Asegurarse de mantener el ID
      'musculo': widget.registro['musculo'],
      'nombre': widget.registro['nombre'],
      'repeticiones': int.tryParse(repeticiones) ?? 0,
      'peso': pesoCorrecto,
      'pesoExtra': double.tryParse(pesoExtra) ?? 0.0,
      'segundos': _esIsometrico ? int.tryParse(_segundosController.text) ?? 0 : 0,
      'esIsometrico': _esIsometrico ? 1 : 0,
      'tipoAgarre': _tipoDeAgarreSeleccionado,
      'tipoAmplitud': _tipoDeAmplitudSeleccionado,
      'tipoEquipo': _tipoDeEquipoSeleccionado,
      'fechaRegistro': _fechaSeleccionada?.toIso8601String(),
      'observaciones':observaciones,
      'usuario_id':widget.registro['usuario_id'],

    };

    try {
      await DatabaseHelper.instance.updateEntreno(nuevoRegistro);
      if(widget.onUpdate!=null) {
        widget.onUpdate!();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('REGISTRO DE EJERCICIO ACTUALIZADO')),
      );// Llama a la función para recargar la lista
      Navigator.pop(context);
    }catch(e) {
      print('ERROR AL ACTUALIZAR EN LA BASE DE DATOS: $e');
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ERROR AL ACTUALIZAR EN LA BASE DE DATOS: $e')),
      );
    }

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.registro['nombre']}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
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
              enabled: !((_tipoDeEquipoSeleccionado=='Bodyweight')||_esIsometrico),
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
                const Spacer(),
                TextButton(
                  onPressed: () => _seleccionarFecha(context),
                  child: Text(_formatoFecha.format(_fechaSeleccionada!)),
                ),
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
              onPressed: _modificarRegistro,
              child: const Text('ACTUALIZAR'),
            ),
          ],
        ),
      ),
    );
  }
}
