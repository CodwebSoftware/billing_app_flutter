import 'dart:io';
import 'package:billing_app_flutter/db/controllers/product_controller.dart';
import 'package:billing_app_flutter/db/controllers/service_controller.dart';
import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';

Future<File> generateInvoicePdf(
    {required SaleEntryEntity invoice,required CustomerEntity customer}) async {
  final pdf = pw.Document();

  final serviceController = Get.find<ServiceController>();

  final productController = Get.find<ProductController>();

  // Load a custom font (optional)
  final font = await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
  final ttf = pw.Font.ttf(font);

  // Add a page
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Header
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('INVOICE', style: pw.TextStyle(font: ttf, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                pw.Text('No: ${invoice.invoiceNumber}', style: pw.TextStyle(font: ttf, fontSize: 7)),
                pw.Text('Date: ${DateFormat('yyyy-MM-dd').format(invoice.date!)}', style: pw.TextStyle(font: ttf, fontSize: 7)),
              ],
            ),

            pw.Container(
              margin: pw.EdgeInsets.symmetric(vertical: 5),
                color: PdfColors.blue200,
                height: 2),

            // From - To section
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // From
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('From:', style: pw.TextStyle(font: ttf, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text('The Beauty Hub', style: pw.TextStyle(font: ttf, fontSize: 7,)),
                      pw.Text('New SBH Colony, Jyoti Nagar', style: pw.TextStyle(font: ttf, fontSize: 7,)),
                      pw.Text('New Usmanpura, Chh. Sambhaji Nagar', style: pw.TextStyle(font: ttf, fontSize: 7,)),
                      pw.Text('+91 88306 55830', style: pw.TextStyle(font: ttf, fontSize: 7,)),
                    ],
                  ),
                ),

                // To
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('To:', style: pw.TextStyle(font: ttf, fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text(customer.name!, style: pw.TextStyle(font: ttf, fontSize: 7,)),
                      pw.Text(customer.email!, style: pw.TextStyle(font: ttf, fontSize: 7,)),
                      pw.Text(customer.phone!, style: pw.TextStyle(font: ttf, fontSize: 7,)),
                    ],
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // Invoice items table
            pw.Table(
              // border: pw.TableBorder.all(),
              children: [
                // Header row
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue200, // Light blue background
                  ),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Description', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 8,)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Quantity', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 8,)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Unit Price', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 8,)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(4),
                      child: pw.Text('Total', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 8,)),
                    ),
                  ],
                ),

                // Service rows
                ...invoice.services.map((service){
                  final serviceRes = serviceController.getService(service.service.target!.id);
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50, // Light blue background
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(serviceRes!.name!, style: pw.TextStyle(font: ttf, fontSize: 7)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(service.quantity.toString(), style: pw.TextStyle(font: ttf, fontSize: 7)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('₹ ${service.price!.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 7)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('₹ ${(service.quantity! * service.price!).toStringAsFixed(2)}',
                            style: pw.TextStyle(font: ttf, fontSize: 7)),
                      ),
                    ],
                  );
                }).toList(),

                // Item rows
                ...invoice.items.map((item){
                  final itemRes = productController.getProduct(item.product.target!.id);
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue50, // Light blue background
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(itemRes!.name!, style: pw.TextStyle(font: ttf, fontSize: 7)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(item.quantity.toString(), style: pw.TextStyle(font: ttf, fontSize: 7)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('₹ ${item.unitPrice!.toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 7)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('₹ ${(item.quantity! * item.unitPrice!).toStringAsFixed(2)}',
                            style: pw.TextStyle(font: ttf, fontSize: 7)),
                      ),
                    ],
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 10),

            // Totals
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text('Subtotal: ', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 8)),
                      pw.Text('₹ ${calculateSubtotal().toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 8)),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  pw.Row(
                    mainAxisSize: pw.MainAxisSize.min,
                    children: [
                      pw.Text('Total: ', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('₹ ${calculateTotal().toStringAsFixed(2)}', style: pw.TextStyle(font: ttf, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),

            pw.Container(
                margin: pw.EdgeInsets.symmetric(vertical: 15),
                color: PdfColors.blue200,
                height: 2),

            // Footer
            pw.Text('Thank you for visiting The Beauty Hub Salon !', style: pw.TextStyle(font: ttf, fontWeight: pw.FontWeight.bold, fontSize: 8,)),
          ],
        );
      },
    ),
  );
  // return pdf;

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/document.pdf');

  await file.writeAsBytes(await pdf.save());
  return file;
}

// Sample data model and calculations
class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;

  InvoiceItem(this.description, this.quantity, this.unitPrice);
}

List<InvoiceItem> invoiceItems = [
  InvoiceItem('Website Development', 1, 2000.00),
  InvoiceItem('SEO Services', 1, 500.00),
  InvoiceItem('Hosting (1 year)', 1, 300.00),
];

double calculateSubtotal() {
  return invoiceItems.fold(0, (sum, item) => sum + (item.quantity * item.unitPrice));
}

double calculateTax() {
  return calculateSubtotal() * 0.10;
}

double calculateTotal() {
  return calculateSubtotal() + calculateTax();
}