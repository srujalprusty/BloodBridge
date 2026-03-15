import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'shared/theme/app_theme.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/otp_screen.dart';
// TODO Day 2+: import donor, request, map screens

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // TODO: Add your google-services.json / GoogleService-Info.plist
    // options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BloodBridgeApp());
}

class BloodBridgeApp extends StatelessWidget {
  const BloodBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // TODO Day 2+: Add DonorProvider, RequestProvider, MapProvider
      ],
      child: MaterialApp(
        title: 'BloodBridge',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (ctx) => const SplashScreen(),
          '/login': (ctx) => const LoginScreen(),
          '/otp': (ctx) => const OtpScreen(),
          // TODO Day 2+: Add remaining routes
          '/complete-profile': (ctx) => const PlaceholderScreen(title: 'Complete Profile'),
          // '/home': (ctx) => const HomeScreen(),
          // '/map': (ctx) => const MapScreen(),
          // '/request': (ctx) => const CreateRequestScreen(),
        },
      ),
    );
  }
}
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFC0392B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🩸', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Coming in Day 2!',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
