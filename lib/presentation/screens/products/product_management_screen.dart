import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:billing_app_flutter/db/controllers/product_controller.dart';
import 'package:billing_app_flutter/db/models/product_entity.dart';
import 'package:billing_app_flutter/presentation/screens/products/add_edit_product_screen.dart';
import 'package:billing_app_flutter/presentation/screens/products/product_detail_screen.dart';
import 'package:billing_app_flutter/presentation/screens/products/product_categories_screen.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final ProductController _productController = Get.find<ProductController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    _productController.loadProductsByNameOrCode(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or code',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.analytics_outlined),
          //   tooltip: 'Analytics',
          //   onPressed: () async {
          //     // await Get.dialog(FrequentProductsView());
          //   },
          // ),
          // IconButton(
          //   icon: const Icon(Icons.category_outlined),
          //   tooltip: 'Categories',
          //   onPressed: () async {
          //     await Get.to(const ProductCategoriesScreen());
          //     setState(() {});
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Product',
            onPressed: () async {
              await Get.dialog(AddEditProductScreen(product: ProductEntity()));
              setState(() {});
            },
          ),
        ],
      ),
      body: Obx(
            () => _productController.products.isEmpty
            ? Center(
          child: Text(
            'No products found',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        )
            : isLargeScreen
            ? _buildGridView()
            : _buildListView(),
      ),
    );
  }

  Widget _buildListView() {
    return RefreshIndicator(
      onRefresh: () async {
        _productController.loadProductsByNameOrCode(_searchController.text);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _productController.products.length,
        itemBuilder: (context, index) => _buildProductCard(_productController.products[index]),
      ),
    );
  }

  Widget _buildGridView() {
    return RefreshIndicator(
      onRefresh: () async {
        _productController.loadProductsByNameOrCode(_searchController.text);
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 400,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _productController.products.length,
        itemBuilder: (context, index) => _buildProductCard(_productController.products[index]),
      ),
    );
  }

  Widget _buildProductCard(ProductEntity product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: product.isDeleted! ? Colors.grey.shade200 : Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Get.dialog(ProductDetailScreen(product: product));
          setState(() {});
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.name!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (product.isDeleted!)
                    Chip(
                      label: const Text('Deleted'),
                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Price: ₹${product.price!.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'Quantity: ${product.quantity}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!product.isDeleted!)
                    _buildActionButton(
                      icon: Icons.aod_outlined,
                      tooltip: 'View Details',
                      onPressed: () async {
                        await Get.dialog(ProductDetailScreen(product: product));
                        setState(() {});
                      },
                    ),
                  if (!product.isDeleted!)
                    _buildActionButton(
                      icon: Icons.edit_outlined,
                      tooltip: 'Edit Product',
                      onPressed: () async {
                        await Get.dialog(AddEditProductScreen(product: product));
                        setState(() {});
                      },
                    ),
                  _buildActionButton(
                    icon: product.isDeleted! ? Icons.add : Icons.delete_outline,
                    tooltip: product.isDeleted! ? 'Revoke Product' : 'Delete Product',
                    onPressed: () {
                      product.isDeleted = !product.isDeleted!;
                      _productController.saveProduct(product);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onPressed,
      color: Theme.of(context).colorScheme.primary,
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}