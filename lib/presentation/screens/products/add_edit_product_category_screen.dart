import 'package:billing_app_flutter/db/controllers/product_category_controller.dart';
import 'package:billing_app_flutter/db/models/product_category_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddEditProductCategoryScreen extends StatelessWidget {
  final ProductCategoryController productCategoryController = Get.find();
  final ProductCategoryEntity productCategoryEntity;
  final TextEditingController nameController;
  final TextEditingController codeController;

  AddEditProductCategoryScreen({super.key, required this.productCategoryEntity})
    : nameController = TextEditingController(text: productCategoryEntity.name),
      codeController = TextEditingController(text: productCategoryEntity.code);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add / Edit Product'),
      content: Container(
        height: 300,
        width: 300,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: codeController,
              decoration: InputDecoration(labelText: 'Code'),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                productCategoryEntity.name = nameController.text;
                productCategoryEntity.code = codeController.text;
                await productCategoryController.createCategory(
                  productCategoryEntity,
                );
                productCategoryController.getAllCategories();
                Get.back();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
