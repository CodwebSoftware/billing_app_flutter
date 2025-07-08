import 'package:billing_app_flutter/db/models/batch_entity.dart';
import 'package:billing_app_flutter/db/models/product_entity.dart';
import 'package:billing_app_flutter/db/models/sale_return_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class SaleReturnItemEntity {
  @Id()
  int id = 0;

  int? quantity;
  double? unitPrice;
  double? discount;
  bool? isDiscountPercentage;
  String? gstType;
  double? gstRate;

  final saleReturn = ToOne<SaleReturnEntity>();
  final product = ToOne<ProductEntity>();
  final batch = ToOne<BatchEntity>();

  SaleReturnItemEntity();

  double getSubtotal() {
    double subtotal = unitPrice! * quantity!;
    if (isDiscountPercentage!) {
      subtotal -= subtotal * (discount! / 100);
    } else {
      subtotal -= discount!;
    }
    return subtotal;
  }
}