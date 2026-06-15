import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../authentication/user_session.dart';

// ─── Server config ────────────────────────────────────────────────
const String _serverIp = '10.107.148.193';

String get _baseUrl => kIsWeb
    ? 'http://localhost/client_project/api'
    : 'http://$_serverIp/client_project/api';

// ════════════════════════════════════════════════════════════════════
// Profile Screen
// ════════════════════════════════════════════════════════════════════
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  Map<String, dynamic> _profile = {};

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // ── Fetch profile from API ──────────────────────────────────────
  Future<void> _fetchProfile() async {
    setState(() => _loading = true);
    try {
      final userId = await UserSession.getUserId();
      if (userId == 0) {
        if (mounted) Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/profile.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          setState(() => _profile = Map<String, dynamic>.from(data['profile']));
        }
      }
    } catch (e) {
      _showSnack('Failed to load profile: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red[700] : const Color(0xFF2E7D32),
      ),
    );
  }

  // ── Open Edit Profile bottom sheet ─────────────────────────────
  void _openEditProfile() async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _EditProfileSheet(profile: _profile, baseUrl: _baseUrl),
    );
    if (updated == true) _fetchProfile();
  }

  // ── Open Change Password bottom sheet ──────────────────────────
  void _openChangePassword() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ChangePasswordSheet(baseUrl: _baseUrl),
    );
  }

  // ── Logout ─────────────────────────────────────────────────────
  void _logout() async {
    await UserSession.clear();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
      );
    }

    final fullName =
        '${_profile['first_name'] ?? ''} ${_profile['last_name'] ?? ''}'.trim();
    final email = _profile['email'] ?? '';
    final address = _profile['address'] ?? 'Not set';
    final contact = _profile['contact'] ?? 'Not set';
    final gender = _profile['gender'] ?? 'Not set';
    final dob = _profile['dob'] ?? 'Not set';
    final imageUrl = _profile['image_url'] ?? '';

    return SingleChildScrollView(
      child: Column(
        children: [
          // ── Gradient Header ──────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B5E20), Color(0xFF388E3C)],
              ),
            ),
            child: Column(
              children: [
                // Profile picture
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: ClipOval(
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _openEditProfile,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF2E7D32),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 14,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  fullName.isEmpty ? 'User' : fullName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Personal Info Card
                _SectionCard(
                  title: 'Personal Information',
                  children: [
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: contact,
                    ),
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date of Birth',
                      value: dob,
                    ),
                    _InfoRow(
                      icon: Icons.person_outline,
                      label: 'Gender',
                      value: gender == 'M'
                          ? 'Male'
                          : gender == 'F'
                          ? 'Female'
                          : gender,
                    ),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: address,
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Account options
                _SectionCard(
                  title: 'Account',
                  children: [
                    _MenuTile(
                      icon: Icons.edit_outlined,
                      label: 'Edit Profile',
                      color: const Color(0xFF2E7D32),
                      onTap: _openEditProfile,
                    ),
                    _MenuTile(
                      icon: Icons.lock_outlined,
                      label: 'Change Password',
                      color: Colors.orange,
                      onTap: _openChangePassword,
                    ),
                    _MenuTile(
                      icon: Icons.receipt_long_outlined,
                      label: 'My Packages',
                      color: Colors.purple,
                      onTap: () =>
                          Navigator.pushNamed(context, '/profile_setup'),
                    ),
                    _MenuTile(
                      icon: Icons.refresh_outlined,
                      label: 'Refresh Profile',
                      color: Colors.blue,
                      onTap: _fetchProfile,
                      isLast: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
// Edit Profile Bottom Sheet
// ════════════════════════════════════════════════════════════════════
class _EditProfileSheet extends StatefulWidget {
  final Map<String, dynamic> profile;
  final String baseUrl;
  const _EditProfileSheet({required this.profile, required this.baseUrl});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fname;
  late TextEditingController _lname;
  late TextEditingController _email;
  late TextEditingController _address;
  late TextEditingController _contact;
  bool _saving = false;
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _fname = TextEditingController(text: widget.profile['first_name'] ?? '');
    _lname = TextEditingController(text: widget.profile['last_name'] ?? '');
    _email = TextEditingController(text: widget.profile['email'] ?? '');
    _address = TextEditingController(text: widget.profile['address'] ?? '');
    _contact = TextEditingController(text: widget.profile['contact'] ?? '');
  }

  @override
  void dispose() {
    _fname.dispose();
    _lname.dispose();
    _email.dispose();
    _address.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (img != null) setState(() => _pickedImage = img);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final userId = await UserSession.getUserId();
      final uri = Uri.parse('${widget.baseUrl}/update_profile.php');
      final request = http.MultipartRequest('POST', uri);

      request.fields['user_id'] = userId.toString();
      request.fields['fname'] = _fname.text.trim();
      request.fields['lname'] = _lname.text.trim();
      request.fields['email'] = _email.text.trim();
      request.fields['address'] = _address.text.trim();
      request.fields['contactno'] = _contact.text.trim();

      if (_pickedImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', _pickedImage!.path),
        );
      }

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        // Update local session quick-cache
        await UserSession.saveUser({
          'id': userId,
          'first_name': _fname.text.trim(),
          'last_name': _lname.text.trim(),
          'email': _email.text.trim(),
          'contact': _contact.text.trim(),
          'image':
              data['profile']['image_url'] ?? data['profile']['image'] ?? '',
          'role_id': widget.profile['role_id'] ?? '',
        });
        if (mounted) Navigator.pop(context, true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Update failed'),
              backgroundColor: Colors.red[700],
            ),
          );
        }
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
                'Edit Profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 16),

              // Profile image picker
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFFE8F5E9),
                    backgroundImage: _pickedImage != null
                        ? FileImage(File(_pickedImage!.path))
                        : null,
                    child: _pickedImage == null
                        ? const Icon(
                            Icons.camera_alt,
                            color: Color(0xFF2E7D32),
                            size: 28,
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'Tap to change photo',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              _field(_fname, 'First Name', Icons.person_outline),
              const SizedBox(height: 12),
              _field(_lname, 'Last Name', Icons.person_outline),
              const SizedBox(height: 12),
              _field(
                _email,
                'Email',
                Icons.email_outlined,
                type: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _field(
                _contact,
                'Contact No',
                Icons.phone_outlined,
                type: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _field(
                _address,
                'Address',
                Icons.location_on_outlined,
                maxLines: 3,
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
                      : const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Change Password Bottom Sheet
// ════════════════════════════════════════════════════════════════════
class _ChangePasswordSheet extends StatefulWidget {
  final String baseUrl;
  const _ChangePasswordSheet({required this.baseUrl});

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _oldPass = TextEditingController();
  final _newPass = TextEditingController();
  final _confirmPass = TextEditingController();
  bool _saving = false;
  bool _hideOld = true;
  bool _hideNew = true;
  bool _hideConfirm = true;

  @override
  void dispose() {
    _oldPass.dispose();
    _newPass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final userId = await UserSession.getUserId();
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${widget.baseUrl}/change_password.php'),
      );
      request.fields['user_id'] = userId.toString();
      request.fields['old_password'] = _oldPass.text;
      request.fields['new_password'] = _newPass.text;
      request.fields['confirm_password'] = _confirmPass.text;

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      final data = json.decode(response.body);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? ''),
            backgroundColor: data['status'] == 'success'
                ? const Color(0xFF2E7D32)
                : Colors.red[700],
          ),
        );
        if (data['status'] == 'success') Navigator.pop(context);
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
                'Change Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 20),
              _passField(
                _oldPass,
                'Old Password',
                _hideOld,
                () => setState(() => _hideOld = !_hideOld),
              ),
              const SizedBox(height: 12),
              _passField(
                _newPass,
                'New Password',
                _hideNew,
                () => setState(() => _hideNew = !_hideNew),
              ),
              const SizedBox(height: 12),
              _passField(
                _confirmPass,
                'Confirm Password',
                _hideConfirm,
                () => setState(() => _hideConfirm = !_hideConfirm),
                extraValidator: (v) {
                  if (v != _newPass.text) return 'Passwords do not match';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: _saving ? null : _changePassword,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Change Password'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _passField(
    TextEditingController ctrl,
    String label,
    bool obscure,
    VoidCallback toggle, {
    String? Function(String?)? extraValidator,
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outlined, color: Color(0xFF2E7D32)),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: Colors.grey,
          ),
          onPressed: toggle,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Required';
        if (v.length < 6) return 'At least 6 characters';
        return extraValidator?.call(v);
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// Reusable Widgets
// ════════════════════════════════════════════════════════════════════
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
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
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
              Expanded(
                child: Column(
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
                        color: Color(0xFF333333),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 50),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isLast;
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF333333),
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Color(0xFFCCCCCC),
            size: 20,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 2,
          ),
        ),
        if (!isLast) const Divider(height: 1, indent: 70),
      ],
    );
  }
}
