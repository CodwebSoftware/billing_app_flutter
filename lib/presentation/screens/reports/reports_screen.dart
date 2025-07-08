import 'package:billing_app_flutter/db/controllers/sale_entry_controller.dart';
import 'package:billing_app_flutter/db/controllers/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_charts/flutter_charts.dart' as charts;

class ReportsScreen extends StatelessWidget {
  final SaleEntryController invoiceController = Get.find();
  final ProductController productController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reports & Analytics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Sales Report',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // _buildSalesChart(),
            SizedBox(height: 20),
            Text(
              'Stock Report',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // _buildStockChart(),
            SizedBox(height: 20),
            Text(
              'Revenue Report',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // _buildRevenueChart(),
          ],
        ),
      ),
    );
  }

  // Widget _buildSalesChart() {
  //   final data = [
  //     SalesData(
  //       'Jan',
  //       invoiceController.invoices.where((i) => i.date.month == 1).length,
  //     ),
  //     SalesData(
  //       'Feb',
  //       invoiceController.invoices.where((i) => i.date.month == 2).length,
  //     ),
  //     SalesData(
  //       'Mar',
  //       invoiceController.invoices.where((i) => i.date.month == 3).length,
  //     ),
  //   ];
  //
  //   final series = [
  //     charts.Series<SalesData, String>(
  //       id: 'Sales',
  //       domainFn: (SalesData sales, _) => sales.month,
  //       measureFn: (SalesData sales, _) => sales.sales,
  //       data: data,
  //     ),
  //   ];
  //
  //   return SizedBox(height: 300, child: charts.BarChart(series, animate: true));
  // }

  // Widget _buildStockChart() {
  //   final data =
  //       productController.products.map((product) {
  //         return StockData(product.name, product.quantity);
  //       }).toList();
  //
  //   final series = [
  //     charts.Series<StockData, String>(
  //       id: 'Stock',
  //       domainFn: (StockData stock, _) => stock.product,
  //       measureFn: (StockData stock, _) => stock.stock,
  //       data: data,
  //     ),
  //   ];
  //
  //   return SizedBox(height: 300, child: charts.BarChart(series, animate: true));
  // }

  // Widget _buildRevenueChart() {
  //   final data = [
  //     RevenueData(
  //       'Jan',
  //       invoiceController.invoices
  //           .where((i) => i.date.month == 1)
  //           .fold(0, (sum, i) => sum + i.totalAmount),
  //     ),
  //     RevenueData(
  //       'Feb',
  //       invoiceController.invoices
  //           .where((i) => i.date.month == 2)
  //           .fold(0, (sum, i) => sum + i.totalAmount),
  //     ),
  //     RevenueData(
  //       'Mar',
  //       invoiceController.invoices
  //           .where((i) => i.date.month == 3)
  //           .fold(0, (sum, i) => sum + i.totalAmount),
  //     ),
  //   ];

  //   final series = [
  //     charts.Series<RevenueData, String>(
  //       id: 'Revenue',
  //       domainFn: (RevenueData revenue, _) => revenue.month,
  //       measureFn: (RevenueData revenue, _) => revenue.revenue,
  //       data: data,
  //     ),
  //   ];

  //   return SizedBox(
  //     height: 300,
  //     child: charts.LineChart(series, animate: true),
  //   );
  // }
}

class SalesData {
  final String month;
  final int sales;

  SalesData(this.month, this.sales);
}

class StockData {
  final String product;
  final int stock;

  StockData(this.product, this.stock);
}

class RevenueData {
  final String month;
  final double revenue;

  RevenueData(this.month, this.revenue);
}
