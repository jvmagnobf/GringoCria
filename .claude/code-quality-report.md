# Relatório de Qualidade de Código — GringoCria
Data: 2026-05-23
Avaliador: swift-architect
Histórico: 3 rodadas de refatoração anteriores

---

## Notas por Aspecto

| Aspecto | Nota | Síntese |
|---|---|---|
| Qualidade de Código | **8.0 / 10** | Código limpo, comentado, sem gambiarra, com pequenas inconsistências pontuais |
| Estrutura do Projeto | **8.5 / 10** | Organização por camada bem executada; inconsistência menor de localização entre Components e Views/Feature/Components |
| Modularização | **7.5 / 10** | Boa coesão geral, mas dois acoplamentos estruturais remanescentes reduzem a nota |
| Onboarding de Novos Devs | **8.0 / 10** | Comentários arquiteturais no código são um diferencial raro; TODOs abertos e nomes híbridos PT/EN criam fricção |
| MVVM — Consistência | **8.5 / 10** | Modelo adotado corretamente na quase totalidade dos arquivos; dois padrões de inicialização de ViewModel divergem sem justificativa documentada |

### Nota Geral: **8.1 / 10**

---

## Pontos Fortes

### 1. Adoção completa e correta de @Observable + @MainActor
Todos os ViewModels e Services usam `@Observable @MainActor final class`. Nenhum `ObservableObject` residual. Acesso a propriedades reativas feito exclusivamente via `@Environment` ou `@State`. O padrão de iOS 17+ foi implementado sem mistura com padrões anteriores — isso é raro em projetos de time pequeno sob pressão de prazo.

### 2. Separação de camadas coerente
A divisão `Models / Services / ViewModels / Views / Components / Extensions` está respeitada. Cada arquivo tem responsabilidade única e facilmente identificável. Repositórios (`PersonaRepository`, `ScenarioRepository`) estão corretamente separados dos Services que guardam estado.

### 3. Concorrência feita com cuidado
O padrão `Task.detached(priority: .utility)` para I/O de bundle é consistente e justificado em comentário. `SpeechService` resolve o problema de `AVSpeechSynthesizerDelegate` (callbacks de thread arbitrária) via `nonisolated` + `Task { @MainActor in }`, que é a abordagem correta para Swift 6 strict concurrency.

### 4. Comentários arquiteturais no código-fonte
Comentários como o aviso de ownership do `HomeViewModel` em `AuthenticatedTabView`, a explicação de `UUID()` novo em `ScenarioViewModel.selectChoice`, e o alerta sobre o motivo do `nonisolated` em `SpeechService` são raros e extremamente úteis para quem pegar o projeto depois. A codebase tem mais autodocumentação do que a média de projetos acadêmicos.

### 5. Modelos de dados limpos
`Scenario`, `Subscenario`, `Persona`, `ChatMessage`, `ScriptStep` e `ChoiceOption` são structs puras, `Codable`/`Identifiable` onde necessário, sem lógica de negócio embutida. A extensão `preferredIntroPages` em `Subscenario` é um bom exemplo de lógica derivada colocada no lugar certo.

### 6. Reutilização de componentes visuais
`TypingIndicatorView`, `ChatVendorAvatarView`, `ChatUserAvatarView`, `ConversationHeaderImage`, `ProfilePhotoField`, `ChatBubble`, `MessageBubble`, `FeedbackBubble` e `ScorePill` estão todos extraídos e reutilizados. Não há duplicação relevante de UI.

### 7. Enum centralizado de constantes de persistência
`KeychainKey` e `UserDefaultsKey` como enums sem cases é o padrão correto — evita strings mágicas espalhadas pelo código e torna typos detectáveis em compile time.

---

## Pontos Fracos Restantes (por prioridade)

### CRÍTICO — 1. Semântica de `isLocked` não está formalizada no modelo

**Arquivos afetados:** `Models/Scenario.swift`, `Views/Home/HomeView.swift`, `Views/Home/ScenarioListView.swift`, `Views/AI/AIChatEntryView.swift`

A distinção entre "cenário de script bloqueado" e "cenário de chat AI premium" está espalhada em três views diferentes via a expressão `isLocked && scriptName.isEmpty`. Não existe propriedade computada, enum ou documentação formal dessa semântica no modelo.

```swift
// Em HomeView.navigationDestination:
if subscenario.isLocked && subscenario.scriptName.isEmpty {
    AIChatEntryView(subscenario: subscenario)
} else {
    ScenarioView(subscenario: subscenario)
}

// Em ScenarioListView.SubscenarioCard.statusIcon:
let isAIEnabled = subscenario.scriptName.isEmpty
Image(systemName: isAIEnabled ? "wand.and.sparkles" : "lock.fill")

// Em ScenarioListView.shouldOpenPremiumSheet:
subscenario.isLocked && subscenario.scriptName.isEmpty
```

**Risco:** adicionar um terceiro tipo de conteúdo locked (ex: "apenas para usuários Apple") quebra silenciosamente o fluxo sem erro de compilação. Um novo dev não tem como saber onde atualizar sem ler três arquivos.

---

### CRÍTICO — 2. ScenarioView inicializa ViewModel dentro de .task com AnyView como workaround

**Arquivo:** `Views/Scenario/ScenarioView.swift`, linhas 15, 69-76, 117

```swift
@State private var viewModel: ScenarioViewModel?

.task {
    if viewModel == nil {
        viewModel = ScenarioViewModel(progressService: progressService)
    }
}

private var conversationContent: some View {
    guard let viewModel else { return AnyView(EmptyView()) }
    return AnyView(...)
}
```

O uso de `AnyView` como workaround para o ViewModel optional apaga o tipo estático, impedindo que o SwiftUI otimize a árvore de views. O ViewModel é `nil` na primeira renderização, causando um frame de `EmptyView` antes do `.task` disparar. O padrão correto seria inicializar o ViewModel no `init` da View, recebendo o `ProgressService` via parâmetro (já que a View recebe `subscenario` como parâmetro):

```swift
// Solução mais limpa:
init(subscenario: Subscenario, progressService: ProgressService) {
    self.subscenario = subscenario
    _viewModel = State(initialValue: ScenarioViewModel(progressService: progressService))
    // ...
}
```

Isso eliminaria o optional e o `AnyView`. O mesmo problema existe em `ProfileView`.

---

### IMPORTANTE — 3. Dois padrões de inicialização de ViewModel sem critério documentado

Existem dois padrões coexistindo sem comentário explicativo:

**Padrão A — ViewModel direto no `@State`** (TipsView, AuthView, ProfileSetupView, AIChatEntryView):
```swift
@State private var viewModel = TipsViewModel()
```

**Padrão B — ViewModel Optional inicializado no `.task`** (ScenarioView, ProfileView):
```swift
@State private var viewModel: ScenarioViewModel?
// inicializado em .task porque depende de @Environment
```

Para um novo desenvolvedor, parece que são simplesmente duas formas de fazer a mesma coisa. O Padrão B existe porque o ViewModel precisa de dependências que chegam via `@Environment` — mas isso não está documentado no código.

---

### IMPORTANTE — 4. ChatStyling contém lógica de mapeamento hardcoded por scriptName

**Arquivo:** `Components/ChatStyling.swift`

```swift
static func vendorIconName(for subscenario: Subscenario) -> String? {
    if let icon = subscenario.vendorIcon { return icon }
    switch subscenario.scriptName {
    case "matte", "biscoito-globo": return "IconeMatte"
    // ...
    }
}
```

O campo `vendorIcon: String?` já existe em `Subscenario`. O switch por `scriptName` é um fallback para cenários cujo JSON não preencheu `vendorIcon`. Isso cria acoplamento implícito entre um utilitário de estilo e os nomes dos scripts de conteúdo — quando um novo script é adicionado, o desenvolvedor precisa saber que tem que atualizar também `ChatStyling.swift`.

O mesmo problema existe para `headerImageName`. Com 9 cenários hoje é gerenciável; com 20, o arquivo vira uma tabela de lookup de manutenção manual.

---

### IMPORTANTE — 5. loadUserPhoto() duplicado entre ScenarioViewModel e AIChatViewModel

**Arquivos:** `ViewModels/ScenarioViewModel.swift` linha 47, `ViewModels/AIChatViewModel.swift` linha 44

O código e as propriedades `userProfileImage: UIImage?` e `profileService: ProfileService` são duplicadas nos dois ViewModels. O comentário em `AIChatViewModel` justifica como "duplicação intencional para evitar acoplamento", o que é razoável, mas se a lógica de `ProfileService.loadProfilePhoto()` mudar (ex: resize automático), precisa ser atualizada em dois lugares.

---

### MELHORIA — 6. IntroOverlayView e OnboardingView duplicam estrutura de paginação

**Arquivos:** `Views/Scenario/IntroOverlayView.swift`, `Views/Onboarding/OnboardingView.swift`

Ambas implementam:
- `@State private var currentPage = 0`
- `ForEach(0..<pages.count, id: \.self)` para page dots com a mesma estética
- `.onTapGesture` para avançar ou completar com a mesma lógica

Os page dots e a lógica de avanço poderiam ser um `PageDotsView` e uma extensão reutilizável.

---

### MELHORIA — 7. Nomes de assets misturam PT, EN e convenções de capitalização

**Pasta:** `Assets.xcassets`

Três convenções coexistindo:
- PascalCase em PT: `BarracaFundo`, `CaipiFundo`, `MatteFundo`, `GarcomFundo`
- PascalCase em EN: `CristoPose`, `CristoPoseChat`, `CristoPoseInfo`
- snake_case em EN: `menu_background`
- lowercase misto: `telaWelcome`

Para um novo dev, não há como inferir a convenção correta para um novo asset sem olhar os existentes.

---

### MELHORIA — 8. TODOs abertos sem owner ou prazo

**Localizações:**
- `ScenarioViewModel.swift` linha 67: penalidade para escolhas incorretas
- `ProfileSetupViewModel.swift` linha 55: moderação de nickname
- `AuthViewModel.swift` linha 68: **migração de progresso guest → conta** (crítico para UX de lançamento)
- `SpeechService.swift` linha 10: controle de velocidade de fala

A migração `guest → conta` é particularmente relevante: um usuário que pratica como guest e depois faz Sign In with Apple perde todo o progresso.

---

### MELHORIA — 9. PremiumView duplica os estados de erro de HomeView

**Arquivos:** `Views/Premium/PremiumView.swift`, `Views/Home/HomeView.swift`

As duas views têm o mesmo bloco de estados (isLoading / isEmpty / loadError / lista) porque consomem o mesmo `HomeViewModel`. Poderia ser um `@ViewBuilder` compartilhado ou uma view de conteúdo genérica.

---

### MELHORIA — 10. "Click to continue" na SplashView usa terminologia de desktop

**Arquivo:** `Views/Navigation/SplashView.swift` linha 26

```swift
Text("Click to continue")
```

"Click" é terminologia de desktop. O correto para iOS é "Tap to continue".

---

## Recomendações para Handoff

### O que está pronto para entregar
- Toda a camada de Services está bem encapsulada e testável de forma isolada
- ViewModels expõem estado via `private(set)` de forma consistente
- Fluxo de autenticação (Apple + guest) está completo e robusto
- Chat scriptado (`ScenarioView` + `ScenarioViewModel`) está maduro, com suporte a ramificação por `nextStepId`, `vendorVariation` aleatório e `skipReveal`
- Chat com IA (`AIChatView` + `AIChatViewModel` + `AIPersonaService`) está funcional com feedback estruturado via `@Generable`
- StoreKit 2 implementado com verificação de entitlements

### O que um novo dev precisa entender antes de mexer

**Regra 1 — ProgressService é compartilhado, nunca instanciar localmente.**
Esta é a regra mais fácil de violar por acidente e a de maior impacto (progresso não refletido na UI sem erro de compilação).

**Regra 2 — HomeViewModel tem ownership em AuthenticatedTabView, não em GringoCriaApp.**
O comentário na view explica isso, mas é contraintuitivo. Mover para `GringoCriaApp` sem atualizar todos os consumidores causa crash em runtime.

**Regra 3 — `isLocked && scriptName.isEmpty` significa "chat AI premium".**
Esta semântica não está no modelo — está distribuída em três views. Qualquer novo tipo de conteúdo locked exige atualização em `HomeView`, `ScenarioListView` e `AIChatEntryView`.

**Regra 4 — Adicionar um novo cenário exige checklist de 5 passos:**
1. Criar o JSON do script em `Resources/scripts/`
2. Registrar em `scenarios.json`
3. Criar a `Persona` em `personas.json` (para chat AI)
4. Adicionar os assets de imagem no xcassets
5. Atualizar `ChatStyling.vendorIconName` e `ChatStyling.headerImageName` com o novo `scriptName`

Este checklist não está documentado em nenhum lugar no código-fonte.

**Regra 5 — AIPersonaService mantém sessões com estado; `reset()` é obrigatório ao sair.**
Isso acontece em `AIChatView.onDisappear`. Remover sem substituto causa vazamento de sessões de IA.

### Dívida técnica prioritária antes de escalar

1. **Formalizar a semântica de `isLocked`** — criar `var isAIPremium: Bool` em `Subscenario` e eliminar `isLocked && scriptName.isEmpty` das views.
2. **Adicionar `headerImage: String?` em `Subscenario`** — mover o switch de `ChatStyling.headerImageName` para o JSON.
3. **Resolver a migração guest → conta** (TODO em AuthViewModel) antes de lançamento público.
