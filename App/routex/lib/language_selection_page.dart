import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSelectionPage extends StatelessWidget {
  final List<Locale> supportedLocales = [
    const Locale('en'),
    const Locale('si'),
    const Locale('ta'),
    // Add more supported locales here
  ];

  LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add gradient background
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.purple.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Text(
                    tr('select_language'),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: supportedLocales.length,
                  itemBuilder: (context, index) {
                    final locale = supportedLocales[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24.0, vertical: 8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 6,
                        child: ListTile(
                          leading: _getLanguageIcon(locale),
                          title: Text(
                            _getLanguageName(locale),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios,
                              color: Colors.deepPurple),
                          onTap: () async {
                            await context.setLocale(locale);
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Add icons for each language
  Widget _getLanguageIcon(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return const Icon(Icons.language, color: Colors.blueAccent);
      case 'si':
        return const Icon(Icons.flag, color: Colors.orange);
      case 'ta':
        return const Icon(Icons.flag, color: Colors.green);
      default:
        return const Icon(Icons.language, color: Colors.grey);
    }
  }

  String _getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'si':
        return 'සිංහල';
      case 'ta':
        return 'தமிழ்';
      default:
        return locale.languageCode;
    }
  }
}
