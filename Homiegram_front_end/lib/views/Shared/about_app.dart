import 'package:flutter/material.dart';

class AboutHomiegram extends StatelessWidget {
  const AboutHomiegram({super.key});

  final List<Map<String, dynamic>> sections = const [
    {
      "title": "Landlords",
      "description":
          "Easily manage rental agreements, tenants, and maintenance requests in one place. Save time and focus on growth with streamlined property tools.",
      "image": "assets/images/landlord1.jpeg",
      "align": "left",
    },
    {
      "title": "Tenants",
      "description":
          "Students can find their ideal rentals using budget, location, and preference filters. Browse listings, apply, and settle in with ease.",
      "image": "assets/images/tenant1.jpeg",
      "align": "right",
    },
  ];

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
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final item = sections[index];
          return Padding(
            padding: const EdgeInsets.all(10),
            child: _buildCard(item),
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

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: imageAlignment,
              child: Container(
                width: 200,
                height: 200,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: ClipOval(
                  child: Image.asset(
                    item["image"],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              item["title"],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF126E06),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              item["description"],
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
