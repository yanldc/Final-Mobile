import 'package:hive/hive.dart';

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
  late String favoritos;

  @HiveField(4)
  late String futuros;

  UserModel({
    required this.id,
    required this.login,
    required this.senha,
    this.favoritos = '',
    this.futuros = '',
  });
}