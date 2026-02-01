import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseConnection {
  static final DatabaseConnection instance = DatabaseConnection.internal();
  factory DatabaseConnection() => instance;
  DatabaseConnection.internal();

  static Database? database;

  Future<Database> get db async {
    if (database != null) return database!;
    database = await initDB();
    return database!;
  }

  Future<Database> initDB() async {
    final routeDB = await getDatabasesPath();
    final absoluteRoute = join(routeDB, 'a.db');

    return await openDatabase(
      absoluteRoute,
      version: 1,
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: (Database db, int version) async {
        await db.execute("""
        CREATE TABLE tipoInfraccion (
          id_tipo_infraccion INTEGER PRIMARY KEY AUTOINCREMENT,
          codigo TEXT NOT NULL,
          descripcion TEXT NOT NULL,
          gravedad TEXT NOT NULL, 
          monto_base REAL NOT NULL,
          puntos_licencia INTEGER NOT NULL
        );
          
        """);

        await db.execute("""
        CREATE TABLE conductor (
          id_conductor INTEGER PRIMARY KEY AUTOINCREMENT,
          cedula TEXT NOT NULL,
          nombres TEXT NOT NULL,
          apellidos TEXT NOT NULL,
          numero_licencia TEXT NOT NULL,
          tipo_licencia TEXT NOT NULL,
          telefono TEXT NOT NULL
        );
        """);
        await db.execute("""
        CREATE TABLE vehiculo (
          id_vehiculo INTEGER PRIMARY KEY AUTOINCREMENT,
          placa TEXT NOT NULL,
          marca TEXT NOT NULL,
          modelo TEXT NOT NULL,
          color TEXT NOT NULL,
          anio INTEGER NOT NULL,
          id_conductor INTEGER NOT NULL,
          FOREIGN KEY (id_conductor) REFERENCES conductores(id_conductor)
        );
        """);

        await db.execute("""
        CREATE TABLE multa (
          id_multa INTEGER PRIMARY KEY AUTOINCREMENT,
          fecha_multa TEXT NOT NULL,
          lugar TEXT NOT NULL,
          monto_final REAL NOT NULL,
          estado TEXT NOT NULL, -- PENDIENTE | PAGADA
          id_conductor INTEGER NOT NULL,
          id_vehiculo INTEGER NOT NULL,
          id_tipo_infraccion INTEGER NOT NULL,
          FOREIGN KEY (id_conductor) REFERENCES conductores(id_conductor),
          FOREIGN KEY (id_vehiculo) REFERENCES vehiculos(id_vehiculo),
          FOREIGN KEY (id_tipo_infraccion) REFERENCES tipos_infraccion(id_tipo_infraccion)
        );
        """);

        await db.execute("""
        CREATE TABLE pagos (
          id_pago INTEGER PRIMARY KEY AUTOINCREMENT,
          fecha_pago TEXT NOT NULL,
          monto_pagado REAL NOT NULL,
          metodo_pago TEXT NOT NULL, 
          referencia TEXT NOT NULL,
          id_multa INTEGER NOT NULL,
          comprobante_path TEXT, 
          FOREIGN KEY (id_multa) REFERENCES multas(id_multa)
        );
        """);
      },
    );
  }
}
