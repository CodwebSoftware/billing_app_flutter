import 'dart:io';

import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/presentation/pdf/generate_invoice_pdf.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;

class SaleEntryPdfScreen extends StatelessWidget {
  final File pdf;

  SaleEntryPdfScreen({Key? key, required this.pdf});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Preview')),
      body: PDFView(
        filePath: pdf.path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
        onError: (error) {
          print(error.toString());
        },
        onPageError: (page, error) {
          print('$page: ${error.toString()}');
        },
        onViewCreated: (PDFViewController controller) {
          print('PDF view created');
        },
      ),
    );
  }
}
