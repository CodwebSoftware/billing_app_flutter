import 'package:objectbox/objectbox.dart';

@Entity()
class ServiceEntity {
  @Id()
  int id = 0;
  String? code;
  String? hsnSacCode; // Added for HSN/SAC code
  String? gstType; // Intra-state or Inter-state
  double? gstRate; // GST rate (e.g., 18.0)
  double? cgstAmount; // CGST amount for intra-state
  double? sgstAmount; // SGST amount for intra-state
  double? igstAmount; // IGST amount for inter-state
  int? qty;
  String? name;
  String? description;
  double? price;
  int? duration; // Duration in minutes
  bool? isDeleted;

  ServiceEntity();
}
