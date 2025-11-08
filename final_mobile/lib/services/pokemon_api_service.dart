import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_card.dart';

class PokemonApiService {
  static const String _baseUrl = 'https://api.pokemontcg.io/v2';
  static const String _apiKey = '104c9160-18b4-414a-9ab5-d4812649eb40';

  static Future<List<PokemonCard>> getCards({int page = 1, int pageSize = 12}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cards?page=$page&pageSize=$pageSize&select=id,images'),
        headers: {
          'X-Api-Key': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> cardsJson = data['data'] ?? [];
        
        return cardsJson.map((cardJson) => PokemonCard.fromJson(cardJson)).toList();
      } else {
        throw Exception('Erro ao carregar cartas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static List<String> getTypes() {
    return [
      "Colorless",
      "Darkness",
      "Dragon",
      "Fairy",
      "Fighting",
      "Fire",
      "Grass",
      "Lightning",
      "Metal",
      "Psychic",
      "Water"
    ];
  }

  static List<String> getRarities() {
    return [
      "Amazing Rare",
      "Common",
      "LEGEND",
      "Promo",
      "Rare",
      "Rare ACE",
      "Rare BREAK",
      "Rare Holo",
      "Rare Holo EX",
      "Rare Holo GX",
      "Rare Holo LV.X",
      "Rare Holo Star",
      "Rare Holo V",
      "Rare Holo VMAX",
      "Rare Prime",
      "Rare Prism Star",
      "Rare Rainbow",
      "Rare Secret",
      "Rare Shining",
      "Rare Shiny",
      "Rare Shiny GX",
      "Rare Ultra",
      "Uncommon"
    ];
  }

  static Future<List<PokemonCard>> getCardsWithFilters({String? type, String? rarity}) async {
    try {
      String query = '';
      if (type != null && type.isNotEmpty) {
        query += 'types:$type';
      }
      if (rarity != null && rarity.isNotEmpty) {
        if (query.isNotEmpty) query += ' ';
        query += 'rarity:"$rarity"';
      }
      
      final url = query.isEmpty 
          ? '$_baseUrl/cards?pageSize=12&select=id,name,images,set'
          : '$_baseUrl/cards?q=$query&pageSize=12&select=id,name,images,set';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'X-Api-Key': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> cardsJson = data['data'] ?? [];
        
        return cardsJson.map((cardJson) => PokemonCard.fromJson(cardJson)).toList();
      } else {
        throw Exception('Erro ao carregar cartas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<List<PokemonCard>> searchCards(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cards?q=name:$query*&pageSize=12&select=id,name,images,set'),
        headers: {
          'X-Api-Key': _apiKey,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> cardsJson = data['data'] ?? [];
        
        return cardsJson.map((cardJson) => PokemonCard.fromJson(cardJson)).toList();
      } else {
        throw Exception('Erro ao buscar cartas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  static Future<List<PokemonCard>> getCardsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    
    final futures = ids.map((id) => _fetchSingleCard(id)).toList();
    final results = await Future.wait(futures);
    
    return results.where((card) => card != null).cast<PokemonCard>().toList();
  }
  
  static Future<PokemonCard?> _fetchSingleCard(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cards/$id'),
        headers: {
          'X-Api-Key': _apiKey,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cardJson = data['data'];
        if (cardJson != null) {
          return PokemonCard.fromJson(cardJson);
        }
      }
    } catch (e) {
      // Falha silenciosa
    }
    return null;
  }
}