import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/feedback_entity.dart';
import 'package:billing_app_flutter/db/models/loyalty_point_entity.dart';
import 'package:billing_app_flutter/db/models/membership_entity.dart';
import 'package:billing_app_flutter/objectbox.g.dart';
import 'package:billing_app_flutter/objectboxes.dart';
import 'package:get/get.dart';

class CustomerController extends GetxController {
  final ObjectBoxes objectBox;
  var customers = <CustomerEntity>[].obs;
  var birthDateCustomers = <CustomerEntity>[].obs;
  final Rx<CustomerEntity?> selectedCustomer = Rx<CustomerEntity?>(null);
  final RxInt totalLoyaltyPoints = 0.obs;

  final isLoading = false.obs;

  CustomerController({required this.objectBox});

  @override
  void onInit() async {
    super.onInit();
    getCustomersByNameOrMobile("");
  }

  int getCustomersCount() {
    return objectBox.customerBox.count();
  }

  CustomerEntity? getCustomer(int id){
    // Build a query to find invoices where the customer matches
    if(id != 0){
    return
    objectBox.customerBox.get(id);
  }else{
      return CustomerEntity();
    }}
  
  getCustomersByNameOrMobile(String str){
    // Build a query to find invoices where the customer matches
    final query =
    objectBox.customerBox
        .query(CustomerEntity_.name.startsWith(str, caseSensitive: false).or(CustomerEntity_.phone.startsWith(str)))
        .build();

    // Execute the query and get the results
    customers.value = query.find();
    query.close();
  }

  getCustomersByNameOrMobileAndDOB(String str, DateTime dob){
    // Build a query to find invoices where the customer matches
    final query =
    objectBox.customerBox
        .query(CustomerEntity_.name.startsWith(str, caseSensitive: false).or(CustomerEntity_.phone.startsWith(str))
        .and(CustomerEntity_.dateOfBirth.equalsDate(dob)))
        .build();

    // Execute the query and get the results
    customers.value = query.find();
    query.close();
  }

  void saveCustomer(CustomerEntity customer) {
    objectBox.customerBox.put(customer, mode: PutMode.put);
    getCustomersByNameOrMobile("");
  }

  void selectCustomer(CustomerEntity customer) {
    selectedCustomer.value = customer;
  }

  void addFeedback(FeedbackEntity feedback, CustomerEntity customer) {
    feedback.customer.target = customer;
    objectBox.feedbackBox.put(feedback);
    customer.feedbacks.add(feedback);
    objectBox.customerBox.put(customer);
  }

  void addMembership(MembershipEntity membership, CustomerEntity customer) {
    membership.customer.target = customer;
    objectBox.membershipBox.put(membership);
    customer.memberships.add(membership);
    objectBox.customerBox.put(customer);
  }


  List<CustomerEntity> getUpcomingBirthdays() {
    final now = DateTime.now();
    final nextMonth = now.add(Duration(days: 30));
    return customers.where((c) => c.dateOfBirth.isNullOrBlank! && c.dateOfBirth!.month == nextMonth.month && c.dateOfBirth!.day >= now.day).toList();
  }

  List<CustomerEntity> getUpcomingAnniversaries() {
    final now = DateTime.now();
    final nextMonth = now.add(Duration(days: 30));
    return customers.where((c) => c.anniversaryDate.isNullOrBlank! && c.anniversaryDate!.month == nextMonth.month && c.anniversaryDate!.day >= now.day).toList();
  }
}
