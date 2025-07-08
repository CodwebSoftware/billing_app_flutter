import 'package:billing_app_flutter/db/models/batch_entity.dart';
import 'package:billing_app_flutter/db/models/product_category_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class ProductEntity {
  @Id()
  int id = 0;
  String? code;
  String? hsnSacCode; // Added for HSN/SAC code
  String? name;
  String? description;
  String? barcode;
  double? price;
  int? quantity;
  double? discount;
  bool? isDiscountPercentage;
  bool? isDeleted;

  final category = ToOne<ProductCategoryEntity>();

  final batches = ToMany<BatchEntity>();

  ProductEntity();
}
