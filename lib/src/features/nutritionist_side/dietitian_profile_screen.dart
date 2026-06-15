import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../authentication/user_session.dart';
import 'dietitian_edit_profile_screen.dart';
import 'dietitian_speciality_screen.dart';
import 'dietitian_packages_screen.dart';
import 'dietitian_payments_screen.dart';

const String _baseUrl = 'http://10.107.148.193/client_project/api';

class DietitianProfileScreen extends StatefulWidget {
  const DietitianProfileScreen({super.key});

  @override
  State<DietitianProfileScreen> createState() => _DietitianProfileScreenState();
}

class _DietitianProfileScreenState extends State<DietitianProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final userId = await UserSession.getUserId();
      final uri = Uri.parse('$_baseUrl/dietitian_profile.php?user_id=$userId');
      final res = await http.get(uri);
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['status'] == 'success') {
        setState(() {
          _profile = data['profile'];
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
      backgroundColor: const Color(0xFFF9FBF4),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 12),
                  Text(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _loadProfile,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildProfileHeader(theme),
                    const SizedBox(height: 12),
                    _buildInfoSection(theme),
                    const SizedBox(height: 12),
                    _buildSpecialitiesSection(theme),
                    const SizedBox(height: 12),
                    _buildActionsSection(theme),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    final p = _profile!;
    final imageUrl = p['image_url'] ?? '';
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: Colors.white24,
            backgroundImage: imageUrl.isNotEmpty
                ? NetworkImage(imageUrl)
                : null,
            child: imageUrl.isEmpty
                ? Text(
                    (p['first_name'] ?? 'D')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 40,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 14),
          Text(
            p['full_name'] ?? '',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Dietitian',
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme) {
    final p = _profile!;
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
            _infoRow(Icons.email_outlined, 'Email', p['email'] ?? ''),
            _infoRow(Icons.phone_outlined, 'Phone', p['contact'] ?? ''),
            _infoRow(Icons.location_on_outlined, 'Address', p['address'] ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialitiesSection(ThemeData theme) {
    final specialities = (_profile!['specialities'] as List? ?? []);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Specialities',
              style: theme.textTheme.titleMedium!.copyWith(
                color: const Color(0xFF2E7D32),
              ),
            ),
            const Divider(),
            if (specialities.isEmpty)
              const Text(
                'No speciality added yet.',
                style: TextStyle(color: Colors.grey),
              )
            else
              ...specialities.map(
                (s) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_hospital_outlined,
                            size: 18,
                            color: Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              s['disease_name'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if ((s['education'] ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 24, top: 2),
                          child: Text(
                            'Edu: ${s['education']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      if ((s['experience'] ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 24, top: 2),
                          child: Text(
                            'Exp: ${s['experience']}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      if ((s['description'] ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 24, top: 2),
                          child: Text(
                            s['description'],
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _actionTile(
            Icons.edit_outlined,
            'Edit Profile',
            'Update address & contact',
            () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DietitianEditProfileScreen(),
                ),
              );
              _loadProfile();
            },
          ),
          const SizedBox(height: 8),
          _actionTile(
            Icons.medical_information_outlined,
            'Manage Speciality',
            'Add or remove specialities',
            () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DietitianSpecialityScreen(),
                ),
              );
              _loadProfile();
            },
          ),
          const SizedBox(height: 8),
          _actionTile(
            Icons.inventory_2_outlined,
            'Manage Packages',
            'Create & edit diet packages',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DietitianPackagesScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          _actionTile(
            Icons.payment_outlined,
            'View Payments',
            'See all payment records',
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DietitianPaymentsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
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

  Widget _actionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF2E7D32), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
