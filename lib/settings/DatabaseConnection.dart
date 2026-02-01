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
    final absoluteRoute = join(routeDB, 'b.db');

    return await openDatabase(
      absoluteRoute,
      version: 1,
      onConfigure: (db) async {
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: (Database db, int version) async {
        await db.transaction((txn) async {
          // TABLAS
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
  referencia TEXT NOT NULL,
  idMulta INTEGER NOT NULL,
  comprobantePath TEXT,
  FOREIGN KEY (idMulta) REFERENCES multa(id) ON DELETE RESTRICT ON UPDATE CASCADE
);
""");

          // INSERTS (DATOS SEMILLA)

          // tipoInfraccion
          await txn.execute("""
INSERT INTO tipoInfraccion (codigo, descripcion, gravedad, montoBase, puntosLicencia) VALUES
('A01', 'Exceso de velocidad en zona urbana', 'GRAVE', 150.00, 10),
('B12', 'Estacionar en lugar prohibido', 'LEVE', 40.00, 2),
('C07', 'No usar cinturón de seguridad', 'MEDIA', 75.50, 5);
""");

          // conductor
          await txn.execute("""
INSERT INTO conductor (cedula, nombres, apellidos, numeroLicencia, tipoLicencia, telefono) VALUES
('0102030405', 'Carlos', 'Mendoza', 'LIC-001122', 'B', '0991234567'),
('0912345678', 'María', 'Gómez', 'LIC-009988', 'C', '0987654321'),
('1717171717', 'Juan', 'Paredes', 'LIC-007700', 'A', '0971122334');
""");

          // vehiculo (idConductor -> conductor.id = 1,2,3)
          await txn.execute("""
INSERT INTO vehiculo (placa, marca, modelo, color, anio, idConductor) VALUES
('ABC-1234', 'Toyota', 'Corolla', 'Blanco', 2018, 1),
('PCD-5678', 'Chevrolet', 'Sail', 'Gris', 2020, 2),
('GHI-9012', 'Kia', 'Rio', 'Rojo', 2017, 3);
""");

          // multa (idConductor, idVehiculo, idTipoInfraccion)
          // multa 1: conductor 1, vehiculo 1, infraccion 1
          // multa 2: conductor 2, vehiculo 2, infraccion 2
          // multa 3: conductor 3, vehiculo 3, infraccion 3
          await txn.execute("""
INSERT INTO multa (fechaMulta, lugar, montoFinal, estado, idConductor, idVehiculo, idTipoInfraccion) VALUES
('2026-02-01', 'Av. Principal y Calle 10', 150.00, 'PENDIENTE', 1, 1, 1),
('2026-01-28', 'Centro - Parqueadero Municipal', 40.00, 'PAGADA', 2, 2, 2),
('2026-01-15', 'Vía Perimetral Km 3', 75.50, 'PENDIENTE', 3, 3, 3);
""");

          // pago (solo para la multa que está PAGADA -> idMulta = 2)
          await txn.execute("""
INSERT INTO pago (fechaPago, montoPagado, metodoPago, referencia, idMulta, comprobantePath) VALUES
('2026-01-29', 40.00, 'EFECTIVO', 'REC-0001', 2, NULL);
""");
        });
      },
    );
  }
}
