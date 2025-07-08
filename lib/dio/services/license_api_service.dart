import 'package:billing_app_flutter/core/constants/constants.dart';
import 'package:billing_app_flutter/dio/models/license/license_model.dart';
import 'package:billing_app_flutter/dio/models/purchase/complete_purchase_request.dart';
import 'package:billing_app_flutter/dio/models/purchase/create_purchase_request.dart';
import 'package:billing_app_flutter/dio/models/purchase/purchase_model.dart';
import 'package:billing_app_flutter/dio/models/renew_license/renew_license_request.dart';
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'license_api_service.g.dart';

@RestApi(baseUrl: BASE_URL)
abstract class LicenseApiService {
  factory LicenseApiService(Dio dio, {String baseUrl}) = _LicenseApiService;

  @GET("/licenses/user/{email}")
  Future<List<LicenseModel>> getUserLicenses(@Path("email") String email);

  @POST("/licenses/validate")
  Future<LicenseModel> validateLicense(@Body() Map<String, dynamic> body);

  @POST("/licenses/renew")
  Future<LicenseModel> renewLicense(@Body() RenewLicenseRequest request);

  @POST("/purchases")
  Future<PurchaseModel> createPurchase(@Body() CreatePurchaseRequest request);

  @POST("/purchases/complete")
  Future<LicenseModel> completePurchase(
    @Body() CompletePurchaseRequest request,
  );

  @GET("/purchases/{id}")
  Future<PurchaseModel> getPurchase(@Path("id") String id);

  @POST("/purchases/cash")
  Future<PurchaseModel> processCashPayment(@Body() Map<String, dynamic> body);

  @POST("/purchases/check")
  Future<PurchaseModel> processCheckPayment(@Body() Map<String, dynamic> body);
}
