import 'package:billing_app_flutter/db/models/company_profile_entity.dart';
import 'package:billing_app_flutter/objectboxes.dart';

class CompanyProfileRepository {
  ObjectBoxes _objectBoxes;
  CompanyProfileRepository(this._objectBoxes);

  int addCompanyProfile(CompanyProfileEntity companyProfileEntity) =>
      _objectBoxes.companyProfileBox.put(companyProfileEntity);

  CompanyProfileEntity? getCompanyProfile(int id) => _objectBoxes.companyProfileBox.get(id);

  List<CompanyProfileEntity> getAllCompanyProfiles() =>
      _objectBoxes.companyProfileBox.getAll();


  bool updateCompanyProfile(CompanyProfileEntity companyProfileEntity) =>
      _objectBoxes.companyProfileBox.put(companyProfileEntity) > 0;
}
