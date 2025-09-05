import 'package:flutter/material.dart';
import 'package:homi_2/components/constants.dart';
import 'package:homi_2/models/ads.dart';
import 'package:intl/intl.dart';

const devUrl = AppConstants.baseUrl;

class AdDetailPage extends StatelessWidget {
  final Ad ad;

  const AdDetailPage({super.key, required this.ad});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Ad Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ad.imageUrl != null
                  ? Image.network(
                      '$devUrl${ad.imageUrl!}',
                      height: 450,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/advertise.png',
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 20),
            Text(
              ad.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Divider(
              color: Colors.grey.shade500,
              thickness: 1,
              endIndent: 40,
            ),
            const SizedBox(height: 16),
            Text(
              ad.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Divider(
              color: Colors.grey.shade500,
              thickness: 1,
              endIndent: 40,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Start: ${DateFormat('MMMM d, y').format(DateTime.parse(ad.startDate))}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'End: ${DateFormat('MMMM d, y').format(DateTime.parse(ad.endDate))}',
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
