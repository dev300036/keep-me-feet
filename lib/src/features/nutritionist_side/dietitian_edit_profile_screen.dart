import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../authentication/user_session.dart';

const String _baseUrl = 'http://10.107.148.193/client_project/api';

class DietitianEditProfileScreen extends StatefulWidget {
  const DietitianEditProfileScreen({super.key});

  @override
  State<DietitianEditProfileScreen> createState() =>
      _DietitianEditProfileScreenState();
}

class _DietitianEditProfileScreenState
    extends State<DietitianEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      _userId = await UserSession.getUserId();
      final uri = Uri.parse('$_baseUrl/dietitian_profile.php?user_id=$_userId');
      final res = await http.get(uri);
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['status'] == 'success') {
        final p = data['profile'];
        _addressCtrl.text = p['address'] ?? '';
        _contactCtrl.text = p['contact'] ?? '';
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/dietitian_update_profile.php'),
        body: {
          'user_id': _userId.toString(),
          'address': _addressCtrl.text.trim(),
          'contactno': _contactCtrl.text.trim(),
        },
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (!mounted) return;
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
    setState(() => _saving = false);
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      backgroundColor: const Color(0xFFF9FBF4),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel('Address'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _addressCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Enter your address',
                              prefixIcon: Icon(Icons.location_on_outlined),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Address is required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _sectionLabel('Contact Number'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _contactCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                              hintText: 'Enter contact number',
                              prefixIcon: Icon(Icons.phone_outlined),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Contact is required'
                                : null,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E7D32),
      ),
    );
  }
}
