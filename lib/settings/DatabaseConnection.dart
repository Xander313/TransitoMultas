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
    final absoluteRoute = join(routeDB, 'agencianacionadetransito.db');

    return await openDatabase(
      absoluteRoute,
      version: 1,
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: (Database db, int version) async {
        await db.transaction((txn) async {
          await txn.execute("""
          CREATE TABLE tipoInfraccion (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            codigo TEXT NOT NULL,
            descripcion TEXT NOT NULL,
            gravedad TEXT NOT NULL,
            montoBase REAL NOT NULL,
            puntosLicencia INTEGER NOT NULL
          );
          """);

          await txn.execute("""
          CREATE TABLE conductor (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cedula TEXT NOT NULL,
            nombres TEXT NOT NULL,
            apellidos TEXT NOT NULL,
            numeroLicencia TEXT NOT NULL,
            tipoLicencia TEXT NOT NULL,
            telefono TEXT NOT NULL
          );
          """);

          await txn.execute("""
          CREATE TABLE vehiculo (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            placa TEXT NOT NULL,
            marca TEXT NOT NULL,
            modelo TEXT NOT NULL,
            color TEXT NOT NULL,
            anio INTEGER NOT NULL,
            idConductor INTEGER NOT NULL,
            FOREIGN KEY (idConductor) REFERENCES conductor(id) ON DELETE RESTRICT ON UPDATE CASCADE
          );
          """);

          await txn.execute("""
          CREATE TABLE multa (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fechaMulta TEXT NOT NULL,
            lugar TEXT NOT NULL,
            montoFinal REAL NOT NULL,
            estado TEXT NOT NULL,
            idConductor INTEGER NOT NULL,
            idVehiculo INTEGER NOT NULL,
            idTipoInfraccion INTEGER NOT NULL,
            FOREIGN KEY (idConductor) REFERENCES conductor(id) ON DELETE RESTRICT ON UPDATE CASCADE,
            FOREIGN KEY (idVehiculo) REFERENCES vehiculo(id) ON DELETE RESTRICT ON UPDATE CASCADE,
            FOREIGN KEY (idTipoInfraccion) REFERENCES tipoInfraccion(id) ON DELETE RESTRICT ON UPDATE CASCADE
          );
          """);

          await txn.execute("""
          CREATE TABLE pago (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            fechaPago TEXT NOT NULL,
            montoPagado REAL NOT NULL,
            metodoPago TEXT NOT NULL,
            idMulta INTEGER NOT NULL UNIQUE,
            comprobantePath TEXT,
            FOREIGN KEY (idMulta) REFERENCES multa(id) ON DELETE RESTRICT ON UPDATE CASCADE
          );
          """);
        });
      },
    );
  }
}
