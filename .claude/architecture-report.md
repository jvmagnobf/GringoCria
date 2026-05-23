# Relatório de Arquitetura — GringoCria
Data: 2026-05-23 (terceira rodada, pós segunda refatoração)

## Contexto
Duas rodadas de refatoração já foram executadas. O código está em estado consideravelmente melhor: `@Observable @MainActor` aplicado uniformemente, ViewModels separados, Services extraídos, repositórios criados, componentes reutilizáveis isolados. Este relatório foca exclusivamente nos problemas **remanescentes** encontrados na análise do estado atual do código.

## Resumo
- Total de problemas: 13
- Críticos (bug real / lógica errada): 3
- Importantes (violações MVVM ou design incorreto): 5
- Melhorias (qualidade, consistência, cosmético): 5

---

## 1. Violações MVVM

### ✅ Tarefa 1.1: ScenarioViewModel cria ProgressService localmente — instância isolada da compartilhada no @Environment
- **Prioridade**: Crítica
- **Arquivo**: `GringoCria/ViewModels/ScenarioViewModel.swift`
- **Linhas**: 26–36
- **Problema**: `ScenarioViewModel` instancia `ProgressService()` no seu `init` com valor-padrão. `ProgressService` já existe como instância única injetada via `@Environment` em toda a árvore de views. O ViewModel cria uma **segunda instância isolada**, completamente separada. Consequência: `progressService.markCompleted(id:)` é chamado na instância local do ViewModel, que não tem nada a ver com a instância usada por `SubscenarioCard` para exibir o checkmark de conclusão. O progresso pode não ser refletido na UI após completar um scenario.
- **Código atual**:
```swift
init(
    profileService: ProfileService = ProfileService(),
    progressService: ProgressService = ProgressService()
) {
    self.profileService = profileService
    self.progressService = progressService
}
```
- **Código esperado**: `ScenarioView` captura `ProgressService` do `@Environment` e passa ao ViewModel.

Em `ScenarioView.swift`, substituir a linha 15:
```swift
// ANTES:
@State private var viewModel = ScenarioViewModel()

// DEPOIS:
@Environment(ProgressService.self) private var progressService
@State private var viewModel: ScenarioViewModel?
```
E substituir o `.task(id: introCompleted)` existente para incluir inicialização:
```swift
.task {
    if viewModel == nil {
        viewModel = ScenarioViewModel(progressService: progressService)
    }
}
.task(id: introCompleted) {
    guard introCompleted, !subscenario.scriptName.isEmpty else { return }
    await viewModel?.start(scriptName: subscenario.scriptName, subscenarioId: subscenario.id)
}
.task {
    await viewModel?.loadUserPhoto()
}
```
Em `ScenarioViewModel.swift`, remover o default de `progressService`:
```swift
init(
    profileService: ProfileService = ProfileService(),
    progressService: ProgressService
) {
    self.profileService = profileService
    self.progressService = progressService
}
```
> `ProfileService` pode permanecer com default pois é uma struct stateless sem estado compartilhado.

---

### ✅ Tarefa 1.2: HomeView bloqueia navegação para subscenarios isLocked — PremiumGateView nunca é exibida
- **Prioridade**: Crítica
- **Arquivo**: `GringoCria/Views/Home/HomeView.swift`
- **Linhas**: 67–78
- **Problema**: O callback `onPremiumTap` tem `guard !subscenario.isLocked else { return }`, que bloqueia silenciosamente a navegação para qualquer subscenario com `isLocked = true`. Isso significa que subscenarios de AI premium (isLocked=true, scriptName="") nunca chegam ao `AIChatEntryView`, e portanto `PremiumGateView` nunca é exibida ao usuário. O fluxo premium está completamente inacessível a partir da aba Scenarios.
- **Código atual**:
```swift
onPremiumTap: { subscenario in
    guard !subscenario.isLocked else { return }  // bloqueia TUDO que é locked
    if subscenario.disclaimer != nil {
        pendingSubscenario = subscenario
        withAnimation(.easeInOut(duration: 0.4)) { showDisclaimer = true }
    } else {
        navigationPath.append(subscenario)
    }
}
```
- **Código esperado**: Remover o `guard !subscenario.isLocked`. Subscenarios de AI (isLocked=true, scriptName="") devem navegar normalmente — `AIChatEntryView` já faz a verificação premium internamente:
```swift
onPremiumTap: { subscenario in
    if subscenario.disclaimer != nil {
        pendingSubscenario = subscenario
        withAnimation(.easeInOut(duration: 0.4)) { showDisclaimer = true }
    } else {
        navigationPath.append(subscenario)
    }
}
```
Também atualizar o `navigationDestination` em `HomeView` para cobrir subscenarios de AI:
```swift
.navigationDestination(for: Subscenario.self) { subscenario in
    if subscenario.isLocked && subscenario.scriptName.isEmpty {
        AIChatEntryView(subscenario: subscenario)
    } else {
        ScenarioView(subscenario: subscenario)
    }
}
```

---

### ✅ Tarefa 1.3: AuthView usa @State opcional para ViewModel — causa frame em branco antes do .task executar
- **Prioridade**: Crítica
- **Arquivo**: `GringoCria/Views/Auth/AuthView.swift`
- **Linhas**: 17–55
- **Problema**: `@State private var viewModel: AuthViewModel?` é opcional e inicializado dentro de `.task`. No primeiro frame de render, `viewModel` é `nil` e o body renderiza um `Group {}` vazio — tela em branco por um ciclo de render assíncrono. O padrão correto para `@Observable` é ter o ViewModel como `@State` não-opcional.
- **Código atual**:
```swift
@State private var viewModel: AuthViewModel?

var body: some View {
    Group {
        if let viewModel { ... }
    }
    .task {
        if viewModel == nil {
            viewModel = AuthViewModel(appState: appState)
        }
    }
}
```
- **Código esperado**: Refatorar `AuthViewModel` para receber `AppState` via método `bind`, permitindo inicialização imediata:
```swift
// AuthViewModel.swift — trocar propriedade imutável por mutável interna
private var appState: AppState?  // ou weak var se necessário

func bind(to appState: AppState) {
    self.appState = appState
}
// Atualizar continueAsGuest() e handleSuccessfulSignIn() para usar self.appState

// AuthView.swift
@State private var viewModel = AuthViewModel()

var body: some View {
    ZStack { ... }  // sem Group/if let
    .onAppear { viewModel.bind(to: appState) }
}
```

---

### ✅ Tarefa 1.4: ProfileView lê ProgressService diretamente via @Environment — dado de domínio deve passar pelo ViewModel
- **Prioridade**: Importante
- **Arquivo**: `GringoCria/Views/Profile/ProfileView.swift`
- **Linhas**: 14, 93–107
- **Problema**: `ProfileView` injeta `@Environment(ProgressService.self)` e acessa `progressService.completedIDs.count` diretamente no `statsSection`. Dados de domínio devem ser expostos pelo `ProfileViewModel`.
- **Código atual**:
```swift
// ProfileView
@Environment(ProgressService.self) private var progressService
// ...
Text("\(progressService.completedIDs.count) / \(viewModel.totalScenarios)")
ProgressView(value: Double(progressService.completedIDs.count), ...)
```
- **Código esperado**:
```swift
// ProfileViewModel — adicionar dependência e propriedade computada
private let progressService: ProgressService

var completedCount: Int { progressService.completedIDs.count }

init(profileService: ProfileService = ProfileService(), progressService: ProgressService) {
    ...
}

// ProfileView — remover @Environment(ProgressService.self)
// Capturar no init da View e passar ao ViewModel:
@State private var viewModel: ProfileViewModel?

// Inicializar com .task ou .onAppear passando o ProgressService do @Environment
Text("\(viewModel.completedCount) / \(viewModel.totalScenarios)")
ProgressView(value: Double(viewModel.completedCount), ...)
```

---

### ✅ Tarefa 1.5: ScenarioViewModel e AIChatViewModel duplicam loadUserPhoto()
- **Prioridade**: Importante
- **Arquivo**: `GringoCria/ViewModels/ScenarioViewModel.swift` linhas 47–49, `GringoCria/ViewModels/AIChatViewModel.swift` linhas 39–41
- **Problema**: Ambos os ViewModels têm o mesmo método `loadUserPhoto() async` que delega para `profileService.loadProfilePhoto()`. Duplicação que deve ser eliminada.
- **Código atual**:
```swift
// Em ambos os ViewModels:
func loadUserPhoto() async {
    userProfileImage = await profileService.loadProfilePhoto()
}
```
- **Código esperado**: Eliminar o método intermediário e chamar diretamente no `.task` das Views:
```swift
// Em ScenarioView e AIChatView, dentro do .task:
userProfileImage = await profileService.loadProfilePhoto()
// OU manter apenas em um dos ViewModels e reutilizar padrão consistente
```

---

### ✅ Tarefa 1.6: AIChatViewModel — ProfileService instanciado localmente sem documentação clara
- **Prioridade**: Importante
- **Arquivo**: `GringoCria/ViewModels/AIChatViewModel.swift`
- **Linhas**: 26–35
- **Problema**: `ProfileService` é uma struct stateless, então instanciar localmente não causa bug de estado duplicado. Mas a assimetria com o restante do código (onde dependências são injetadas) é confusa. O init recebe `aiPersonaService` e `aiAvailabilityService` como obrigatórios mas `profileService` como default silencioso sem explicação.
- **O que fazer**: Adicionar comentário explicativo no init:
```swift
init(
    aiPersonaService: AIPersonaService,
    aiAvailabilityService: AIAvailabilityService,
    /// ProfileService é stateless (struct) — não há estado compartilhado que exija
    /// injeção via @Environment, portanto o default local é aceitável aqui.
    profileService: ProfileService = ProfileService()
) { ... }
```

---

## 2. Qualidade de Código

### ✅ Tarefa 2.1: ChatStyling.swift contém duas structs de View — mover para arquivo próprio
- **Prioridade**: Importante
- **Arquivo**: `GringoCria/Components/ChatStyling.swift`
- **Linhas**: 61–110
- **Problema**: `ChatVendorAvatarView` e `ChatUserAvatarView` vivem dentro do arquivo `ChatStyling.swift` junto com o enum de estilos. Views não pertencem a um arquivo de constantes/estilos.
- **O que fazer**: Criar `GringoCria/Components/ChatAvatarViews.swift` e mover as duas structs para lá. `ChatStyling.swift` fica apenas com o `enum ChatStyling` e seus métodos estáticos.

---

### ✅ Tarefa 2.2: ScenarioViewModel duplica lógica entre processAutoStep e processVendorMessage
- **Prioridade**: Melhoria
- **Arquivo**: `GringoCria/ViewModels/ScenarioViewModel.swift`
- **Linhas**: 221–251
- **Problema**: Os dois métodos são quase idênticos — typing indicator, sleep, append, advanceCurrentStep, isTerminal check.
- **Código esperado**: Extrair helper privado:
```swift
private func processStepWithTyping(_ step: ScriptStep) async throws {
    isTyping = true
    try await Task.sleep(for: .seconds(1.2))
    isTyping = false

    revealedSteps.append(step)
    advanceCurrentStep(from: step)

    if step.isTerminal {
        isCompleted = true
        if let id = subscenarioId { progressService.markCompleted(id: id) }
    }
}
```
Substituir os corpos de `processAutoStep` e `processVendorMessage` por `try await processStepWithTyping(step)`.

---

### ✅ Tarefa 2.3: ProfileViewModel e ProfileSetupViewModel usam convenience init desnecessário
- **Prioridade**: Melhoria
- **Arquivo**: `GringoCria/ViewModels/ProfileViewModel.swift` linhas 30–37, `GringoCria/ViewModels/ProfileSetupViewModel.swift` linhas 26–33
- **Problema**: O padrão `convenience init() { self.init(profileService: ProfileService()) }` é idiomático de antes do `@Observable`. Com `final class @Observable`, basta um `init` com parâmetro default.
- **Código atual**:
```swift
convenience init() {
    self.init(profileService: ProfileService())
}
init(profileService: ProfileService) { ... }
```
- **Código esperado**:
```swift
init(profileService: ProfileService = ProfileService()) { ... }
```

---

### ✅ Tarefa 2.4: HomeView — lógica de tap de subscenario inline no body deve ser extraída para método
- **Prioridade**: Melhoria
- **Arquivo**: `GringoCria/Views/Home/HomeView.swift`
- **Linhas**: 65–78
- **Problema**: O closure `onPremiumTap` no body é longo e mistura lógica de decisão de navegação com construção da UI.
- **Código esperado**:
```swift
private func handleSubscenarioTap(_ subscenario: Subscenario) {
    if subscenario.disclaimer != nil {
        pendingSubscenario = subscenario
        withAnimation(.easeInOut(duration: 0.4)) { showDisclaimer = true }
    } else {
        navigationPath.append(subscenario)
    }
}
```
E no body: `onPremiumTap: handleSubscenarioTap`.

---

### ✅ Tarefa 2.5: OnboardingView — OnboardingPage declarada antes da View principal, linha em branco dupla no final
- **Prioridade**: Melhoria
- **Arquivo**: `GringoCria/Views/Onboarding/OnboardingView.swift`
- **Linhas**: 12–16, 128–129
- **Problema**: `private struct OnboardingPage` está antes do `// MARK: - OnboardingView` sem marcação própria. Há também linha em branco duplicada no final.
- **O que fazer**:
  1. Mover `OnboardingPage` para após o closing `}` da View, precedida de `// MARK: - Supporting Types`.
  2. Remover a linha em branco extra no final.

---

## 3. Verificação de Dados

### ✅ Tarefa 3.1: Confirmar que personas.json contém o campo vendorIcon nos objetos JSON
- **Prioridade**: Importante
- **Arquivo**: `GringoCria/Resources/personas.json`
- **Problema**: `Persona.swift` define `let vendorIcon: String?` (campo existe no modelo). `ChatStyling.vendorIconName(for persona:)` usa `persona.vendorIcon` para exibir o ícone no chat AI. Se o campo `"vendorIcon"` estiver ausente nos objetos JSON de `personas.json`, decodifica como `nil` e o avatar cai no placeholder genérico `person.fill`.
- **O que fazer**: Abrir `GringoCria/Resources/personas.json` e confirmar que cada objeto de persona tem `"vendorIcon": "NomeDoAsset"` preenchido. Exemplos esperados por persona: `"vendorIcon": "IconeMatte"`, `"vendorIcon": "IconeCaipi"`, etc.

---

## Ordem de execução recomendada

1. **Tarefa 1.2** — Bug crítico: fluxo premium completamente bloqueado; nenhum usuário consegue acessar AI chat pela aba Scenarios. Impacto de produto máximo.
2. **Tarefa 1.1** — Bug crítico: ProgressService duplicado faz progresso não ser refletido na UI.
3. **Tarefa 1.3** — UX: frame em branco em AuthView; corrigir antes de release.
4. **Tarefa 2.1** — Organização: mover ChatAvatarViews para arquivo próprio (baixo risco, melhora clareza).
5. **Tarefa 1.4** — MVVM: ProfileView lendo dados diretamente do ProgressService.
6. **Tarefa 1.5** — Deduplicar loadUserPhoto() nos dois ViewModels.
7. **Tarefa 2.2** — Extrair processStepWithTyping helper em ScenarioViewModel.
8. **Tarefa 2.3** — Remover convenience init desnecessário em ProfileViewModel e ProfileSetupViewModel.
9. **Tarefa 1.6** — Documentar ProfileService default em AIChatViewModel.
10. **Tarefa 2.4** — Extrair handleSubscenarioTap em HomeView.
11. **Tarefa 3.1** — Verificar personas.json para vendorIcon.
12. **Tarefa 2.5** — Reorganizar OnboardingView (cosmético).
