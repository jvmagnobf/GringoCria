# Comandos de Desenvolvimento
Data: 2026-05-15
Baseado em: .claude/classified-feedback.md
Total de comandos: 3

---

> Ordem de execução recomendada por dependência:
> IMP-002 -> IMP-001 -> FEAT-001.
>
> Justificativa: a troca do label `Home` para `Scenarios` é isolada e reduz ambiguidade antes da nova aba. Depois, a estrutura visual da `HomeView` deve ser extraída ou parametrizada para evitar duplicação. Por fim, a aba `Premium` entra na `AuthenticatedTabView` apontando para a composição reutilizável já filtrada.

---

## Bugs

Nenhum bug classificado em `.claude/classified-feedback.md`.

---

## Features

### FEAT-001: Implemente a aba Premium na TabView autenticada existente
**Ref**: Feedback original #1

**Contexto**:
O app GringoCria já possui uma `TabView` autenticada em `GringoCria/Views/AuthenticatedTabView.swift`, atualmente com as abas `Home` e `Profile`. O AI Chat premium já existe, usa Apple Foundation Models on-device e é aberto por `AIChatEntryView` quando um `Subscenario` bloqueado tem `scriptName` vazio. O pedido é adicionar uma nova superfície de navegação para conversas premium sem trocar provider, backend ou arquitetura de IA.

**Comportamento atual**:
`AuthenticatedTabView` renderiza apenas duas abas. A primeira aba exibe `HomeView()` com label `"Home"` e a segunda exibe `ProfileView()` com label `"Profile"`. Conversas premium aparecem misturadas na Home como subscenarios bloqueados, e não existe uma aba dedicada para descobri-las.

**Comportamento esperado**:
`AuthenticatedTabView` deve renderizar três abas autenticadas: `Scenarios`, `Premium` e `Profile`. A aba `Premium` deve abrir uma tela dedicada a conteúdos premium/conversas premium e deve usar o mesmo fluxo existente de abertura de `AIChatEntryView` em sheet. A aba deve viver dentro da `TabView` autenticada existente, não em rota paralela, sheet global ou nova arquitetura de navegação.

**Passos para reproduzir**:
1. Inicie o app em estado autenticado.
2. Observe a `TabView` principal.
3. Confirme que existem apenas as abas `Home` e `Profile`.
4. Abra a lista da Home e observe que o card premium `AI Mate Chat` aparece misturado aos cenários comuns.

**Ação**:
Crie `GringoCria/Views/Premium/PremiumView.swift` como wrapper da composição compartilhada criada em IMP-001. Adicione `PremiumView()` como uma nova aba em `AuthenticatedTabView`, entre `Scenarios` e `Profile`, encapsulada em `NavigationStack` como as demais abas. Use label visível `"Premium"` e SF Symbol `wand.and.sparkles`. A tela deve listar somente subscenarios premium e abrir `AIChatEntryView(subscenario:)` em sheet ao tocar em uma conversa premium.

**Restrições**:
- Não substitua Apple Foundation Models por outro provider de IA.
- Não crie backend, endpoint remoto, proxy, serviço externo ou nova arquitetura de IA.
- Não altere `AIChatView`, `AIChatEntryView`, `AIPersonaService`, `AIAvailabilityService` ou `PersonaRepository`, exceto se for estritamente necessário para consumir a composição reutilizável sem mudar comportamento.
- Não crie uma segunda `TabView`; use a `AuthenticatedTabView` existente.
- Não mova a aba `Profile` para fora da navegação autenticada.
- Não implemente paywall, compra, assinatura, login premium ou mudanças em `PremiumService` nesta tarefa.
- Não duplique a `HomeView` inteira para criar a aba Premium; dependa da estrutura extraída ou parametrizada em IMP-001.

**Critério de aceite**:
- [ ] Usuário autenticado vê três abas na TabBar: `Scenarios`, `Premium` e `Profile`, nessa ordem.
- [ ] A aba `Premium` está dentro de `AuthenticatedTabView` e usa `NavigationStack`.
- [ ] A aba `Premium` exibe apenas subscenarios com `isLocked == true` e `scriptName.isEmpty`.
- [ ] Tocar em uma conversa premium abre `AIChatEntryView(subscenario:)` em sheet.
- [ ] Conversa premium com persona cadastrada em `PersonaRepository` abre o fluxo existente de `AIChatView`.
- [ ] Conversa premium sem persona cadastrada continua exibindo o estado existente de `Coming Soon` de `AIChatEntryView`.
- [ ] A aba `Profile` continua acessível após a inclusão da aba `Premium`.
- [ ] O app compila sem warnings novos de disponibilidade relacionados a `@available(iOS 26, *)`.

**Ambiente**: iOS 26+/SwiftUI. Dispositivo e versão exata do simulador não informados, investigar.

---

## Improvements

### IMP-001: Refatore a composição da Home para reutilizar a listagem com filtro premium
**Ref**: Feedback original #1

**Contexto**:
`GringoCria/Views/Home/HomeView.swift` carrega cenários via `HomeViewModel`, renderiza seções por `Scenario`, cards por `Subscenario`, navega para `ScenarioView` nos conteúdos gratuitos e abre `AIChatEntryView` em sheet nos subscenarios bloqueados. Hoje `ScenarioSection` e `SubscenarioCard` são `private` dentro de `HomeView.swift`, então uma `PremiumView` separada teria que duplicar a composição visual ou forçar acoplamento indevido. A nova aba Premium deve espelhar a estrutura/composição da Home, mas filtrar apenas conteúdos premium/conversas premium.

**Comportamento atual**:
`HomeView` renderiza todos os `viewModel.scenarios` sem filtro. Subscenarios gratuitos usam `NavigationLink` para `ScenarioView`; subscenarios bloqueados usam `Button` e abrem `AIChatEntryView` em sheet. Como os componentes são privados no mesmo arquivo, outra tela não consegue reutilizar a mesma estrutura visual de forma limpa.

**Comportamento esperado**:
A listagem de cenários/subscenarios deve ser reutilizável por `HomeView` e pela nova superfície Premium. A tela de cenários deve manter o comportamento atual para conteúdos comuns, enquanto a tela Premium deve usar a mesma composição visual e navegação de sheet para exibir somente subscenarios premium.

**Passos para reproduzir**:
1. Abra `GringoCria/Views/Home/HomeView.swift`.
2. Observe que `ScenarioSection` e `SubscenarioCard` estão declarados como `private`.
3. Observe que `HomeView` percorre todos os cenários de `HomeViewModel` sem filtro.
4. Tente criar uma tela Premium com o mesmo visual sem duplicar código e observe que os componentes não estão disponíveis fora do arquivo.

**Ação**:
Crie um componente reutilizável `ScenarioListView` em `GringoCria/Views/Home/ScenarioListView.swift` para concentrar a composição visual hoje privada em `HomeView.swift`. O componente deve receber a lista de `Scenario`, um modo de exibição (`scenarios` ou `premium`) e closures para abrir `ScenarioView` ou `AIChatEntryView` conforme o tipo de item. Mantenha o layout visual existente: `ScrollView`, `LazyVStack`, seções com ícone/títulos e cards com título, subtítulo e ícones de status. No modo `premium`, aplique o filtro `subscenario.isLocked == true && subscenario.scriptName.isEmpty` e remova seções que ficarem sem subscenarios. Preserve o uso de `AIChatEntryView` em sheet para subscenarios premium. Defina um estado vazio explícito para a tela Premium quando nenhum conteúdo premium existir.

**Restrições**:
- Não altere o schema de `Scenario`, `Subscenario` ou `scenarios.json`.
- Não altere `scriptName`, IDs, progresso salvo, recursos do bundle ou scripts existentes.
- Não mude a regra técnica de identificação de conversa premium: `isLocked == true && scriptName.isEmpty`.
- Não transforme cards gratuitos em AI Chat.
- Não faça a tela Premium navegar para `ScenarioView`; conteúdo premium deve abrir `AIChatEntryView`.
- Não remova o suporte a subscenario bloqueado sem persona; `AIChatEntryView` já trata esse caso com `Coming Soon`.
- Não introduza infraestrutura de arquitetura maior, coordinator novo ou estado global novo para resolver apenas reutilização visual.
- Não mude textos pedagógicos, scripts ou provider de IA.

**Critério de aceite**:
- [ ] `HomeView` continua carregando cenários por `HomeViewModel` e exibindo conteúdos comuns sem regressão visual perceptível.
- [ ] A composição compartilhada é usada por `HomeView` e pela tela Premium, sem duplicar integralmente `ScenarioSection` e `SubscenarioCard`.
- [ ] O filtro premium mantém somente subscenarios com `isLocked == true` e `scriptName.isEmpty`.
- [ ] Seções sem subscenarios após o filtro premium não aparecem na tela Premium.
- [ ] Cards premium continuam exibindo o ícone de AI premium (`wand.and.sparkles` ou equivalente já escolhido).
- [ ] Tocar em card premium abre `AIChatEntryView(subscenario:)` em sheet.
- [ ] Tocar em card gratuito na aba de cenários continua navegando para `ScenarioView(subscenario:)`.
- [ ] A tela Premium exibe um estado vazio claro quando o filtro não retorna nenhum subscenario.
- [ ] O projeto compila sem duplicação de tipos com o mesmo nome em arquivos diferentes.

**Ambiente**: iOS 26+/SwiftUI. Dispositivo e versão exata do simulador não informados, investigar.

---

### IMP-002: Renomeie a aba Home para Scenarios na TabBar
**Ref**: Feedback original #1

**Contexto**:
`AuthenticatedTabView` usa `Label("Home", systemImage: "house.fill")` para a primeira aba, mas essa tela lista cenários e subcenários de prática. Com a criação de uma aba `Premium`, o rótulo `Home` fica impreciso e conflita com a separação entre cenários comuns e conversas premium.

**Comportamento atual**:
A primeira aba da `TabView` autenticada aparece como `"Home"` na TabBar, embora renderize `HomeView` com a listagem de cenários.

**Comportamento esperado**:
A primeira aba deve aparecer como `"Scenarios"` na TabBar. A mudança obrigatória é apenas no texto visível da TabBar; nomes internos como `HomeView` e o título de navegação `"GringoCria"` devem permanecer inalterados, salvo se outro comando exigir refatoração posterior.

**Passos para reproduzir**:
1. Abra o app em estado autenticado.
2. Observe a primeira aba da TabBar.
3. Confirme que o label visível é `"Home"`.

**Ação**:
Edite `GringoCria/Views/AuthenticatedTabView.swift` e troque o label visível da primeira aba de `"Home"` para `"Scenarios"`. Mantenha `HomeView()` como conteúdo da aba. Mantenha o `NavigationStack` existente. Mantenha o ícone atual `house.fill` neste comando; qualquer troca de ícone fica fora do escopo.

**Restrições**:
- Não renomeie `HomeView`, `HomeView.swift`, `HomeViewModel` ou diretórios nesta tarefa.
- Não altere `.navigationTitle("GringoCria")` em `HomeView`.
- Não mude a navegação para `ScenarioView`.
- Não altere a aba `Profile`.
- Não implemente a aba `Premium` dentro deste comando; isso pertence a FEAT-001.
- Não altere provider, backend ou arquitetura de IA.

**Critério de aceite**:
- [ ] A primeira aba da TabBar exibe exatamente o texto `Scenarios`.
- [ ] `HomeView()` continua sendo o conteúdo da primeira aba.
- [ ] A primeira aba continua dentro de `NavigationStack`.
- [ ] A navegação de `HomeView` para `ScenarioView` continua funcionando.
- [ ] A aba `Profile` continua exibindo label `Profile`.
- [ ] O projeto compila sem renomeações quebradas.

**Ambiente**: iOS 26+/SwiftUI. Dispositivo e versão exata do simulador não informados, investigar.
