import 'package:billing_app_flutter/db/controllers/customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FindCustomerScreen extends StatefulWidget {
  const FindCustomerScreen({super.key});

  @override
  State<FindCustomerScreen> createState() => _AddCustomerListScreenState();
}

class _AddCustomerListScreenState extends State<FindCustomerScreen> {
  final customerController = Get.find<CustomerController>();
  final _searchController = TextEditingController();

  @override
  void initState() {
    customerController.getCustomersByNameOrMobile(_searchController.text);
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Find Customer', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, description or price...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () { _searchController.clear();
                    customerController.getCustomersByNameOrMobile(_searchController.text);
                      },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onChanged: (value){
                  customerController.getCustomersByNameOrMobile(_searchController.text);
                },
              ),
            ),
            // Service List
            Expanded(
              child: Obx(() {
                return ListView.builder(
                  itemCount: customerController.customers.length,
                  itemBuilder: (context, index) {
                    final customer = customerController.customers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Text(customer.name!),
                        subtitle: Text(customer.email!),
                        trailing: Text(customer.phone!),
                        onTap: () => Get.back(result: customer),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}