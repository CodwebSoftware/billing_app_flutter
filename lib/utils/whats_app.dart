import 'package:url_launcher/url_launcher.dart';

Future<void> sendWhatsAppMessage(String phoneNumber, String message) async {
  String formattedPhone = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
  if (!formattedPhone.startsWith('+')) {
    formattedPhone = '+91$formattedPhone'; // Example: India country code
  }

  final encodedMessage = Uri.encodeComponent(message);
  final whatsappUrl = 'whatsapp://send?phone=$formattedPhone&text=$encodedMessage';

  final uri = Uri.parse(whatsappUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    throw 'Could not launch WhatsApp. Ensure WhatsApp is installed or accessible.';
  }
}