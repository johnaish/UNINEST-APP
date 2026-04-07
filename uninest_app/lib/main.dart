import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/property.dart';
import 'services/auth_service.dart';
import 'models/user_role.dart';
import 'services/property_service.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';

import 'screens/student/student_dashboard_screen.dart';
import 'screens/student/property_list_screen.dart';
import 'screens/student/property_detail_screen.dart';
import 'screens/student/compare_screen.dart';
import 'screens/student/wishlist_screen.dart';
import 'screens/student/map_screen.dart';

import 'screens/landlord/landlord_dashboard_screen.dart';
import 'screens/landlord/add_property_screen.dart';

import 'screens/admin/admin_dashboard_screen.dart';

import 'screens/student/bookings_screen.dart';
import 'screens/student/inbox_screen.dart';
import 'screens/student/account_management_screen.dart';
import 'screens/student/close_account_screen.dart';
import 'screens/shared/security_screen.dart';
import 'screens/shared/help_support_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for all platforms
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCb6ihnr-QxCKjUVfCN-BA0R8B0a4P0IxI',
        authDomain: 'uninest-app-1.firebaseapp.com',
        projectId: 'uninest-app-1',
        storageBucket: 'uninest-app-1.firebasestorage.app',
        messagingSenderId: '43761353988',
        appId: '1:43761353988:web:8d0d5a040ee7d2a65b3c51',
        measurementId: 'G-9GFF4GFWY4',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PropertyService.instance),
      ],
      child: const UninestApp(),
    ),
  );
}

class UninestApp extends StatefulWidget {
  const UninestApp({super.key});

  @override
  State<UninestApp> createState() => _UninestAppState();
}

class _UninestAppState extends State<UninestApp> {
  String _initialRoute = LoginScreen.routeName; // Default to login
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      // Check if Firebase is available (only when initialized)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // User is logged in, get their role from Firestore
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final data = userDoc.data();
        String? roleValue;

        if (data == null) {
          // User document doesn't exist, create it with default role
          await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
            'fullName': user.displayName ?? 'Unknown User',
            'email': user.email ?? '',
            'role': 'student',
            'createdAt': FieldValue.serverTimestamp(),
          });
          roleValue = 'student';
        } else {
          roleValue = data['role'] as String?;
          if (roleValue == null) {
            // Role is missing, set default
            await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
              'role': 'student',
            });
            roleValue = 'student';
          }
        }

        UserRole? role = _roleFromString(roleValue);

        switch (role) {
          case UserRole.student:
            _initialRoute = StudentDashboardScreen.routeName;
            break;
          case UserRole.landlord:
            _initialRoute = LandlordDashboardScreen.routeName;
            break;
          case UserRole.admin:
            _initialRoute = AdminDashboardScreen.routeName;
            break;
          default:
            _initialRoute = StudentDashboardScreen.routeName; // Default to student
        }
      } else {
        _initialRoute = LoginScreen.routeName;
      }
    } catch (e) {
      // Firebase not available or error occurred, default to login
      print('Firebase not available, defaulting to login screen: $e');
      _initialRoute = LoginScreen.routeName;
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  UserRole? _roleFromString(String? value) {
    switch (value) {
      case 'admin':
        return UserRole.admin;
      case 'landlord':
        return UserRole.landlord;
      case 'student':
        return UserRole.student;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      title: 'UNINEST',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF68B1E),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF68B1E),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF68B1E),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF68B1E), width: 2),
          ),
        ),
      ),
      initialRoute: _initialRoute,
      routes: {
        '/': (_) => const LoginScreen(),
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        StudentDashboardScreen.routeName: (_) => const StudentDashboardScreen(),
        LandlordDashboardScreen.routeName: (_) => const LandlordDashboardScreen(),
        AdminDashboardScreen.routeName: (_) => const AdminDashboardScreen(),
        PropertyListScreen.routeName: (_) => const PropertyListScreen(),
        MapScreen.routeName: (_) => const MapScreen(),
        CompareScreen.routeName: (_) => const CompareScreen(),
        WishlistScreen.routeName: (_) => const WishlistScreen(),
        BookingsScreen.routeName: (_) => const BookingsScreen(),
        InboxScreen.routeName: (_) => const InboxScreen(),
        AccountManagementScreen.routeName: (_) => const AccountManagementScreen(),
        CloseAccountScreen.routeName: (_) => const CloseAccountScreen(),
        SecurityScreen.routeName: (_) => const SecurityScreen(),
        HelpSupportScreen.routeName: (_) => const HelpSupportScreen(),
        AddPropertyScreen.routeName: (_) => const AddPropertyScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == PropertyDetailScreen.routeName) {
          final args = settings.arguments;
          if (args is Property) {
            return MaterialPageRoute(
              builder: (_) => const PropertyDetailScreen(),
              settings: settings,
            );
          }
          return MaterialPageRoute(
            builder: (_) => const PlaceholderScreen(title: 'Invalid Property Data'),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFFF68B1E),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              '$title Screen Under Construction',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}