import 'package:hive/hive.dart';
import 'saved_card.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String login;

  @HiveField(2)
  late String senha;

  @HiveField(3)
  List<SavedCard> favoritos;

  @HiveField(4)
  List<SavedCard> minhasCartas;

  UserModel({
    required this.id,
    required this.login,
    required this.senha,
    List<SavedCard>? favoritos,
    List<SavedCard>? minhasCartas,
  }) : favoritos = favoritos ?? [],
       minhasCartas = minhasCartas ?? [];
}
