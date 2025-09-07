import 'package:flutter/material.dart';

class AboutHomiegram extends StatelessWidget {
  const AboutHomiegram({super.key});

  final List<Map<String, dynamic>> sections = const [
    {
      "title": "Landlords",
      "description":
          "Easily manage rental agreements, tenants, and maintenance requests in one place. Save time and focus on growth with streamlined property tools.",
      "image": "https://cdn-icons-png.flaticon.com/512/3944/3944336.png",
      "align": "left",
    },
    {
      "title": "Tenants",
      "description":
          "Students can find their ideal rentals using budget, location, and preference filters. Browse listings, apply, and settle in with ease.",
      "image": "https://cdn-icons-png.flaticon.com/512/747/747376.png",
      "align": "center",
    },
    {
      "title": "Market",
      "description":
          "Buy and sell essentials like furniture and appliances. HomieGram’s Market is a one-stop shop for student life and rental needs.",
      "image": "https://cdn-icons-png.flaticon.com/512/3081/3081559.png",
      "align": "right",
    },
  ];

  final Color cardColor = const Color(0xFF0D6B05);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "What is Homigram?",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final item = sections[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              // color: Colors.transparent, // transparent background
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: cardColor,
                width: 2.5,
              ),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.06),
              //     blurRadius: 6,
              //     offset: const Offset(0, 3),
              //   ),
              // ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _buildCard(item),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    final String align = item["align"];

    Alignment imageAlignment;
    switch (align) {
      case "left":
        imageAlignment = Alignment.topLeft;
        break;
      case "right":
        imageAlignment = Alignment.topRight;
        break;
      default:
        imageAlignment = Alignment.topCenter;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: imageAlignment,
          child: Image.network(
            item["image"],
            height: 90,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          item["title"],
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          item["description"],
          style: const TextStyle(
            fontSize: 16,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
