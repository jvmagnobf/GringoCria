# Feedback Classificado
Data: 2026-05-15
Total de feedbacks recebidos: 1 (pedido de navegação premium com 3 requisitos explícitos)
Itens gerados: 3

---

## Bugs (0 itens)

Nenhum bug identificado. O pedido descreve reorganização de navegação e descoberta de conteúdo premium já existente, não falha funcional no app atual.

---

## Feature Requests (1 item)

### FEAT-001: Adicionar aba `Premium` na TabBar autenticada

- **Componente/Tela**: `GringoCria/Views/AuthenticatedTabView.swift`; nova tela provável em `GringoCria/Views/Premium/PremiumView.swift` ou reaproveitamento parametrizado de `HomeView`.
- **O que o usuário quer**: Uma terceira aba na `TabView` autenticada, ao lado de `Scenarios` e `Profile`, dedicada exclusivamente às conversas premium.
- **Valor para o usuário**: Dá uma superfície própria para conteúdo premium e evita que conversas de AI Chat fiquem enterradas junto dos cenários scriptados gratuitos.
- **Estado atual observado**: `AuthenticatedTabView` contém apenas duas abas: `HomeView()` com label `"Home"` e `ProfileView()` com label `"Profile"`. O AI Chat premium existe, mas aparece como subscenario bloqueado dentro da Home.
- **Filtro esperado**: Mostrar somente subscenarios premium/conversas premium. No estado atual, o identificador técnico mais seguro é `Subscenario.isLocked == true && Subscenario.scriptName.isEmpty`, porque essa é a convenção documentada para cards de AI Chat. Para maior precisão, a tela também pode validar se `PersonaRepository.persona(for:)` retorna uma persona antes de exibir o item como conversa premium disponível.
- **Decisão fechada**: A implementação do AI Chat premium com Apple Foundation Models on-device não deve ser reavaliada nem substituída. Este item é só de navegação e apresentação.
- **Info faltante**:
  - Ícone da nova aba `Premium` na TabBar. Sugestão técnica coerente com o estado atual: `wand.and.sparkles` ou `sparkles`.
  - Se a aba Premium deve listar conversas premium "em breve" sem persona ou apenas conversas já disponíveis via `PersonaRepository`.
  - Se o título de navegação da nova tela deve ser exatamente `"Premium"` ou seguir algum padrão bilíngue do app.
- **Feedback original**: "Adicionar mais uma tela na TabBar, no mesmo estilo da tela inicial/Home, mas dedicada somente às conversas premium."

---

## Improvements (2 itens)

### IMP-001: Reaproveitar a estrutura visual/navegação da Home com filtro premium

- **Componente/Tela**: `GringoCria/Views/Home/HomeView.swift`; `GringoCria/ViewModels/HomeViewModel.swift`; possível extração de componentes privados `ScenarioSection` e `SubscenarioCard`.
- **Estado atual**: `HomeView` carrega todos os cenários de `scenarios.json` via `HomeViewModel`, renderiza seções por scenario, navega para `ScenarioView` em subscenarios gratuitos e abre `AIChatEntryView` em sheet para subscenarios bloqueados. `ScenarioSection` e `SubscenarioCard` são `private` dentro de `HomeView.swift`, então uma tela Premium separada não consegue reutilizá-los diretamente sem duplicar código ou extrair componentes.
- **Melhoria sugerida**: Criar uma estrutura reutilizável para listar cenários/subscenarios com configuração de filtro e título. A tela atual deve continuar exibindo os cenários normais; a nova tela Premium deve usar a mesma estrutura visual e o mesmo fluxo de sheet para `AIChatEntryView`, mas recebendo um filtro que mantém apenas conversas premium.
- **Critério de filtro sugerido**:
  - Premium AI disponível: `subscenario.isLocked == true && subscenario.scriptName.isEmpty && PersonaRepository().persona(for: subscenario) != nil`
  - Premium AI em desenvolvimento: `subscenario.isLocked == true && subscenario.scriptName.isEmpty && PersonaRepository().persona(for: subscenario) == nil`, se produto quiser mostrar "Coming Soon".
- **Causa provável da mudança**: A Home foi criada como superfície única para todos os subscenarios. Com AI Chat premium implementado, a arquitetura de UI precisa separar descoberta de cenários scriptados e descoberta de conversas premium sem duplicar renderização.
- **Info faltante**:
  - Se a Home/Scenarios deve continuar exibindo também os cards premium ou se os premium devem migrar exclusivamente para a aba Premium. O texto pede "somente" para a nova tela, mas não diz para remover da tela inicial.
  - Se a nova tela deve preservar agrupamento por `Scenario` ("Beach" contendo "AI Mate Chat") ou achatar a lista de conversas premium.
  - Estado vazio da tela Premium quando não houver conversas premium disponíveis.
- **Feedback original**: "Essa nova tela deve ser igual à tela inicial em estrutura visual/navegação, mudando o nome para Premium e filtrando para mostrar apenas os conteúdos premium/conversas premium."

---

### IMP-002: Renomear aba `Home` para `Scenarios`

- **Componente/Tela**: `GringoCria/Views/AuthenticatedTabView.swift`; possível ajuste futuro de nomes internos se o time quiser alinhar semântica.
- **Estado atual**: A primeira aba usa `Label("Home", systemImage: "house.fill")`, mas a tela renderiza uma lista de cenários e subcenários, não uma home genérica.
- **Melhoria sugerida**: Trocar apenas o texto visível da TabBar de `"Home"` para `"Scenarios"`. Não é necessário renomear `HomeView`, arquivo ou navigation title para cumprir o pedido; fazer isso agora seria refatoração extra sem necessidade.
- **Causa provável da mudança**: Com a chegada de uma aba `Premium`, o rótulo `Home` fica impreciso. `Scenarios` descreve melhor a função da primeira aba e reduz ambiguidade entre conteúdo comum e conteúdo premium.
- **Info faltante**:
  - Se o ícone deve continuar `house.fill` ou mudar para algo semanticamente mais próximo de cenários, como `list.bullet.rectangle` ou `map`.
  - Se o `navigationTitle("GringoCria")` dentro de `HomeView` deve permanecer como marca do app ou também mudar para `"Scenarios"`. O pedido só exige mudança na TabBar.
- **Feedback original**: "Trocar o nome na TabBar da tela inicial para Scenarios."

---

## Duplicatas

Nenhuma duplicata técnica identificada.

FEAT-001 e IMP-001 se sobrepõem na mesma iniciativa, mas não são duplicatas: FEAT-001 trata da nova superfície de navegação na `TabView`; IMP-001 trata da reutilização/filtro da lista de cenários para que a nova superfície não duplique `HomeView` de forma frágil.

IMP-002 é independente: pode ser implementado sozinho com uma alteração pequena em `AuthenticatedTabView`.

---

## Itens de Suporte (não geram tarefas de dev)

Nenhum.

---

## Ordem de implementação sugerida

1. **IMP-002 primeiro** — troca simples e isolada do label `"Home"` para `"Scenarios"` em `AuthenticatedTabView`.
2. **IMP-001 depois** — extrair ou parametrizar a estrutura de listagem da Home antes de criar a tela Premium. Duplicar `HomeView` inteira seria dívida técnica barata de criar e chata de manter.
3. **FEAT-001 por último** — adicionar a aba `Premium` na `TabView` apontando para a estrutura filtrada já pronta.
4. **QA obrigatório** — validar que a aba `Scenarios` continua abrindo `ScenarioView` para conteúdo gratuito, que a aba `Premium` só mostra conversas premium, que o sheet `AIChatEntryView` abre corretamente e que `Profile` continua preservado como terceira/última aba conforme decisão visual do time.
