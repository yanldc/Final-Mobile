import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon_card.dart';

class PokemonApiService {
  static const String _baseUrl = 'https://api.pokemontcg.io/v2';
  static const String _apiKey = '104c9160-18b4-414a-9ab5-d4812649eb40';

  static Future<List<PokemonCard>> getCards({int page = 1, int pageSize = 12}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cards?page=$page&pageSize=$pageSize'),
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
        Uri.parse('$_baseUrl/cards?q=name:$query*'),
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
}