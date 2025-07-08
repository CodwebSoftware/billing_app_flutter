import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LicenseService {
  // Secret key for generating and validating license keys
  static const String _secretKey = 'your-secret-key';

  // Generate a license key
  String generateLicenseKey(String userEmail) {
    final input = '$_secretKey-$userEmail';
    return sha256.convert(utf8.encode(input)).toString().substring(0, 16);
  }

  // Validate a license key
  Future<bool> validateLicense(String licenseKey, String userEmail) async {
    final expectedKey = generateLicenseKey(userEmail);
    if (licenseKey != expectedKey) return false;

    // Check activation count
    final activationCount = await LicenseUsage.getActivationCount();
    if (activationCount >= 3) { // Allow up to 3 activations
      return false;
    }

    // Save the license key and increment activation count
    await LicenseUsage.saveLicense(licenseKey);
    await LicenseUsage.incrementActivationCount();
    return true;
  }
}

class LicenseUsage {
  static const String _licenseKey = 'license_key';
  static const String _activationCountKey = 'activation_count';

  // Save the license key and activation count
  static Future<void> saveLicense(String licenseKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_licenseKey, licenseKey);
    await prefs.setInt(_activationCountKey, 1); // Initial activation
  }

  // Check if the license key is already activated
  static Future<bool> isLicenseActivated(String licenseKey) async {
    final prefs = await SharedPreferences.getInstance();
    final savedKey = prefs.getString(_licenseKey);
    return savedKey == licenseKey;
  }

  // Get the activation count
  
  static Future<int> getActivationCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_activationCountKey) ?? 0;
  }

  // Increment the activation count
  static Future<void> incrementActivationCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_activationCountKey) ?? 0;
    await prefs.setInt(_activationCountKey, count + 1);
  }
}