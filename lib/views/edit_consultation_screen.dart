import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_flutter/viewmodels/consultation_view_model.dart';

class EditConsultationScreen extends StatefulWidget {
  final Map<String, dynamic> consultation;

  const EditConsultationScreen({Key? key, required this.consultation}) : super(key: key);

  @override
  _EditConsultationScreenState createState() => _EditConsultationScreenState();
}

class _EditConsultationScreenState extends State<EditConsultationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _selectedDateTime;

@override
void initState() {
  super.initState();
  _titleController = TextEditingController(text: widget.consultation['title'] ?? '');
  _descriptionController = TextEditingController(text: widget.consultation['description'] ?? '');
  _locationController = TextEditingController(text: widget.consultation['location'] ?? '');
  _selectedDateTime = widget.consultation['dateTime'] ?? DateTime.now();
}

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

Future<void> _saveConsultation() async {
  if (!_formKey.currentState!.validate()) return;

  final viewModel = Provider.of<ConsultationViewModel>(context, listen: false);
  
  try {
    await viewModel.updateConsultation(
      widget.consultation['id'],
      _titleController.text.trim(),
      _descriptionController.text.trim(),
      _locationController.text.trim(),
      _selectedDateTime,
    );
    
    Navigator.of(context).pop(true); // Return success
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update consultation: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Consultation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConsultation,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date & Time'),
                subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(_selectedDateTime)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context),
              ),
              const SizedBox(height: 24),
              Consumer<ConsultationViewModel>(
                builder: (context, viewModel, child) {
                  if (viewModel.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: _saveConsultation,
                    child: const Text('Save Changes'),
                  );
                },
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Consultation'),
                      content: const Text('Are you sure you want to delete this consultation?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  
                  if (shouldDelete == true) {
                    try {
                      await Provider.of<ConsultationViewModel>(context, listen: false)
                          .removeConsultation(widget.consultation['id']);
                      
                      if (mounted) {
                        Navigator.of(context).pop(true); // Return success
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to delete: ${e.toString()}')),
                        );
                      }
                    }
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
                child: const Text('Delete Consultation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}