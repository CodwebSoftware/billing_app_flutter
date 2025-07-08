import 'dart:async';

import 'package:billing_app_flutter/db/controllers/product_controller.dart';
import 'package:billing_app_flutter/db/models/product_entity.dart';
import 'package:billing_app_flutter/presentation/screens/products/add_edit_product_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FindProductScreen extends StatefulWidget {
  const FindProductScreen({super.key});

  @override
  State<FindProductScreen> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<FindProductScreen> {
  final productController = Get.find<ProductController>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    productController.loadActiveProducts();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Find Product',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(onPressed: () async{
            await Get.dialog(AddEditProductScreen(product: ProductEntity()));
            setState(() {

            });
          }, icon: Icon(Icons.add_outlined))
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.grey.shade600),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
            ),
            // Product List with Cards
            Expanded(
              child: Obx(() {
                final filteredProducts = productController.products.where((product) {
                  final name = product.name?.toLowerCase() ?? '';
                  final description = product.description?.toLowerCase() ?? '';
                  return name.contains(_searchQuery) || description.contains(_searchQuery);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text(
                      'No products found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    ProductEntity product = filteredProducts[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: InkWell(
                        onTap: () {
                          Get.back(result: product);
                        },
                        borderRadius: BorderRadius.circular(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name ?? 'Unknown Product',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.description ?? 'No description',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Qty: ${product.quantity ?? 0}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '₹ ${product.price?.toStringAsFixed(2) ?? '0.00'} /-',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
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
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text('Cancel'),
        ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      backgroundColor: Colors.white,
    );
  }
}