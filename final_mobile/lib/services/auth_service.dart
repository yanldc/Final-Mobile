import 'package:hive/hive.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _sessionBoxName = 'session';
  static const String _currentUserKey = 'current_user';
  static Box? _sessionBox;
  static UserModel? _currentUser;

  static Future<void> init() async {
    _sessionBox = await Hive.openBox(_sessionBoxName);
    await _loadCurrentUser();
  }

  static Future<void> _loadCurrentUser() async {
    final userId = _sessionBox?.get(_currentUserKey);
    if (userId != null) {
      final userBox = await Hive.openBox<UserModel>('users');
      _currentUser = userBox.get(userId);
    }
  }

  static Future<void> setCurrentUser(UserModel user) async {
    _currentUser = user;
    await _sessionBox?.put(_currentUserKey, user.id);
  }

  static UserModel? getCurrentUser() {
    return _currentUser;
  }

  static Future<void> logout() async {
    _currentUser = null;
    await _sessionBox?.delete(_currentUserKey);
  }

  static bool isLoggedIn() {
    return _currentUser != null;
  }
}