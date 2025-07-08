import 'package:billing_app_flutter/db/models/product_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class BatchEntity {
  @Id()
  int id = 0;
  String? barcode;
  String? batchNumber;
  String? hsnSacCode; // Added for HSN/SAC code
  String? gstType; // Intra-state or Inter-state
  double? gstRate; // GST rate (e.g., 18.0)
  double? cgstAmount; // CGST amount for intra-state
  double? sgstAmount; // SGST amount for intra-state
  double? igstAmount; // IGST amount for inter-state
  DateTime? manufactureDate;
  DateTime? expiryDate;
  double? unitPrice;
  int? quantity;
  double? discount;
  bool? isDiscountPercentage;
  bool? isDeleted;

  final product = ToOne<ProductEntity>();

  BatchEntity();
}
