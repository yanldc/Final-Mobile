import 'package:hive/hive.dart';
import '../models/user_model.dart';
import '../models/saved_card.dart';
import '../models/pokemon_card.dart';

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

  static Future<void> addToFavoritos(String userId, PokemonCard card) async {
    if (_box == null) await init();
    
    final user = _box!.get(userId);
    if (user != null) {
      // Verificar se a carta já está nos favoritos
      bool cardExists = user.favoritos.any((favCard) => favCard.id == card.id);
      if (!cardExists) {
        final savedCard = SavedCard.fromPokemonCard(card);
        user.favoritos.add(savedCard);
        await user.save();
      }
    }
  }

  static Future<void> removeFromFavoritos(String userId, String cardId) async {
    if (_box == null) await init();
    
    final user = _box!.get(userId);
    if (user != null) {
      user.favoritos.removeWhere((favCard) => favCard.id == cardId);
      await user.save();
    }
  }

  static Future<void> addToMinhasCartas(String userId, PokemonCard card) async {
    if (_box == null) await init();
    
    final user = _box!.get(userId);
    if (user != null) {
      bool cardExists = user.minhasCartas.any((myCard) => myCard.id == card.id);
      if (!cardExists) {
        final savedCard = SavedCard.fromPokemonCard(card);
        user.minhasCartas.add(savedCard);
        await user.save();
      }
    }
  }

  static Future<void> removeFromMinhasCartas(String userId, String cardId) async {
    if (_box == null) await init();
    
    final user = _box!.get(userId);
    if (user != null) {
      user.minhasCartas.removeWhere((myCard) => myCard.id == cardId);
      await user.save();
    }
  }

  static List<SavedCard> getFavoritos(String userId) {
    if (_box == null) return [];
    final user = _box!.get(userId);
    if (user == null) return [];
    return user.favoritos;
  }

  static bool isFavorite(String userId, String cardId) {
    if (_box == null) return false;
    final user = _box!.get(userId);
    if (user == null) return false;
    return user.favoritos.any((favCard) => favCard.id == cardId);
  }

  static List<SavedCard> getMinhasCartas(String userId) {
    if (_box == null) return [];
    final user = _box!.get(userId);
    if (user == null) return [];
    return user.minhasCartas;
  }

  static bool isMyCard(String userId, String cardId) {
    if (_box == null) return false;
    final user = _box!.get(userId);
    if (user == null) return false;
    return user.minhasCartas.any((myCard) => myCard.id == cardId);
  }


}