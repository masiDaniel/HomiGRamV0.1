import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:homi_2/components/my_button.dart';

class WelcomePage extends StatelessWidget {
  ///
  /// this page holds the homigram animation together with,
  /// three buttons: login, signup and about us
  ///

  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedTextKit(animatedTexts: [
              TypewriterAnimatedText(
                "Homigram",
                textStyle: GoogleFonts.aBeeZee(
                    color: const Color(0xFF126E06),
                    fontSize: 26,
                    fontWeight: FontWeight.w800),
                speed: const Duration(milliseconds: 300),
              )
            ]),
            const SizedBox(
              height: 50,
            ),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  "assets/images/production_splash.png", // Replace with your image path
                  fit: BoxFit
                      .cover, // Ensures image fits well inside the container
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                MyButton(
                  buttonText: "Login",
                  onPressed: () {
                    Navigator.pushNamed(context, '/signin');
                  },
                  width: 90,
                  height: 40,
                  color: const Color(0xFF126E06),
                ),
                MyButton(
                  buttonText: "Sign Up",
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  width: 90,
                  height: 40,
                  color: const Color(0xFF126E06),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            MyButton(
              buttonText: "About Us",
              onPressed: () {
                Navigator.pushNamed(context, '/about');
              },
              width: 300,
              height: 40,
              color: const Color(0xFF126E06),
            ),
          ],
        ),
      ),
    );
  }
}
