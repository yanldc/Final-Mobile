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
  bool _isLoading = false;
  String _error = '';
  List<String> _favoritos = [];
  List<String> _minhasCartas = [];
  List<String> _types = [];
  List<String> _rarities = [];
  String? _selectedType;
  String? _selectedRarity;
  bool _filtersLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    setState(() {
      _types = PokemonApiService.getTypes();
      _rarities = PokemonApiService.getRarities();
      _filtersLoaded = true;
    });
  }

  Future<void> _searchCards() async {
    if (_selectedType == null && _selectedRarity == null) {
      setState(() => _error = 'Selecione pelo menos um filtro');
      return;
    }
    
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });
      
      final cards = await PokemonApiService.getCardsWithFilters(
        type: _selectedType,
        rarity: _selectedRarity,
      );
      
      final user = AuthService.getCurrentUser();
      
      List<String> favoritos = [];
      List<String> minhasCartas = [];
      
      if (user != null) {
        favoritos = UserService.getFavoritos(user.id);
        minhasCartas = UserService.getMinhasCartas(user.id);
      }
      
      setState(() {
        _cards = cards;
        _favoritos = favoritos;
        _minhasCartas = minhasCartas;
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
        final card = _cards.firstWhere((c) => c.id == cardId);
        final cardData = '{"id":"${card.id}","images":{"small":"${card.smallImageUrl}","large":"${card.imageUrl}"}}';
        
        await UserService.addToFavoritos(user.id, cardId, cardData: cardData);
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
        final card = _cards.firstWhere((c) => c.id == cardId);
        final cardData = '{"id":"${card.id}","images":{"small":"${card.smallImageUrl}","large":"${card.imageUrl}"}}';
        
        await UserService.addToMinhasCartas(user.id, cardId, cardData: cardData);
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
              _filtersLoaded ? 'Carregando cartas...' : 'Carregando filtros...',
              style: TextStyle(
                color: themeController.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      );
    }

    if (!_filtersLoaded) {
      return Center(
        child: ElevatedButton(
          onPressed: _loadFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF560982),
            foregroundColor: Colors.white,
          ),
          child: const Text('Carregar Filtros'),
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
              onPressed: _searchCards,
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

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: themeController.isDarkMode ? Colors.grey[800] : Colors.grey[100],
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedType,
                      decoration: InputDecoration(
                        labelText: 'Tipo',
                        labelStyle: TextStyle(
                          color: themeController.isDarkMode ? Colors.white70 : const Color(0xFF560982),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF560982), width: 2),
                        ),
                        filled: true,
                        fillColor: themeController.isDarkMode ? Colors.grey[800] : Colors.white,
                      ),
                      dropdownColor: themeController.isDarkMode ? Colors.grey[800] : Colors.white,
                      style: TextStyle(
                        color: themeController.isDarkMode ? Colors.white : Colors.black,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null, 
                          child: Text(
                            'Todos os tipos',
                            style: TextStyle(
                              color: themeController.isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                        ..._types.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        )),
                      ],
                      onChanged: (value) => setState(() => _selectedType = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedRarity,
                      decoration: InputDecoration(
                        labelText: 'Raridade',
                        labelStyle: TextStyle(
                          color: themeController.isDarkMode ? Colors.white70 : const Color(0xFF560982),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF560982), width: 2),
                        ),
                        filled: true,
                        fillColor: themeController.isDarkMode ? Colors.grey[800] : Colors.white,
                      ),
                      dropdownColor: themeController.isDarkMode ? Colors.grey[800] : Colors.white,
                      style: TextStyle(
                        color: themeController.isDarkMode ? Colors.white : Colors.black,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null, 
                          child: Text(
                            'Todas as raridades',
                            style: TextStyle(
                              color: themeController.isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ),
                        ..._rarities.map((rarity) => DropdownMenuItem(
                          value: rarity,
                          child: Text(rarity),
                        )),
                      ],
                      onChanged: (value) => setState(() => _selectedRarity = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _searchCards,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF560982),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Pesquisar'),
                ),
              ),
            ],
          ),
        ),
        if (_cards.isEmpty && !_isLoading && _error.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'Selecione os filtros e clique em Pesquisar',
                style: TextStyle(
                  color: themeController.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          )
        else if (_cards.isNotEmpty)
          Expanded(
            child: RefreshIndicator(
              onRefresh: _searchCards,
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
            ),
          ),
      ],
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