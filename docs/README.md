# Ariston

Chatbot com IA em Flutter (Android, iOS e web), arquitetura **MVVM**.

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

```bash
flutterfire configure          # gera lib/firebase_options.dart (uma vez)
flutter pub get
flutter run                    # IA simulada (FakeAiService)
flutter run --dart-define=ARISTON_DEMO_MODE=true  # interface sem Firebase
flutter run --dart-define=ARISTON_AI_URL=https://seu-proxy/chat   # IA real
flutter test
```

No modo demo, o Firebase é ignorado, qualquer email e senha não vazios entram
e a IA responde com mensagens simuladas. O modo é opt-in e não altera o build
normal, que continua exigindo a configuração gerada pelo `flutterfire configure`.

A chave da API de IA **nunca** vai no app: ela fica no proxy. Contrato esperado:

```
POST ARISTON_AI_URL
{"messages": [{"role": "user" | "assistant", "content": "..."}]}
→ {"reply": "texto"}
```

O ID token do Firebase segue em `Authorization: Bearer`.

## Versões e deploy

Veja [docs/CI-CD.md](docs/CI-CD.md). Resumo: use *Conventional Commits*
(`feat:`, `fix:`, `feat!:`); o CI abre um PR de release com a nova versão e o
changelog; ao mergeá-lo, a release é criada e o site é atualizado.

## Licença

MIT
