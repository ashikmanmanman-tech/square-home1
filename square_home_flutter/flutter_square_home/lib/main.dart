import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'state/launcher_provider.dart';

void main() {
  runApp(const SquareHomeApp());
}

class SquareHomeApp extends StatelessWidget {
  const SquareHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LauncherProvider(),
      child: MaterialApp(
        title: "Square Home",
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color(0xFF0C0D10),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
