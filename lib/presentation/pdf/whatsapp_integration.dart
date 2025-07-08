import 'package:url_launcher/url_launcher.dart';

Future<void> sendLinkToWhatsApp({String? mobile, String? message}) async {
  String whatsappUrl = "whatsapp://send?phone=91$mobile&text=$message";

  if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
    await launchUrl(Uri.parse(whatsappUrl));
  } else {
    print("WhatsApp is not installed or URL could not be launched.");
  }
}