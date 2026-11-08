import 'package:flutter/material.dart';

import 'constants.dart';
import 'screens/splash_screen.dart';

void main() => runApp(const MoneyTrackerApp());

class MoneyTrackerApp extends StatelessWidget {
  const MoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money Tracker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: navy, primary: navy),
        scaffoldBackgroundColor: pageBg,
      ),
      home: const SplashScreen(),
    );
  }
}
