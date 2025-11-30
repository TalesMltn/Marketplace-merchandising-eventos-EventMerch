import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ←←← AQUÍ PON TU URL Y ANON KEY DE SUPABASE (los encuentras en Settings → API)
  await Supabase.initialize(
    url: 'https://thmlvvgerforijewihgf.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRobWx2dmdlcmZvcmlqZXdpaGdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ0MjU2MTUsImV4cCI6MjA4MDAwMTYxNX0.-b_XTfR8fahttp3h-nr-CTXMDdsOaqubKlUKClG4mwo',
  );
  runApp(
    const ProviderScope(
      child: EventMerchApp(),
    ),
  );
}

class EventMerchApp extends StatelessWidget {
  const EventMerchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EventMerch',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}