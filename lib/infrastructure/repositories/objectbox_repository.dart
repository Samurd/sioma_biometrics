import 'package:sioma_biometrics/domain/entities/employee.dart';
import 'package:sioma_biometrics/domain/repositories/local_db_repository.dart';
import 'package:sioma_biometrics/infrastructure/datasources/objectbox_datasource.dart';

class ObjectBoxRepository implements LocalDbRepository {
  final ObjectBoxDatasource objectBoxImpl;

  ObjectBoxRepository({required this.objectBoxImpl});

  @override
  Future<void> createEmployee(Employee employee) async {
    await objectBoxImpl.createEmployee(employee);
  }

  @override
  Future<Employee?> getEmployeeById(int id) async {
    return objectBoxImpl.getEmployeeById(id);
  }
}
