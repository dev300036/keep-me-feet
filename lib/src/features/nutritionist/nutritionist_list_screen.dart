import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'nutritionist_detail_screen.dart';

const String _nutServerIp = '10.107.148.193';
String get _nutBaseUrl => kIsWeb
    ? 'http://localhost/client_project/api'
    : 'http://$_nutServerIp/client_project/api';

class NutritionistListScreen extends StatefulWidget {
  const NutritionistListScreen({super.key});

  @override
  State<NutritionistListScreen> createState() => _NutritionistListScreenState();
}

class _NutritionistListScreenState extends State<NutritionistListScreen> {
  String _selectedFilter = 'All';
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _loading = true;
  List<Map<String, dynamic>> _nutritionists = [];

  @override
  void initState() {
    super.initState();
    _fetchNutritionists();
  }

  Future<void> _fetchNutritionists() async {
    setState(() => _loading = true);
    try {
      final res = await http.get(
        Uri.parse('$_nutBaseUrl/nutritionist_list.php'),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'success') {
          setState(
            () => _nutritionists = List<Map<String, dynamic>>.from(
              data['nutritionists'],
            ),
          );
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  List<Map<String, dynamic>> get _filtered {
    return _nutritionists.where((n) {
      final spec = (n['speciality'] ?? '').toString().toLowerCase();
      final matchFilter =
          _selectedFilter == 'All' ||
          spec.contains(_selectedFilter.toLowerCase());
      final q = _searchQuery.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          (n['full_name'] ?? '').toString().toLowerCase().contains(q) ||
          spec.contains(q);
      return matchFilter && matchSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(Map<String, dynamic> n) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NutritionistDetailScreen(dietitianId: n['user_id'].toString()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      );
    }
    return Column(
      children: [
        // Header with gradient
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nutritionist & Dietitian',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Find the perfect nutrition expert for you',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search nutritionist...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF2E7D32),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Filter chips
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Clinical', 'Sports', 'Pediatric'].map((f) {
                final isSelected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = f),
                    selectedColor: const Color(0xFF2E7D32),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF444444),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    backgroundColor: const Color(0xFFF5F5F5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? const Color(0xFF2E7D32)
                          : Colors.transparent,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // List
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No nutritionists found',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchNutritionists,
                  color: const Color(0xFF2E7D32),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _NutritionistCard(
                      nutritionist: filtered[i],
                      onTap: () => _openDetail(filtered[i]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// ── Nutritionist Card (API-backed) ──────────────────────────────
class _NutritionistCard extends StatelessWidget {
  final Map<String, dynamic> nutritionist;
  final VoidCallback onTap;
  const _NutritionistCard({required this.nutritionist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final n = nutritionist;
    final name = n['full_name'] ?? '';
    final spec = n['speciality'] ?? '';
    final exp = n['experience'] ?? '';
    final rating = (n['avg_rating'] as num?)?.toDouble() ?? 0.0;
    final reviews = (n['rating_count'] as num?)?.toInt() ?? 0;
    final imgUrl = n['image_url'] as String? ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            ClipRRect(
              borderRadius: BorderRadius.circular(31),
              child: imgUrl.isNotEmpty
                  ? Image.network(
                      imgUrl,
                      width: 62,
                      height: 62,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                      ),
                      if (spec.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            spec.length > 12
                                ? '${spec.substring(0, 12)}…'
                                : spec,
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  if (spec.isNotEmpty)
                    Text(
                      spec,
                      style: const TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        '$rating ($reviews)',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (exp.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.work_outline,
                          size: 13,
                          color: Color(0xFF888888),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          exp,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Consult'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 62,
    height: 62,
    color: const Color(0xFFE8F5E9),
    child: const Icon(Icons.person, size: 30, color: Color(0xFF2E7D32)),
  );
}
