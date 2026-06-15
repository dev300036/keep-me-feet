import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String _baseUrl = 'http://10.107.148.193/client_project/api';

class DietitianPaymentsScreen extends StatefulWidget {
  const DietitianPaymentsScreen({super.key});

  @override
  State<DietitianPaymentsScreen> createState() =>
      _DietitianPaymentsScreenState();
}

class _DietitianPaymentsScreenState extends State<DietitianPaymentsScreen> {
  List<Map<String, dynamic>> _payments = [];
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
      final res = await http.get(Uri.parse('$_baseUrl/dietitian_payments.php'));
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (data['status'] == 'success') {
        setState(() {
          _payments = List<Map<String, dynamic>>.from(data['payments']);
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
    return Scaffold(
      appBar: AppBar(title: const Text('Payments')),
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
                  Text(_error!),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: _load, child: const Text('Retry')),
                ],
              ),
            )
          : _payments.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No payment records found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _payments.length,
                itemBuilder: (_, i) {
                  final p = _payments[i];
                  final status = p['payment_status'] ?? '';
                  final isCompleted = status.toLowerCase() == 'completed';
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${p['currency_code'] ?? ''} ${p['payment_gross'] ?? ''}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isCompleted
                                      ? const Color(0xFFE8F5E9)
                                      : Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isCompleted
                                        ? const Color(0xFF2E7D32)
                                        : Colors.orange,
                                  ),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: isCompleted
                                        ? const Color(0xFF2E7D32)
                                        : Colors.orange.shade700,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Divider(),
                          _paymentRow(
                            'Payment ID',
                            p['payment_id']?.toString() ?? '',
                          ),
                          _paymentRow(
                            'Package ID',
                            p['item_number']?.toString() ?? '',
                          ),
                          _paymentRow('TXN ID', p['txn_id']?.toString() ?? ''),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _paymentRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
