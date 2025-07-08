class SubscriptionModel {
  final String id;
  final String name;
  final double price;
  final String duration;
  final List<String> features;
  final bool isPopular;

  SubscriptionModel({
    required this.id,
    required this.name,
    required this.price,
    required this.duration,
    required this.features,
    this.isPopular = false,
  });
}