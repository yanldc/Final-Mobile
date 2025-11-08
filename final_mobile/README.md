# Pokémon TCG Collection App

Um aplicativo Flutter para colecionadores de cartas Pokémon TCG que permite pesquisar, favoritar e gerenciar sua coleção de cartas.

## 📱 Funcionalidades

### 🔍 **Pesquisa de Cartas**
- **Pesquisa por Filtros**: Busque cartas por tipo (Fire, Water, etc.) e raridade (Common, Rare, etc.)
- **Pesquisa por Nome**: Digite o nome da carta para encontrar cartas específicas
- **Paginação**: Carregue mais cartas com o botão "Carregar Mais" (8 cartas por página)

### ❤️ **Sistema de Favoritos**
- Adicione cartas aos seus favoritos
- Visualize todas as cartas favoritadas em uma tela dedicada
- Cache local para acesso offline aos favoritos

### 🎴 **Minha Coleção**
- Marque cartas que você possui
- Gerencie sua coleção pessoal
- Visualização organizada das suas cartas

### 👤 **Gerenciamento de Conta**
- Sistema de login e cadastro
- Perfil do usuário com nome
- Configurações de tema (claro/escuro)
- Logout seguro

### 🎨 **Interface**
- Design moderno e intuitivo
- Tema claro e escuro
- Animações suaves
- Interface responsiva

## 🛠️ Tecnologias Utilizadas

- **Flutter** - Framework de desenvolvimento
- **Dart** - Linguagem de programação
- **Hive** - Banco de dados local
- **GetX** - Gerenciamento de estado
- **HTTP** - Requisições para API
- **Pokémon TCG API** - Fonte de dados das cartas

## 📋 Pré-requisitos

- **Android Studio** (OBRIGATÓRIO - o app foi otimizado especificamente para Android Studio)
- Flutter SDK (versão 3.8.1 ou superior)
- Dart SDK
- Emulador Android ou dispositivo físico Android

## 🚀 Como Iniciar

### 1. **Clone o Repositório**
```bash
git clone [URL_DO_REPOSITORIO]
cd Final-Mobile/final_mobile
```

### 2. **Instale as Dependências**
```bash
flutter pub get
```

### 3. **Execute o Build Runner** (para gerar arquivos Hive)
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 4. **Execute o Aplicativo**
```bash
flutter run
```

## ⚠️ Importante

**Este aplicativo foi desenvolvido e testado especificamente para Android Studio. Para funcionamento adequado, utilize:**

- **Android Studio** como IDE principal
- **Emulador Android** ou dispositivo Android físico
- **Não recomendado** para iOS ou Flutter Web devido a limitações da API

## 🔧 Configuração da API

O app utiliza a [Pokémon TCG API](https://pokemontcg.io/) com uma chave de API já configurada. A API possui:

- **Rate Limiting**: Limitações de requisições por minuto
- **Retry Automático**: 3 tentativas com delay progressivo
- **Cache Local**: Favoritos salvos localmente para acesso offline
- **Timeout Otimizado**: 8 segundos para melhor performance

## 📱 Como Usar

### **Primeiro Acesso**
1. Abra o aplicativo
2. Crie uma conta ou faça login
3. Escolha um tipo de pesquisa na tela inicial

### **Pesquisar Cartas**
1. **Por Filtros**: Clique em "Pesquisar por Tipo/Raridade" → Selecione filtros → Pesquisar
2. **Por Nome**: Clique em "Pesquisar por Nome" → Digite o nome → Pesquisar
3. Use "Carregar Mais" para ver mais resultados

### **Gerenciar Coleção**
1. **Favoritar**: Clique no ❤️ vermelho em qualquer carta
2. **Adicionar à Coleção**: Clique no 🎨 roxo em qualquer carta
3. **Visualizar**: Use as abas "Favoritos" e "Minhas Cartas"

### **Configurações**
1. Vá para a aba "Minha Conta"
2. Altere o tema (claro/escuro)
3. Faça logout quando necessário

## 🏗️ Estrutura do Projeto

```
lib/
├── controllers/          # Controladores (GetX)
├── models/              # Modelos de dados
├── screens/             # Telas do aplicativo
├── services/            # Serviços (API, Auth, User)
├── widgets/             # Widgets reutilizáveis
└── main.dart           # Ponto de entrada
```

## 🐛 Solução de Problemas

### **Erro de Conexão 504**
- O app possui retry automático
- Aguarde alguns segundos e tente novamente
- Verifique sua conexão com a internet

### **Cartas não Carregam**
- Verifique se está usando Android Studio
- Reinicie o aplicativo
- Limpe o cache: `flutter clean && flutter pub get`

### **Problemas de Build**
```bash
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter run
```

## 📄 Licença

Este projeto é para fins educacionais e utiliza a API pública do Pokémon TCG.

## 🤝 Contribuição

Para contribuir com o projeto:
1. Fork o repositório
2. Crie uma branch para sua feature
3. Commit suas mudanças
4. Abra um Pull Request

---

**Desenvolvido com ❤️ usando Flutter**