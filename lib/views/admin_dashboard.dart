import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../viewmodels/consultation_view_model.dart';
import 'package:firebase_flutter/routes/app_router.dart';

class AdminDashboard extends StatefulWidget {

  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    Provider.of<ConsultationViewModel>(context, listen: false).fetchConsultations();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final consultationVM = Provider.of<ConsultationViewModel>(context);

    final filteredConsultations = consultationVM.consultations.where((consultation) {
      final studentID = consultation['studentId']?.toString().toLowerCase() ?? '';
      final matchesSearch = _searchController.text.isEmpty ||
          studentID.contains(_searchController.text.toLowerCase());

      final dateTime = consultation['dateTime'] as DateTime;
      final inDateRange = (_startDate == null || dateTime.isAfter(_startDate!)) &&
                          (_endDate == null || dateTime.isBefore(_endDate!));

      return matchesSearch && inDateRange;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              Navigator.pushReplacementNamed(context, RouteManager.loginPage);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildFilters(),
            const SizedBox(height: 16),
            Expanded(
              child: filteredConsultations.isEmpty
                  ? const Center(child: Text("No bookings found"))
                  : ListView.builder(
                      itemCount: filteredConsultations.length,
                      itemBuilder: (context, index) {
                        final consultation = filteredConsultations[index];
                        return _buildBookingCard(consultation, consultationVM);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: 'Search by Student ID',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDateSelector(
                label: 'Start Date',
                selectedDate: _startDate,
                onDateSelected: (date) => setState(() => _startDate = date),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildDateSelector(
                label: 'End Date',
                selectedDate: _endDate,
                onDateSelected: (date) => setState(() => _endDate = date),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSelector({
    required String label,
    DateTime? selectedDate,
    required ValueChanged<DateTime?> onDateSelected,
  }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        onDateSelected(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          selectedDate != null
              ? DateFormat('MMM dd, yyyy').format(selectedDate)
              : 'Select Date',
        ),
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> consultation, ConsultationViewModel vm) {
    final dateTime = consultation['dateTime'] as DateTime;
    final formattedDate = DateFormat('MMM dd, yyyy').format(dateTime);
    final formattedTime = DateFormat('hh:mm a').format(dateTime);
 

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        title: Text('${consultation['name'] } (${consultation['studentId']})'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Lecturer: ${consultation['lecturer'] ?? 'N/A'}'),
            Text('Topic: ${consultation['title'] ?? 'N/A'}'),
            Text('Date: $formattedDate'),
            Text('Time: $formattedTime'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _showDeleteDialog(context, consultation, vm),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> consultation, ConsultationViewModel vm) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Booking"),
        content: const Text("Are you sure you want to delete this booking?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await vm.removeConsultation(consultation['id']);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Booking deleted")),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: ${e.toString()}")),
                  );
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
