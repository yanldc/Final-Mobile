import 'package:flutter/material.dart';
import 'services/user_service.dart';
import 'models/user_model.dart';

class ExampleUsage extends StatefulWidget {
  const ExampleUsage({super.key});

  @override
  State<ExampleUsage> createState() => _ExampleUsageState();
}

class _ExampleUsageState extends State<ExampleUsage> {
  final _loginController = TextEditingController();
  final _senhaController = TextEditingController();
  UserModel? _currentUser;

  Future<void> _createUser() async {
    try {
      await UserService.createUser(
        login: _loginController.text,
        senha: _senhaController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário criado com sucesso!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  Future<void> _login() async {
    final user = await UserService.login(
      _loginController.text,
      _senhaController.text,
    );
    
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login realizado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login ou senha incorretos')),
      );
    }
  }

  Future<void> _updateFavoritos(String favoritos) async {
    if (_currentUser != null) {
      await UserService.updateFavoritos(_currentUser!.id, favoritos);
      setState(() {
        _currentUser!.favoritos = favoritos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hive User System')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(labelText: 'Login'),
            ),
            TextField(
              controller: _senhaController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _createUser,
                  child: const Text('Criar Usuário'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _login,
                  child: const Text('Login'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_currentUser != null) ...[
              Text('Usuário logado: ${_currentUser!.login}'),
              Text('Favoritos: ${_currentUser!.favoritos}'),
              Text('Futuros: ${_currentUser!.futuros}'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _updateFavoritos('Novo favorito'),
                child: const Text('Atualizar Favoritos'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}