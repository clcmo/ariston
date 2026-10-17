#!/usr/bin/env bash
# Cria labels e as issues iniciais do roadmap do Ariston.
# Requisitos: GitHub CLI (gh) autenticado.
#   Para adicionar ao Project: gh auth refresh -s project
# Uso: ./criar-issues.sh            (cria e adiciona ao Project "Ariston")
#      PROJECT="" ./criar-issues.sh (cria sem adicionar ao Project)
set -euo pipefail

REPO="${REPO:-clcmo/ariston}"
PROJECT="${PROJECT-Ariston}"

echo "==> Labels"
mk_label() { gh label create "$1" --color "$2" --description "$3" --repo "$REPO" --force >/dev/null; }
mk_label tarefa            0e8a16 "Entrega do roadmap"
mk_label bug               d73a4a "Algo não funciona"
mk_label area:arquitetura  5319e7 "MVVM, camadas e estrutura"
mk_label area:ui           1d76db "Telas e componentes"
mk_label area:ia           fbca04 "Integração com IA"
mk_label area:firebase     ff9800 "Firebase (projeto ariston-chat)"
mk_label area:ci-cd        0052cc "Pipelines, versão e deploy"
mk_label area:docs         c5def5 "Documentação"
mk_label prioridade:alta   b60205 "Fazer primeiro"
mk_label prioridade:media  fbca04 "Importante"
mk_label prioridade:baixa  c2e0c6 "Quando der"

mk_issue() {
  local title="$1" area="$2" prio="$3" body="$4"
  local args=(--repo "$REPO" --title "$title" --body "$body" --label "tarefa,area:$area,prioridade:$prio")
  [ -n "$PROJECT" ] && args+=(--project "$PROJECT")
  gh issue create "${args[@]}"
}

echo "==> Issues"

mk_issue "[Tarefa] Esqueleto MVVM (pastas e pubspec)" arquitetura alta "## Contexto
Base da refatoração híbrida do Ariston em Flutter com MVVM. Todo o resto depende dela.

## Critérios de aceite
- [ ] Estrutura em \`lib/\` separando \`ui/\` (views), \`viewmodels/\`, \`data/\` (repositories e services) e \`models/\`
- [ ] \`pubspec.yaml\` com as dependências básicas e gerência de estado escolhida
- [ ] App abre sem erros em web e mobile
- [ ] CI (analyze-test-build) verde"

mk_issue "[Tarefa] ChatViewModel + ChatRepository com AiService de mentira" arquitetura alta "## Contexto
Permite desenvolver e testar o chat antes de plugar a IA real.

## Critérios de aceite
- [ ] Interface \`AiService\` e uma implementação falsa (respostas fixas, com atraso simulado)
- [ ] \`ChatRepository\` depende da interface, não da implementação
- [ ] \`ChatViewModel\` expõe lista de mensagens e estados: ocioso, carregando, erro
- [ ] Troca da implementação falsa pela real sem mexer em ViewModel/UI"

mk_issue "[Tarefa] Tela de chat (lista, entrada e estados)" ui alta "## Contexto
Primeira interface usável do chatbot, ligada ao \`ChatViewModel\`.

## Critérios de aceite
- [ ] Lista de mensagens (usuário e assistente) com rolagem automática
- [ ] Campo de entrada com envio por botão e Enter (web)
- [ ] Indicador de carregamento e mensagem de erro com \"tentar de novo\"
- [ ] Layout responsivo (celular e web)"

mk_issue "[Tarefa] Testes de ViewModel e Repository" arquitetura media "## Contexto
O \`AiService\` falso torna a lógica testável sem rede.

## Critérios de aceite
- [ ] Testes de unidade do \`ChatViewModel\` (envio, carregando, erro)
- [ ] Testes do \`ChatRepository\`
- [ ] \`flutter test\` verde no CI"

mk_issue "[Tarefa] Integrar a IA real (AiService)" ia alta "## Contexto
Substituir o serviço falso por um provedor de IA de verdade.

## Critérios de aceite
- [ ] Provedor de IA definido (registrar a decisão nesta issue)
- [ ] Chave de API **fora do app**: usar um proxy (ex.: a pasta \`worker/\`) ou variável protegida, nunca commitada
- [ ] Implementação real de \`AiService\` com tratamento de erro, timeout e limite de taxa
- [ ] Respostas em streaming, se o provedor suportar (opcional)
- [ ] Testes do \`worker/\` atualizados (\`npm test --prefix worker\`)

## Notas técnicas
Depende do esqueleto MVVM e do \`ChatViewModel\`."

mk_issue "[Tarefa] Configurar Firebase (projeto ariston-chat) com FlutterFire" firebase media "## Contexto
O projeto \`ariston-chat\` já existe no console; falta ligar ao app.

## Critérios de aceite
- [ ] \`flutterfire configure\` executado para web, Android e iOS
- [ ] Decidir e registrar aqui para que o Firebase será usado (autenticação, histórico, ambos)
- [ ] Regras de segurança do banco restritivas (nada aberto ao público)
- [ ] Arquivos de configuração tratados conforme o \`.gitignore\` (sem segredos no repositório)"

mk_issue "[Tarefa] Persistir o histórico de conversas" firebase baixa "## Contexto
Manter as conversas entre sessões.

## Critérios de aceite
- [ ] Modelo de dados das conversas definido
- [ ] \`ChatRepository\` salva e carrega o histórico
- [ ] Estratégia de offline/erro definida
- [ ] Testes cobrindo salvar e carregar"

mk_issue "[Tarefa] Deploy da versão web no GitHub Pages" ci-cd alta "## Contexto
Quer testar o Ariston no navegador via Pages.

## Critérios de aceite
- [ ] Workflow de deploy rodando no \`main\` (não é check obrigatório de PR)
- [ ] \`flutter build web --release --base-href /ariston/\`
- [ ] Pages configurado para publicar via GitHub Actions
- [ ] URL do site no campo *About* do repositório"

mk_issue "[Tarefa] Workflow de versão (tag v* → release)" ci-cd media "## Contexto
Geração de versão automatizada, compatível com o ruleset de tags (\`refs/tags/v*\`).

## Critérios de aceite
- [ ] Workflow disparado por \`push\` de tag \`v*\`
- [ ] Cria a GitHub Release com notas geradas e anexa o build web
- [ ] Confirmar se a criação de tag funciona com o ruleset \`proteger-tags-de-versao\`
- [ ] Documentar o passo a passo de lançar versão no README"

mk_issue "[Tarefa] Aplicar rulesets e atualizar o dependabot.yml" ci-cd alta "## Contexto
Proteger o \`main\` e as tags de versão e manter dependências em dia.

## Critérios de aceite
- [ ] Ruleset \`proteger-main\` ativo com o check \`analyze-test-build\`
- [ ] Ruleset \`proteger-tags-de-versao\` ativo
- [ ] \`dependabot.yml\` com grupos, cooldown e a entrada npm para \`/worker\`
- [ ] Um PR de teste mesclado com sucesso sob as regras"

mk_issue "[Tarefa] Limpar o repositório (.gitignore)" ci-cd media "## Contexto
Pastas e arquivos gerados (\`.dart_tool\`, \`.idea\`, \`.flutter-plugins*\`) estão versionados.

## Critérios de aceite
- [ ] \`.gitignore\` atualizado
- [ ] Arquivos removidos do índice com \`git rm -r --cached\` (sem apagar localmente)
- [ ] CI continua verde"

mk_issue "[Tarefa] README e documentação de arquitetura" docs baixa "## Contexto
O README ainda é o texto padrão do \`flutter create\`.

## Critérios de aceite
- [ ] Descrição do Ariston, como rodar (web e mobile) e como contribuir
- [ ] Diagrama/explicação das camadas MVVM em \`docs/\`
- [ ] Seção sobre CI/CD, Pages e versões"

echo "Pronto."
