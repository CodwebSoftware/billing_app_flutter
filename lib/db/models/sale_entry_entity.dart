import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_items_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_services_entity.dart';
import 'package:billing_app_flutter/db/models/payment_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class SaleEntryEntity {
  @Id()
  int id = 0;
  String? invoiceNumber;
  DateTime? date;
  double? totalBillAmount;
  double? amountPaid; // Total amount paid so far
  String? status;
  double? invoiceDiscount;
  bool? isInvoiceDiscountPercentage;
  String? employeeId;

  final customer = ToOne<CustomerEntity>();
  final items = ToMany<SaleEntryItemEntity>();
  final services = ToMany<SaleEntryServicesEntity>();
  final payments = ToMany<PaymentEntity>();

  SaleEntryEntity();

  // Calculate the total amount after applying tax and discount
  double get grandTotal {
    double amountAfterDiscount = totalAmount - invoiceDiscount!;
    return amountAfterDiscount;
  }

  double get totalAmount {
    final st = services.fold(
      0.0,
      (sum, service) => sum + service.getSubtotal(),
    );
    final it = items.fold(0.0, (sum, item) => sum + item.getSubtotal());
    return st + it;
  }

  // Calculate the outstanding balance
  double get outstandingBalance {
    return grandTotal - amountPaid!;
  }

  // Check if the invoice is fully paid
  bool get isFullyPaid {
    return outstandingBalance <= 0;
  }
}
