import 'package:billing_app_flutter/db/models/batch_entity.dart';
import 'package:billing_app_flutter/db/models/product_entity.dart';
import 'package:billing_app_flutter/objectbox.g.dart';
import 'package:billing_app_flutter/objectboxes.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  final ObjectBoxes objectBox;
  var products = <ProductEntity>[].obs;

  ProductController({required this.objectBox});

  @override
  void onInit() async {
    super.onInit();
    loadProducts();
  }

  void loadProducts() {
    products.value = objectBox.productBox.getAll();
  }

  void loadActiveProducts() {
    final query =
        objectBox.productBox
            .query(ProductEntity_.isDeleted.equals(false))
            .build();

    products.value = query.find();
    query.close();
  }

  List<BatchEntity> getActiveBatchesForProduct(ProductEntity productEntity){
    return productEntity.batches
        .where((batch) => !batch.isDeleted!)
        .toList();
  }

  loadProductsByNameOrCode(String str) {
    // Build a query to find invoices where the customer matches
    final query =
        objectBox.productBox
            .query(
              ProductEntity_.name
                  .startsWith(str, caseSensitive: false)
                  .or(ProductEntity_.code.startsWith(str)),
            )
            .build();

    // Execute the query and get the results
    products.value = query.find();
    query.close();
  }

  void saveProduct(ProductEntity product) {
    objectBox.productBox.put(product);
    loadProducts();
  }

  void saveBatch(BatchEntity batch) {
    objectBox.batchBox.put(batch);
    loadProducts();
  }

  void saveBatchToProduct(ProductEntity product, BatchEntity batch) {
    product.quantity = product.quantity! + batch.quantity!;
    batch.product.target = product;
    objectBox.batchBox.put(batch);
    product.batches.add(batch);
    objectBox.productBox.put(product);
    update();
    loadProducts();
  }

  ProductEntity? getProduct(int id) {
    return objectBox.productBox.get(id);
  }

  BatchEntity? getBatch(int id) {
    return objectBox.batchBox.get(id);
  }

  int countProducts() {
    return objectBox.productBox.count();
  }

  int countBatches() {
    return objectBox.batchBox.count();
  }

  (BatchEntity?, ProductEntity?) findProductAndBatchByBarcode(String barcode) {
    // Create a query to find a batch with the matching barcode
    final batchQuery = objectBox.batchBox.query(BatchEntity_.barcode.equals(barcode)).build();

    // Find a unique batch (assuming barcodes are unique)
    final batch = batchQuery.findUnique();

    // Close the query to free resources
    batchQuery.close();

    if (batch != null) {
      // Get the associated product via the ToOne relationship
      final product = batch.product.target;
      return (batch, product);
    } else {
      // No batch found, return null for both
      return (null, null);
    }
  }
}
