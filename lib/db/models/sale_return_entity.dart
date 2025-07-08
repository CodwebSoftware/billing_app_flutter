import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/db/models/sale_return_item_entity.dart';
import 'package:billing_app_flutter/db/models/sale_return_service_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class SaleReturnEntity {
  @Id()
  int id = 0;

  String? returnNumber;
  DateTime? date;
  double? totalReturnAmount;
  String? reason;
  String? status;

  final originalInvoice = ToOne<SaleEntryEntity>();
  final customer = ToOne<CustomerEntity>();

  @Backlink()
  final items = ToMany<SaleReturnItemEntity>();
  @Backlink()
  final services = ToMany<SaleReturnServiceEntity>();

  SaleReturnEntity();

  // Add this method to match SaleEntryEntity structure
  double get grandTotal => totalReturnAmount ?? 0.0;
}