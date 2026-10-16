# CI/CD

## Workflows

| Arquivo | Quando roda | O que faz |
|---|---|---|
| `ci.yml` | Pull requests e pushes fora da `main` | `flutter analyze`, `flutter test`, `flutter build web` |
| `cd.yml` | Push na `main` | release-please, build web versionado, deploy no GitHub Pages, anexo na release |

## Como a versão é gerada

O projeto usa [release-please](https://github.com/googleapis/release-please)
e [Conventional Commits](https://www.conventionalcommits.org/pt-br/):

| Commit | Efeito (enquanto < 1.0.0) |
|---|---|
| `fix: corrige envio vazio` | patch (0.1.0 → 0.1.1) |
| `feat: histórico por usuário` | minor (0.1.0 → 0.2.0) |
| `feat!: novo contrato do proxy` | minor, com aviso de breaking change |
| `docs:`, `chore:`, `test:` | não geram versão |

1. Você faz merge de commits na `main`.
2. O release-please abre (ou atualiza) um PR **"chore(main): release x.y.z"**
   com o `CHANGELOG.md` e a `version:` do `pubspec.yaml` atualizados.
3. Ao mergear esse PR, ele cria a tag `vX.Y.Z` e a GitHub Release.
4. O mesmo `cd.yml` compila o web com `--dart-define=APP_VERSION=X.Y.Z`,
   publica no Pages e anexa `ariston-web-X.Y.Z.zip` à release.

Pushes na `main` sem release publicam no Pages com versão `X.Y.Z-dev+<sha>`.
A versão aparece na tela de login e na tela vazia do chat.

> A linha `version: ... # x-release-please-version` do `pubspec.yaml` não deve
> perder o comentário: é por ele que o release-please a encontra.

## Configuração única no GitHub

1. **Settings → Pages → Source:** GitHub Actions.
2. **Settings → Actions → General → Workflow permissions:** *Read and write*
   e marcar *Allow GitHub Actions to create and approve pull requests*.
3. **Settings → Secrets and variables → Actions → Variables:** criar
   `ARISTON_AI_URL` com a URL do proxy de IA (é uma variável, não um secret,
   porque o valor vai embutido no app). Sem ela, o site usa a IA simulada.
4. Firebase Console → Authentication → Settings → Authorized domains:
   adicionar `clcmo.github.io`.
5. *(Opcional)* Criar um PAT e salvá-lo como secret `RELEASE_PLEASE_TOKEN`:
   pushes feitos com o `GITHUB_TOKEN` não disparam outros workflows, então sem
   o PAT o `ci.yml` não roda no PR de release.

## Android/iOS

O deploy automático cobre só o web. A pasta `android/` ainda usa Gradle 7.1 e
Kotlin 1.6 (2021) e precisa ser regenerada (`flutter create --platforms=android,ios .`)
antes de entrar no pipeline.
