import 'package:billing_app_flutter/db/controllers/product_controller.dart';
import 'package:billing_app_flutter/db/models/batch_entity.dart';
import 'package:billing_app_flutter/db/models/product_entity.dart';
import 'package:billing_app_flutter/presentation/screens/products/add_edit_batch_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ProductDetailScreen extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailScreen({Key? key, required this.product})
    : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductController _productController = Get.find();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Debounced search listener
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        setState(() {});
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  List<BatchEntity> _filterBatches(String query) {
    if (query.isEmpty) {
      return widget.product.batches.toList()
        ..sort((a, b) => a.batchNumber!.compareTo(b.batchNumber!));
    }

    final lowerQuery = query.toLowerCase();
    return widget.product.batches.where((batch) {
        final batchNumberMatch = batch.batchNumber!.toLowerCase().contains(
          lowerQuery,
        );
        final unitPriceMatch = batch.unitPrice
            .toString()
            .toLowerCase()
            .contains(lowerQuery);
        final quantityMatch = batch.quantity.toString().toLowerCase().contains(
          lowerQuery,
        );
        final expiryDateMatch = DateFormat('yyyy-MM-dd')
            .format(batch.expiryDate!.toLocal())
            .toLowerCase()
            .contains(lowerQuery);
        return batchNumberMatch ||
            unitPriceMatch ||
            quantityMatch ||
            expiryDateMatch;
      }).toList()
      ..sort((a, b) => a.batchNumber!.compareTo(b.batchNumber!));
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;
    final filteredBatches = _filterBatches(_searchController.text);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product.name!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search batches (number, price, quantity, expiry)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surface.withOpacity(0.8),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              filteredBatches.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No batches found',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    padding: EdgeInsets.all(isLargeScreen ? 24 : 16),
                    itemCount: filteredBatches.length,
                    itemBuilder: (context, index) {
                      final batch = filteredBatches[index];
                      return AnimatedOpacity(
                        opacity: batch.isDeleted! ? 0.6 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          color:
                              batch.isDeleted!
                                  ? Colors.grey.shade100
                                  : Theme.of(context).colorScheme.surface,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.1),
                              child: Icon(
                                Icons.inventory,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            title: Text(
                              'Batch: ${batch.batchNumber}',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color:
                                    batch.isDeleted!
                                        ? Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant
                                        : Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Price: \$${batch.unitPrice!.toStringAsFixed(2)} | Qty: ${batch.quantity} | Expiry: ${DateFormat('yyyy-MM-dd').format(batch.expiryDate!.toLocal())}',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (!batch.isDeleted!)
                                    _buildActionButton(
                                      icon: Icons.edit_outlined,
                                      tooltip: 'Edit batch',
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      onPressed: () async {
                                        await Get.dialog(
                                          AddEditBatchScreen(
                                            product: batch.product.target!,
                                            batch: batch,
                                          ),
                                        );
                                        setState(() {});
                                      },
                                    ),
                                  _buildActionButton(
                                    icon:
                                        batch.isDeleted!
                                            ? Icons.add_outlined
                                            : Icons.delete_outline,
                                    tooltip:
                                        batch.isDeleted!
                                            ? 'Re-add batch'
                                            : 'Delete batch',
                                    color:
                                        batch.isDeleted!
                                            ? Colors.green
                                            : Theme.of(
                                              context,
                                            ).colorScheme.error,
                                    onPressed: () {
                                      batch.isDeleted = !batch.isDeleted!;
                                      _productController.saveBatch(batch);
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              // Add Batch Button
              Positioned(
                bottom: isLargeScreen ? 24 : 16,
                right: isLargeScreen ? 24 : 16,
                child:
                    isLargeScreen
                        ? ElevatedButton.icon(
                          onPressed: () async {
                            await Get.dialog(
                              AddEditBatchScreen(
                                product: widget.product,
                                batch: BatchEntity(),
                              ),
                            );
                            setState(() {});
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Batch'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            textStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        : FloatingActionButton.extended(
                          onPressed: () async {
                            await Get.dialog(
                              AddEditBatchScreen(
                                product: widget.product,
                                batch: BatchEntity(),
                              ),
                            );
                            setState(() {});
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add Batch'),
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}
