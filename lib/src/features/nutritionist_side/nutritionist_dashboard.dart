import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../authentication/user_session.dart';
import 'dietitian_profile_screen.dart';
import 'client_detail_screen.dart';

const String _baseUrl = 'http://10.107.148.193/client_project/api';

class NutritionistDashboardScreen extends StatefulWidget {
  const NutritionistDashboardScreen({super.key});

  @override
  State<NutritionistDashboardScreen> createState() =>
      _NutritionistDashboardScreenState();
}

class _NutritionistDashboardScreenState
    extends State<NutritionistDashboardScreen> {
  int _selectedIndex = 0;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    _userId = await UserSession.getUserId();
    setState(() {});
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  Future<void> _logout() async {
    await UserSession.clear();
    if (mounted) Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Widget>[
      _ClientsTab(userId: _userId),
      _RequestsTab(userId: _userId),
      const DietitianProfileScreen(),
    ];

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
          title: const Text('Dietitian Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
              tooltip: 'Logout',
            ),
          ],
        ),
        body: _userId == 0
            ? const Center(child: CircularProgressIndicator())
            : IndexedStack(index: _selectedIndex, children: tabs),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: _onItemTapped,
          selectedIndex: _selectedIndex,
          indicatorColor: const Color(0xFFA5D6A7),
          backgroundColor: Colors.white,
          destinations: const <Widget>[
            NavigationDestination(
              icon: Icon(Icons.people_outlined),
              selectedIcon: Icon(Icons.people),
              label: 'My Clients',
            ),
            NavigationDestination(
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications),
              label: 'Requests',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Clients Tab ─────────────────────────────────────────────────────────────

class _ClientsTab extends StatefulWidget {
  final int userId;
  const _ClientsTab({required this.userId});

  @override
  State<_ClientsTab> createState() => _ClientsTabState();
}

class _ClientsTabState extends State<_ClientsTab> {
  List<Map<String, dynamic>> _clients = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.userId > 0) _load();
  }

  @override
  void didUpdateWidget(_ClientsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId && widget.userId > 0) _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await http.get(
        Uri.parse(
          '$_baseUrl/dietitian_clients.php?dietitian_user_id=${widget.userId}',
        ),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['status'] == 'success') {
        setState(() {
          _clients = List<Map<String, dynamic>>.from(data['clients']);
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
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null)
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_error!),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Retry')),
          ],
        ),
      );
    if (_clients.isEmpty)
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No clients yet.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _clients.length,
        itemBuilder: (_, i) {
          final c = _clients[i];
          final imageUrl = c['image_url'] ?? '';
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFE8F5E9),
                backgroundImage: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl.isEmpty
                    ? Text(
                        (c['first_name'] ?? 'C')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              title: Text(
                c['full_name'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(c['package_name'] ?? ''),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientDetailScreen(
                    clientUserId: int.parse(c['user_id'].toString()),
                    dietId: int.tryParse(c['diet_id']?.toString() ?? ''),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Requests Tab (diet plans) ────────────────────────────────────────────────

class _RequestsTab extends StatefulWidget {
  final int userId;
  const _RequestsTab({required this.userId});

  @override
  State<_RequestsTab> createState() => _RequestsTabState();
}

class _RequestsTabState extends State<_RequestsTab> {
  List<Map<String, dynamic>> _clients = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.userId > 0) _load();
  }

  @override
  void didUpdateWidget(_RequestsTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId && widget.userId > 0) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(
        Uri.parse(
          '$_baseUrl/dietitian_clients.php?dietitian_user_id=${widget.userId}',
        ),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['status'] == 'success') {
        setState(() {
          _clients = List<Map<String, dynamic>>.from(data['clients']);
          _loading = false;
        });
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_clients.isEmpty)
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('No pending requests.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _clients.length,
      itemBuilder: (_, i) {
        final c = _clients[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.mark_email_unread, color: Color(0xFF2E7D32)),
            ),
            title: Text(
              c['full_name'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Package: ${c['package_name'] ?? ''} • ${c['package_dur'] ?? ''} days',
            ),
            trailing: const Icon(Icons.send, color: Color(0xFF2E7D32)),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ClientDetailScreen(
                  clientUserId: int.parse(c['user_id'].toString()),
                  dietId: int.tryParse(c['diet_id']?.toString() ?? ''),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
