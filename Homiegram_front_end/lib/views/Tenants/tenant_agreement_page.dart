import 'package:flutter/material.dart';
import 'package:homi_2/models/tenancy_agreement_model.dart';
import 'package:homi_2/services/agreement_service.dart';

class AgreementDetailsPage extends StatelessWidget {
  final Agreement agreement;

  const AgreementDetailsPage({Key? key, required this.agreement})
      : super(key: key);

  String formatDate(String? date) {
    if (date == null) return "Ongoing";
    return DateTime.tryParse(date)?.toLocal().toString().split(" ")[0] ?? date;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agreement Details"),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tenancy Agreement",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Start Date",
                            style: TextStyle(
                              fontSize: 16,
                            )),
                        Text(formatDate(agreement.startDate),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("End Date",
                            style: TextStyle(
                              fontSize: 16,
                            )),
                        Text(formatDate(agreement.endDate),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Status", style: TextStyle(fontSize: 16)),
                        Text(
                          agreement.status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: agreement.status == "active"
                                ? Colors.green
                                : agreement.status == "pending"
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildRow(
                      "Termination Requested",
                      agreement.terminationRequested ? "Yes" : "No",
                      valueColor: agreement.terminationRequested
                          ? Colors.red
                          : Colors.green,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text("Renew",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Renew request sent")));
                  },
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.cancel, color: Colors.white),
                  label: const Text("Terminate",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                  ),
                  onPressed: () async {
                    bool success = await AgreementService()
                        .terminateAgreement(agreement.id);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(success
                              ? "Termination request sent"
                              : "Termination failed")),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 16,
            )),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
