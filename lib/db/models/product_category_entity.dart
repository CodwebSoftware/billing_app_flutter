import 'package:billing_app_flutter/db/models/product_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class ProductCategoryEntity {
  @Id()
  int id = 0;
  String? name;
  String? code;
  String? description;

  bool? isDeleted;

  // Self-referential relationship for subcategories
  final parent = ToOne<ProductCategoryEntity>();

  final subcategories = ToMany<ProductCategoryEntity>();

  // Products in this category
  final products = ToMany<ProductEntity>();

  ProductCategoryEntity();
}