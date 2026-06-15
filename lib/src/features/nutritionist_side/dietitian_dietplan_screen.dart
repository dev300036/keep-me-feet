import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../authentication/user_session.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

const String _dietServerIp = '10.107.148.193';
String get _baseUrl => kIsWeb
    ? 'http://localhost/client_project/api'
    : 'http://$_dietServerIp/client_project/api';

class DietitianDietplanScreen extends StatefulWidget {
  final int dietId;
  const DietitianDietplanScreen({super.key, required this.dietId});

  @override
  State<DietitianDietplanScreen> createState() =>
      _DietitianDietplanScreenState();
}

class _DietitianDietplanScreenState extends State<DietitianDietplanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  Map<String, dynamic>? _dietplan;
  bool _loading = true;
  bool _sending = false;
  String? _error;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _userId = await UserSession.getUserId();
    await _loadDietplan();
  }

  Future<void> _loadDietplan() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await http.get(
        Uri.parse('$_baseUrl/dietitian_dietplan.php?diet_id=${widget.dietId}'),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['status'] == 'success') {
        setState(() {
          _dietplan = data['dietplan'];
          _loading = false;
        });
      } else {
        setState(() {
          _error = data['message'];
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _sendSchedule() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      // client user_id is stored in dietplan.user_id
      final clientUserId = _dietplan!['user_id'].toString();

      final res = await http.post(
        Uri.parse('$_baseUrl/dietitian_dietplan.php'),
        body: {
          'dietitian_id': _userId.toString(),
          'client_id': clientUserId,
          'date': _dateCtrl.text.trim(),
          'time': _timeCtrl.text.trim(),
        },
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (!mounted) return;
      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule sent successfully!'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
        _dateCtrl.clear();
        _timeCtrl.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
    setState(() => _sending = false);
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Schedule')),
      backgroundColor: const Color(0xFFF9FBF4),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Diet plan info
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Diet Plan Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const Divider(),
                          _infoRow('Package', _dietplan!['package_name'] ?? ''),
                          _infoRow('Client', _dietplan!['client_name'] ?? ''),
                          _infoRow('Email', _dietplan!['client_email'] ?? ''),
                          _infoRow(
                            'Duration',
                            '${_dietplan!['package_dur']} days',
                          ),
                          _infoRow('Price', '₹${_dietplan!['package_price']}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Schedule form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Schedule Consultation',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            const Divider(),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _dateCtrl,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Issue Date *',
                                prefixIcon: Icon(Icons.calendar_today),
                              ),
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime(2030),
                                );
                                if (picked != null)
                                  _dateCtrl.text = picked
                                      .toIso8601String()
                                      .split('T')
                                      .first;
                              },
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Date is required'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _timeCtrl,
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Time *',
                                prefixIcon: Icon(Icons.access_time),
                              ),
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null)
                                  _timeCtrl.text = picked.format(context);
                              },
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Time is required'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _sending ? null : _sendSchedule,
                                icon: _sending
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.send),
                                label: const Text('Send Schedule'),
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
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
