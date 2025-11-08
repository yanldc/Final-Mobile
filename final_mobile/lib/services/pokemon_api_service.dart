import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_card.dart';

class PokemonApiService {
  static const String _baseUrl = 'https://api.pokemontcg.io/v2';
  static const String _apiKey = '104c9160-18b4-414a-9ab5-d4812649eb40';

  static Future<List<PokemonCard>> getCards({int page = 1, int pageSize = 8}) async {
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/cards?page=$page&pageSize=$pageSize&select=id,name,images,set'),
          headers: {
            'X-Api-Key': _apiKey,
          },
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic> cardsJson = data['data'] ?? [];
          
          return cardsJson.map((cardJson) => PokemonCard.fromJson(cardJson)).toList();
        } else if (response.statusCode >= 500) {
          if (attempt < 2) {
            await Future.delayed(Duration(seconds: attempt + 1));
            continue;
          }
          throw Exception('Servidor indisponível');
        } else {
          throw Exception('Erro: ${response.statusCode}');
        }
      } catch (e) {
        if (attempt < 2) {
          await Future.delayed(Duration(seconds: attempt + 1));
          continue;
        }
        throw Exception('Conexão falhou');
      }
    }
    return [];
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

  static Future<List<PokemonCard>> getCardsWithFilters({String? type, String? rarity, int page = 1}) async {
    for (int attempt = 0; attempt < 3; attempt++) {
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
            ? '$_baseUrl/cards?page=$page&pageSize=8&select=id,name,images,set'
            : '$_baseUrl/cards?q=$query&page=$page&pageSize=8&select=id,name,images,set';
        
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'X-Api-Key': _apiKey,
          },
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic> cardsJson = data['data'] ?? [];
          
          return cardsJson.map((cardJson) => PokemonCard.fromJson(cardJson)).toList();
        } else if (response.statusCode >= 500) {
          if (attempt < 2) {
            await Future.delayed(Duration(seconds: attempt + 1));
            continue;
          }
          throw Exception('Servidor indisponível');
        } else {
          throw Exception('Erro: ${response.statusCode}');
        }
      } catch (e) {
        if (attempt < 2) {
          await Future.delayed(Duration(seconds: attempt + 1));
          continue;
        }
        throw Exception('Conexão falhou');
      }
    }
    return [];
  }

  static Future<List<PokemonCard>> searchCards(String query, {int page = 1}) async {
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/cards?q=name:$query*&page=$page&pageSize=8&select=id,name,images,set'),
          headers: {
            'X-Api-Key': _apiKey,
          },
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic> cardsJson = data['data'] ?? [];
          
          return cardsJson.map((cardJson) => PokemonCard.fromJson(cardJson)).toList();
        } else if (response.statusCode >= 500) {
          if (attempt < 2) {
            await Future.delayed(Duration(seconds: attempt + 1));
            continue;
          }
          throw Exception('Servidor indisponível');
        } else {
          throw Exception('Erro: ${response.statusCode}');
        }
      } catch (e) {
        if (attempt < 2) {
          await Future.delayed(Duration(seconds: attempt + 1));
          continue;
        }
        throw Exception('Conexão falhou');
      }
    }
    return [];
  }

  static Future<List<PokemonCard>> getCardsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    
    final futures = ids.map((id) => _fetchSingleCard(id)).toList();
    final results = await Future.wait(futures);
    
    return results.where((card) => card != null).cast<PokemonCard>().toList();
  }
  
  static Future<PokemonCard?> _fetchSingleCard(String id) async {
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrl/cards/$id'),
          headers: {
            'X-Api-Key': _apiKey,
          },
        ).timeout(const Duration(seconds: 6));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final cardJson = data['data'];
          if (cardJson != null) {
            return PokemonCard.fromJson(cardJson);
          }
        } else if (response.statusCode >= 500 && attempt < 1) {
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }
        break;
      } catch (e) {
        if (attempt < 1) {
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }
      }
    }
    return null;
  }
}