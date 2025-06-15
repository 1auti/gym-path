import 'package:flutter/material.dart';
import 'package:coloso/registroEjercicio.dart';

class PantallaEjercicios extends StatelessWidget {

  final String musculo;

  PantallaEjercicios({super.key,required this.musculo});

  final Map<String, List<String>> musculo_ejercicios = {
    'ANTEBRAZO': ['CURL MARTILLO'],
      'BICEPS': ['CHIN UPS','CURL BICEPS'],
      'PECTORALES': ['PUSH UPS',
        'PRESS PLANO',
        'PRESS INCLINADO',
        'PRESS DECLINADO',
        'APERTURAS PLANAS',
        'APERTURAS INCLINADAS',
        'APERTURAS DECLINADAS'],
      'ESPALDA': ['PULL UPS',
        'POLEA ALTA',
        'POLEA BAJA',
        'PULL OVER',
        'REMO T',
        'REMO HORIZONTAL'],
      'HOMBROS': ['ENCOGIMIENTOS',
        'PRESS ARNOLD',
        'PRESS MILITAR',
        'VUELOS FRONTALES',
        'VUELOS LATERALES',
        'VUELOS POSTERIORES',
        'LATERAL-FRONTAL',
        'REMO AL MENTON',],
      'TRICEPS': ['DIPS','POLEA TRICEPS'],
      'ABDOMINALES': ['ELEVACIONES ABDOMEN',
        'L-HOLD',
        'L-SIT',
        'OBLICUOS'],
    'PANTORRILLAS':['SIT CALVES',
      'UP CALVES'],
    'ADUCTORES': ['IN-OUT ADUCTOR'],
    'GLUTEOS': ['G-BULGARIAN SQUATS',
      'HIP THRUST', '1LEG-SQUATGLUTES','ZANCADAS GLUTEO'],
    'CUADRICEPS': ['SQUATS',
      'COSSACK SQUATS','LEG EXTENSION','1LEG-SQUAT','ZANCADAS','BULGARIAN SQUATS'],
    'ISQUIOTIBIALES': ['DEADLIFT',
      'ROMANIAN DEADLIFT','LEG PRESS','CURL EXTENSION']
  };


  @override
  Widget build(BuildContext context) {

    final List<String> ejercicios = musculo_ejercicios[musculo] ?? [];
    return Scaffold(
      appBar: AppBar(title: Text('EJERCICIOS PARA $musculo'),
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
        itemCount: ejercicios.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegistrarEntrenoScreen(
                    nombreEjercicio: ejercicios[index], musculo: musculo,
                  ),
                ),
              );
            },
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Image.asset(ejercicios[index]['imagen']!, height: 80),
                  //const SizedBox(height: 10),
                  Text(
                    ejercicios[index],
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