import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';
import 'grupos.dart';
import 'historialEjercicios.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // PARA ASEGURARME QUE SE CARGUEN LAS INICIALIZACIONES ANTES DE INICIAR EL APP
  await versionDeLaDB();
  runApp(const MyApp());
}

Future<void> versionDeLaDB() async {

  Database db = await openDatabase('ejercicios.db');
  int version = await db.getVersion();
  print("VERSION DB EN USO: $version");
  int versionN = Sqflite.firstIntValue(await db.rawQuery('PRAGMA user_version'))!;
  print("VERSION DB EN USO: $versionN");
  await db.close();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COLOSO',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light, // Tema claro
        colorScheme: ColorScheme.light(primary: Colors.grey[300]!, // Color principal oscuro
          secondary: Colors.grey[500]!, // Color secundario
        ),
        scaffoldBackgroundColor: Colors.blueGrey[300], // Fondo de toda la app
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[900], // Fondo de AppBar
          foregroundColor: Colors.white, // Texto en blanco
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900], // Botón gris oscuro
            foregroundColor: Colors.white, // Texto del botón
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black),
          hintStyle: TextStyle(color: Colors.black54),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.black),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStatePropertyAll(Colors.black),
          checkColor: MaterialStatePropertyAll(Colors.white),
          side: const BorderSide(color: Colors.black),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: const TextStyle(color: Colors.black),
        ),

      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark, // Tema oscuro
        colorScheme: ColorScheme.dark(
          primary: Colors.grey[300]!, // Gris claro en modo oscuro
          secondary: Colors.grey[500]!,
        ),
        scaffoldBackgroundColor: Colors.blueGrey[300],
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900], // Botón visible en oscuro
            foregroundColor: Colors.white, // Texto del botón oscuro
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.black),
          hintStyle: TextStyle(color: Colors.black54),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black),
          ),
        ),
        textSelectionTheme: const TextSelectionThemeData(cursorColor: Colors.black),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStatePropertyAll(Colors.black),
          checkColor: MaterialStatePropertyAll(Colors.white),
        ),
        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: const TextStyle(color: Colors.black),
        ),
      ),
      routes: {
        '/login': (context) => const LoginScreen(),  // Definir la ruta de login
        '/home': (context) => const PantallaInicio(),  // Definir la ruta de inicio
      },
      home: const AuthCheck(),
    );
  }
}

// Esta pantalla decide si mostrar el login o la pantalla principal
class AuthCheck extends StatelessWidget {

  const AuthCheck({super.key});

  Future<bool> _isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userId'); // Devuelve true si hay sesión
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Pantalla de carga
        } else if (snapshot.data == true) {
          return const PantallaInicio(); // Usuario logueado
        } else {
          return const LoginScreen(); // Usuario no logueado
        }
      },
    );
  }
}

class PantallaInicio extends StatelessWidget {

  const PantallaInicio({super.key});


  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Eliminar el usuario guardado
    Navigator.pushReplacementNamed(context, '/login');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PantallaGrupos()),
                    );
                  },
                  child: const Text('INICIO'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HistorialScreen()),
                    );
                  },
                  child: const Text('HISTORIAL'),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: ElevatedButton.icon(
              onPressed: () => logout(context),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(''),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[900], // Color del botón
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

