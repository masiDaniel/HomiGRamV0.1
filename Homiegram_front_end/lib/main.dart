import 'package:flutter/material.dart';
import 'package:homi_2/components/not_found.dart';
import 'package:homi_2/providers/user_provider.dart';
import 'package:homi_2/services/theme_provider.dart';
import 'package:homi_2/views/Shared/about_app.dart';
import 'package:homi_2/views/Shared/splash_screen.dart';
import 'package:homi_2/views/Shared/navigation_bar.dart';
import 'package:homi_2/views/Shared/search_page.dart';
import 'package:homi_2/views/Shared/video_splash_screen.dart';
import 'package:homi_2/views/landlord/management.dart';
import 'package:homi_2/views/Shared/sign_in.dart';
import 'package:homi_2/views/Shared/sign_up.dart';
import 'package:homi_2/views/Shared/welcome_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final initialRoute = await getInitialRoute();

  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => UserProvider()..loadUserData()),
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
  ], child: MyApp(initialRoute: initialRoute)));
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HG',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      initialRoute: initialRoute,
      // home: const WelcomePage(),

      home: const VideoSplashScreen(),
      // should refactor on this to user flutters way
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomePage(),
        '/signin': (context) => const SignIn(),
        '/signup': (context) => const SignUp(),
        '/about': (context) => const AboutHomiegram(),
        '/homescreen': (context) => const CustomBottomNavigartion(),
        '/searchPage': (context) => const SearchPage(),
        '/landlordManagement': (context) => const LandlordManagement(),
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const NotFoundPage(),
        );
      },
    );
  }
}
