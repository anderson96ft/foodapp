import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/map_screen.dart';
import 'screens/vendor_detail.dart';
import 'providers/vendor_provider.dart';
import 'firebase_options.dart'; // Este archivo se genera automáticamente

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => VendorProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vendedores Ambulantes',
      initialRoute: '/',
      routes: {
        '/': (context) => MapScreen(),
        '/vendor_detail': (context) => VendorDetailScreen(),
      },
    );
  }
}