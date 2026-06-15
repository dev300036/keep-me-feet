import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../authentication/user_session.dart';

const String _serverIp = '10.107.148.193';
String get _baseUrl => kIsWeb
    ? 'http://localhost/client_project/api'
    : 'http://$_serverIp/client_project/api';

// ════════════════════════════════════════════════════════════════════
// Health Screen
// ════════════════════════════════════════════════════════════════════
class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});
  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  bool _loading = true;
  Map<String, dynamic>? _health;
  List<String> _diseases = [];

  @override
  void initState() {
    super.initState();
    _fetchHealth();
    _fetchDiseases();
  }

  Future<void> _fetchHealth() async {
    setState(() => _loading = true);
    try {
      final userId = await UserSession.getUserId();
      if (userId == 0) return;
      final res = await http.get(
        Uri.parse('$_baseUrl/health_detail.php?user_id=$userId'),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'success') {
          setState(() => _health = Map<String, dynamic>.from(data['data']));
        } else {
          setState(() => _health = null);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _fetchDiseases() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/get_diseases.php'));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'success') {
          final list = (data['diseases'] as List)
              .map((d) => d['name'].toString())
              .toList();
          if (mounted) setState(() => _diseases = list);
        }
      }
    } catch (_) {}
  }

  void _openForm() async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _HealthFormSheet(
        existing: _health,
        diseases: _diseases,
        baseUrl: _baseUrl,
      ),
    );
    if (updated == true) _fetchHealth();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.monitor_heart_outlined,
                  size: 52,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Health Details',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _health == null
                      ? 'No record yet — add yours!'
                      : 'Your health snapshot',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_health == null) ...[
                  const SizedBox(height: 40),
                  const Icon(
                    Icons.health_and_safety_outlined,
                    size: 72,
                    color: Color(0xFFCFD8DC),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No health record found',
                    style: TextStyle(fontSize: 16, color: Color(0xFF888888)),
                  ),
                  const SizedBox(height: 24),
                ] else ...[
                  _SectionCard(
                    title: 'Body Metrics',
                    children: [
                      _InfoRow(
                        label: 'Age',
                        value: '${_health!['age'] ?? '--'} years',
                        icon: Icons.cake_outlined,
                      ),
                      _InfoRow(
                        label: 'Height',
                        value: '${_health!['height'] ?? '--'} inches',
                        icon: Icons.height_outlined,
                      ),
                      _InfoRow(
                        label: 'Weight',
                        value: '${_health!['weight'] ?? '--'} kg',
                        icon: Icons.monitor_weight_outlined,
                      ),
                      _InfoRow(
                        label: 'Blood Group',
                        value: _health!['blood_group'] ?? '--',
                        icon: Icons.bloodtype_outlined,
                      ),
                      _InfoRow(
                        label: 'Disease / Condition',
                        value: _health!['disease'] ?? '--',
                        icon: Icons.medical_information_outlined,
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: _openForm,
                    icon: Icon(
                      _health == null ? Icons.add : Icons.edit_outlined,
                    ),
                    label: Text(
                      _health == null
                          ? 'Add Health Details'
                          : 'Update Health Details',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Health Form Bottom Sheet
// ════════════════════════════════════════════════════════════════════
class _HealthFormSheet extends StatefulWidget {
  final Map<String, dynamic>? existing;
  final List<String> diseases;
  final String baseUrl;
  const _HealthFormSheet({
    this.existing,
    required this.diseases,
    required this.baseUrl,
  });

  @override
  State<_HealthFormSheet> createState() => _HealthFormSheetState();
}

class _HealthFormSheetState extends State<_HealthFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _age;
  late TextEditingController _height;
  late TextEditingController _weight;
  String? _bloodGroup;
  String? _disease;
  bool _saving = false;

  final List<String> _bloodGroups = [
    'O+',
    'O-',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
  ];

  @override
  void initState() {
    super.initState();
    _age = TextEditingController(
      text: widget.existing?['age']?.toString() ?? '',
    );
    _height = TextEditingController(
      text: widget.existing?['height']?.toString() ?? '',
    );
    _weight = TextEditingController(
      text: widget.existing?['weight']?.toString() ?? '',
    );
    _bloodGroup = widget.existing?['blood_group'];
    _disease = widget.existing?['disease'];
  }

  @override
  void dispose() {
    _age.dispose();
    _height.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final userId = await UserSession.getUserId();
      final res = await http.post(
        Uri.parse('${widget.baseUrl}/health_detail.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'age': _age.text.trim(),
          'height': _height.text.trim(),
          'weight': _weight.text.trim(),
          'bloodgroup': _bloodGroup ?? '',
          'disease_name': _disease ?? '',
        }),
      );
      final data = json.decode(res.body);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? ''),
            backgroundColor: data['status'] == 'success'
                ? const Color(0xFF2E7D32)
                : Colors.red[700],
          ),
        );
        if (data['status'] == 'success') Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Health Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 20),
              _numField(_age, 'Age (years)', Icons.cake_outlined),
              const SizedBox(height: 12),
              _numField(_height, 'Height (inches)', Icons.height_outlined),
              const SizedBox(height: 12),
              _numField(_weight, 'Weight (kg)', Icons.monitor_weight_outlined),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _bloodGroups.contains(_bloodGroup) ? _bloodGroup : null,
                decoration: InputDecoration(
                  labelText: 'Blood Group',
                  prefixIcon: const Icon(
                    Icons.bloodtype_outlined,
                    color: Color(0xFF2E7D32),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _bloodGroups
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _bloodGroup = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              // Disease dropdown or text field if diseases not loaded
              widget.diseases.isEmpty
                  ? TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Disease / Condition',
                        prefixIcon: const Icon(
                          Icons.medical_information_outlined,
                          color: Color(0xFF2E7D32),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      initialValue: _disease,
                      onChanged: (v) => _disease = v,
                    )
                  : DropdownButtonFormField<String>(
                      value: widget.diseases.contains(_disease)
                          ? _disease
                          : null,
                      decoration: InputDecoration(
                        labelText: 'Disease / Condition',
                        prefixIcon: const Icon(
                          Icons.medical_information_outlined,
                          color: Color(0xFF2E7D32),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: widget.diseases
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _disease = v),
                    ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Save'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _numField(TextEditingController ctrl, String label, IconData icon) {
    return TextFormField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }
}

// ── Shared widgets ───────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B5E20),
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final bool isLast;
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 50),
      ],
    );
  }
}
