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
  final _searchController = TextEditingController();
  bool _showFilters = false;
  bool _showNameSearch = false;

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
        _showFilters = false; // Recolhe após pesquisar
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

  Future<void> _searchByName() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() => _error = 'Digite o nome da carta');
      return;
    }
    
    try {
      setState(() {
        _isLoading = true;
        _error = '';
        _showNameSearch = false; // Recolhe após pesquisar
      });
      
      final cards = await PokemonApiService.searchCards(query);
      
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
        final cardData = '{"id":"${card.id}","name":"${card.name}","images":{"small":"${card.smallImageUrl}","large":"${card.imageUrl}"},"set":{"name":"${card.setName}"}}';
        
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
        final cardData = '{"id":"${card.id}","name":"${card.name}","images":{"small":"${card.smallImageUrl}","large":"${card.imageUrl}"},"set":{"name":"${card.setName}"}}';
        
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
              // Botão Tipo/Raridade
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    _showFilters = !_showFilters;
                    _showNameSearch = false;
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showFilters ? const Color(0xFF560982) : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pesquisar por Tipo/Raridade'),
                      const SizedBox(width: 8),
                      Icon(_showFilters ? Icons.expand_less : Icons.expand_more),
                    ],
                  ),
                ),
              ),
              // Filtros expansíveis
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showFilters ? null : 0,
                child: _showFilters ? Column(
                  children: [
                    const SizedBox(height: 16),
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
                ) : const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),
              // Botão Nome
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() {
                    _showNameSearch = !_showNameSearch;
                    _showFilters = false;
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showNameSearch ? const Color(0xFF560982) : Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pesquisar por Nome'),
                      const SizedBox(width: 8),
                      Icon(_showNameSearch ? Icons.expand_less : Icons.expand_more),
                    ],
                  ),
                ),
              ),
              // Campo nome expansível
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showNameSearch ? null : 0,
                child: _showNameSearch ? Column(
                  children: [
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _searchController,
                      style: TextStyle(
                        color: themeController.isDarkMode ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Nome da carta',
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
                        prefixIcon: Icon(
                          Icons.search,
                          color: themeController.isDarkMode ? Colors.white70 : const Color(0xFF560982),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _searchByName,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF560982),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Pesquisar'),
                      ),
                    ),
                  ],
                ) : const SizedBox.shrink(),
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
          childAspectRatio: 0.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
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
                            fit: BoxFit.contain,
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
                  padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        card.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        card.setName,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
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
                              size: 18,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          ),
                          IconButton(
                            onPressed: () => _toggleMinhaCarta(card.id),
                            icon: Icon(
                              Icons.style,
                              color: _minhasCartas.contains(card.id) 
                                  ? const Color(0xFF560982) 
                                  : Colors.grey,
                              size: 18,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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