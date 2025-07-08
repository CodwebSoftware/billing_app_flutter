import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:objectbox/objectbox.dart';

@Entity()
class FeedbackEntity {
  @Id()
  int id = 0;
  int? rating;
  String? comment;
  DateTime? date;

  final customer = ToOne<CustomerEntity>();

  FeedbackEntity();
}