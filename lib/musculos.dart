import 'package:flutter/material.dart';
import 'package:coloso/ejercicios.dart';
import 'package:coloso/registroEjercicio.dart';

class PantallaMusculos extends StatelessWidget {

  final String grupo;

  PantallaMusculos({super.key, required this.grupo});

  final Map<String, List<String>> grupo_musculos = {
    'TORSO': ['ANTEBRAZO',
      'BICEPS',
      'PECTORALES',
      'ESPALDA',
      'HOMBROS',
      'TRICEPS',
      'ABDOMINALES'],
    'PIERNAS': ['PANTORRILLAS',
      'ADUCTORES',
      'GLUTEOS',
      'CUADRICEPS',
      'ISQUIOTIBIALES'],
  };


  @override
  Widget build(BuildContext context) {

    final List<String> musculos=grupo_musculos[grupo] ?? [];

    return Scaffold(
      appBar: AppBar(title: Text('MUSCULOS DE $grupo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: musculos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaEjercicios(
                    musculo:musculos[index]
                  ),
                ),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    musculos[index],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}