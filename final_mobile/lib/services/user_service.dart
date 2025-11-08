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

  static Future<void> addToFavoritos(String userId, String cardId) async {
    if (_box == null) await init();
    
    final user = _box!.get(userId);
    if (user != null) {
      List<String> favoritos = user.favoritos.isEmpty ? [] : user.favoritos.split(',');
      if (!favoritos.contains(cardId)) {
        favoritos.add(cardId);
        user.favoritos = favoritos.join(',');
        await user.save();
      }
    }
  }

  static Future<void> removeFromFavoritos(String userId, String cardId) async {
    if (_box == null) await init();
    
    final user = _box!.get(userId);
    if (user != null) {
      List<String> favoritos = user.favoritos.isEmpty ? [] : user.favoritos.split(',');
      favoritos.remove(cardId);
      user.favoritos = favoritos.join(',');
      await user.save();
    }
  }

  static Future<void> addToMinhasCartas(String userId, String cardId) async {
    if (_box == null) await init();
    
    final user = _box!.get(userId);
    if (user != null) {
      List<String> minhasCartas = user.minhas_cartas.isEmpty ? [] : user.minhas_cartas.split(',');
      if (!minhasCartas.contains(cardId)) {
        minhasCartas.add(cardId);
        user.minhas_cartas = minhasCartas.join(',');
        await user.save();
      }
    }
  }

  static Future<void> removeFromMinhasCartas(String userId, String cardId) async {
    if (_box == null) await init();
    
    final user = _box!.get(userId);
    if (user != null) {
      List<String> minhasCartas = user.minhas_cartas.isEmpty ? [] : user.minhas_cartas.split(',');
      minhasCartas.remove(cardId);
      user.minhas_cartas = minhasCartas.join(',');
      await user.save();
    }
  }

  static List<String> getFavoritos(String userId) {
    if (_box == null) return [];
    final user = _box!.get(userId);
    if (user == null || user.favoritos.isEmpty) return [];
    return user.favoritos.split(',').where((id) => id.isNotEmpty).toList();
  }

  static List<String> getMinhasCartas(String userId) {
    if (_box == null) return [];
    final user = _box!.get(userId);
    if (user == null || user.minhas_cartas.isEmpty) return [];
    return user.minhas_cartas.split(',').where((id) => id.isNotEmpty).toList();
  }


}