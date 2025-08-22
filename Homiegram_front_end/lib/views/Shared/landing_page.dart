import 'package:flutter/material.dart';
import 'package:homi_2/components/my_button.dart';

class LandingPage extends StatelessWidget {
  /// this is the ui that will be used in production
  /// it will have the sign up and sign in and will be the landing page
  ///
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 252, 252),
      body: Column(
        children: <Widget>[
          const Text("find your perfect home,"),
          const Text("Home away from home"),
          Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(20)),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MyButton(
                buttonText: "Sign Up",
                onPressed: () {
                  Navigator.pushNamed(context, '/signin');
                },
                width: 15,
                height: 5,
                color: const Color.fromARGB(255, 71, 70, 70),
              ),
              const SizedBox(
                width: 20,
              ),
              MyButton(
                buttonText: "Sign Up",
                onPressed: () {
                  Navigator.pushNamed(context, '/signin');
                },
                width: 15,
                height: 5,
                color: const Color.fromARGB(255, 71, 70, 70),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              MyButton(
                buttonText: "Sign Up",
                onPressed: () {
                  Navigator.pushNamed(context, '/signin');
                },
                width: 15,
                height: 5,
                color: const Color.fromARGB(255, 71, 70, 70),
              ),
              const SizedBox(
                width: 20,
              ),
              MyButton(
                buttonText: "Sign Up",
                onPressed: () {
                  Navigator.pushNamed(context, '/signin');
                },
                width: 15,
                height: 5,
                color: const Color.fromARGB(255, 71, 70, 70),
              ),
              const SizedBox(
                width: 20,
              ),
              MyButton(
                buttonText: "Sign Up",
                onPressed: () {
                  Navigator.pushNamed(context, '/signin');
                },
                width: 15,
                height: 5,
                color: const Color.fromARGB(255, 71, 70, 70),
              )
            ],
          )
        ],
      ),
    );
  }
}
