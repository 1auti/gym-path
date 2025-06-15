import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'main.dart'; // Importa la pantalla principal
import 'database_helper.dart'; // Importa tu helper de base de datos

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _errorMessage = '';

  Future<void> _login() async {

    String username = _userController.text.trim();
    String password = _passwordController.text.trim();

    final db = await DatabaseHelper.instance.database;
    final versionDB= await db.getVersion();
    print("VERSION DB ACTUALIZADA: $versionDB");
    var result = await db.rawQuery("SELECT id FROM usuarios WHERE username = ? AND password = ?", [username, password]);
    if (result.isNotEmpty) {
      int userId = result.first['id'] as int;

      // Guardar el ID del usuario en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', userId);

      // Navegar a la pantalla principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaInicio()),
      );
    } else {
      setState(() {
        _errorMessage = 'USUARIO O PASSWORD INCORRECTOS';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _userController,
              decoration: const InputDecoration(labelText: 'Usuario',labelStyle: TextStyle(color: Colors.black),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              style: const TextStyle(color: Colors.black),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña',
                labelStyle: TextStyle(color: Colors.black),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Ingresar'),
            ),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
