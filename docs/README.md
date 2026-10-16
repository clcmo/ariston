# Ariston

Chatbot com IA em Flutter para Android, iOS e web, com arquitetura **MVVM**.

[![GitHub license](https://img.shields.io/github/license/clcmo/ariston?style=for-the-badge)](https://github.com/clcmo/ariston)
[![GitHub stars](https://img.shields.io/github/stars/clcmo/ariston?style=for-the-badge)](https://github.com/clcmo/ariston/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/clcmo/ariston?style=for-the-badge)](https://github.com/clcmo/ariston/network)
[![GitHub issues](https://img.shields.io/github/issues/clcmo/ariston?style=for-the-badge)](https://github.com/clcmo/ariston/issues)
[![GitHub donate](https://img.shields.io/github/sponsors/clcmo?color=pink&style=for-the-badge)](https://github.com/sponsors/clcmo)


[![CI](https://github.com/clcmo/ariston/actions/workflows/ci.yml/badge.svg)](https://github.com/clcmo/ariston/actions/workflows/ci.yml)
[![CD](https://github.com/clcmo/ariston/actions/workflows/cd.yml/badge.svg)](https://github.com/clcmo/ariston/actions/workflows/cd.yml)

**Demo web:** https://clcmo.github.io/ariston/

## Arquitetura

```
lib/
├── main.dart                 # injeção de dependências (Provider)
├── app/                      # MaterialApp e tema
├── config/                   # Hive, AppInfo (versão do build)
├── data/
│   ├── models/               # ChatMessage
│   ├── services/             # AiService, AuthService, ChatHistoryStore
│   └── repositories/         # ChatRepository
└── ui/
    ├── auth/                 # AuthViewModel, AuthGate, LoginView
    └── chat/                 # ChatViewModel, ChatView, widgets/
```

- **View**: só widgets; observa o ViewModel.
- **ViewModel** (`ChangeNotifier`): estado e comandos (`sendMessage`, `clearChat`, `login`...).
- **Repository/Services**: acesso a dados. `AiService` é uma interface — troque o provedor sem tocar na UI.

## Rodando

Configure o Firebase Web uma vez (se `lib/firebase_options.dart` ainda não
estiver configurado) e instale as dependências:

```bash
flutterfire configure --project=ariston-chat --platforms=web
flutter pub get
```

Para executar o app:

```bash
flutter run
```

Sem `ARISTON_AI_URL`, o app usa respostas simuladas (`FakeAiService`). Para
conversar com a IA do Cloudflare pelo Worker de produção:

```bash
flutter run \
  --dart-define=ARISTON_AI_URL=https://ariston-chat-api.ariston-app.workers.dev/chat
```

Esse modo requer que o usuário entre com uma conta Firebase válida. Para
experimentar a interface sem Firebase ou backend:

```bash
flutter run --dart-define=ARISTON_DEMO_MODE=true
```

O modo demo aceita qualquer email e senha não vazios e sempre usa respostas
simuladas. Ele é opt-in e não altera o build normal, que requer a configuração
gerada pelo `flutterfire configure`.

Para executar os testes:

```bash
flutter test
```

## Backend de IA

O app envia o histórico de mensagens ao endpoint `/chat` do **Cloudflare
Worker**. O Worker valida o ID token do Firebase e encaminha a conversa para
um modelo do Cloudflare Workers AI usando o binding `AI` configurado no Worker.
Não é necessária uma chave externa de provedor de IA no app.

O endpoint de produção é
`https://ariston-chat-api.ariston-app.workers.dev/chat`. O app envia o ID token
do Firebase no cabeçalho `Authorization: Bearer`. Para publicar o Worker ou
substituir a URL usada no deploy, siga
[CI/CD e configuração do backend](./CI-CD.md#configurar-o-backend-de-ia).

## Versões e deploy

Veja [CI/CD](./CI-CD.md). Resumo: use *Conventional Commits*
(`feat:`, `fix:`, `feat!:`); o CI abre um PR de release com a nova versão e o
changelog; ao mergeá-lo, a release é criada e o site é atualizado.

## Licença

MIT
