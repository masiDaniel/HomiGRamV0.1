import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homi_2/components/my_button.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/components/my_text_field.dart';
import 'package:homi_2/services/user_sigin_service.dart';
import 'package:homi_2/views/Shared/navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  SignInState createState() => SignInState();
}

class SignInState extends State<SignIn> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Basic email validation
    bool isValidEmail(String email) {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      return emailRegex.hasMatch(email);
    }

    // Input validation
    if (email.isEmpty || password.isEmpty) {
      showCustomSnackBar(
        context,
        'Please enter both email and password.',
        type: SnackBarType.warning,
      );
      return;
    }

    if (!isValidEmail(email)) {
      showCustomSnackBar(
        context,
        'Please enter a valid email address.',
        type: SnackBarType.warning,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt sign-in with a timeout
      final userRegistration =
          await fetchUserSignIn(context, email, password).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException(
          "Connection timed out. Please check your internet connection and try again.",
        ),
      );

      if (!mounted) return;

      // Successful sign-in
      if (userRegistration != null) {
        await _saveCredentials();
        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const CustomBottomNavigation(),
          ),
          (route) => false,
        );
      } else {
        // Invalid credentials
        showCustomSnackBar(
          context,
          'Invalid email or password. Please try again.',
          type: SnackBarType.error,
        );
      }
    } on TimeoutException catch (e) {
      if (!mounted) return;
      showCustomSnackBar(
        context,
        e.message ?? 'Request timed out. Please try again later.',
        type: SnackBarType.warning,
      );
    } on SocketException {
      if (!mounted) return;
      showCustomSnackBar(
        context,
        'Unable to reach the server. Please check your internet connection.',
        type: SnackBarType.warning,
      );
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(
        context,
        'An unexpected error occurred. Please try again later.',
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _emailController.text = prefs.getString('username') ?? '';
      _passwordController.text = prefs.getString('password') ?? '';
      _rememberMe = prefs.getBool('rememberMe') ?? false;
    });
  }

  Future<void> _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('username', _emailController.text);
      await prefs.setString('password', _passwordController.text);
      await prefs.setBool('rememberMe', _rememberMe);
    } else {
      await prefs.remove('username');
      await prefs.remove('password');
      await prefs.setBool('rememberMe', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sign in",
                    style: GoogleFonts.carterOne(
                        color: const Color(0xFF126E06),
                        fontSize: 50,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 15),
                  MyTextField(
                    controller: _emailController,
                    hintText: 'Email',
                    obscureText: false,
                    suffixIcon: Icons.email,
                    onChanged: (value) {},
                  ),
                  const SizedBox(height: 25),
                  MyTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    suffixIcon: Icons.lock_outline_sharp,
                    onChanged: (value) {},
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text('Remember Me'),
                        Checkbox(
                          value: _rememberMe,
                          activeColor: const Color(0xFF126E06),
                          checkColor: const Color(0xFFFFFFFF),
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value ?? false;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Don't have an account?  ",
                          style: TextStyle(
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w700),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: const Text(
                            " sign up",
                            style: TextStyle(
                                color: Color(0xFF126E06),
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  MyButton(
                    buttonText: 'Sign In',
                    onPressed: _signIn,
                    width: 150,
                    height: 40,
                    color: const Color(0xFF126E06),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Align(
              alignment: Alignment.center,
              child: Container(
                height: deviceHeight * 0.5,
                width: deviceWidth * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color.fromARGB(255, 9, 63, 2),
                ),
                child: const Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.green,
                      strokeWidth: 6.0,
                    ),
                    SizedBox(height: 10),
                    Text("Loading, please wait...",
                        style: TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                )),
              ),
            ),
        ],
      )),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
