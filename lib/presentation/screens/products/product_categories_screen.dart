import 'package:billing_app_flutter/db/controllers/product_category_controller.dart';
import 'package:billing_app_flutter/db/models/product_category_entity.dart';
import 'package:billing_app_flutter/presentation/screens/products/add_edit_product_category_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductCategoriesScreen extends StatefulWidget {
  const ProductCategoriesScreen({super.key});

  @override
  State<ProductCategoriesScreen> createState() =>
      _ProductCategoriesScreenState();
}

class _ProductCategoriesScreenState extends State<ProductCategoriesScreen> {
  final ProductCategoryController _productCategoryController =
      Get.find<ProductCategoryController>();

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productCategoryController.getAllCategories();
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    _productCategoryController.getCategoriesByNameOrCode(
      _searchController.text,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text('Product Categories'),
            SizedBox(
              width: 400,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search by name / code",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await Get.dialog(
                AddEditProductCategoryScreen(
                  productCategoryEntity: ProductCategoryEntity(
                    ),
                ),
              );
              setState(() {});
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: _productCategoryController.productCategories.length,
          itemBuilder: (context, index) {
            ProductCategoryEntity categoryEntity =
                _productCategoryController.productCategories[index];
            return ListTile(
              title: Text(categoryEntity.name!),
              subtitle: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Code ${categoryEntity.code}"),
                  Text(
                    "No. of Sub Categories ${categoryEntity.subcategories.length}",
                  ),
                  Text("No. of Products ${categoryEntity.products.length}"),
                ],
              ),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined),
                      onPressed: () async {
                        await Get.dialog(
                          AddEditProductCategoryScreen(
                            productCategoryEntity: categoryEntity,
                          ),
                        );
                        setState(() {});
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline),
                      onPressed:
                          () => _productCategoryController.deleteCategory(
                            categoryEntity.id,
                            deleteProducts: true,
                          ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
