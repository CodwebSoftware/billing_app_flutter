import 'package:billing_app_flutter/objectboxes.dart';

class BackupRestore {
  final ObjectBoxes objectBox;

  BackupRestore(this.objectBox);

  // Export data to a JSON file
  Future<void> exportData() async {
    // try {
    //   // Fetch all data from the database
    //   final customers = objectBox.customerBox.getAll();
    //   final invoices = objectBox.invoiceBox.getAll();
    //   final products = objectBox.productBox.getAll();
    //   final transactions = objectBox.transactionBox.getAll();

    //   // Convert data to JSON
    //   final data = {
    //     'customers': customers.map((c) => c.toJson()).toList(),
    //     'invoices': invoices.map((i) => i.toJson()).toList(),
    //     'products': products.map((p) => p.toJson()).toList(),
    //     'transactions': transactions.map((t) => t.toJson()).toList(),
    //   };

    //   // Save JSON to a file
    //   final directory = await getApplicationDocumentsDirectory();
    //   final file = File('${directory.path}/backup.json');
    //   await file.writeAsString(jsonEncode(data));

    //   Get.snackbar(
    //     'Success',
    //     'Data exported successfully!',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // } catch (e) {
    //   Get.snackbar(
    //     'Error',
    //     'Failed to export data: $e',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // }
  }

  // Import data from a JSON file
  Future<void> importData() async {
    // try {
    //   // Load JSON from a file
    //   final directory = await getApplicationDocumentsDirectory();
    //   final file = File('${directory.path}/backup.json');
    //   if (!file.existsSync()) {
    //     Get.snackbar(
    //       'Error',
    //       'Backup file not found!',
    //       snackPosition: SnackPosition.BOTTOM,
    //     );
    //     return;
    //   }

    //   final data = jsonDecode(await file.readAsString());

    //   // Clear existing data
    //   objectBox.customerBox.removeAll();
    //   objectBox.invoiceBox.removeAll();
    //   objectBox.productBox.removeAll();
    //   objectBox.transactionBox.removeAll();

    //   // Restore customers
    //   for (var json in data['customers']) {
    //     objectBox.customerBox.put(Customer.fromJson(json));
    //   }

    //   // Restore products
    //   for (var json in data['products']) {
    //     objectBox.productBox.put(Product.fromJson(json));
    //   }

    //   // Restore invoices
    //   for (var json in data['invoices']) {
    //     objectBox.invoiceBox.put(Invoice.fromJson(json));
    //   }

    //   // Restore transactions
    //   for (var json in data['transactions']) {
    //     objectBox.transactionBox.put(Transaction.fromJson(json));
    //   }

    //   Get.snackbar(
    //     'Success',
    //     'Data imported successfully!',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // } catch (e) {
    //   Get.snackbar(
    //     'Error',
    //     'Failed to import data: $e',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    // }
  }
}
