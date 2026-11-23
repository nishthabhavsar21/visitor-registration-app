// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'visitor_form_screen.dart';

class VisitorDetailsScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> visitorData;

  const VisitorDetailsScreen({
    super.key,
    required this.docId,
    required this.visitorData,
  });

  @override
  VisitorDetailsScreenState createState() => VisitorDetailsScreenState();
}

class VisitorDetailsScreenState extends State<VisitorDetailsScreen> {
  bool _isEditing = false;
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _purposeController;

  late Map<String, dynamic> _currentData;

  @override
  void initState() {
    super.initState();
    _currentData = Map.from(widget.visitorData);
    _nameController = TextEditingController(text: _currentData['name'] ?? '');
    _phoneController =
        TextEditingController(text: _currentData['phoneNo'] ?? '');
    _dobController = TextEditingController(text: _currentData['dob'] ?? '');
    _emailController =
        TextEditingController(text: _currentData['email'] ?? '');
    _addressController =
        TextEditingController(text: _currentData['address'] ?? '');
    _purposeController =
        TextEditingController(text: _currentData['purpose'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _dobController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text("Name and Phone are required"),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedData = {
        'name': _nameController.text.trim(),
        'phoneNo': _phoneController.text.trim(),
        'dob': _dobController.text.trim(),
        'email': _emailController.text.trim(),
        'address': _addressController.text.trim(),
        'purpose': _purposeController.text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('visitors')
          .doc(widget.docId)
          .update(updatedData);

      if (!mounted) return;

      setState(() {
        _currentData = {
          ..._currentData,
          ...updatedData,
        };
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Details Updated Successfully!"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text("Update failed: ${e.toString()}")),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _cancelEdit() {
    setState(() {
      _nameController.text = _currentData['name'] ?? '';
      _phoneController.text = _currentData['phoneNo'] ?? '';
      _dobController.text = _currentData['dob'] ?? '';
      _emailController.text = _currentData['email'] ?? '';
      _addressController.text = _currentData['address'] ?? '';
      _purposeController.text = _currentData['purpose'] ?? '';
      _isEditing = false;
    });
  }

  Widget _buildDetailTile({
    required IconData icon,
    required String label,
    required String value,
    required TextEditingController controller,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    if (_isEditing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF6C63FF), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : '—',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: value.isNotEmpty
                        ? const Color(0xFF2D2D2D)
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6C63FF), Color(0xFF3F3D94)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                        );
                      },
                      icon: const Icon(Icons.logout_rounded,
                          color: Colors.white),
                      tooltip: 'Sign Out',
                    ),
                    const Expanded(
                      child: Text(
                        'Visitor Details',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Profile avatar area
              Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(30),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withAlpha(60),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        (_currentData['name'] ?? 'V')
                            .toString()
                            .substring(0, 1)
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentData['name'] ?? 'Visitor',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentData['email'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withAlpha(180),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),

              // Details card
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section header with edit toggle
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF6C63FF).withAlpha(25),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _isEditing
                                    ? Icons.edit_rounded
                                    : Icons.info_outline_rounded,
                                color: const Color(0xFF6C63FF),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                _isEditing
                                    ? 'Edit Your Details'
                                    : 'Registration Info',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D2D2D),
                                ),
                              ),
                            ),
                            if (!_isEditing)
                              FilledButton.tonalIcon(
                                onPressed: () =>
                                    setState(() => _isEditing = true),
                                icon: const Icon(Icons.edit_outlined,
                                    size: 18),
                                label: const Text('Edit'),
                                style: FilledButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF6C63FF).withAlpha(25),
                                  foregroundColor: const Color(0xFF6C63FF),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _buildDetailTile(
                          icon: Icons.person_outline,
                          label: 'Full Name',
                          value: _currentData['name'] ?? '',
                          controller: _nameController,
                        ),
                        _buildDetailTile(
                          icon: Icons.phone_outlined,
                          label: 'Phone Number',
                          value: _currentData['phoneNo'] ?? '',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                        _buildDetailTile(
                          icon: Icons.calendar_today_outlined,
                          label: 'Date of Birth',
                          value: _currentData['dob'] ?? '',
                          controller: _dobController,
                          readOnly: true,
                          onTap: _isEditing ? _pickDate : null,
                        ),
                        _buildDetailTile(
                          icon: Icons.email_outlined,
                          label: 'Email Address',
                          value: _currentData['email'] ?? '',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildDetailTile(
                          icon: Icons.location_on_outlined,
                          label: 'Address',
                          value: _currentData['address'] ?? '',
                          controller: _addressController,
                          maxLines: 2,
                        ),
                        _buildDetailTile(
                          icon: Icons.description_outlined,
                          label: 'Purpose of Visit',
                          value: _currentData['purpose'] ?? '',
                          controller: _purposeController,
                          maxLines: 2,
                        ),

                        if (_isEditing) ...[
                          const SizedBox(height: 10),
                          _isSaving
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF6C63FF),
                                    ),
                                  ),
                                )
                              : Column(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _saveChanges,
                                      icon: const Icon(Icons.save_rounded),
                                      label: const Text('Save Changes'),
                                    ),
                                    const SizedBox(height: 12),
                                    OutlinedButton.icon(
                                      onPressed: _cancelEdit,
                                      icon: const Icon(Icons.close_rounded),
                                      label: const Text('Cancel'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.grey.shade700,
                                        minimumSize:
                                            const Size(double.infinity, 56),
                                        side: BorderSide(
                                            color: Colors.grey.shade400,
                                            width: 1.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ],

                        const SizedBox(height: 20),

                        // New registration button
                        if (!_isEditing)
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const VisitorFormScreen()),
                              );
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('New Registration'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF6C63FF),
                              minimumSize: const Size(double.infinity, 56),
                              side: const BorderSide(
                                  color: Color(0xFF6C63FF), width: 1.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
