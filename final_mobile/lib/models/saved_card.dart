import 'package:hive/hive.dart';

part 'saved_card.g.dart';

@HiveType(typeId: 1)
class SavedCard extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? imageUrl;

  @HiveField(3)
  String? smallImageUrl;

  @HiveField(4)
  late String setName;

  SavedCard({
    required this.id,
    required this.name,
    this.imageUrl,
    this.smallImageUrl,
    required this.setName,
  });

  factory SavedCard.fromPokemonCard(dynamic card) {
    return SavedCard(
      id: card.id,
      name: card.name,
      imageUrl: card.imageUrl,
      smallImageUrl: card.smallImageUrl,
      setName: card.setName,
    );
  }
}