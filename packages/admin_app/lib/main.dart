import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Firebase.initializeApp()
  runApp(const HaruPassAdminApp());
}

class HaruPassAdminApp extends StatelessWidget {
  const HaruPassAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '하루패스',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const AdminHomePlaceholder(),
    );
  }
}

class AdminHomePlaceholder extends StatelessWidget {
  const AdminHomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('하루패스'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '하루패스',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '관리자 앱',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
