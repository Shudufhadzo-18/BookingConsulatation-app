import 'package:firebase_flutter/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:firebase_flutter/viewmodels/consultation_view_model.dart';
import 'package:firebase_flutter/views/edit_consultation_screen.dart';

class ConsultationDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> consultation;
  const ConsultationDetailsScreen({super.key, required this.consultation});

  @override
  State<ConsultationDetailsScreen> createState() =>
      _ConsultationDetailsScreenState();
}

class _ConsultationDetailsScreenState extends State<ConsultationDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final consultation = widget.consultation;
    final dateTime = consultation['dateTime'] as DateTime;
    final formattedDate = DateFormat('MMMM dd, yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Consultation Details",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6A1B9A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      consultation['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.description,
                      consultation['description'] ?? 'No description',
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.calendar_today, formattedDate),
                    const SizedBox(height: 12),
                    _buildDetailRow(Icons.access_time, formattedTime),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.location_on,
                      consultation['location'] ?? 'No location specified',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text("Back"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    // When tapping on a consultation item or edit button
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => ChangeNotifierProvider(
                                create: (context) => ConsultationViewModel(),
                                child: EditConsultationScreen(
                                  consultation: consultation,
                                ),
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text("Edit"),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.delete),
                    label: const Text("Delete"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF6A1B9A), size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Delete"),
          content: const Text(
            "Are you sure you want to delete this consultation?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Color(0xFF6A1B9A)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteConsultation(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteConsultation(BuildContext context) async {
    final consultationViewModel = Provider.of<ConsultationViewModel>(
      context,
      listen: false,
    );

    final consultationId =
        widget.consultation['id'] ??
        widget.consultation['consultationId'] ??
        widget.consultation['documentId'];

    if (consultationId == null) {
      debugPrint('Full consultation data: ${widget.consultation}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Error: Could not find consultation ID in the data"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      await consultationViewModel.removeConsultation(consultationId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Consultation deleted successfully!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
