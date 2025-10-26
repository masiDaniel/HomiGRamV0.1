import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final String hintText;
  final bool obscureText;
  final IconData? suffixIcon;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const MyTextField({
    Key? key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.suffixIcon,
    this.onChanged,
  }) : super(key: key);

  @override
  MyTextFieldState createState() => MyTextFieldState();
}

class MyTextFieldState extends State<MyTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: TextField(
        controller: widget.controller,
        obscureText: _obscureText,
        cursorColor: const Color(0xFF149204),
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide:
                const BorderSide(color: Color.fromARGB(255, 77, 76, 76)),
            borderRadius: BorderRadius.circular(12.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF149204)),
            borderRadius: BorderRadius.circular(12.0),
          ),
          hintText: widget.hintText,
          suffixIcon: widget.obscureText
              ? IconButton(
                  onPressed: _toggleObscureText,
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                )
              : (widget.suffixIcon != null ? Icon(widget.suffixIcon) : null),
        ),
      ),
    );
  }
}
