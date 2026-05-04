import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Firebase.initializeApp()
  runApp(const HaruPassSubjectApp());
}

class HaruPassSubjectApp extends StatelessWidget {
  const HaruPassSubjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '하루패스 미션',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const SubjectHomePlaceholder(),
    );
  }
}

class SubjectHomePlaceholder extends StatelessWidget {
  const SubjectHomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('하루패스 미션'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '하루패스 미션',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '오늘의 미션을 완료하세요!',
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
