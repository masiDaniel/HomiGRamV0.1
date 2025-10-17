import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Providers
import 'package:homi_2/providers/user_provider.dart';
import 'package:homi_2/services/theme_provider.dart';

// Shared Views
import 'package:homi_2/views/Shared/video_splash_screen.dart';
import 'package:homi_2/views/Shared/splash_screen.dart';
import 'package:homi_2/views/Shared/welcome_page.dart';
import 'package:homi_2/views/Shared/sign_in.dart';
import 'package:homi_2/views/Shared/sign_up.dart';
import 'package:homi_2/views/Shared/about_app.dart';
import 'package:homi_2/views/Shared/navigation_bar.dart';
import 'package:homi_2/views/Shared/search_page.dart';
import 'package:homi_2/components/not_found.dart';

// Landlord Views
import 'package:homi_2/views/landlord/management.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final initialRoute = await getInitialRoute();
  runApp(MyApp(initialRoute: initialRoute));
}

Future<String> getInitialRoute() async {
  final prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  return isLoggedIn ? '/homescreen' : '/';
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({Key? key, required this.initialRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()..loadUserData()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const _AppWrapper(),
    );
  }
}

class _AppWrapper extends StatelessWidget {
  const _AppWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'HomiGram',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const VideoSplashScreen(),
            '/splash': (context) => const SplashScreen(),
            '/welcome': (context) => const WelcomePage(),
            '/signin': (context) => const SignIn(),
            '/signup': (context) => const SignUp(),
            '/about': (context) => const AboutHomiegram(),
            '/homescreen': (context) => const CustomBottomNavigation(),
            '/searchPage': (context) => const SearchPage(),
            '/landlordManagement': (context) => const LandlordManagement(),
          },
          onUnknownRoute: (_) => MaterialPageRoute(
            builder: (_) => const NotFoundPage(),
          ),
        );
      },
    );
  }
}
