import 'dart:async';

import 'package:billing_app_flutter/db/controllers/product_controller.dart';
import 'package:billing_app_flutter/db/models/batch_entity.dart';
import 'package:billing_app_flutter/db/models/product_entity.dart';
import 'package:billing_app_flutter/presentation/screens/products/add_edit_batch_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FindBatchScreen extends StatefulWidget {
  final ProductEntity product;

  const FindBatchScreen({super.key, required this.product});

  @override
  State<FindBatchScreen> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<FindBatchScreen> {
  final productController = Get.find<ProductController>();
  final _searchController = TextEditingController();
  List<BatchEntity>? batchList;
  List<BatchEntity>? filteredBatchList;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    batchList = productController.getActiveBatchesForProduct(widget.product);
    filteredBatchList = batchList;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _filterBatches();
    });
  }

  void _filterBatches() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredBatchList = batchList ?? [];
      } else if (batchList != null) {
        final exactMatches =
            batchList!
                .where((batch) => batch.batchNumber?.toLowerCase() == query)
                .toList();
        final partialMatches =
            batchList!
                .where(
                  (batch) =>
                      (batch.batchNumber?.toLowerCase().contains(query) ??
                          false) &&
                      batch.batchNumber?.toLowerCase() != query,
                )
                .toList();

        filteredBatchList =
            [
              ...exactMatches,
              ...partialMatches,
              ...batchList!
                  .where(
                    (batch) =>
                        batch.quantity.toString().contains(query) ||
                        batch.unitPrice.toString().contains(query),
                  )
                  .toList(),
            ].toList(); // Remove duplicates
      } else {
        filteredBatchList = [];
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      //AddEditBatchScreen
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Select Batch',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            onPressed: () async {
              await Get.dialog(
                AddEditBatchScreen(
                  product: widget.product,
                  batch: BatchEntity(),
                ),
              );
              batchList = productController.getActiveBatchesForProduct(
                widget.product,
              );
              setState(() {});
            },
            icon: Icon(Icons.add_outlined),
          ),
        ],
      ),
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
                  hintText: 'Search by batch, quantity, or price...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => _searchController.clear(),
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            // Batch List
            Expanded(
              child:
                  filteredBatchList == null || filteredBatchList!.isEmpty
                      ? const Center(child: Text('No batches found'))
                      : ListView.builder(
                        itemCount: filteredBatchList!.length,
                        itemBuilder: (context, index) {
                          final batch = filteredBatchList![index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            child: ListTile(
                              title: Text(
                                widget.product.name ?? 'Unknown Product',
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.product.description ??
                                        'No description',
                                  ),
                                  Text('Batch: ${batch.batchNumber ?? 'N/A'}'),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Qty: ${batch.quantity}'),
                                  Text('₹ ${batch.unitPrice}'),
                                ],
                              ),
                              onTap: () => Get.back(result: batch),
                            ),
                          );
                        },
                      ),
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
