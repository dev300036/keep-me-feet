import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../authentication/user_session.dart';

const String _baseUrl = 'http://10.107.148.193/client_project/api';

class DietitianSpecialityScreen extends StatefulWidget {
  const DietitianSpecialityScreen({super.key});

  @override
  State<DietitianSpecialityScreen> createState() =>
      _DietitianSpecialityScreenState();
}

class _DietitianSpecialityScreenState extends State<DietitianSpecialityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diseaseCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  List<Map<String, dynamic>> _specialities = [];
  List<String> _diseases = [];
  bool _loading = true;
  bool _adding = false;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _userId = await UserSession.getUserId();
    await Future.wait([_loadSpecialities(), _loadDiseases()]);
    setState(() => _loading = false);
  }

  Future<void> _loadSpecialities() async {
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/dietitian_speciality.php?user_id=$_userId'),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['status'] == 'success') {
        setState(
          () => _specialities = List<Map<String, dynamic>>.from(
            data['specialities'],
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _loadDiseases() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/get_diseases.php'));
      final data = jsonDecode(res.body);
      if (data is List) {
        setState(
          () => _diseases = data.map((d) => d['name'].toString()).toList(),
        );
      } else if (data['diseases'] != null) {
        setState(
          () => _diseases = (data['diseases'] as List)
              .map((d) => d['name'].toString())
              .toList(),
        );
      }
    } catch (_) {}
  }

  Future<void> _addSpeciality() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _adding = true);
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/dietitian_speciality.php'),
        body: {
          'action': 'add',
          'user_id': _userId.toString(),
          'disease_name': _diseaseCtrl.text.trim(),
          'education': _educationCtrl.text.trim(),
          'experience': _experienceCtrl.text.trim(),
          'description': _descriptionCtrl.text.trim(),
        },
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (!mounted) return;
      if (data['status'] == 'success') {
        _diseaseCtrl.clear();
        _educationCtrl.clear();
        _experienceCtrl.clear();
        _descriptionCtrl.clear();
        await _loadSpecialities();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speciality added!'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _adding = false);
  }

  Future<void> _deleteSpeciality(String dietitianId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Speciality'),
        content: const Text('Are you sure you want to delete this speciality?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/dietitian_speciality.php'),
        body: {'action': 'delete', 'dietitian_id': dietitianId},
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (!mounted) return;
      if (data['status'] == 'success') {
        await _loadSpecialities();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'] ?? 'Error')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  void dispose() {
    _diseaseCtrl.dispose();
    _educationCtrl.dispose();
    _experienceCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Speciality')),
      backgroundColor: const Color(0xFFF9FBF4),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add Speciality',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            _diseases.isEmpty
                                ? TextFormField(
                                    controller: _diseaseCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'Speciality / Disease *',
                                      prefixIcon: Icon(
                                        Icons.medical_services_outlined,
                                      ),
                                    ),
                                    validator: (v) => (v == null || v.isEmpty)
                                        ? 'Required'
                                        : null,
                                  )
                                : DropdownButtonFormField<String>(
                                    value: _diseaseCtrl.text.isNotEmpty
                                        ? _diseaseCtrl.text
                                        : null,
                                    decoration: const InputDecoration(
                                      labelText: 'Speciality / Disease *',
                                      prefixIcon: Icon(
                                        Icons.medical_services_outlined,
                                      ),
                                    ),
                                    items: _diseases
                                        .map(
                                          (d) => DropdownMenuItem(
                                            value: d,
                                            child: Text(d),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) =>
                                        _diseaseCtrl.text = v ?? '',
                                    validator: (v) => (v == null || v.isEmpty)
                                        ? 'Required'
                                        : null,
                                  ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _educationCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Education',
                                prefixIcon: Icon(Icons.school_outlined),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _experienceCtrl,
                              decoration: const InputDecoration(
                                labelText: 'Experience',
                                prefixIcon: Icon(Icons.work_outline),
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _descriptionCtrl,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                prefixIcon: Icon(Icons.description_outlined),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _adding ? null : _addSpeciality,
                                icon: _adding
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.add),
                                label: const Text('Add Speciality'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // List
                  if (_specialities.isNotEmpty) ...[
                    const Text(
                      'My Specialities',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ..._specialities.map(
                      (s) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE8F5E9),
                            child: Icon(
                              Icons.local_hospital,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          title: Text(
                            s['disease_name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${s['education'] ?? ''} • ${s['experience'] ?? ''}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _deleteSpeciality(s['dietitian_id'].toString()),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
