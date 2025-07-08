import 'package:billing_app_flutter/db/models/product_category_entity.dart';
import 'package:billing_app_flutter/objectbox.g.dart';
import 'package:billing_app_flutter/objectboxes.dart';
import 'package:get/get.dart';

class ProductCategoryController extends GetxController {
  final ObjectBoxes objectBox;

  var productCategories = <ProductCategoryEntity>[].obs;

  ProductCategoryController({required this.objectBox});

  @override
  void onInit() async {
    super.onInit();
    getAllCategories();
  }

  // Create a category or subcategory
  Future<int> createCategory(ProductCategoryEntity category, {int? parentCategoryId}) async {
    if (parentCategoryId != null) {
      final parent = objectBox.productCategoryBox.get(parentCategoryId);
      if (parent != null) {
        category.parent.target = parent;
      }
    }
    return objectBox.productCategoryBox.put(category);
  }

  // Read All Categories
  getAllCategories() {
    productCategories.value = objectBox.productCategoryBox.getAll();
  }

  // Read all root categories (no parent)
  getRootCategories() {
    productCategories.value =
        objectBox.productCategoryBox
            .query(ProductCategoryEntity_.parent.isNull())
            .build()
            .find();
  }

  // Read subcategories of a parent category
  getSubcategories(int parentCategoryId) {
    final parent = objectBox.productCategoryBox.get(parentCategoryId);
    if (parent != null) {
      // Load the subcategories
      productCategories.value = parent.subcategories;
    }
    productCategories.value = [];
  }

  getCategoriesByNameOrCode(String str) {
    // Build a query to find invoices where the customer matches
    final query =
        objectBox.productCategoryBox
            .query(
              ProductCategoryEntity_.name
                  .startsWith(str, caseSensitive: false)
                  .or(ProductCategoryEntity_.code.startsWith(str)),
            )
            .build();

    // Execute the query and get the results
    productCategories.value = query.find();
    query.close();
  }

  // Read a single category
  ProductCategoryEntity? getCategory(int id) {
    return objectBox.productCategoryBox.get(id);
  }

  // Update a category
  void updateCategory(ProductCategoryEntity category) {
    objectBox.productCategoryBox.put(category);
  }

  // Delete a category and its subcategories (recursive)
  bool deleteCategory(int id, {bool deleteProducts = false}) {
    final category = objectBox.productCategoryBox.get(id);
    if (category != null) {
      // Delete all subcategories first
      for (final subcategory in category.subcategories) {
        deleteCategory(subcategory.id, deleteProducts: deleteProducts);
      }

      // Handle products if needed
      if (deleteProducts) {
        for (var product in category.products) {
          product.isDeleted = true;
          objectBox.productBox.put(product);
        }
      } else {
        for (final product in category.products) {
          product.category.target = null;
          objectBox.productBox.put(product);
        }
      }

      // Finally delete the category itself
      category.isDeleted = true;
      objectBox.productCategoryBox.put(category);
      return true;
    }
    return false;
  }

  // Get the full hierarchy path of a category
  List<ProductCategoryEntity> getCategoryPath(int categoryId) {
    final path = <ProductCategoryEntity>[];
    var current = objectBox.productCategoryBox.get(categoryId);

    while (current != null) {
      path.insert(0, current);
      current = current.parent.target;
    }

    return path;
  }
}
