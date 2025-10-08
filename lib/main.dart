import 'package:flutter/material.dart';
import 'package:fitquest_frontend/pages/dashboard_page.dart';

void main() {
  runApp(const FitQuestApp());
}

class FitQuestApp extends StatelessWidget {
  const FitQuestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitQuest',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D0D0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF99),
          secondary: Color(0xFFFFD166),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white70),
        ),
      ),
      home: const DashboardPage(),
    );
  }
}
