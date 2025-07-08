import 'package:billing_app_flutter/db/models/batch_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/db/models/product_entity.dart';
import 'package:billing_app_flutter/objectboxes.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:objectbox/objectbox.dart';


@Entity()
class SaleEntryItemEntity {
  @Id()
  int id = 0;

  int? quantity;
  double? unitPrice;
  double? discount;
  bool? isDiscountPercentage;
  String? gstType;
  double? gstRate;
  bool? isHeld ;
  bool? isDeleted ;

  final invoice = ToOne<SaleEntryEntity>();
  final product = ToOne<ProductEntity>();
  final batch = ToOne<BatchEntity>();

  SaleEntryItemEntity();

  Map<String, dynamic> toJson() => {
    'id': id,
    'unitPrice': unitPrice,
    'quantity': quantity,
    'isHeld': isHeld,
    'discount': discount,
    'isDiscountPercentage': isDiscountPercentage,
    'productId': product.target?.id,
    'batchId': batch.target?.id,
  };

  static SaleEntryItemEntity fromJson(Map<String, dynamic> json, ObjectBoxes objectBox) {
    var item = SaleEntryItemEntity(

    );
    item.unitPrice = json['unitPrice'];
    item.quantity = json['quantity'];
    item.id = json['id'];
    item.isHeld = json['isHeld'] ?? false;
    item.discount = json['discount'] ?? 0.0;
    item.isDiscountPercentage = json['isDiscountPercentage'] ?? false;
    if (json['productId'] != null) {
      item.product.target = objectBox.productBox.get(json['productId']);
    }
    if (json['batchId'] != null) {
      item.batch.target = objectBox.batchBox.get(json['batchId']);
    }
    return item;
  }

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
