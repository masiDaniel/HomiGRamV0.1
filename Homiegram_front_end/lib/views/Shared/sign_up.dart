import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homi_2/components/my_button.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/components/my_text_field.dart';
import 'package:homi_2/models/user_signup.dart';
import 'package:homi_2/services/user_signup_service.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUp> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  String? passwordError;
  String? confirmPasswordError;

  void _validatePassword(String password) {
    if (password.length < 6) {
      passwordError = "Password must be at least 6 characters";
    } else if (!RegExp(r'[0-9]').hasMatch(password)) {
      passwordError = "Password must contain a number";
    } else if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) {
      passwordError = "Password must contain a special character";
    } else if (!RegExp(r'[A-Z]').hasMatch(password)) {
      passwordError = "Password must contain an uppercase letter";
    } else {
      passwordError = null;
    }
    setState(() {});
  }

  // ✅ Confirm password validation (live)
  void _validateConfirmPassword(String confirmPassword) {
    if (confirmPassword != passwordController.text) {
      confirmPasswordError = "Passwords do not match";
    } else {
      confirmPasswordError = null;
    }
    setState(() {});
  }

  void _signUserUp() async {
    if (passwordError != null || confirmPasswordError != null) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    try {
      UserSignUp? userSignUp = await fetchUserSignUp(
        firstNameController.text.trim(),
        lastNameController.text.trim(),
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      if (!mounted) return;
      if (userSignUp != null) {
        showCustomSnackBar(
            context, 'Sign Up Successful - Login to your account.');
        Navigator.pushNamed(context, '/signin');
      } else {
        showCustomSnackBar(context, 'Sign-up failed. Please try again later.',
            type: SnackBarType.warning);
      }
    } catch (e) {
      showCustomSnackBar(context, 'Error: ${e.toString()}');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool get isFormValid {
    return firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  @override
  void initState() {
    super.initState();

    firstNameController.addListener(() => setState(() {}));
    lastNameController.addListener(() => setState(() {}));
    emailController.addListener(() => setState(() {}));
    passwordController.addListener(() => setState(() {}));
    confirmPasswordController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: deviceHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sign Up",
                    style: GoogleFonts.carterOne(
                      color: const Color(0xFF126E06),
                      fontSize: 50,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: deviceHeight * 0.02),

                  // First Name
                  MyTextField(
                    controller: firstNameController,
                    hintText: "First name",
                    obscureText: false,
                    onChanged: (value) {},
                  ),
                  SizedBox(height: deviceHeight * 0.02),

                  // Last Name
                  MyTextField(
                    controller: lastNameController,
                    hintText: "Last name",
                    obscureText: false,
                    onChanged: (value) {},
                  ),
                  SizedBox(height: deviceHeight * 0.02),

                  // Email
                  MyTextField(
                    controller: emailController,
                    hintText: "Email",
                    obscureText: false,
                    suffixIcon: Icons.email,
                    onChanged: (value) {},
                  ),
                  SizedBox(height: deviceHeight * 0.02),

                  // Password
                  MyTextField(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                    suffixIcon: Icons.lock,
                    onChanged: (value) => _validatePassword(value),
                  ),
                  if (passwordError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          passwordError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ),
                  SizedBox(height: deviceHeight * 0.02),

                  // Confirm Password
                  MyTextField(
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    obscureText: true,
                    suffixIcon: Icons.lock,
                    onChanged: (value) => _validateConfirmPassword(value),
                  ),
                  if (confirmPasswordError != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 35, top: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          confirmPasswordError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ),
                  SizedBox(height: deviceHeight * 0.03),

                  // Already have account
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Already have an account?",
                          style: TextStyle(
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/signin');
                          },
                          child: const Text(
                            "Sign In",
                            style: TextStyle(
                              color: Color(0xFF126E06),
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: deviceHeight * 0.04),

                  isLoading
                      ? const CircularProgressIndicator(
                          color: Color(0xFF126E06))
                      : Opacity(
                          opacity: isFormValid ? 1.0 : 0.5, // dim when invalid
                          child: MyButton(
                            buttonText: "Sign Up",
                            onPressed:
                                isFormValid ? _signUserUp : null, // disable tap
                            width: 150,
                            height: 40,
                            color: const Color(0xFF126E06),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
