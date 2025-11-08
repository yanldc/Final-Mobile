import 'package:hive/hive.dart';
import '../models/user_model.dart';

class UserService {
  static const String _boxName = 'users';
  static Box<UserModel>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<UserModel>(_boxName);
  }

  static Future<String> createUser({
    required String login,
    required String senha,
  }) async {
    if (_box == null) await init();
    
    // Verificar se login já existe
    final existingUser = _box!.values.firstWhere(
      (user) => user.login == login,
      orElse: () => UserModel(id: '', login: '', senha: ''),
    );
    
    if (existingUser.login.isNotEmpty) {
      throw Exception('Login já existe');
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final user = UserModel(
      id: id,
      login: login,
      senha: senha,
    );

    await _box!.put(id, user);
    return id;
  }

  static Future<UserModel?> login(String login, String senha) async {
    if (_box == null) await init();
    
    for (var user in _box!.values) {
      if (user.login == login && user.senha == senha) {
        return user;
      }
    }
    return null;
  }

  static Future<void> updateFavoritos(String userId, String favoritos) async {
    if (_box == null) await init();
    
    final user = _box!.get(userId);
    if (user != null) {
      user.favoritos = favoritos;
      await user.save();
    }
  }

  static Future<void> updateFuturos(String userId, String futuros) async {
    if (_box == null) await init();
    
    final user = _box!.get(userId);
    if (user != null) {
      user.futuros = futuros;
      await user.save();
    }
  }

  static Future<UserModel?> getUserById(String id) async {
    if (_box == null) await init();
    return _box!.get(id);
  }
}