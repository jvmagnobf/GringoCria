# GringoCria — Documento de Handoff

> App iOS para estudantes de intercâmbio praticarem português em cenários reais do Rio de Janeiro.
> Projeto do Challenge 2 da Apple Developer Academy.

---

## Como começar

### Requisitos

- **Xcode 26 beta** (ou versão que suporte iOS 26 SDK e FoundationModels)
- **iOS 26+** — o app usa `@available(iOS 26, *)` em todo o código
- **iPhone 15 Pro ou superior** com **Apple Intelligence habilitado** para testar o chat AI
- Conta Apple Developer para Sign in with Apple funcionar no simulador (exige entitlement)

### Passos para rodar

1. Clone o repositório ou copie a pasta do projeto
2. Abra `GringoCria.xcodeproj` no Xcode
3. Selecione um simulador iOS 26 (ou dispositivo físico)
4. `Cmd + R` para rodar

### O que esperar no primeiro boot

O app começa pela `SplashView` com uma imagem de fundo (`TELA1GRINGOCRIA`) e o texto "Click to continue". Ao tocar, o `AppRouter` verifica o estado de autenticação via `SessionService` (Keychain). Como é o primeiro acesso, redireciona para `AuthView` (Sign in com Apple), depois para `ProfileSetupView`, e finalmente para o `AuthenticatedTabView` com três abas.

---

## Contexto do projeto

O GringoCria coloca o usuário em situações reais do Rio de Janeiro — comprar matte na praia de Ipanema, pedir biscoito globo, etc. Cada cenário tem duas modalidades:

- **Script guiado**: conversa roteirizada com branching, onde o usuário escolhe entre opções de fala em português carioca. Sem IA, funciona em qualquer dispositivo.
- **Chat AI livre**: conversa aberta com um personagem carioca gerado pelo modelo on-device da Apple (FoundationModels). Recebe feedback estruturado sobre gramática e naturalidade. Requer Apple Intelligence habilitado.

---

## Estrutura de arquivos

```
GringoCria/
├── GringoCriaApp.swift              # Entry point — injeta 6 services via .environment()
├── Models/
│   ├── AppState.swift               # AuthState enum + @Observable AppState
│   ├── Scenario.swift               # Scenario + Subscenario (Codable)
│   ├── ScriptStep.swift             # ScriptStep + ChoiceOption + Speaker + StepType enums
│   ├── Persona.swift                # Persona para AI chat (id, subscenarioId, systemPrompt, openingLine)
│   └── MessageFeedback.swift        # @Generable struct para feedback de português (FoundationModels)
├── Services/
│   ├── SessionService.swift         # Keychain-based auth, resolveAuthState()
│   ├── KeychainService.swift        # Wrapper Keychain
│   ├── ProfileService.swift         # Salva/carrega perfil do usuário
│   ├── ProfileImageStore.swift      # Armazena foto de perfil
│   ├── ProgressService.swift        # Marca subscenários como completados (UserDefaults)
│   ├── SpeechService.swift          # AVSpeechSynthesizer — lê mensagens em voz alta
│   ├── AIAvailabilityService.swift  # Verifica elegibilidade do device para FoundationModels
│   ├── AIPersonaService.swift       # Gerencia LanguageModelSessions (persona + avaliador)
│   ├── PremiumService.swift         # StoreKit 2 — IAP não-consumível $1
│   └── PersonaRepository.swift      # Carrega personas.json, lookup por subscenarioId
├── ViewModels/
│   ├── AuthViewModel.swift
│   ├── ProfileSetupViewModel.swift
│   ├── ProfileViewModel.swift
│   ├── HomeViewModel.swift          # Carrega scenarios.json
│   ├── ScenarioViewModel.swift      # Motor do script: stepMap, currentStepId, branching
│   └── AIChatViewModel.swift        # Estado do chat AI: mensagens, isTyping, feedback
├── Views/
│   ├── SplashView.swift             # Tela inicial com imagem TELA1GRINGOCRIA
│   ├── AppRouter.swift              # showingSplash → switch authState
│   ├── AuthenticatedTabView.swift   # TabView: Scenarios / Premium / Profile
│   ├── Auth/AuthView.swift          # Sign in com Apple
│   ├── Home/
│   │   ├── HomeView.swift           # Lista de cenários desbloqueados
│   │   └── ScenarioListView.swift   # Componente com DisplayMode (.scenarios / .premium)
│   ├── Premium/PremiumView.swift    # Lista de cenários AI (isLocked: true)
│   ├── Profile/
│   │   ├── ProfileSetupView.swift
│   │   └── ProfileView.swift
│   ├── Scenario/ScenarioView.swift  # Chat de script com MessageBubble, TypingIndicator, choices
│   └── AI/
│       ├── AIChatEntryView.swift    # Roteador: persona existe? → AIChatView : "Coming Soon"
│       ├── AIChatView.swift         # Chat livre com IA + FeedbackBubble
│       ├── FeedbackBubble.swift     # Card colapsável com scores, correção, alternativas
│       └── PremiumGateView.swift    # Paywall (ainda não ativado)
├── Resources/
│   ├── scenarios.json               # Dados dos cenários e subscenários
│   ├── personas.json                # Personas AI (ex: "Seu Zé" o mateiro de Ipanema)
│   └── scripts/
│       └── matte.json               # Script completo do cenário do mate com branching
└── Components/
    ├── CameraPickerView.swift
    └── ProfilePhotoField.swift
```

---

## Fluxo de navegação

```
App abre
  └── SplashView
        └── toque → AppRouter verifica authState (Keychain)
              ├── unauthenticated → AuthView (Sign in com Apple)
              ├── firstAccess     → ProfileSetupView
              └── authenticated   → AuthenticatedTabView
                    ├── Tab "Scenarios" → HomeView → ScenarioView (chat com script)
                    ├── Tab "Premium"   → PremiumView → AIChatEntryView → AIChatView
                    └── Tab "Profile"   → ProfileView
```

---

## Arquitetura

### Padrão geral

MVVM com `@Observable` (Swift 5.9+). Todos os services e ViewModels usam `@Observable @MainActor final class`. Nenhum `@StateObject` ou `@ObservableObject` no projeto — usa exclusivamente o novo modelo de observação.

### Injeção de dependências

Os 6 services são instanciados no `GringoCriaApp.swift` e injetados via `.environment()`:

```swift
AppRouter()
    .environment(appState)
    .environment(speechService)
    .environment(progressService)
    .environment(aiAvailabilityService)
    .environment(aiPersonaService)
    .environment(premiumService)
```

Nas Views, são consumidos com `@Environment(NomeDoService.self) private var nomeDoService`.

### Navegação

`NavigationStack` + `NavigationLink(value:)` + `navigationDestination(for:)`. O `HomeView` usa `navigationDestination(for: Subscenario.self)` para abrir o `ScenarioView` correto com base no subscenário selecionado.

### Requisito de versão

Todo o código usa `@available(iOS 26, *)`. O deployment target é iOS 26. Não tente baixar isso — o `FoundationModels` framework não existe em versões anteriores.

---

## Como os dados são estruturados

### scenarios.json

Array de `Scenario`, cada um com array de `Subscenario`. O campo `isLocked` e `scriptName` determinam onde o subscenário aparece:

| isLocked | scriptName | Onde aparece |
|----------|------------|--------------|
| false    | "matte"    | Aba Scenarios (chat com script) |
| true     | ""         | Aba Premium (chat AI livre) |

Subscenário com `isLocked: true` e `scriptName` preenchido seria um cenário de script pago — não existe ainda no projeto.

### personas.json

Array de `Persona`, linkado ao subscenário via `subscenarioId`. O `PersonaRepository` faz o lookup por esse ID. Se não existir persona para um subscenário Premium, o `AIChatEntryView` exibe a tela "Coming Soon" em vez do chat.

**Persona atual:** "Seu Zé" — mateiro de Ipanema, vinculado ao subscenário "Matte com IA".

### matte.json (script)

Array de `ScriptStep` com 11 steps: 9 lineares + 2 condicionais (6a, 6b). O motor de branching usa `nextStepId` nas `ChoiceOption` para pular steps. Steps sem `nextStepId` avançam linearmente.

Tipos de step:
- `message` — balão de fala simples (vendedor ou cliente)
- `choice` — usuário escolhe entre opções; cada opção pode ter `nextStepId` próprio
- `vendorVariation` — sorteia aleatoriamente uma string de `vendorVariations[]`; string vazia = silêncio do vendedor, sem balão
- `auto` — ação automática do cliente (ex: `*Paga o matte*`), avança sozinho após delay

---

## Motor de script (ScenarioViewModel)

O `ScenarioViewModel` é o coração do chat roteirizado. Pontos importantes:

### Como o branching funciona

- `stepMap: [UUID: ScriptStep]` — todos os steps indexados para lookup O(1)
- `currentStepId: UUID?` — posição atual no script
- `revealedSteps: [ScriptStep]` — steps já exibidos no chat (usado pelo ForEach da View)

Quando o usuário seleciona uma `ChoiceOption`, o ViewModel:
1. Cria um `ScriptStep` efêmero com UUID novo (para evitar conflito de IDs no ForEach) e adiciona em `revealedSteps`
2. Avança `currentStepId` para `choice.nextStepId` se existir, senão avança linearmente
3. Chama `revealNextVendorMessage()` para processar os próximos steps automáticos

### Por que UUID novo nos steps de choice

O ForEach exige IDs únicos. Reutilizar o `step.id` original causaria crash com "Fatal error: Duplicate ID" em debug. Esse é um detalhe importante se você for mexer na lógica de revelação. Nao "otimize" isso.

### Delay entre mensagens

Cada step automático (vendor, auto, vendorVariation) tem `Task.sleep(for: .seconds(1.2))` para simular o vendedor digitando. O `isTyping: Bool` controla o `TypingIndicator` na View.

---

## Feature AI (FoundationModels)

### Requisitos de hardware

- iPhone 15 Pro ou superior
- Apple Intelligence habilitado nas configurações do dispositivo
- iOS 26+

O `AIAvailabilityService` verifica isso antes de tentar usar o modelo.

### Duas sessões separadas

O `AIPersonaService` mantém duas `LanguageModelSession` independentes:

- **`personaSession`** — inicializada com o `systemPrompt` da `Persona`. Mantém o vendedor em personagem, responde em PT-BR mesmo que o usuário escreva em inglês.
- **`evaluatorSession`** — inicializada com prompt fixo de coach de português. Avalia a mensagem do usuário e retorna `MessageFeedback` via geração estruturada (`@Generable`).

As duas sessões rodam em paralelo com `async let`:

```swift
async let replyTask    = aiPersonaService.sendMessage(trimmed, persona: persona)
async let feedbackTask = aiPersonaService.evaluateMessage(trimmed, vendorReply: "", persona: persona)
```

### Acesso ao response do FoundationModels

**Sempre usar `.content`**, nunca `.output`. Isso se aplica tanto para respostas de texto quanto para geração estruturada:

```swift
let response = try await session.respond(to: text)
return response.content  // correto

let response = try await session.respond(to: prompt, generating: MessageFeedback.self)
return response.content  // correto
```

### Recuperação de contexto excedido

Quando a `LanguageModelSession` estoura o limite de contexto, ela lança `LanguageModelSession.GenerationError.exceededContextWindowSize`. O `AIPersonaService` captura esse erro, recria a sessão e tenta novamente. Isso está implementado nos dois métodos (`sendMessage` e `evaluateMessage`).

### MessageFeedback

Struct `@Generable` que o modelo popula automaticamente:

```swift
struct MessageFeedback {
    var contextScore: Int        // 0-10, naturalidade no contexto carioca
    var grammarScore: Int        // 0-10, correcao gramatical
    var correctedMessage: String // mensagem corrigida (ou igual se ja estiver certa)
    var explanationEN: String    // explicacao em ingles do que foi corrigido
    var feelsCarioca: Bool       // soa autenticamente carioca?
    var nicerAlternatives: [String] // ate 2 alternativas mais naturais
}
```

O feedback é exibido na `FeedbackBubble`, um card colapsável que aparece abaixo da mensagem do usuário no chat AI.

---

## IAP Premium (StoreKit 2)

- **ProductId**: `com.gringocria.premium.ai`
- **Arquivo**: `PremiumService.swift`
- **Status atual**: o gate está **desativado**. O `AIChatEntryView` vai direto para o `AIChatView` sem verificar `isPremium`.

Para reativar o paywall, no `AIChatEntryView` adicione verificação de `premiumService.isPremium` e mostre `PremiumGateView` quando false.

O produto ainda precisa ser cadastrado no App Store Connect antes de funcionar em produção.

---

## Como adicionar um novo cenário com script

1. Crie o arquivo JSON em `Resources/scripts/nome_do_cenario.json` seguindo a estrutura do `matte.json`
2. Adicione o subscenário em `scenarios.json` com `"scriptName": "nome_do_cenario"` e `"isLocked": false`
3. Gere os UUIDs dos steps com `UUID()` ou use um gerador online — eles precisam ser únicos e consistentes dentro do arquivo

O `ScenarioViewModel` carrega o script pelo `scriptName` do subscenário via `Bundle.main.url(forResource:withExtension:)`. Não é necessária nenhuma outra configuração — com Xcode 16+ e `PBXFileSystemSynchronizedRootGroup`, arquivos na pasta do projeto são automaticamente incluídos no bundle.

---

## Como adicionar uma nova persona AI

1. Adicione uma entrada em `personas.json`:

```json
{
  "id": "UUID-novo",
  "subscenarioId": "UUID-do-subscenario-em-scenarios.json",
  "nameEN": "Nome em ingles",
  "namePT": "Nome em portugues",
  "systemPrompt": "Voce e [personagem]...",
  "openingLine": "Linha de abertura em PT",
  "openingLineEN": "Opening line in EN"
}
```

2. Adicione o subscenário correspondente em `scenarios.json` com `"isLocked": true` e `"scriptName": ""`

O `PersonaRepository` carrega o arquivo na inicialização e faz lookup por `subscenarioId`. Se o ID bater, o `AIChatEntryView` abre o chat; se não bater, mostra "Coming Soon".

---

## Convenções que o projeto segue

- Todos os arquivos têm `// MARK: -` comments separando seções
- Services: `@Observable @MainActor final class`
- ViewModels: `@Observable @MainActor`
- Views consomem services com `@Environment(NomeDoService.self) private var nomeDoService`
- I/O pesado (leitura de JSON) usa `Task.detached(priority: .utility)` para nao bloquear o MainActor
- Nenhum dado é inventado nas previews — todas usam dados reais ou mocks inline explícitos

---

## O que ainda falta / próximos passos

1. **Mais cenários com script** — só o mate existe. Próximos naturais: biscoito globo, uber carioca, restaurante carioca.
2. **Mais personas AI** — adicionar entradas em `personas.json` para os novos cenários Premium.
3. **Ativar o paywall** — recolocar verificação de `isPremium` no `AIChatEntryView` e cadastrar o produto no App Store Connect (`com.gringocria.premium.ai`).
4. **Voz no chat AI** — `SpeechService` já existe com `AVSpeechSynthesizer`. Só precisa ser chamado no `AIChatView` quando chegar uma mensagem do vendedor.
5. **Tela de conclusão no chat AI** — `ScenarioView` já tem um `completionOverlay`. Criar algo equivalente para o `AIChatView`.
6. **Onboarding** — tela antes do `ProfileSetupView` explicando o conceito do app para novos usuários.
7. **Idioma oficial da interface** — o app está misto PT/EN. Definir e padronizar, depois implementar localização se necessário.
8. **`isCorrect` nas choices** — o campo existe em `ChoiceOption` mas a lógica de penalidade por escolha incorreta está marcada como `// TODO` no `ScenarioViewModel.selectChoice()`.

---

## Armadilhas conhecidas

**Sign in com Apple no simulador**: requer que a conta Apple Developer esteja configurada no Xcode e que o entitlement de Sign in with Apple esteja ativo no target. Se aparecer erro de autenticação, verifique Signing & Capabilities.

**FoundationModels no simulador**: o modelo on-device não roda em simulador. Para testar o chat AI, use um iPhone 15 Pro ou superior com Apple Intelligence habilitado. Em simulador, o `AIAvailabilityService` vai reportar indisponível.

**UUIDs no JSON**: os UUIDs nos arquivos JSON precisam ser estáveis e únicos. Não regenere UUIDs de steps existentes — o branching depende dos IDs fixos (ex: `nextStepId` apontando para o ID de um step condicional específico).

**Steps efêmeros no ScenarioViewModel**: quando o usuário seleciona uma choice, o ViewModel cria um novo `ScriptStep` com `id: UUID()` novo em vez de reutilizar o `id` do step original. Isso é intencional para evitar IDs duplicados no `ForEach`. Não "otimize" isso.
