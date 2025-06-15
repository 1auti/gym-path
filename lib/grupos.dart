import 'package:flutter/material.dart';
import 'package:coloso/musculos.dart';

class PantallaGrupos extends StatelessWidget{

  const PantallaGrupos({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SELECCIONA GRUPO')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaMusculos(grupo: 'TORSO'),
                ),
              ),
              child: Text('TORSO'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PantallaMusculos(grupo: 'PIERNAS'),
                ),
              ),
              child: Text('PIERNAS'),
            ),
          ],
        ),
      ),
    );
  }


}