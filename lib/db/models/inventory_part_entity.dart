import 'package:objectbox/objectbox.dart';

@Entity()
class InventoryPartEntity {
  @Id()
  int id = 0;

  String? partNumber;
  String? name;
  String? description;
  int? stockQuantity;
  double? unitPrice;
  bool? isDeleted;

  InventoryPartEntity();
}
