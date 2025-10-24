import 'package:sioma_biometrics/domain/entities/employee.dart';

abstract class LocalDbDatasource {
  Future<void> createEmployee(Employee employee);
  Future<Employee?> getEmployeeById(int id);
}
