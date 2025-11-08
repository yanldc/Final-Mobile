class PokemonCard {
  final String id;
  final String name;
  final String? imageUrl;
  final String? smallImageUrl;
  final String setName;
  final String? rarity;
  final String? artist;

  PokemonCard({
    required this.id,
    required this.name,
    this.imageUrl,
    this.smallImageUrl,
    required this.setName,
    this.rarity,
    this.artist,
  });

  factory PokemonCard.fromJson(Map<String, dynamic> json) {
    return PokemonCard(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['images']?['large'],
      smallImageUrl: json['images']?['small'],
      setName: json['set']?['name'] ?? '',
      rarity: json['rarity'],
      artist: json['artist'],
    );
  }
}