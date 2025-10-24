import 'package:sioma_biometrics/domain/entities/employee.dart';

abstract class LocalDbRepository {
  Future<void> createEmployee(Employee employee);
  Future<Employee?> getEmployeeById(int id);
}
