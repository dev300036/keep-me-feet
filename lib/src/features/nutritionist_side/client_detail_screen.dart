import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dietitian_dietplan_screen.dart';

const String _baseUrl = 'http://10.107.148.193/client_project/api';

class ClientDetailScreen extends StatefulWidget {
  final int clientUserId;
  final int? dietId;

  const ClientDetailScreen({
    super.key,
    required this.clientUserId,
    this.dietId,
  });

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  Map<String, dynamic>? _client;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await http.get(
        Uri.parse(
          '$_baseUrl/dietitian_clients.php?client_user_id=${widget.clientUserId}',
        ),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['status'] == 'success') {
        setState(() {
          _client = data['client'];
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Client Profile')),
      backgroundColor: const Color(0xFFF9FBF4),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 12),
                  _buildInfoCard(theme),
                  const SizedBox(height: 12),
                  _buildHealthCard(theme),
                  if (widget.dietId != null) ...[
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          icon: const Icon(Icons.schedule_send),
                          label: const Text('Send Schedule'),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DietitianDietplanScreen(
                                dietId: widget.dietId!,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final c = _client!;
    final imageUrl = c['image_url'] ?? '';
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: Colors.white24,
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : null,
            child: imageUrl.isEmpty
                ? Text(
                    (c['first_name'] ?? 'C')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 10),
          Text(
            c['full_name'] ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Text('Client', style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    final c = _client!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Info',
              style: theme.textTheme.titleMedium!.copyWith(
                color: const Color(0xFF2E7D32),
              ),
            ),
            const Divider(),
            _row(Icons.email_outlined, 'Email', c['email'] ?? ''),
            _row(Icons.phone_outlined, 'Phone', c['contact'] ?? ''),
            _row(Icons.location_on_outlined, 'Address', c['address'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(ThemeData theme) {
    final c = _client!;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Health Info',
              style: theme.textTheme.titleMedium!.copyWith(
                color: const Color(0xFF2E7D32),
              ),
            ),
            const Divider(),
            _row(Icons.cake_outlined, 'Age', c['age'] ?? '-'),
            _row(Icons.height, 'Height', c['height'] ?? '-'),
            _row(Icons.monitor_weight_outlined, 'Weight', c['weight'] ?? '-'),
            _row(
              Icons.bloodtype_outlined,
              'Blood Group',
              c['blood_group'] ?? '-',
            ),
            _row(Icons.sick_outlined, 'Disease', c['disease'] ?? '-'),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
