// lib/screens/policy_page.dart
import 'package:flutter/material.dart';
import 'package:panot/theme/app_theme.dart';

class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Policies'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Terms and Conditions'),
            _buildParagraph(
              'Welcome to NU-Dine! This application is provided as a service to the students and sellers of National University - Dasmarinas. By creating an account and using this app, you agree to the following terms:',
            ),
            _buildListItem(
                '1. Purpose: NU-Dine is a directory for viewing campus shops and their menus. It is not a platform for financial transactions or direct ordering.'),
            _buildListItem(
                '2. Account Responsibility: You are responsible for maintaining the confidentiality of your account password and for all activities that occur under your account.'),
            _buildListItem(
                '3. Seller Conduct: Sellers are responsible for keeping their shop information, menu items, prices, and availability accurate and up-to-date.'),
            _buildListItem(
                '4. Student Conduct: Students are expected to provide fair and respectful reviews and feedback. Any abusive, spam, or inappropriate content will be removed, and may result in account suspension.'),
            _buildListItem(
                '5. Limitation of Liability: NU-Dine and its administrators are not responsible for the quality of food, service from sellers, or any issues arising from direct interactions between students and sellers.'),
            const SizedBox(height: 24),
            _buildSectionTitle('Data Privacy Policy'),
            _buildParagraph(
              'We are committed to protecting your privacy. This policy outlines how we collect, use, and protect your personal information.',
            ),
            _buildListItem(
                '1. Information We Collect: We collect your name, email address, and role (Student/Seller). For students, we also collect your Student ID, Course, and Year Level to verify your status within the university community.'),
            _buildListItem(
                '2. Use of Information: Your information is used solely to provide and improve the services of the NU-Dine app, manage your account, and facilitate communication within the app (e.g., reviews).'),
            _buildListItem(
                '3. Data Storage: Your data is securely stored using Supabase services. We implement industry-standard security measures to protect your information from unauthorized access.'),
            _buildListItem(
                '4. Data Sharing: We will not sell, distribute, or lease your personal information to third parties unless we have your permission or are required by law to do so.'),
            const SizedBox(height: 16),
            _buildParagraph(
                'By checking the consent box during registration, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions and Data Privacy Policy.'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, height: 1.5),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, height: 1.5),
        textAlign: TextAlign.justify,
      ),
    );
  }
}