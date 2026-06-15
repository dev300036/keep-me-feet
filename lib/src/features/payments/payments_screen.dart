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
// Payments Screen
// ════════════════════════════════════════════════════════════════════
class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});
  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  bool _loading = true;
  List<dynamic> _payments = [];

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    setState(() => _loading = true);
    try {
      final userId = await UserSession.getUserId();
      if (userId == 0) return;
      final res = await http.get(
        Uri.parse('$_baseUrl/my_payments.php?user_id=$userId'),
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        if (data['status'] == 'success') {
          setState(() => _payments = data['payments'] as List);
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF4),
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPayments,
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            )
          : _payments.isEmpty
          ? _emptyView()
          : RefreshIndicator(
              onRefresh: _fetchPayments,
              color: const Color(0xFF2E7D32),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _payments.length,
                itemBuilder: (_, i) => _PaymentCard(data: _payments[i]),
              ),
            ),
    );
  }

  Widget _emptyView() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.receipt_long_outlined,
          size: 72,
          color: Colors.grey.shade300,
        ),
        const SizedBox(height: 16),
        const Text(
          'No payments found',
          style: TextStyle(fontSize: 16, color: Color(0xFF888888)),
        ),
      ],
    ),
  );
}

// ── Payment Card ──────────────────────────────────────────────────
class _PaymentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PaymentCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final status = data['payment_status'] as String? ?? '';
    final amount = data['payment_gross'] as String? ?? '0';
    final txn = data['txn_id'] as String? ?? '';
    final pkgId = data['item_number'] as String? ?? '';
    final isOk = status.toLowerCase() == 'completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${data['payment_id']}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                  ),
                ),
                _StatusBadge(status: status, isOk: isOk),
              ],
            ),
            const Divider(height: 16),
            _Row(
              label: 'Amount',
              value: '${data['currency_code'] ?? 'USD'}  $amount',
            ),
            const SizedBox(height: 6),
            _Row(label: 'Package', value: pkgId.isNotEmpty ? pkgId : '--'),
            const SizedBox(height: 6),
            _Row(label: 'TXN ID', value: txn.isNotEmpty ? txn : '--'),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final bool isOk;
  const _StatusBadge({required this.status, required this.isOk});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isOk ? const Color(0xFF2E7D32) : Colors.orange).withOpacity(
          0.1,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isEmpty ? 'Unknown' : status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isOk ? const Color(0xFF2E7D32) : Colors.orange[800],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF333333),
          ),
        ),
      ],
    );
  }
}
