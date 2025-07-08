import 'package:billing_app_flutter/presentation/screens/settings/contact_us_screen.dart';
import 'package:flutter/material.dart';

class HelpCenterScreen extends StatelessWidget {
  final List<FAQItem> faqs = [
    FAQItem(
      question: "How do I reset my password?",
      answer: "Go to Settings > Account > Security and tap 'Change Password'. You'll receive an email with instructions to reset your password.",
    ),
    FAQItem(
      question: "How can I update my payment method?",
      answer: "Navigate to Settings > Payments to add or update your payment information.",
    ),
    FAQItem(
      question: "Where can I find my order history?",
      answer: "All your past orders are available in the 'Orders' section of your profile.",
    ),
    FAQItem(
      question: "How do I contact customer support?",
      answer: "You can reach our support team 24/7 through the Contact Us page or via live chat.",
    ),
    FAQItem(
      question: "What's your refund policy?",
      answer: "We offer 30-day refunds for most products. See our full policy in the Terms & Conditions.",
    ),
  ];

  final List<HelpCategory> categories = [
    HelpCategory(
      icon: Icons.account_circle_rounded,
      title: "Account Help",
      color: Colors.blue,
    ),
    HelpCategory(
      icon: Icons.payment_rounded,
      title: "Payments",
      color: Colors.green,
    ),
    HelpCategory(
      icon: Icons.shopping_bag_rounded,
      title: "Orders",
      color: Colors.orange,
    ),
    HelpCategory(
      icon: Icons.devices_rounded,
      title: "Technical Issues",
      color: Colors.purple,
    ),
  ];

  HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Help Center', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),textAlign: TextAlign.left, ),
        // centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with illustration
            Center(
              child: Column(
                children: [
                  // SvgPicture.asset(
                  //   'assets/help_center.svg', // Replace with your SVG
                  //   height: 150,
                  // ),
                  // SizedBox(height: 16),
                  Text(
                    'How can we help you?',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Find answers to common questions or contact our support team',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Search box
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showSearch(context),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 12),
                      Text(
                        'Search help articles...',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 24),

            // Categories grid
            Text(
              'Browse by Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryCard(context, categories[index]);
              },
            ),
            SizedBox(height: 24),

            // Popular questions
            Text(
              'Popular Questions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: faqs.length,
              itemBuilder: (context, index) {
                return _buildFAQItem(context, faqs[index]);
              },
            ),
            SizedBox(height: 16),

            // Contact support card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.support_agent_rounded,
                        size: 40, color: Theme.of(context).primaryColor),
                    SizedBox(height: 12),
                    Text(
                      'Still need help?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Our support team is available 24/7 to assist you',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ContactUsScreen())),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                              color: Theme.of(context).primaryColor),
                        ),
                        child: Text('Contact Support'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, HelpCategory category) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToCategory(context, category.title),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 40,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(category.icon, color: category.color, size: 24),
              ),
              SizedBox(height: 12),
              Text(
                category.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, FAQItem faq) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        children: [
          Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                faq.answer,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
              )),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: HelpSearchDelegate(faqs),
    );
  }

  void _navigateToCategory(BuildContext context, String category) {
    // Implement category navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Showing $category articles')),
    );
  }
}

class HelpSearchDelegate extends SearchDelegate {
  final List<FAQItem> faqs;

  HelpSearchDelegate(this.faqs);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = faqs
        .where((faq) =>
    faq.question.toLowerCase().contains(query.toLowerCase()) ||
        faq.answer.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildSearchResults(results);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = query.isEmpty
        ? faqs.take(3).toList()
        : faqs
        .where((faq) =>
    faq.question.toLowerCase().contains(query.toLowerCase()) ||
        faq.answer.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _buildSearchResults(suggestions);
  }

  Widget _buildSearchResults(List<FAQItem> items) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(items[index].question),
          subtitle: Text(items[index].answer,
              maxLines: 2, overflow: TextOverflow.ellipsis),
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(items[index].question),
                content: Text(items[index].answer),
                actions: [
                  TextButton(
                    child: Text('Close'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

class HelpCategory {
  final IconData icon;
  final String title;
  final Color color;

  HelpCategory({
    required this.icon,
    required this.title,
    required this.color,
  });
}
