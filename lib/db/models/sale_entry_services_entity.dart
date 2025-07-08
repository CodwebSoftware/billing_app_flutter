import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/db/models/service_entity.dart';
import 'package:billing_app_flutter/objectboxes.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class SaleEntryServicesEntity {
  @Id()
  int id = 0;
  int? quantity;
  double? price;
  double? discount;
  bool? isDiscountPercentage;
  String? gstType;
  double? gstRate;
  bool? isHeld;
  bool? isDeleted;

  final invoice = ToOne<SaleEntryEntity>();
  final service = ToOne<ServiceEntity>();

  SaleEntryServicesEntity();

  Map<String, dynamic> toJson() => {
    'id': id,
    'price': price,
    'quantity': quantity,
    'isHeld': isHeld,
    'discount': discount,
    'isDiscountPercentage': isDiscountPercentage,
    'serviceId': service.target!.id,
  };

  static SaleEntryServicesEntity fromJson(
    Map<String, dynamic> json,
    ObjectBoxes objectBox,
  ) {
    var service = SaleEntryServicesEntity();
    service.price = json['price'];
    service.quantity = json['quantity'];
    service.service.target!.id = json['serviceId'];
    service.id = json['id'];
    service.isHeld = json['isHeld'] ?? false;
    service.discount = json['discount'] ?? 0.0;
    service.isDiscountPercentage = json['isDiscountPercentage'] ?? false;
    return service;
  }

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
