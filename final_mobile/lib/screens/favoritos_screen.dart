import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../services/pokemon_api_service.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../models/pokemon_card.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  State<FavoritosScreen> createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  List<PokemonCard> _favoritosCards = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadFavoritos();
  }

  Future<void> _loadFavoritos() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final user = AuthService.getCurrentUser();
      
      if (user != null) {
        final favoritosIds = UserService.getFavoritos(user.id);
        
        if (favoritosIds.isNotEmpty) {
          List<PokemonCard> cards = [];
          List<String> idsToFetch = [];
          
          for (String id in favoritosIds) {
            final cachedData = await UserService.getCachedCardData(id);
            
            if (cachedData != null) {
              try {
                final cardJson = json.decode(cachedData);
                cards.add(PokemonCard.fromJson(cardJson));
              } catch (e) {
                idsToFetch.add(id);
              }
            } else {
              idsToFetch.add(id);
            }
          }
          
          if (idsToFetch.isNotEmpty) {
            try {
              final apiCards = await PokemonApiService.getCardsByIds(idsToFetch);
              cards.addAll(apiCards);
            } catch (e) {
              // Falha silenciosa na API
            }
          }
          
          setState(() {
            _favoritosCards = cards;
            _isLoading = false;
          });
        } else {
          setState(() {
            _favoritosCards = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _favoritosCards = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorito(String cardId) async {
    final user = AuthService.getCurrentUser();
    if (user != null) {
      await UserService.removeFromFavoritos(user.id, cardId);
      _loadFavoritos();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) => Scaffold(
        backgroundColor: themeController.isDarkMode ? Colors.black : Colors.white,
        body: _buildBody(themeController),
      ),
    );
  }

  Widget _buildBody(ThemeController themeController) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF560982)),
            const SizedBox(height: 16),
            Text(
              'Carregando favoritos...',
              style: TextStyle(
                color: themeController.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: themeController.isDarkMode ? Colors.white : Colors.black54,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar favoritos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeController.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFavoritos,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF560982),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      );
    }

    if (_favoritosCards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: themeController.isDarkMode ? Colors.white54 : Colors.black54,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma carta favoritada',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeController.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione cartas aos favoritos na tela inicial',
              style: TextStyle(
                color: themeController.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavoritos,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _favoritosCards.length,
        itemBuilder: (context, index) {
          final card = _favoritosCards[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: card.smallImageUrl != null
                        ? Image.network(
                            card.smallImageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF560982),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.setName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: IconButton(
                          onPressed: () => _removeFavorito(card.id),
                          icon: const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}