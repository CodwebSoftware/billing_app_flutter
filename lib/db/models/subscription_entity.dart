import 'package:objectbox/objectbox.dart';

@Entity()
class SubscriptionEntity {
  int id = 0 ; // ObjectBox requires an id field
  String? mobileNumber;
  String? plan;
  String? status;

  bool? isDeleted;

  DateTime? startDate;
  DateTime? endDate;
  DateTime? createdAt;
  DateTime? updatedAt;

  SubscriptionEntity();
}