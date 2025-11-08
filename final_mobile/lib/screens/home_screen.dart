import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_navbar.dart';
import '../controllers/theme_controller.dart';
import '../services/pokemon_api_service.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../models/pokemon_card.dart';
import 'favoritos_screen.dart';
import 'minhas_cartas_screen.dart';
import 'minha_conta_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<PokemonCard> _cards = [];
  bool _isLoading = true;
  String _error = '';
  List<String> _favoritos = [];
  List<String> _minhasCartas = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      
      final cards = await PokemonApiService.getCards();
      final user = AuthService.getCurrentUser();
      if (user != null) {
        _favoritos = UserService.getFavoritos(user.id);
        _minhasCartas = UserService.getMinhasCartas(user.id);
      }
      
      setState(() {
        _cards = cards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorito(String cardId) async {
    final user = AuthService.getCurrentUser();
    if (user != null) {
      if (_favoritos.contains(cardId)) {
        await UserService.removeFromFavoritos(user.id, cardId);
        _favoritos.remove(cardId);
      } else {
        await UserService.addToFavoritos(user.id, cardId);
        _favoritos.add(cardId);
      }
      setState(() {});
    }
  }

  Future<void> _toggleMinhaCarta(String cardId) async {
    final user = AuthService.getCurrentUser();
    if (user != null) {
      if (_minhasCartas.contains(cardId)) {
        await UserService.removeFromMinhasCartas(user.id, cardId);
        _minhasCartas.remove(cardId);
      } else {
        await UserService.addToMinhasCartas(user.id, cardId);
        _minhasCartas.add(cardId);
      }
      setState(() {});
    }
  }

  Widget _buildHomeScreen(ThemeController themeController) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF560982)),
            const SizedBox(height: 16),
            Text(
              'Carregando cartas...',
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
              'Erro ao carregar cartas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeController.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeController.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCards,
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

    return RefreshIndicator(
      onRefresh: _loadCards,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            onPressed: () => _toggleFavorito(card.id),
                            icon: Icon(
                              Icons.favorite,
                              color: _favoritos.contains(card.id) 
                                  ? Colors.red 
                                  : Colors.grey,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            onPressed: () => _toggleMinhaCarta(card.id),
                            icon: Icon(
                              Icons.style,
                              color: _minhasCartas.contains(card.id) 
                                  ? const Color(0xFF560982) 
                                  : Colors.grey,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
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

  List<Widget> _getScreens(ThemeController themeController) => [
    _buildHomeScreen(themeController),
    const FavoritosScreen(),
    const MinhasCartasScreen(),
    const MinhaContaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeController) => Scaffold(
        backgroundColor: themeController.isDarkMode ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _getScreens(themeController)[_currentIndex],
        bottomNavigationBar: CustomNavbar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}