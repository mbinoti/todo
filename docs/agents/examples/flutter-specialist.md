# FlutterEspecialist — Complementos

## Arquitetura MVVM + Repository
- **View (Widgets)**: apenas compõe UI, consome `ChangeNotifier` via Provider; não acessa serviços ou lógica de dados diretamente.
- **ViewModel (ChangeNotifier/Controller)**: mantém estado derivado, expõe ações assíncronas e encapsula orquestração; conversa somente com `UseCases`/`Repositories`, nunca com data sources concretas.
- **Repository**: interface no domínio que abstrai fontes (HTTP, cache, persistência). Converte DTO ↔ entidades e lida com falhas transformando em erros de domínio consumíveis pela ViewModel.
- **Data Sources**: camadas concretas (remote/local) injetadas no repository; podem usar Dio, SharedPreferences, Hive etc. Mantêm-se livres de regras de apresentação.
- **Fluxo esperado**: Widget → ViewModel → Repository → Data Source(s)

Documente nos PRs como cada nova tela e repositório respeitam esse fluxo e garanta testes unitários para ViewModel (mockando repository) e para repositories (mockando data sources/clients).

## Guardrails
- **Gerenciamento de Estado:** seguir o bloco “State Management Guardrails” em `docs/agents/agent-guidelines.md`.
- **Layout:** componentes nativos, validando a plataforma em tempo de execução e espelhando o mesmo fluxo em cada variante.
  - iOS → siga `Cupertino*` para manter o look & feel do sistema.
  - Android → siga Material You (M3) com `MaterialApp`.
- **Estilo/Docs:** seguir [Effective Dart](https://dart.dev/effective-dart/documentation) e o [Flutter style guide](https://docs.flutter.dev/development/tools/analysis#style-guide); use `flutter format` e mantenha exemplos `///` quando relevante.

## Checklist de Qualidade
- `flutter analyze` e `dart format` sem warnings antes de abrir PR.
- Testes unitários/widget cobrindo novas camadas; inclua golden tests para componentes visuais quando existirem tokens/estado distintos.
- Novas rotas e provedores registrados no bootstrap (`main.dart`/`app_router.dart`) com DI validada via testes.
- Documentação `///` para símbolos públicos e README/overview atualizado quando houver novas features.
- Validar todos os itens aplicáveis do DoR/DoD central (quando existir em `docs/process/dor-dod.md`) e registrar os comandos executados na descrição do PR.

## Tratamento de Erros (Briefing)
- Objetivo: padronizar o tratamento de erros para a UI reagir de forma previsível.
- Fluxo: repositórios/serviços convertem exceções em falhas; viewmodels expõem estados (`Initial`, `Loading`, `Success`, `Error`) via Provider.
- UI: widgets não fazem `try/catch`; apenas reagem ao estado com mensagens/telas adequadas.
- Testes: cobrir cenários de erro em viewmodels e widgets.
