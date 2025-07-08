import 'package:flutter/material.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with illustration
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SvgPicture.asset(
                  //   'assets/contact_us.svg', // Replace with your SVG asset
                  //   height: 180,
                  // ),
                  // SizedBox(height: 16),
                  Text(
                    'We\'d love to hear from you!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Reach out to us with any questions or feedback',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Contact form
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildInputField(
                    context,
                    controller: _nameController,
                    label: 'Your Name',
                    icon: Icons.person_outline_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  _buildInputField(
                    context,
                    controller: _emailController,
                    label: 'Email Address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  _buildInputField(
                    context,
                    controller: _messageController,
                    label: 'Your Message',
                    icon: Icons.message_outlined,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your message';
                      }
                      if (value.length < 10) {
                        return 'Message should be at least 10 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Send Message',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Alternative contact methods
            Text(
              'Other Ways to Reach Us',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildContactMethod(
              context,
              icon: Icons.phone_rounded,
              title: 'Call Us',
              subtitle: '+91 9404 124 875',
              color: Colors.blue,
              onTap: () => _launchPhoneCall(),
            ),
            SizedBox(height: 12),
            _buildContactMethod(
              context,
              icon: Icons.email_rounded,
              title: 'Email Us',
              subtitle: 'codwebsoftware@gmail.com',
              color: Colors.red,
              onTap: () => _launchEmail(),
            ),
            // SizedBox(height: 12),
            // _buildContactMethod(
            //   context,
            //   icon: Icons.chat_rounded,
            //   title: 'Live Chat',
            //   subtitle: 'Available 24/7',
            //   color: Colors.green,
            //   onTap: () => _launchChat(),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required IconData icon,
        required String? Function(String?) validator,
        TextInputType? keyboardType,
        int maxLines = 1,
      }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildContactMethod(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      // Form is valid, submit the data
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your message has been sent!'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      // Clear the form
      _nameController.clear();
      _emailController.clear();
      _messageController.clear();
    }
  }

  void _launchPhoneCall() {
    // Implement phone call functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Launching phone call...')),
    );
  }

  void _launchEmail() {
    // Implement email functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Launching email client...')),
    );
  }

  void _launchChat() {
    // Implement chat functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Launching live chat...')),
    );
  }
}