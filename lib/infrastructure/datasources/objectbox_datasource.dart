// ignore: depend_on_referenced_packages
// import 'package:objectbox/objectbox.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sioma_biometrics/domain/datasources/local_db_datasource.dart';
import 'package:sioma_biometrics/domain/entities/employee.dart';
import 'package:sioma_biometrics/objectbox.g.dart';

class ObjectBoxDatasource implements LocalDbDatasource {
  static final ObjectBoxDatasource _instance = ObjectBoxDatasource._internal();
  late Future<Store> _db;

  factory ObjectBoxDatasource() {
    return _instance;
  }

  ObjectBoxDatasource._internal() {
    _db = openDb();
  }

  Future<Store> get db => _db;

  Future<Store> openDb() async {
    final supportDir = await getApplicationSupportDirectory();
    final dbPath = path.join(supportDir.path, 'db');

    // Verifica si el directorio existe y elimínalo de forma recursiva.
    // final dbDirectory = Directory(dbPath);
    // if (await dbDirectory.exists()) {
    //   await dbDirectory.delete(recursive: true);
    //   print('Directorio de base de datos eliminado.');
    // }

    // Ahora crea el store con el esquema actualizado.
    final store = await openStore(directory: dbPath);
    return store;
  }

  @override
  Future<void> createEmployee(Employee employee) async {
    final store = await db;
    final employeeBox = store.box<Employee>();
    employeeBox.put(employee);
    return;
  }

  @override
  Future<Employee?> getEmployeeById(int id) async {
    final store = await db;
    final employeeBox = store.box<Employee>();
    return employeeBox.get(id);
  }
}
