import 'package:shared_preferences/shared_preferences.dart';

/// Simple singleton to store and retrieve logged-in user session data.
class UserSession {
  static const String _keyUserId = 'user_id';
  static const String _keyFirstName = 'first_name';
  static const String _keyLastName = 'last_name';
  static const String _keyEmail = 'email';
  static const String _keyContact = 'contact';
  static const String _keyImage = 'image';
  static const String _keyRoleId = 'role_id';

  /// Save user data after successful login.
  static Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, int.tryParse(user['id'].toString()) ?? 0);
    await prefs.setString(_keyFirstName, user['first_name']?.toString() ?? '');
    await prefs.setString(_keyLastName, user['last_name']?.toString() ?? '');
    await prefs.setString(_keyEmail, user['email']?.toString() ?? '');
    await prefs.setString(_keyContact, user['contact']?.toString() ?? '');
    await prefs.setString(_keyImage, user['image']?.toString() ?? '');
    await prefs.setString(_keyRoleId, user['role_id']?.toString() ?? '');
  }

  /// Get stored user_id (0 if not logged in).
  static Future<int> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId) ?? 0;
  }

  /// Get all stored session data as a map.
  static Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'user_id': (prefs.getInt(_keyUserId) ?? 0).toString(),
      'first_name': prefs.getString(_keyFirstName) ?? '',
      'last_name': prefs.getString(_keyLastName) ?? '',
      'email': prefs.getString(_keyEmail) ?? '',
      'contact': prefs.getString(_keyContact) ?? '',
      'image': prefs.getString(_keyImage) ?? '',
      'role_id': prefs.getString(_keyRoleId) ?? '',
    };
  }

  /// Clear session on logout.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
