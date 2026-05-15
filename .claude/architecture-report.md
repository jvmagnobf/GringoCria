# Relatório de Arquitetura — GringoCria
Data: 2026-05-13

## Resumo

| Categoria | Quantidade |
|---|---|
| Total de problemas | 14 |
| Críticos (bloqueiam features ou causam bugs) | 3 |
| Importantes (violações MVVM, design frágil) | 5 |
| Melhorias (qualidade, escalabilidade, polish) | 6 |

---

## O que está bem e não deve ser tocado

Estas partes estão corretas. Refatorar por refatorar vai introduzir bugs sem benefício real.

**AppState + AppRouter**: a trinca `AppState → AuthState → AppRouter` é limpa. A view só lê `authState` e renderiza a árvore certa. Nenhuma lógica de transição vaza para a View.

**GringoCriaApp.swift**: injeção de `SpeechService` e `ProgressService` como `@State` no entry point é a forma correta para iOS 17+ com `@Observable`. Não usar `@StateObject` foi a decisão certa.

**ProfileImageStore como actor**: isola o I/O de arquivo em um ator dedicado, eliminando data races. Não trocar isso por `async/await` direto em `ProfileService`.

**SpeechService com nonisolated + Task @MainActor**: o padrão de despachar os callbacks do `AVSpeechSynthesizerDelegate` de volta ao MainActor via `Task { @MainActor in … }` é a abordagem correta para Swift 6 strict concurrency. Não simplificar.

**ScenarioView.scrollToBottom**: a função auxiliar evita duplicação dentro dos dois `onChange`. Simples e correta.

**TypingIndicator**: componente autocontido, sem dependências externas. O `onAppear` para disparar a animação é a forma certa aqui.

**CameraPickerView + ProfilePhotoField**: a separação entre o wrapper UIKit (`CameraPickerView`) e o componente SwiftUI de alto nível (`ProfilePhotoField`) está bem feita. `ProfilePhotoField` encapsula picker, câmera e dialog sem vazar estado para o pai.

**HomeViewModel.load() com Task.detached**: a decisão de mover o `Data(contentsOf:)` para fora do MainActor via `Task.detached` está comentada e é tecnicamente correta. Não "simplificar" isso removendo o detach.

---

## 1. Problemas Críticos

### ✅ Tarefa 1.1: Script não tem índice — `nextStepId` não garante avanço correto depois de ramificação

- **Prioridade**: Crítica
- **Arquivo**: `GringoCria/ViewModels/ScenarioViewModel.swift` + `GringoCria/Resources/scripts/matte.json`
- **Linhas**: 64–77 (ScenarioViewModel), steps `A100006A` e `A100006B` no JSON
- **Problema**: Após o usuário escolher uma opção com `nextStepId`, o ViewModel salta para aquele índice via `firstIndex(where:)`. O problema é que os steps `A100006A` (resposta do vendedor "Sim") e `A100006B` (novo choice de preço) aparecem no final do array, não após `A1000006`. O loop `revealNextVendorMessage` percorre o array de forma linear a partir de `currentIndex`. Quando o usuário escolhe "Tem maracujá e limão?" (nextStepId = `A100006A`), o `currentIndex` pula para o índice 9 (posição de `A100006A` no array). Isso funciona. Mas logo em seguida o loop continua linear e encontra `A100006B` no índice 10 — correto por acidente. Se alguém reorganizar o JSON, o fluxo quebra silenciosamente. O ViewModel assume que `steps` é uma lista sequencial, mas o JSON já está usando-o como um grafo. Essa contradição vai quebrar com os próximos cenários.
- **Código atual** (ScenarioViewModel.swift, linha 162):
```swift
// MARK: message do vendor — exibe e verifica terminal
guard step.type == .message, step.speaker == .vendor else { break }
```
O `break` sai do loop quando encontra um step que não é mensagem de vendor nem auto nem vendorVariation — o que inclui steps de ramos não visitados que ficarem no caminho linear.
- **Código esperado**: o ViewModel precisa de um mapa `[UUID: ScriptStep]` para navegação por ID, e `currentStep` rastreado por ID, não por índice de array.
```swift
// Em ScenarioViewModel
private var stepMap: [UUID: ScriptStep] = [:]
private var currentStepId: UUID?

private func loadScript(named name: String) async {
    // ... decode ...
    stepMap = Dictionary(uniqueKeysWithValues: steps.map { ($0.id, $0) })
    currentStepId = steps.first?.id
}
```

---

### ✅ Tarefa 1.2: `onCompleted` é atribuído dentro do `.task` — race condition se o Task for cancelado antes da conclusão

- **Prioridade**: Crítica
- **Arquivo**: `GringoCria/Views/Scenario/ScenarioView.swift`
- **Linhas**: 43–47
- **Problema**: `onCompleted` é atribuído dentro do `.task`, que é assíncrono e pode ser cancelado pelo SwiftUI ao sair da View. Se o usuário navegar para fora rapidamente, o closure responsável por chamar `progressService.markCompleted(id:)` pode nunca ser configurado. Além disso, a atribuição do closure e o início da execução do script estão no mesmo bloco assíncrono sem garantia de ordem no contexto de cancelamento.
- **Código atual**:
```swift
.task {
    viewModel.onCompleted = {
        progressService.markCompleted(id: subscenario.id)
    }
    await viewModel.start(scriptName: subscenario.scriptName)
}
```
- **Código esperado**: separar atribuição do closure (síncrona) do início da execução (assíncrona).
```swift
.onAppear {
    viewModel.onCompleted = {
        progressService.markCompleted(id: subscenario.id)
    }
}
.task {
    await viewModel.start(scriptName: subscenario.scriptName)
}
```

---

### ✅ Tarefa 1.3: `ProgressService` usa `UserDefaults.standard` hardcoded — inconsistente com todos os outros serviços

- **Prioridade**: Crítica
- **Arquivo**: `GringoCria/Services/ProgressService.swift`
- **Linhas**: 33–40
- **Problema**: `SessionService` e `ProfileService` recebem `UserDefaults` por injeção no `init`. `ProgressService` usa `UserDefaults.standard` hardcoded. Inconsistência que contamina dados reais durante desenvolvimento nos Previews (`AuthenticatedTabView` preview instancia `ProgressService()` que vai ler/escrever `UserDefaults.standard` do dispositivo).
- **Código atual**:
```swift
private func load() {
    guard let raw = UserDefaults.standard.array(forKey: UserDefaultsKey.completedSubscenarioIDs) as? [String]
    else { return }
    completedIDs = Set(raw.compactMap { UUID(uuidString: $0) })
}

private func save() {
    let raw = completedIDs.map { $0.uuidString }
    UserDefaults.standard.set(raw, forKey: UserDefaultsKey.completedSubscenarioIDs)
}
```
- **Código esperado**:
```swift
@Observable
@MainActor
final class ProgressService {
    private(set) var completedIDs: Set<UUID> = []
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        load()
    }

    private func load() {
        guard let raw = userDefaults.array(forKey: UserDefaultsKey.completedSubscenarioIDs) as? [String]
        else { return }
        completedIDs = Set(raw.compactMap { UUID(uuidString: $0) })
    }

    private func save() {
        let raw = completedIDs.map { $0.uuidString }
        userDefaults.set(raw, forKey: UserDefaultsKey.completedSubscenarioIDs)
    }
}
```

---

## 2. Problemas Importantes

### ✅ Tarefa 2.1: `HomeView` faz prop drilling de `ProgressService` — lógica de "está completo" vive na View

- **Prioridade**: Importante
- **Arquivo**: `GringoCria/Views/Home/HomeView.swift`
- **Linhas**: 12–13 e 44–75
- **Problema**: `HomeView` lê `ProgressService` do `@Environment` e passa manualmente para `ScenarioSection`, que passa para `SubscenarioCard`. A lógica de "está completo?" vive na View, não no ViewModel. Quando mais subscenários forem adicionados, esse drilling vai crescer.
- **Código atual**:
```swift
// HomeView
@Environment(ProgressService.self) private var progressService
ScenarioSection(scenario: scenario, progressService: progressService)

// ScenarioSection
let progressService: ProgressService
SubscenarioCard(subscenario: subscenario, isCompleted: progressService.isCompleted(id: subscenario.id))
```
- **Código esperado**: subviews leem `ProgressService` do `@Environment` diretamente.
```swift
private struct ScenarioSection: View {
    let scenario: Scenario
    // sem parâmetro progressService
}

private struct SubscenarioCard: View {
    let subscenario: Subscenario
    @Environment(ProgressService.self) private var progressService

    private var isCompleted: Bool {
        progressService.isCompleted(id: subscenario.id)
    }
}
```

---

### ✅ Tarefa 2.2: `ProfileSetupViewModel.saveDone(appState:)` recebe `AppState` como parâmetro — ViewModel transita estado global

- **Prioridade**: Importante
- **Arquivo**: `GringoCria/ViewModels/ProfileSetupViewModel.swift`
- **Linhas**: 62–70
- **Problema**: `saveDone` recebe `AppState` e chama `appState.restoreSession()` diretamente. O ViewModel está responsável por transitar o estado global da aplicação, o que é responsabilidade da View (conectar o ViewModel ao AppState via closure).
- **Código atual**:
```swift
func saveDone(appState: AppState) {
    validateNickname()
    guard nicknameError == nil else { return }
    nickname = profileService.saveNickname(nickname)
    sessionService.markProfileSetupCompleted()
    appState.restoreSession()
}
```
- **Código esperado**:
```swift
// ProfileSetupViewModel
var onSetupCompleted: (() -> Void)?

func saveDone() {
    validateNickname()
    guard nicknameError == nil else { return }
    nickname = profileService.saveNickname(nickname)
    sessionService.markProfileSetupCompleted()
    onSetupCompleted?()
}
```
```swift
// ProfileSetupView
.onAppear {
    viewModel.onSetupCompleted = {
        appState.restoreSession()
    }
}
Button("Done") {
    viewModel.saveDone()
}
```

---

### ✅ Tarefa 2.3: `AuthView` usa subview privada apenas para hospedar `@State` do ViewModel — indireção desnecessária

- **Prioridade**: Importante
- **Arquivo**: `GringoCria/Views/Auth/AuthView.swift`
- **Linhas**: 43–77
- **Problema**: `AuthActionsView` é uma struct `private` no mesmo arquivo. Sua única razão de existir é hospedar o `@State` do `AuthViewModel` para "evitar recriação a cada render do pai". Mas `@State` já persiste o valor enquanto a View está na hierarquia — isso funcionaria diretamente em `AuthView`. A divisão adiciona indireção sem benefício, e o padrão é inconsistente com `ProfileView` e `ProfileSetupView` que instanciam o ViewModel diretamente.
- **Código atual**: `AuthActionsView` com `init` manual que inicializa `State(initialValue: AuthViewModel(appState: appState))`.
- **Código esperado**: consolidar em `AuthView`:
```swift
struct AuthView: View {
    @Environment(AppState.self) private var appState
    @State private var viewModel: AuthViewModel?

    var body: some View {
        VStack(spacing: 24) {
            // ...
            authActionsContent
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
        }
        .onAppear {
            if viewModel == nil {
                viewModel = AuthViewModel(appState: appState)
            }
        }
    }
}
```

---

### ✅ Tarefa 2.4: `revealNextVendorMessage()` é uma função de 80 linhas com três blocos `if type ==` encadeados — escala mal

- **Prioridade**: Importante
- **Arquivo**: `GringoCria/ViewModels/ScenarioViewModel.swift`
- **Linhas**: 103–183
- **Problema**: a função mistura decisão de tipo de step, delay de timing e atualização de estado observável num único loop `while`. Quando o próximo tipo de step for adicionado (áudio, speech-to-text, animação), essa função vai crescer indefinidamente. O loop com múltiplos `continue` e `return` torna o fluxo difícil de auditar.
- **Código esperado**: extrair processamento por tipo para métodos privados:
```swift
private func revealNextVendorMessage() async {
    do {
        while currentIndex < steps.count {
            let step = steps[currentIndex]
            switch step.type {
            case .vendorVariation: try await processVendorVariation(step)
            case .auto:            try await processAutoStep(step)
            case .message where step.speaker == .vendor: try await processVendorMessage(step)
            default: return
            }
            if isCompleted { return }
        }
        finishIfNeeded()
    } catch is CancellationError {
        isTyping = false
    }
}
```

---

### ✅ Tarefa 2.5: `SessionService.initialAuthState()` e `restoredAuthState()` são idênticas — duplicação semântica

- **Prioridade**: Importante
- **Arquivo**: `GringoCria/Services/SessionService.swift`
- **Linhas**: 26–34
- **Problema**: `restoredAuthState()` apenas delega para `initialAuthState()`. A duplicação sugere uma intenção de diferenciação que nunca foi implementada. Qualquer novo desenvolvedor vai perguntar qual a diferença entre os dois.
- **Código atual**:
```swift
func initialAuthState() -> AuthState { ... }
func restoredAuthState() -> AuthState { initialAuthState() }
```
- **Código esperado**: um único método com nome descritivo:
```swift
func resolveAuthState() -> AuthState {
    guard currentSessionSource() != nil else { return .unauthenticated }
    return hasCompletedProfileSetup() ? .authenticated : .firstAccess
}
```
Atualizar `AppState` para chamar `sessionService.resolveAuthState()`.

---

## 3. Melhorias

### ✅ Tarefa 3.1: `matte.json` — ramificação pós-`A100006A` depende da ordem do array

- **Prioridade**: Melhoria (consequência direta da Tarefa 1.1)
- **Arquivo**: `GringoCria/Resources/scripts/matte.json`
- **Problema**: `A100006A` (resposta "Sim" do vendedor) não tem `nextStepId` para `A100006B`. O avanço para `A100006B` funciona apenas porque esses steps estão no final do array em ordem. Reorganizar o JSON quebra o fluxo silenciosamente. Deve ser resolvido junto com a Tarefa 1.1 (migração para navegação por ID).

---

### ✅ Tarefa 3.2: `ProfileView` não tem estado `isSaving` — double-tap em "Save Changes" dispara dois saves concorrentes

- **Prioridade**: Melhoria
- **Arquivo**: `GringoCria/Views/Profile/ProfileView.swift` + `GringoCria/ViewModels/ProfileViewModel.swift`
- **Linhas**: 75–78 (View), 70–86 (ViewModel)
- **Problema**: `saveChanges()` é `async` e pode levar tempo (salvar foto em disco). A View chama `Task { await viewModel.saveChanges() }` sem desabilitar o botão durante a operação. Double-tap dispara dois saves concorrentes.
- **Solução**: adicionar `private(set) var isSaving = false` no ViewModel. Desabilitar "Save Changes" quando `isSaving` for `true`.

---

### ✅ Tarefa 3.3: `ProfileService.nicknameValidationError` tem bug silencioso no `CharacterSet`

- **Prioridade**: Melhoria
- **Arquivo**: `GringoCria/Services/ProfileService.swift`
- **Linhas**: 49–60
- **Problema**: `.nonBaseCharacters` é um conjunto amplo que inclui caracteres de controle e caracteres Unicode especiais. A intenção era aceitar acentos (ã, é, ç) — mas `.letters` do Unicode já inclui letras com diacríticos. A adição de `.nonBaseCharacters` abre para caracteres indesejados. Além disso, a string `" _-'.'` tem o ponto aparecendo dentro e fora das aspas simples, tornando a intenção ambígua.
- **Código atual**:
```swift
let allowedCharacters = CharacterSet.letters
    .union(.nonBaseCharacters)
    .union(.decimalDigits)
    .union(CharacterSet(charactersIn: " _-'.'"))
```
- **Código esperado**:
```swift
let allowedCharacters = CharacterSet.letters
    .union(.decimalDigits)
    .union(CharacterSet(charactersIn: " _-'."))
```

---

### ✅ Tarefa 3.4: `HomeView` não trata lista vazia ou falha de decode — tela em branco silenciosa

- **Prioridade**: Melhoria
- **Arquivo**: `GringoCria/Views/Home/HomeView.swift` + `GringoCria/ViewModels/HomeViewModel.swift`
- **Linhas**: 16–29 (View), 22–41 (ViewModel)
- **Problema**: se `scenarios.json` decodificar como array vazio ou falhar, o ViewModel seta `scenarios = []` sem sinalizar erro. A View exibe uma `ScrollView` vazia sem mensagem. Quando Restaurante e Rua forem adicionados, uma falha de JSON vai ser muito difícil de diagnosticar.
- **Solução**: adicionar `private(set) var loadError: String?` no ViewModel e exibir mensagem na View quando `scenarios.isEmpty && !isLoading`.

---

### ✅ Tarefa 3.5: `Task.sleep` com `try?` dentro de `revealNextVendorMessage` — tasks continuam rodando após dismiss

- **Prioridade**: Melhoria
- **Arquivo**: `GringoCria/ViewModels/ScenarioViewModel.swift`
- **Linhas**: 122, 148, 165
- **Problema**: `try? await Task.sleep(...)` descarta o `CancellationError`. Quando o usuário sai da View antes do script terminar, o `.task` do SwiftUI é cancelado, mas o loop interno continua executando os delays em background porque o erro de cancelamento foi silenciado.
- **Código atual**:
```swift
try? await Task.sleep(for: .seconds(1.2))
```
- **Código esperado** (a ser implementado junto com a Tarefa 2.4):
```swift
try await Task.sleep(for: .seconds(1.2))
// tratado no catch is CancellationError do método pai
```

---

### ✅ Tarefa 3.6: `Subscenario.isLocked` é `var`, nunca é aplicado na UI e bloqueia navegação apenas no comentário

- **Prioridade**: Melhoria
- **Arquivo**: `GringoCria/Models/Scenario.swift` + `GringoCria/Views/Home/HomeView.swift`
- **Linhas**: `Scenario.swift` linha 23, `HomeView.swift` linha 97 (comentário `// TODO: implementar UI de subcenário bloqueado`)
- **Problema**: `isLocked` é `var` sem razão (deveria ser `let`), está no JSON mas o `NavigationLink` ignora completamente o campo — qualquer subscenário marcado como `isLocked: true` ainda pode ser acessado. Quando Restaurante e Rua forem adicionados com `isLocked: true`, o bloqueio não vai funcionar.
- **Solução imediata**: mudar para `let isLocked`. Implementar o bloqueio de navegação antes de adicionar novos cenários ao JSON, ou remover o campo até que o sistema de desbloqueio seja definido.

---

## Ordem de execução recomendada

| Ordem | Tarefa | Justificativa |
|---|---|---|
| 1 | **1.3** — injetar `UserDefaults` em `ProgressService` | Isolada, zero risco, alinha com padrão já adotado. |
| 2 | **2.5** — consolidar `initialAuthState`/`restoredAuthState` | Mudança em 2 arquivos, sem impacto em lógica. |
| 3 | **3.3** — corrigir `CharacterSet` em `ProfileService` | Bug silencioso que afeta usuários com nomes acentuados. |
| 4 | **2.2** — remover `AppState` de `saveDone` | Isola o ViewModel antes de qualquer novo fluxo de onboarding. |
| 5 | **2.1** — eliminar prop drilling de `ProgressService` | Fazer antes de adicionar mais subscenários. |
| 6 | **1.2** — mover `onCompleted` para `onAppear` | Correção de race condition. Simples e independente. |
| 7 | **3.2** — adicionar `isSaving` em `ProfileViewModel` | Protege contra double-tap antes de polimento de UI. |
| 8 | **3.4** — tratar lista vazia em `HomeView` | UX. Antes da apresentação. |
| 9 | **3.6** — implementar ou remover `isLocked` | Antes de adicionar Restaurante/Rua ao JSON. |
| 10 | **2.3** — simplificar `AuthView`/`AuthActionsView` | Refatoração de organização. Sem impacto funcional. |
| 11 | **2.4** — extrair processamento por tipo em `ScenarioViewModel` | Deixa o ViewModel legível antes das mudanças maiores. |
| 12 | **3.5** — propagar `CancellationError` no `Task.sleep` | Implementar junto com 2.4 (mesmo método). |
| 13 | **1.1** — migrar ScenarioViewModel para navegação por ID | A mudança mais complexa. Requer atualização do JSON e do ViewModel. Depende de 2.4. |
| 14 | **3.1** — adicionar `nextStepId` explícito em `matte.json` | Implementar junto com 1.1. |
