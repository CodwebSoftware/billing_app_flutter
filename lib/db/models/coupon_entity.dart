
import 'package:objectbox/objectbox.dart';

@Entity()
class CouponEntity {
  @Id()
  int id = 0;
  String? code; // Unique coupon code
  bool? isPercentage; // True for percentage, false for fixed
  double? value; // Percentage (e.g., 10.0) or fixed amount
  DateTime? expiryDate; // Optional expiry date
  bool? isActive; // Whether the coupon is valid

  CouponEntity();
}