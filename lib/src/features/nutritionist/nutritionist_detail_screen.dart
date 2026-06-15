import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../authentication/user_session.dart';
import '../payments/payment_page.dart';

const String _serverIp = '10.107.148.193';
String get _baseUrl => kIsWeb
    ? 'http://localhost/client_project/api'
    : 'http://$_serverIp/client_project/api';

// ════════════════════════════════════════════════════════════════════
// Nutritionist Detail Screen
// ════════════════════════════════════════════════════════════════════
class NutritionistDetailScreen extends StatefulWidget {
  final String dietitianId;
  const NutritionistDetailScreen({super.key, required this.dietitianId});

  @override
  State<NutritionistDetailScreen> createState() =>
      _NutritionistDetailScreenState();
}

class _NutritionistDetailScreenState extends State<NutritionistDetailScreen> {
  bool _loading = true;
  Map<String, dynamic>? _data;
  String? _selectedPackageId;
  String _selectedDuration = '30';
  int _userRating = 0;
  bool _booking = false;

  final List<Map<String, String>> _durations = [
    {'label': '1 week', 'value': '7'},
    {'label': '2 weeks', 'value': '14'},
    {'label': '3 weeks', 'value': '21'},
    {'label': '1 month', 'value': '30'},
    {'label': '3 months', 'value': '90'},
    {'label': '6 months', 'value': '180'},
  ];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(
        Uri.parse(
          '$_baseUrl/nutritionist_detail.php?dietitian_id=${widget.dietitianId}',
        ),
      );
      if (res.statusCode == 200) {
        final d = json.decode(res.body);
        if (d['status'] == 'success') {
          setState(() {
            _data = Map<String, dynamic>.from(d['data']);
            final pkgs = _data!['packages'] as List;
            if (pkgs.isNotEmpty) {
              _selectedPackageId = pkgs[0]['package_id'].toString();
            }
          });
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _bookNow() async {
    if (_selectedPackageId == null) {
      _snack('Please select a package', isError: true);
      return;
    }
    setState(() => _booking = true);
    try {
      final userId = await UserSession.getUserId();

      // Step 1: Create the dietplan booking
      final res = await http.post(
        Uri.parse('$_baseUrl/nutdetail.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'dietitian_id': widget.dietitianId,
          'package_id': _selectedPackageId,
          'package_dur': _selectedDuration,
        }),
      );
      final d = json.decode(res.body);
      if (d['status'] != 'success') {
        _snack(d['message'] ?? 'Booking failed', isError: true);
        setState(() => _booking = false);
        return;
      }

      // Step 2: Navigate to Payment Page
      if (!mounted) return;
      final packages = _data?['packages'] as List? ?? [];
      final selectedPkg = packages.firstWhere(
        (p) => p['package_id'].toString() == _selectedPackageId,
        orElse: () => <String, dynamic>{},
      );
      final pkgName = (selectedPkg['package_name'] ?? 'Diet Plan').toString();
      final rawPrice = selectedPkg['price'];
      final price = (rawPrice != null && rawPrice.toString().isNotEmpty)
          ? double.tryParse(rawPrice.toString()) ?? 999.0
          : 999.0;
      final dur = int.tryParse(_selectedDuration) ?? 30;
      final amount = price > 0 ? (price * dur / 180).roundToDouble() : 999.0;

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentPage(
            dietitianName: _data?['full_name'] ?? 'Dietitian',
            packageName: pkgName,
            packageId: _selectedPackageId!,
            dietId: 0,
            amount: amount < 1 ? 999.0 : amount,
            durationDays: dur,
          ),
        ),
      );
    } catch (e) {
      _snack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _booking = false);
    }
  }

  Future<void> _submitRating(int stars) async {
    setState(() => _userRating = stars);
    try {
      final userId = await UserSession.getUserId();
      final res = await http.post(
        Uri.parse('$_baseUrl/rate_nutritionist.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'dietitian_id': widget.dietitianId,
          'rating_count': stars,
        }),
      );
      final d = json.decode(res.body);
      if (d['status'] == 'success') {
        _snack('Rating submitted! Avg: ${d['avg_rating']}');
        _fetch(); // refresh avg
      }
    } catch (_) {}
  }

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : const Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF4),
      appBar: AppBar(
        title: Text(_data?['full_name'] ?? 'Nutritionist'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            )
          : _data == null
          ? const Center(child: Text('Not found'))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final d = _data!;
    final imageUrl = d['image_url'] as String? ?? '';
    final packages = d['packages'] as List? ?? [];
    final avgRating = (d['avg_rating'] as num?)?.toDouble() ?? 0.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
              ),
            ),
            child: Column(
              children: [
                ClipOval(
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 90,
                          height: 90,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _avatar(),
                        )
                      : _avatar(),
                ),
                const SizedBox(height: 12),
                Text(
                  d['full_name'] ?? '',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                if ((d['speciality'] as String? ?? '').isNotEmpty)
                  Text(
                    d['speciality'] ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                const SizedBox(height: 10),
                // Star display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < avgRating.round() ? Icons.star : Icons.star_outline,
                        color: const Color(0xFFFFC107),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$avgRating (${d['rating_count']} reviews)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if ((d['experience'] as String? ?? '').isNotEmpty)
                      _Chip(Icons.work_outline, '${d['experience']} exp'),
                    if ((d['education'] as String? ?? '').isNotEmpty)
                      _Chip(Icons.school_outlined, d['education']),
                    if ((d['address'] as String? ?? '').isNotEmpty)
                      _Chip(Icons.location_on_outlined, d['address']),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                if ((d['description'] as String? ?? '').isNotEmpty) ...[
                  _sectionTitle('About'),
                  const SizedBox(height: 8),
                  Text(
                    d['description'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF555555),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Package selector
                if (packages.isNotEmpty) ...[
                  _sectionTitle('Select Package'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedPackageId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.local_offer_outlined,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    items: packages.map<DropdownMenuItem<String>>((p) {
                      return DropdownMenuItem(
                        value: p['package_id'].toString(),
                        child: Text(p['package_name'].toString()),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() {
                      _selectedPackageId = v;
                    }),
                  ),
                  const SizedBox(height: 12),
                  _sectionTitle('Package Duration'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedDuration,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    items: _durations
                        .map(
                          (d) => DropdownMenuItem(
                            value: d['value'],
                            child: Text(d['label']!),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedDuration = v ?? '30'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: _booking ? null : _bookNow,
                      icon: _booking
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline),
                      label: Text(_booking ? 'Booking...' : 'Book Now'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Star Rating
                _sectionTitle('Rate this Nutritionist'),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (i) => GestureDetector(
                      onTap: () => _submitRating(i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          i < _userRating ? Icons.star : Icons.star_outline,
                          color: const Color(0xFFFFC107),
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar() => Container(
    width: 90,
    height: 90,
    color: Colors.white.withOpacity(0.2),
    child: const Icon(Icons.person, size: 48, color: Colors.white),
  );

  Widget _sectionTitle(String t) => Text(
    t,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1B5E20),
    ),
  );
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String? label;
  const _Chip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    if (label == null || label!.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF2E7D32)),
          const SizedBox(width: 5),
          Text(
            label!,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
