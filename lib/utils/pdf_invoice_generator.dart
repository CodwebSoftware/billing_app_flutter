import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfInvoiceGenerator {
  static Future<pw.Document> generateInvoice(SaleEntryEntity invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(level: 0, child: pw.Text('Invoice')),
              pw.Text('Invoice Number: ${invoice.invoiceNumber}'),
              pw.Text('Date: ${invoice.date!.toLocal()}'),
              pw.SizedBox(height: 20),
              pw.Text('Customer: ${invoice.customer.target!.name}'),
              pw.Text('Email: ${invoice.customer.target!.email}'),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                context: context,
                data: [
                  ['Description', 'Quantity', 'Unit Price', 'Total'],
                  ...invoice.items.map(
                    (item) => [
                      // item.description,
                      item.quantity.toString(),
                      '\₹ ${item.unitPrice!.toStringAsFixed(2)} /-',
                      '\₹ ${item.getSubtotal().toStringAsFixed(2)} /-',
                    ],
                  ),
                  [
                    '',
                    '',
                    'Total Amount',
                    '\₹ ${invoice.totalAmount.toStringAsFixed(2)} /-',
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
