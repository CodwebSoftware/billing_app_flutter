import 'package:billing_app_flutter/db/models/company_branch_profile_entity.dart';
import 'package:billing_app_flutter/db/models/company_profile_entity.dart';
import 'package:billing_app_flutter/objectbox.g.dart';
import 'package:billing_app_flutter/objectboxes.dart';
import 'package:get/get.dart';
import 'package:objectbox/objectbox.dart';

class CompanyProfileController extends GetxController {
  final ObjectBoxes objectBox;
  var companyProfileEntities = <CompanyProfileEntity>[].obs;
  var companyBranches = <CompanyBranchProfileEntity>[].obs;

  var selectedCompanyProfile = CompanyProfileEntity().obs;
  var selectedCompanyBranch = CompanyBranchProfileEntity().obs;

  CompanyProfileController({required this.objectBox});

  getCompanyProfiles() {
    companyProfileEntities.value = objectBox.companyProfileBox.getAll();
  }

  getCompanyBranchProfiles() {
    final query =
        objectBox.companyBranchBox
            .query(CompanyBranchProfileEntity_.companyId.equals(selectedCompanyProfile.value.id!))
            .build();

    // Execute the query and get the results
    companyBranches.value = query.find();
    query.close();
  }

  getCompanyProfilesByName(String str) {
    final query =
        objectBox.companyProfileBox
            .query(
              CompanyProfileEntity_.name.startsWith(str, caseSensitive: false),
            )
            .build();

    // Execute the query and get the results
    companyProfileEntities.value = query.find();
    query.close();
  }

  getCompanyBranchesByName(String str) {
    final query =
    objectBox.companyBranchBox
        .query(
      CompanyBranchProfileEntity_.branchName.startsWith(str, caseSensitive: false)
          .and(CompanyBranchProfileEntity_.companyId.equals(selectedCompanyProfile.value.id!)),
    )
        .build();

    // Execute the query and get the results
    companyBranches.value = query.find();
    query.close();
  }

  saveCompanyProfile(CompanyProfileEntity companyProfileEntity) {
    objectBox.companyProfileBox.put(companyProfileEntity, mode: PutMode.put);
  }

  saveCompanyBranchProfile(CompanyBranchProfileEntity c){
    objectBox.companyBranchBox.put(c);
  }
}
