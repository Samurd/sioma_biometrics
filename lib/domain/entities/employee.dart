import 'package:objectbox/objectbox.dart';

@Entity()
class Employee {
  int id;

  String name;

  String? photoPath; // Ruta local de la foto

  // Embedding facial para reconocimiento
  @Property(type: PropertyType.floatVector)
  List<double>? faceEmbedding;

  Employee({
    this.id = 0,
    required this.name,
    this.photoPath,
    this.faceEmbedding,
  });
}
