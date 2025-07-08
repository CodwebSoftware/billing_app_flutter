import 'package:billing_app_flutter/db/models/service_entity.dart';
import 'package:billing_app_flutter/objectbox.g.dart';
import 'package:billing_app_flutter/objectboxes.dart';
import 'package:get/get.dart';

class ServiceController extends GetxController {
  final ObjectBoxes objectBox;
  final RxList<ServiceEntity> services = <ServiceEntity>[].obs;

ServiceController({required this.objectBox});

  @override
  void onInit() async {
    super.onInit();
    loadServices();
  }

  void loadServices() {
    services.value = objectBox.serviceBox.getAll();
  }


  loadServicesByNameOrCode(String str){
    // Build a query to find invoices where the customer matches
    final query =
    objectBox.serviceBox
        .query(ServiceEntity_.name.startsWith(str, caseSensitive: false).or(ServiceEntity_.code.startsWith(str)))
        .build();

    // Execute the query and get the results
    services.value = query.find();
    query.close();
  }

  ServiceEntity? getService(int id){
    return objectBox.serviceBox.get(id);
  }

  void saveService(ServiceEntity service) {
    if(service.id == 0)
    objectBox.serviceBox.put(service, mode: PutMode.insert);
    else
      objectBox.serviceBox.put(service, mode: PutMode.update);
    loadServices();
  }
}
