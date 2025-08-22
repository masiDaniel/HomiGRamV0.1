import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homi_2/components/my_button.dart';
import 'package:homi_2/components/my_snackbar.dart';
import 'package:homi_2/components/my_text_field.dart';
import 'package:homi_2/models/user_signup.dart';
import 'package:homi_2/services/user_signup_service.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;

  void _signUserUp() async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showCustomSnackBar(context, 'Please fill in all fields',
          type: SnackBarType.warning);
      return;
    }
    bool isValidMandatoryEmail(String email) {
      final RegExp regex = RegExp(r"^[\w\.-]+@gmail\.com$");
      return regex.hasMatch(email);
    }

    if (!isValidMandatoryEmail(email)) {
      showCustomSnackBar(context, 'Invalid. (Valid) Email format gmail.com',
          type: SnackBarType.warning);
      return;
    }

    if (password != confirmPassword) {
      showCustomSnackBar(context, 'Passwords do not match',
          type: SnackBarType.warning);
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      UserSignUp? userSignUp =
          await fetchUserSignUp(firstName, lastName, email, password);
      if (!mounted) return;
      if (userSignUp != null) {
        showCustomSnackBar(
            context, 'Sign Up Sucessful - Login to your account.');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Sign Up",
              style: GoogleFonts.carterOne(
                  color: const Color(0xFF126E06),
                  fontSize: 50,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 15),
            MyTextField(
              controller: firstNameController,
              hintText: "First name",
              obscureText: false,
              onChanged: (value) {},
            ),
            const SizedBox(height: 15),
            MyTextField(
              controller: lastNameController,
              hintText: "Last name",
              obscureText: false,
              onChanged: (value) {},
            ),
            const SizedBox(height: 15),
            MyTextField(
              controller: emailController,
              hintText: "Email",
              obscureText: false,
              suffixIcon: Icons.email,
              onChanged: (value) {},
            ),
            const SizedBox(height: 15),
            MyTextField(
              controller: passwordController,
              hintText: "Password",
              obscureText: true,
              suffixIcon: Icons.password,
              onChanged: (value) {},
            ),
            const SizedBox(height: 15),
            MyTextField(
              controller: confirmPasswordController,
              hintText: "Confirm Password",
              obscureText: true,
              suffixIcon: Icons.password,
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Already have an account?",
                    style: TextStyle(
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w700),
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
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            isLoading
                ? const CircularProgressIndicator(color: Color(0xFF126E06))
                : MyButton(
                    buttonText: "Sign Up",
                    onPressed: _signUserUp,
                    width: 150,
                    height: 40,
                    color: const Color(0xFF126E06)),
          ],
        ),
      ),
    );
  }
}
