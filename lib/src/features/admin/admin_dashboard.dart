import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../authentication/user_session.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  String get _baseUrl {
    const String serverIp = '10.107.148.193';
    if (kIsWeb) {
      return 'http://localhost/client_project/api';
    } else {
      return 'http://$serverIp/client_project/api';
    }
  }

  void _logout() async {
    await UserSession.clear();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: Colors.blueGrey.shade100,
          actions: [
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            _OverviewTab(baseUrl: _baseUrl),
            _UsersTab(
              baseUrl: _baseUrl,
              roleId: 2,
              title: 'Dietitians',
            ), // Dietitians
            _UsersTab(
              baseUrl: _baseUrl,
              roleId: 1,
              title: 'Clients',
            ), // Clients
            _InquiriesTab(baseUrl: _baseUrl), // Inquiries
          ],
        ),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          selectedIndex: _selectedIndex,
          indicatorColor: Colors.blueGrey.shade200,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Overview',
            ),
            NavigationDestination(
              icon: Icon(Icons.medical_services_outlined),
              selectedIcon: Icon(Icons.medical_services),
              label: 'Dietitians',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline),
              selectedIcon: Icon(Icons.people),
              label: 'Clients',
            ),
            NavigationDestination(
              icon: Icon(Icons.message_outlined),
              selectedIcon: Icon(Icons.message),
              label: 'Inquiries',
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Overview Tab
// ----------------------------------------------------------------------------
class _OverviewTab extends StatefulWidget {
  final String baseUrl;
  const _OverviewTab({required this.baseUrl});

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  late Future<Map<String, dynamic>> _statsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _statsFuture = _fetchStats();
    });
  }

  Future<Map<String, dynamic>> _fetchStats() async {
    final res = await http.get(
      Uri.parse('${widget.baseUrl}/admin_dashboard.php'),
    );
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['status'] == 'success') {
        return json['data'];
      }
    }
    throw Exception('Failed to load stats');
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<Map<String, dynamic>>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          return GridView.count(
            crossAxisCount: 2,
            padding: const EdgeInsets.all(16),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              _StatCard(
                title: 'Total Clients',
                value: data['clients'].toString(),
                color: Colors.blue.shade100,
              ),
              _StatCard(
                title: 'Nutritionists',
                value: data['dietitians'].toString(),
                color: Colors.green.shade100,
              ),
              _StatCard(
                title: 'Packages',
                value: data['packages'].toString(),
                color: Colors.orange.shade100,
              ),
              _StatCard(
                title: 'Inquiries',
                value: data['inquiries'].toString(),
                color: Colors.purple.shade100,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: Theme.of(context).textTheme.displaySmall),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Users Tab (used for both Clients and Dietitians)
// ----------------------------------------------------------------------------
class _UsersTab extends StatefulWidget {
  final String baseUrl;
  final int roleId;
  final String title;
  const _UsersTab({
    required this.baseUrl,
    required this.roleId,
    required this.title,
  });

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
  late Future<List<dynamic>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _usersFuture = _fetchUsers();
    });
  }

  Future<List<dynamic>> _fetchUsers() async {
    final res = await http.get(
      Uri.parse('${widget.baseUrl}/admin_users.php?role_id=${widget.roleId}'),
    );
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['status'] == 'success') {
        return json['data'];
      }
    }
    throw Exception('Failed to load users');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${widget.title} List',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: FutureBuilder<List<dynamic>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final users = snapshot.data!;
                if (users.isEmpty) {
                  return const Center(child: Text('No users found.'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: user['image_url'] != null
                              ? NetworkImage(user['image_url'])
                              : null,
                          child: user['image_url'] == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          '${user['user_fname']} ${user['user_lname'] ?? ''}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user['user_emailid'] ?? 'No email'),
                            Text(user['user_contactno'] ?? 'No contact'),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: Text('ID: ${user['user_id']}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// Inquiries Tab
// ----------------------------------------------------------------------------
class _InquiriesTab extends StatefulWidget {
  final String baseUrl;
  const _InquiriesTab({required this.baseUrl});

  @override
  State<_InquiriesTab> createState() => _InquiriesTabState();
}

class _InquiriesTabState extends State<_InquiriesTab> {
  late Future<List<dynamic>> _inquiriesFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() {
      _inquiriesFuture = _fetchInquiries();
    });
  }

  Future<List<dynamic>> _fetchInquiries() async {
    final res = await http.get(
      Uri.parse('${widget.baseUrl}/admin_inquiries.php'),
    );
    if (res.statusCode == 200) {
      final json = jsonDecode(res.body);
      if (json['status'] == 'success') {
        return json['data'];
      }
    }
    throw Exception('Failed to load inquiries');
  }

  Future<void> _deleteInquiry(int id) async {
    try {
      final res = await http.post(
        Uri.parse('${widget.baseUrl}/admin_inquiries.php'),
        body: {'action': 'delete', 'inquiry_id': id.toString()},
      );
      final json = jsonDecode(res.body);
      if (json['status'] == 'success') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Inquiry deleted')));
        _refresh();
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(json['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error deleting inquiry')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<dynamic>>(
        future: _inquiriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final inquiries = snapshot.data!;
          if (inquiries.isEmpty) {
            return const Center(child: Text('No inquiries.'));
          }

          return ListView.builder(
            itemCount: inquiries.length,
            itemBuilder: (context, index) {
              final inq = inquiries[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            inq['email_id'] ?? 'No email',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteInquiry(
                              int.parse(inq['inquiry_id'].toString()),
                            ),
                          ),
                        ],
                      ),
                      Text('Contact: ${inq['contact_no'] ?? 'N/A'}'),
                      const Divider(),
                      Text(inq['message'] ?? 'No message content'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
