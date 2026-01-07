# Estrutura de Pastas (Enxuta)

Este documento descreve uma estrutura mínima para um app pequeno. A ideia é evitar camadas prematuras e criar pastas apenas quando surgirem responsabilidades novas.

```
lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme.dart
├── features/
│   └── tasks/
│       ├── models/
│       ├── repository/
│       ├── view_model/
│       ├── widgets/
│       └── pages/
├── shared/
│   ├── widgets/
│   └── utils/
└── main.dart

test/
├── app/
├── features/
│   └── tasks/
└── shared/
```

## lib/app
Bootstrap do aplicativo: tema, roteamento e widget raiz. Mantém configurações globais em um único lugar.

## lib/features
Código por funcionalidade. Cada feature agrupa modelos, repositórios, view models e UI, evitando espalhar arquivos pela raiz.

## lib/shared
Reuso transversal (widgets e utilitários) sem dependência de feature.

## main.dart
Ponto de entrada único. Para apps pequenos, um único entrypoint é suficiente.

## Quando expandir
Se o app crescer, considere acrescentar apenas o que fizer sentido:
- `data/` e `domain/` dentro de uma feature, quando houver integrações complexas.
- `main_development.dart` e `main_staging.dart` apenas se for usar flavors.
- `services/` em uma feature, quando o acesso a dados exigir separação explícita.
