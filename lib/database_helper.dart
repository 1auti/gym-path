import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;
  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'ejercicios.db');
    //await deleteDatabase(path);
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        print("INICIANDO version 1...");
        await db.execute('''
          CREATE TABLE registroEjercicios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nombre TEXT,
            repeticiones INTEGER,
            pesoUsado INTEGER,
            musculo TEXT,
            fechaRegistro TEXT
            )
        ''');
        await db.execute('''
            ALTER TABLE registroEjercicios ADD COLUMN tipoAgarre TEXT;
          ''');
        await db.execute('''  
            ALTER TABLE registroEjercicios ADD COLUMN tipoEquipo TEXT;
        ''');
        await db.execute('''  
            ALTER TABLE registroEjercicios ADD COLUMN segundos INTEGER;
        ''');
        await db.execute('''  
            ALTER TABLE registroEjercicios ADD COLUMN esIsometrico INTEGER;
        ''');
        await db.execute("ALTER TABLE registroEjercicios ADD COLUMN tipoAmplitud TEXT;");
        await db.execute('''
            CREATE TABLE registroEjercicios_nueva (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT,
              repeticiones INTEGER,
              peso REAL, -- Cambiado a REAL
              musculo TEXT,
              fechaRegistro TEXT ,
              tipoAgarre TEXT DEFAULT NULL,
              tipoEquipo TEXT DEFAULT NULL,
              segundos INTEGER DEFAULT 0,
              pesoExtra REAL DEFAULT 0,
              esIsometrico INTEGER DEFAULT 0,
              tipoAmplitud TEXT DEFAULT NULL,
              usuario_id INTEGER DEFAULT NULL,
              observaciones TEXT DEFAULT NULL
            )
        ''');

        // Copiar los datos de la tabla antigua a la nueva
        // Copiar los datos de la tabla antigua a la nueva, asignando valores por defecto a las columnas nuevas
        await db.execute('''
            INSERT INTO registroEjercicios_nueva (
              id, nombre, repeticiones, peso, musculo, fechaRegistro,
              tipoAgarre, tipoEquipo, segundos, pesoExtra, esIsometrico, 
              tipoAmplitud, usuario_id, observaciones
            )
            SELECT 
              id, nombre, repeticiones, pesoUsado, musculo, fechaRegistro,
              NULL, NULL, 0, 0, 0, -- Valores por defecto para nuevas columnas
              NULL, NULL, NULL
            FROM registroEjercicios
          ''');

        // Eliminar la tabla antigua
        await db.execute('DROP TABLE registroEjercicios');

        // Renombrar la nueva tabla con el nombre original
        await db.execute('ALTER TABLE registroEjercicios_nueva RENAME TO registroEjercicios');


        await db.execute('''
            CREATE TABLE usuarios (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT UNIQUE NOT NULL,
              password INTEGER NOT NULL,
              fechaRegistro TEXT NOT NULL
              )
        ''');
        await db.execute("INSERT INTO usuarios (username, password, fechaRegistro) VALUES ('admin', 'admin', datetime('now'));");
        await db.execute("UPDATE registroEjercicios SET usuario_id = 1 WHERE usuario_id IS NULL;");
        await db.execute('''CREATE TABLE historial_detalles_usuarios (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              usuario_id INTEGER,
              fechaRegistro TEXT NOT NULL UNIQUE,
              peso REAL,
              altura REAL,
              edad INTEGER,
              sexo TEXT,
              nivelActividad REAL,
              objetivo TEXT,
              tipoRutina TEXT,
              totalKcalObjetivo REAL,
              totalKcal REAL,
              carbohidratosKcal REAL,
              proteinasKcal REAL,
              grasasKcal REAL,
              carbohidratosGrs REAL,
              proteinasGrs REAL,
              grasasGrs REAL,
              cinturacm REAL,
              brazoscm REAL,
              piernascm REAL,
              pechocm REAL,
              gluteoscm REAL,
              espaldacm REAL,
              imagen TEXT,
              observaciones TEXT,
              FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
            )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        print("onUpgrade ejecutando - oldVersion: $oldVersion, newVersion: $newVersion");

        // Aquí manejas las migraciones de versión
        if (oldVersion < 2) { //mejoras para version 2
          print("ACTUALIZANDO A VERSION 2...");
          // Si la versión es menor a 2, realiza las modificaciones necesarias
          await db.execute('''
            ALTER TABLE registroEjercicios ADD COLUMN tipoAgarre TEXT;
          ''');
          await db.execute('''  
            ALTER TABLE registroEjercicios ADD COLUMN tipoEquipo TEXT;
        ''');
          await db.execute('''  
            ALTER TABLE registroEjercicios ADD COLUMN segundos INTEGER;
        ''');
          await db.execute('''  
            ALTER TABLE registroEjercicios ADD COLUMN esIsometrico INTEGER;
        ''');
          await db.execute("ALTER TABLE registroEjercicios ADD COLUMN tipoAmplitud TEXT;");
          await db.execute('''
            CREATE TABLE registroEjercicios_nueva (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT,
              repeticiones INTEGER,
              peso REAL, -- Cambiado a REAL
              musculo TEXT,
              fechaRegistro TEXT ,
              tipoAgarre TEXT DEFAULT NULL,
              tipoEquipo TEXT DEFAULT NULL,
              segundos INTEGER DEFAULT 0,
              pesoExtra REAL DEFAULT 0,
              esIsometrico INTEGER DEFAULT 0,
              tipoAmplitud TEXT DEFAULT NULL,
              usuario_id INTEGER DEFAULT NULL,
              observaciones TEXT DEFAULT NULL
            )
        ''');

          // Copiar los datos de la tabla antigua a la nueva
          // Copiar los datos de la tabla antigua a la nueva, asignando valores por defecto a las columnas nuevas
          await db.execute('''
            INSERT INTO registroEjercicios_nueva (
              id, nombre, repeticiones, peso, musculo, fechaRegistro,
              tipoAgarre, tipoEquipo, segundos, pesoExtra, esIsometrico, 
              tipoAmplitud, usuario_id, observaciones
            )
            SELECT 
              id, nombre, repeticiones, pesoUsado, musculo, fechaRegistro,
              NULL, NULL, 0, 0, 0, -- Valores por defecto para nuevas columnas
              NULL, NULL, NULL
            FROM registroEjercicios
          ''');

          // Eliminar la tabla antigua
          await db.execute('DROP TABLE registroEjercicios');

          // Renombrar la nueva tabla con el nombre original
          await db.execute('ALTER TABLE registroEjercicios_nueva RENAME TO registroEjercicios');


          await db.execute('''
            CREATE TABLE usuarios (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT UNIQUE NOT NULL,
              password INTEGER NOT NULL,
              fechaRegistro TEXT NOT NULL
              )
        ''');
          await db.execute("INSERT INTO usuarios (username, password, fechaRegistro) VALUES ('admin', 'admin', datetime('now'));");
          await db.execute("UPDATE registroEjercicios SET usuario_id = 1 WHERE usuario_id IS NULL;");
          await db.execute('''CREATE TABLE historial_detalles_usuarios (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              usuario_id INTEGER,
              fechaRegistro TEXT NOT NULL UNIQUE,
              peso REAL,
              altura REAL,
              edad INTEGER,
              sexo TEXT,
              nivelActividad REAL,
              objetivo TEXT,
              tipoRutina TEXT,
              totalKcalObjetivo REAL,
              totalKcal REAL,
              carbohidratosKcal REAL,
              proteinasKcal REAL,
              grasasKcal REAL,
              carbohidratosGrs REAL,
              proteinasGrs REAL,
              grasasGrs REAL,
              cinturacm REAL,
              brazoscm REAL,
              piernascm REAL,
              pechocm REAL,
              gluteoscm REAL,
              espaldacm REAL,
              imagen TEXT,
              observaciones TEXT,
              FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
            )
        ''');
        }
        //SI HAY MAS CAMBIOS DE VERSION VAN ACA
      },
    );
  }


  Future<void> backupDatabase() async {
    String path = join(await getDatabasesPath(), 'ejercicios.db');
    String backupPath = join(await getDatabasesPath(), 'ejercicios_backup.db');
    File(path).copy(backupPath);
    print("Backup creado en: $backupPath");
  }



  Future<int> insertarEjercicio(String nombre, int repeticiones, double peso, String musculo,
      String tipoAgarre, String tipoEquipo, int segundos, double pesoExtra, int esIsometrico,
      String tipoAmplitud, String observaciones,userId) async {


    final db = await database;
    Map<String, dynamic> nuevoEjercicio = {
        'nombre': nombre,
        'repeticiones': repeticiones,
        'peso': peso,
        'pesoExtra':pesoExtra,
        'musculo':musculo,
        'fechaRegistro':DateTime.now().toIso8601String(),
        'tipoAgarre':tipoAgarre,
        'tipoAmplitud':tipoAmplitud,
        'tipoEquipo':tipoEquipo,
        'segundos':segundos,
        'esIsometrico':esIsometrico,
        'observaciones':observaciones,
        'usuario_id':userId

    };
    return await db.insert(
      'registroEjercicios',
        nuevoEjercicio
    );
  }


  Future<List<Map<String, dynamic>>> getEjercicios() async {
    final db = await database;
    return await db.query('registroEjercicios');
  }


  Future<List<Map<String, dynamic>>> getEjerciciosPorFecha(String fecha) async {
    final db = await _initDB(); // Asegúrate de que esta función abre tu BD
    return await db.query(
      'registroEjercicios',
      where: 'substr(fechaRegistro, 1, 10) = ?',
      whereArgs: [fecha],
    );
  }

  Future<double?> getPesoUsuario(int id_usuario) async {
    final db = await _initDB(); // Asegúrate de que esta función abre tu BD
    final List<Map<String, Object?>> result = await db.query(
      'historial_detalles_usuarios',
      where: 'usuario_id = ?',
      whereArgs: [id_usuario],
      orderBy: 'fechaRegistro DESC', // Ordena por fecha de forma descendente
      limit: 1, // Solo una fila (el más reciente)
    );

    if (result.isNotEmpty) {
      return (result.first['peso'] as num?)?.toDouble();
    }
    return null; // Si no hay registros, devuelve null // Retorna el registro más reciente o null si no hay datos

  }


  Future<int> updateEntreno(Map<String, dynamic> registro) async {
    final db = await database;

    return await db.update(
      'registroEjercicios',
      registro,
      where: 'id = ?',
      whereArgs: [registro['id']],
    );
  }

  Future<int> deleteEntreno(int id) async {
    final db = await database;
    return await db.delete(
      'registroEjercicios',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

}
