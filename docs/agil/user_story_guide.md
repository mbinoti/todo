# Guia Prático de User Stories (baseado em *User Stories Applied*, Mike Cohn)

## O que é uma User Story?
Uma user story descreve uma funcionalidade **valiosa para o usuário** ou comprador.  
Cada story tem três aspectos (os 3Cs):
- **Card**: descrição curta para planejamento.
- **Conversation**: detalhes discutidos entre PO e time.
- **Confirmation**: critérios de aceitação/testes.

---

## Checklist INVEST
| Letra | Significado | O que significa na prática |
|-------|-------------|----------------------------|
| I | Independent | Evite dependências entre histórias. |
| N | Negotiable | Deve ser discutida e refinada, não contrato fixo. |
| V | Valuable | Precisa entregar valor para o usuário, não apenas técnico. |
| E | Estimatable | O time precisa ser capaz de estimar o esforço. |
| S | Small | Deve caber em até uma iteração (meio dia a 2 semanas). |
| T | Testable | Deve ser possível validar com critérios claros. |

---

## Estrutura de uma User Story
```
Como [papel]
Quero [funcionalidade]
Para [benefício]
```

### Exemplos (App Grocery – Cliente)
- **Story**: Como cliente, quero buscar produtos por nome e categoria para encontrar rapidamente o que desejo.  
  **Aceitação**: resultados filtrados corretamente, retorno vazio mostra mensagem clara, paginação de 20 itens, busca insensível a acentos.

- **Story**: Como cliente, quero pagar com cartão de crédito para finalizar minha compra.  
  **Aceitação**: aprova Visa/Master/Amex, rejeita cartões expirados, infere bandeira pelo número.

### Exemplo (App Grocery – Admin)
- **Story**: Como administrador, quero cadastrar novas categorias para organizar os produtos na loja.  
  **Aceitação**: salvar nome, slug, ícone; definir ordem de exibição; campo obrigatório `isActive`.

---

## Testes de Aceitação
- Escritos **antes do código**, para capturar expectativas.  
- Definidos pelo **PO/cliente**, mas implementados com apoio de dev/tester.  
- Devem incluir casos de sucesso e falha.  

Exemplo:  
> Dado que um cliente adiciona mais itens do que o limite do cartão,  
> Então o checkout deve rejeitar a transação e exibir mensagem clara.

---

## Planejamento Ágil
### Release Planning
- Decidir **quando** lançar, **o que** entra, priorizar por valor.  
- Transformar **story points em datas** usando a velocidade média.  

### Iteration Planning
- Selecionar histórias de maior prioridade.  
- Quebrar em tarefas técnicas menores.  
- Confirmar o **compromisso** da equipe.

---

## Smells (Maus Cheiros) de Histórias
- **Muito pequenas**: geram sobrecarga de estimativa → combine para planejar, divida só na iteração.  
- **Muito grandes (épicos)**: quebre em histórias menores e independentes.  
- **Interdependentes**: prefira “fatia de bolo” (atravessa UI, lógica e DB) em vez de dividir por camada.  
- **Goldplating**: dev adicionando features não pedidas.  

---

## Restrições (Constraints / Não-funcionais)
- Devem ser documentadas como **restrições**, não como histórias.  
- Exemplo: “Checkout deve operar com 99,95% de disponibilidade mensal.”  
- Sempre com **testes automatizados** para validar.

---

## Personas e Papéis
- Descobrir histórias a partir de **papéis de usuário**.  
- Criar **personas** ajuda a visualizar motivações e necessidades.  

Exemplo (App Grocery):  
- **Cliente** (Joana, mãe de família que busca praticidade).  
- **Administrador** (Carlos, gerente de loja que cadastra produtos).  

---

## Como usar no projeto
- Guardar este arquivo em `/docs/user_stories.md`.  
- Usar como **checklist** sempre que escrever novas histórias.  
- Complementar no `agents.md` para guiar a IA com exemplos prontos.

---

## Referência
Baseado em: *User Stories Applied – For Agile Software Development* (Mike Cohn).
