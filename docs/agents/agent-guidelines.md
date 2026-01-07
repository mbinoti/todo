# Guia Geral de Agentes

## Objetivo
Centralizar diretrizes comuns e reduzir repetição entre os arquivos de agentes. Use este documento como referência antes de criar ou atualizar instruções específicas.

## Estrutura Base Recomendada
Cada agente deve conter, no máximo, as seções abaixo:

1. **Perfil** – Persona e contexto de atuação (2–3 frases).  
2. **Objetivo** – Resultado principal esperado ao acionar o agente.  
3. **Responsabilidades Chave** – Lista curta (até 5 itens) com entregas ou verificações.  
4. **Limites/Restrições** – O que não fazer ou pré-condições relevantes.  
5. **Formato da Resposta** – Estrutura sugerida (seções, tópicos, idioma).  
6. **Ferramentas ou Referências** (opcional) – Links ou artefatos necessários.  

> Dica: se precisar de exemplos extensos, coloque-os em `docs/agents/examples/<agente>.md` e apenas referencie.

## Orientações Compartilhadas
- **Checklists**: reutilize `docs/process/dor-dod.md` sempre que falar de DoR/DoD.  
- **Cooperação**: mencione apenas interações realmente obrigatórias entre agentes. Use este documento como hub com a lista de relacionamentos ativos.  
- **State Management e DI**: toda implementação Flutter deve usar o pacote `provider` para injeção de dependências e gerenciamento de estado. Ao propor alternativas, deixe explícito o motivo e as implicações.
- **Navegação**: `go_router` é o padrão. Use RouterDelegate/Navigator 2 custom apenas com justificativa documentada (ex.: dependência externa) e alinhamento com o `CleanCodeArchitect`.
 
## State Management Guardrails
- Preferir `ChangeNotifier + Provider`.
- Granularidade:
  - Use `ValueNotifier + ValueListenableBuilder`.
  - Use `Selector` para ouvir apenas fatias necessárias.
- Expor `ValueNotifier` como `ValueListenable` (read-only).
- Usar `read` para ações, `watch`/`Consumer` para UI.
- Chamar `notifyListeners()` apenas para campos que não são `ValueNotifier`.
- Instanciar `ValueNotifier` dentro do `ChangeNotifier`; nunca na UI.
- `dispose()` deve limpar todos os `ValueNotifier`.

## Formato de Resposta Padrão
Sempre que fizer sentido (especialmente agentes técnicos), use a estrutura:

1. **Contexto/Diagnóstico**  
2. **Achados ou Recomendações** (ordenados por prioridade)  
3. **Ações/Snippets/Testes**  
4. **Checklist ou Próximos Passos**

Adapte conforme a natureza da resposta, mas evite múltiplos formatos concorrentes.

## Colaboração Entre Agentes
- `CleanCodeArchitect` define guardrails técnicos e arquiteturais.  
- `FlutterEspecialist` implementa conforme guardrails técnicos e insumos de UI/UX.  
- `UIDesigner` provê telas, tokens e orientações de acessibilidade.  
- `TestEngineer` garante a qualidade automatizada do que foi entregue.  
- `ProductOwner` define valor/escopo; `ScrumMaster` facilita o processo.  
- `FirebaseEspecialist` oferece integração backend serverless alinhada com arquitetura e segurança.

> Necessita adicionar outro relacionamento? Atualize esta lista e referencie nos agentes afetados.

## Idioma e Tom
Padrão geral: português, objetivo, tom colaborativo. Adapte apenas se o agente tiver público-alvo específico.

---

Para contribuições novas, copie o template acima e descreva apenas o que diferencia o agente. Links úteis, checklists completos e exemplos devem viver fora do arquivo principal sempre que possível.
