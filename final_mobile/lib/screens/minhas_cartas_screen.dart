import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/theme_controller.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../models/saved_card.dart';

class MinhasCartasScreen extends StatefulWidget {
  const MinhasCartasScreen({super.key});

  @override
  State<MinhasCartasScreen> createState() => _MinhasCartasScreenState();
}

class _MinhasCartasScreenState extends State<MinhasCartasScreen> {
  List<SavedCard> _minhasCartasCards = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadMinhasCartas();
  }

  Future<void> _loadMinhasCartas() async {
    try {
      setState(() {
        _isLoading = true;
        _error = '';
      });

      final user = AuthService.getCurrentUser();
      
      if (user != null) {
        final minhasCartas = UserService.getMinhasCartas(user.id);
        
        setState(() {
          _minhasCartasCards = minhasCartas;
          _isLoading = false;
        });
      } else {
        setState(() {
          _minhasCartasCards = [];
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

  Future<void> _removeMinhaCarta(String cardId) async {
    final user = AuthService.getCurrentUser();
    if (user != null) {
      await UserService.removeFromMinhasCartas(user.id, cardId);
      _loadMinhasCartas();
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
              'Carregando minhas cartas...',
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
              'Erro ao carregar minhas cartas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeController.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMinhasCartas,
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

    if (_minhasCartasCards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.style,
              size: 64,
              color: themeController.isDarkMode ? Colors.white54 : Colors.black54,
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma carta na coleção',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: themeController.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione cartas à sua coleção na tela inicial',
              style: TextStyle(
                color: themeController.isDarkMode ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMinhasCartas,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.6,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _minhasCartasCards.length,
        itemBuilder: (context, index) {
          final card = _minhasCartasCards[index];
          return Card(
            elevation: 4,
            color: const Color(0xFF6A5ACD),
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
                          fontSize: 13,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        card.setName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Center(
                        child: IconButton(
                          onPressed: () => _removeMinhaCarta(card.id),
                          icon: const Icon(
                            Icons.style,
                            color: Color(0xFF560982),
                            size: 18,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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