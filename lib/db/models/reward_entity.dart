import 'package:objectbox/objectbox.dart';

@Entity()
class RewardEntity {
  @Id()
  int id = 0;

  String? name;
  String? description;
  int? pointsRequired;
  int? stock;

  RewardEntity();
}