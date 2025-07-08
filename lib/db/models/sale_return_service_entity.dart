import 'package:billing_app_flutter/db/models/service_entity.dart';
import 'package:billing_app_flutter/db/models/sale_return_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class SaleReturnServiceEntity {
  @Id()
  int id = 0;

  int? quantity;
  double? price;
  double? discount;
  bool? isDiscountPercentage;
  String? gstType;
  double? gstRate;

  final saleReturn = ToOne<SaleReturnEntity>();
  final service = ToOne<ServiceEntity>();

  SaleReturnServiceEntity();

  double getSubtotal() {
    double subtotal = price! * quantity!;
    if (isDiscountPercentage!) {
      subtotal -= subtotal * (discount! / 100);
    } else {
      subtotal -= discount!;
    }
    return subtotal;
  }
}