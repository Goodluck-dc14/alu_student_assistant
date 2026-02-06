import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/session_provider.dart';
import 'screens/schedule_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SessionProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ALU Student Assistant',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F2D52)),
        ),
        home: const ScheduleScreen(),
      ),
    );
  }
}

