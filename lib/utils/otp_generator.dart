import 'dart:math';

Future<void> sendOTP(String phoneNumber) async{
  // Generate a random 6-digit OTP
  String otp = (100000 + Random().nextInt(900000)).toString();
  print("Generated OTP => $otp");
}