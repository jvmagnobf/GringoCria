# Revisao HIG, UX e Acessibilidade — GringoCria
Data: 2026-05-23
Arquivos analisados: 22 Views + 6 componentes + 4 color assets

---

## Notas Gerais por Aspecto

| Aspecto | Nota | Resumo |
|---|---|---|
| Conformidade com HIG | 6.5/10 | Bons padroes de navegacao, mas Tab Bar em ingles inconsistente, color scheme forcado e UIAppearance global causam atrito com o sistema |
| Acessibilidade | 4/10 | Labels parciais, ausencia total de Dynamic Type, Reduce Motion e agrupamento VoiceOver. Tap targets do speaker abaixo do minimo de 44pt |
| Liquid Glass | 7/10 | Uso correto e consistente nos cards e botoes; ConversationHeaderImage usa ultraThinMaterial adequadamente |
| Consistencia visual | 6/10 | Paleta coesa, mas color assets sem variante real light/dark, hardcoded hex em multiplos lugares, emojis em TipCard violam HIG |
| Fluxos criticos | 6/10 | Onboarding bem executado, auth claro, ScenarioView solido. Fraquezas: SplashView sem acessibilidade, DisclaimerOverlay sem haptics, PremiumGateView sem scroll em telas pequenas |

**Nota geral: 6/10**

---

## Contagem de Problemas

- Problemas criticos de acessibilidade: 7
- Violacoes de HIG: 8
- Melhorias de UX: 6

---

## Problemas Criticos de Acessibilidade

### A11Y-001: Splash e Onboarding sem accessibilityLabel — VoiceOver nao anuncia nada util

- **Arquivo**: `Views/Navigation/SplashView.swift` / `Views/Onboarding/OnboardingView.swift`
- **Problema**: A SplashView e toda a area interativa do OnboardingView usam `.onTapGesture` sem `.accessibilityLabel` ou `.accessibilityHint`. O VoiceOver le "Image" e nao oferece instrucao de como avancar. Usuarios cegos ficam presos na splash.
- **Impacto**: Usuarios de VoiceOver nao conseguem passar da tela inicial — bloqueio total de uso.
- **Correcao**:
```swift
// SplashView — adicionar ao ZStack
.accessibilityElement(children: .ignore)
.accessibilityLabel("GringoCria — welcome screen")
.accessibilityHint("Double tap to enter")
.accessibilityAddTraits(.isButton)

// OnboardingView — adicionar ao ZStack principal
.accessibilityElement(children: .ignore)
.accessibilityLabel(pages[currentPage].title + ". " + pages[currentPage].body)
.accessibilityHint(currentPage < pages.count - 1 ? "Double tap to advance" : "Double tap to get started")
.accessibilityAddTraits(.isButton)
```

---

### A11Y-002: IntroOverlayView sem acessibilidade — mesmo padrao da splash, bloqueia inicio de cenarios

- **Arquivo**: `Views/Scenario/IntroOverlayView.swift`
- **Problema**: Overlay de introducao dos cenarios usa `.onTapGesture` sem nenhum modificador de acessibilidade. VoiceOver le o texto mas nao indica que e uma area clicavel.
- **Impacto**: Usuarios de VoiceOver nao conseguem iniciar nenhum cenario.
- **Correcao**:
```swift
.accessibilityElement(children: .ignore)
.accessibilityLabel(pages[currentPage])
.accessibilityHint(currentPage < pages.count - 1 ? "Double tap to continue" : "Double tap to start the conversation")
.accessibilityAddTraits(.isButton)
```

---

### A11Y-003: SubscenarioCard sem agrupamento — VoiceOver fragmenta o card em 3 elementos separados

- **Arquivo**: `Views/Home/ScenarioListView.swift`, struct `SubscenarioCard`
- **Problema**: O card tem dois `Text` e um icone de status (`lock.fill`, `checkmark.circle.fill`, `wand.and.sparkles`) sem agrupamento nem label composta. VoiceOver navega em tres elementos sem descrever o estado.
- **Impacto**: Usuarios ouvem "Beach" / "Praia" / "lock" sem entender que e um item bloqueado ou concluido.
- **Correcao**:
```swift
var body: some View {
    HStack { ... }
    .padding(16)
    .glassEffect(in: RoundedRectangle(cornerRadius: 12))
    .contentShape(RoundedRectangle(cornerRadius: 12))
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(accessibilityDescription)
    .accessibilityAddTraits(.isButton)
}

private var accessibilityDescription: String {
    var parts = [subscenario.titleEN, subscenario.titlePT]
    if subscenario.isLocked {
        parts.append(subscenario.scriptName.isEmpty ? "Premium AI chat" : "Locked")
    } else if isCompleted {
        parts.append("Completed")
    }
    return parts.joined(separator: ", ")
}
```

---

### A11Y-004: speakerButton com area de toque abaixo de 44pt — HIG exige minimo 44x44

- **Arquivo**: `Views/Scenario/Components/MessageBubble.swift`
- **Problema**: O botao de pronuncia usa `.font(.caption)` — o icone renderiza com aproximadamente 12pt. A area de toque resultante e insuficiente segundo a HIG.
- **Impacto**: Usuarios com motricidade reduzida ou dedo maior nao conseguem acionar o speaker com precisao.
- **Correcao**:
```swift
private var speakerButton: some View {
    Button {
        // ...
    } label: {
        Image(systemName: isSpeakingThis ? "speaker.slash" : "speaker.wave.2")
            .font(.body)
            .foregroundStyle(.secondary)
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
    }
    .accessibilityLabel(isSpeakingThis ? "Stop pronunciation" : "Play pronunciation")
}
```

---

### A11Y-005: Ausencia total de suporte a Dynamic Type — layouts fixos quebram com fonte grande

- **Arquivos**: todos os arquivos de View
- **Problema**: O app nao usa `@ScaledMetric`, tem frames fixos como `.frame(maxHeight: 400)` no OnboardingView e padding fixo que nao se adapta. Usuarios com baixa visao que aumentam a fonte do sistema encontram layout quebrado.
- **Impacto**: Usuarios com deficiencia visual parcial que dependem de fontes maiores nao conseguem usar o app confortavelmente.
- **Correcao** (exemplo para OnboardingView):
```swift
// Adicionar a limit de Dynamic Type nas telas mais sensiveis
.dynamicTypeSize(.xSmall ... .accessibility2)

// Substituir frame fixo por adaptativo
Image(pages[currentPage].cristoImage)
    .resizable()
    .scaledToFit()
    .frame(maxHeight: 280) // valor menor para deixar espaco ao texto maior
```

---

### A11Y-006: TypingIndicatorView com animacao sem respeito a Reduce Motion

- **Arquivo**: `Components/TypingIndicatorView.swift`
- **Problema**: Os tres circulos animados usam `.animation(.easeInOut.repeatForever())` sem verificar `accessibilityReduceMotion`. Usuarios que ativam "Reduzir Movimento" continuam vendo a animacao pulsante.
- **Impacto**: Pode causar desconforto em usuarios com transtornos vestibulares.
- **Correcao**:
```swift
struct TypingIndicatorView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    // ...
    Circle()
        .offset(y: (animating && !reduceMotion) ? -4 : 0)
        .animation(
            reduceMotion ? .none :
                .easeInOut(duration: 0.4).repeatForever().delay(Double(index) * 0.13),
            value: animating
        )
}
```

---

### A11Y-007: FeedbackBubble usa onTapGesture em vez de Button — invisivel para VoiceOver

- **Arquivo**: `Views/AI/Components/FeedbackBubble.swift`
- **Problema**: O `collapsedHeader` usa `.onTapGesture` para expandir/recolher. VoiceOver nao anuncia que e clicavel, nao le o estado expandido/recolhido.
- **Impacto**: Usuarios de VoiceOver nao sabem que podem expandir o feedback de gramatica — funcionalidade central do AI chat e inacessivel.
- **Correcao**:
```swift
Button {
    withAnimation(.easeInOut(duration: 0.2)) {
        isExpanded.toggle()
    }
} label: {
    collapsedHeader
}
.buttonStyle(.plain)
.accessibilityLabel("Grammar feedback")
.accessibilityHint(isExpanded ? "Tap to collapse" : "Tap to expand details")
.accessibilityAddTraits(isExpanded ? [.isButton, .isSelected] : .isButton)
```

---

## Violacoes de HIG

### HIG-001: Color scheme forcado globalmente — ignora preferencia do usuario

- **Arquivo**: `GringoCriaApp.swift`, linha 46
- **Problema**: `.preferredColorScheme(.dark)` no root ignora usuarios que usam light mode por acessibilidade. A HIG e explicita: apps devem respeitar a preferencia do sistema.
- **Correcao**: Remover `.preferredColorScheme(.dark)`. As telas com imagem de fundo ja sao naturalmente escuras e nao precisam do forcamento.

---

### HIG-002: UITabBarAppearance manual sobrescreve o Liquid Glass nativo do iOS 26

- **Arquivo**: `GringoCriaApp.swift`, linhas 29-35
- **Problema**: Configurar `UITabBarAppearance.configureWithTransparentBackground()` com cores manuais pode desativar o efeito glass nativo da Tab Bar no iOS 26, criando inconsistencia com o `.glassEffect()` usado nos cards.
- **Correcao**: Remover a customizacao de `UITabBarAppearance` e usar apenas `tintColor` via `accentColor` no asset catalog se necessario.

---

### HIG-003: UINavigationBarAppearance global — titulo branco invisivel em fundos claros

- **Arquivo**: `GringoCriaApp.swift`, linhas 22-27
- **Problema**: Titulo branco configurado globalmente torna-se ilegivel na `AIChatEntryView.comingSoonView` que usa `Color(.systemGroupedBackground)` (cinza claro). Contraste insuficiente.
- **Correcao**: Usar `.toolbarBackground(.visible, for: .navigationBar)` nas telas com fundo claro.

---

### HIG-004: SplashView usa "Click to continue" — terminologia de desktop em app iOS

- **Arquivo**: `Views/Navigation/SplashView.swift`, linha 26
- **Problema**: A HIG especifica "tap" para interacoes toque, nunca "click" (terminologia de mouse).
- **Correcao**:
```swift
Text("Tap to continue")
    .font(.headline)
    .foregroundStyle(.white)
    .padding(.bottom, 60)
```

---

### HIG-005: Color assets sem variante real de light/dark — mesmo valor nos dois modos

- **Arquivo**: `Assets.xcassets/amarelo_mensagem.colorset`, `branco_mensagem.colorset`, `mensagem_fonte.colorset`
- **Problema**: Os tres color assets definem a mesma cor para universal e dark. Impossibilita suporte a light mode sem refatoracao.
- **Correcao**: Definir variantes light e dark distintas nos tres color assets, especialmente `mensagem_fonte` (texto sobre bolhas).

---

### HIG-006: Cores hardcoded (rgb) espalhadas pelo codigo

- **Arquivos**: `HomeView.swift` (DisclaimerOverlay), `ChatStyling.swift`, `GringoCriaApp.swift`
- **Problema**: Multiplos usos de `Color(red:green:blue:)` e `UIColor(red:green:blue:alpha:)` hardcoded. Impossivel ajustar o tema sem busca manual por todo o codigo.
- **Correcao**: Centralizar todas as cores em color assets ou em uma enum estatica de `Color`. Exemplos a migrar: `navy_button` (DisclaimerOverlay), `user_avatar_blue` (ChatStyling), `window_background` (GringoCriaApp).

---

### HIG-007: TipCard usa emojis como iconografia estrutural — nao escala com Dynamic Type

- **Arquivo**: `Views/Tips/TipsView.swift`
- **Problema**: Emojis renderizam com tamanho fixo e nao se adaptam ao Dynamic Type ou Bold Text. A HIG recomenda SF Symbols para iconografia em apps iOS.
- **Correcao**: Adicionar campo `icon` (SF Symbol) ao modelo `Tip` e substituir o emoji por `Image(systemName: tip.icon)`. Se emojis forem parte da identidade intencional, marcar com `.accessibilityHidden(true)`.

---

### HIG-008: Tab Bar com label "Scenarios" desalinhada — tab principal deveria ser "Home"

- **Arquivo**: `Views/Navigation/AuthenticatedTabView.swift`
- **Problema**: A convencao HIG para a primeira tab de um app e usar o nome do conteudo principal ou simplesmente "Home" com `house.fill`. "Scenarios" descreve o conteudo mas e mais longo e menos intuitivo para navegacao. "Rio Tips" tem 2 palavras e foge do padrao de 1 palavra.
- **Correcao**:
```swift
Label("Home", systemImage: "house.fill")     // era "Scenarios"
Label("AI Chat", systemImage: "wand.and.sparkles") // era "Premium"
Label("Tips", systemImage: "lightbulb.fill")  // era "Rio Tips"
Label("Profile", systemImage: "person.crop.circle.fill")
```

---

## Melhorias de UX

### UX-001: DisclaimerOverlay — tela inteira clicavel cria risco de toque acidental no disclaimer

- **Arquivo**: `Views/Home/HomeView.swift`, `DisclaimerOverlay`
- **Estado atual**: `.onTapGesture` no ZStack inteiro faz qualquer toque avancar, incluindo toques acidentais antes de o usuario terminar de ler o aviso.
- **Sugestao**: Remover `.onTapGesture` do ZStack. Tornar apenas o botao "Tap here to continue" clicavel. Adicionar `.sensoryFeedback(.impact, trigger: onContinue)` para feedback haptico.

---

### UX-002: ProfileSetupView sem NavigationStack e sem instrucoes contextuais

- **Arquivo**: `Views/Profile/ProfileSetupView.swift`
- **Estado atual**: Sem `NavigationStack`, sem `.navigationTitle`, sem texto explicando que a foto e opcional ou o que acontece apos clicar "Done".
- **Sugestao**: Adicionar `NavigationStack` com `.navigationTitle("Create Profile")`. Adicionar texto auxiliar: "Your nickname will appear in the chat." abaixo do campo de nickname.

---

### UX-003: ScenarioView mistura portugues e ingles na mesma tela de conclusao

- **Arquivo**: `Views/Scenario/ScenarioView.swift`, linha 99
- **Estado atual**: Exibe `"Agora voce ja sabe o que esperar!"` em portugues em um app voltado para turistas anglofones.
- **Sugestao**: Traduzir para ingles: `"Now you know what to expect!"` ou parametrizar via JSON do cenario.

---

### UX-004: AIChatView sem feedback haptico no envio de mensagem

- **Arquivo**: `Views/AI/AIChatView.swift`
- **Estado atual**: Mensagem e enviada sem nenhum feedback tatil. O botao de enviar apenas muda de estado (cor).
- **Sugestao**:
```swift
// Adicionar ao sendMessage()
private func sendMessage() {
    let text = inputText
    inputText = ""
    UIImpactFeedbackGenerator(style: .light).impactOccurred()
    Task { await viewModel.send(text, persona: persona) }
}
```

---

### UX-005: PremiumGateView sem ScrollView — conteudo cortado em telas menores

- **Arquivo**: `Views/Premium/PremiumGateView.swift`
- **Estado atual**: Layout com `VStack` + `Spacer()` sem `ScrollView`. Em iPhone SE (667pt de altura) header, features, nota e 3 botoes nao cabem sem scroll.
- **Sugestao**:
```swift
var body: some View {
    ScrollView {
        VStack(spacing: 0) {
            // conteudo atual
        }
        .padding(.bottom, 40)
    }
}
```

---

### UX-006: TipsView sem estado vazio quando tips e vazio e sem loading indicator

- **Arquivo**: `Views/Tips/TipsView.swift`
- **Estado atual**: Se `viewModel.tips` for vazio e nao houver erro, a view exibe apenas o subtitulo. Nao ha indicacao de loading durante o `.task { await viewModel.load() }`.
- **Sugestao**:
```swift
if viewModel.isLoading {
    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
} else if viewModel.tips.isEmpty && viewModel.loadError == nil {
    VStack(spacing: 12) {
        Image(systemName: "lightbulb.slash")
            .font(.system(size: 44)).foregroundStyle(.secondary)
        Text("No tips available yet.")
            .font(.headline).foregroundStyle(.white)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
} else { ... }
```

---

## Padroes Positivos — Replicar no App

**1. accessibilityLabel no toolbar button (ScenarioView e AIChatView)**
O botao de traducao tem `.accessibilityLabel("Toggle translation")` — padrao correto a replicar em todos os botoes de icone.

**2. glassEffect consistente nos cards**
`SubscenarioCard` e `TipCard` usam `.glassEffect(in: RoundedRectangle(cornerRadius: 12))` de forma consistente, criando identidade visual coesa com iOS 26.

**3. scrollDismissesKeyboard(.interactively) no AIChatView**
Excelente uso de API moderna — comportamento natural ao arrastar o scroll com teclado aberto.

**4. Feedback de erro contextualizado no input bar (AIChatView)**
Exibir `viewModel.errorMessage` logo acima do campo de texto e preciso — o usuario sabe exatamente o que falhou.

**5. ConversationHeaderImage com ultraThinMaterial contextualizado**
`.ultraThinMaterial` com `.environment(\.colorScheme, .dark)` para a pill de localizacao — texto legivel sobre qualquer imagem de fundo.

**6. accessibilityLabel como parametro em ProfilePhotoField**
Componente reutilizavel que delega a responsabilidade de acessibilidade ao chamador — padrao correto de composicao.

---

## Checklist de Acessibilidade

- [ ] VoiceOver: SplashView e OnboardingView com label, hint e trait de botao (A11Y-001)
- [ ] VoiceOver: IntroOverlayView com label, hint e trait de botao (A11Y-002)
- [ ] VoiceOver: SubscenarioCard agrupado com label composta incluindo estado (A11Y-003)
- [ ] VoiceOver: FeedbackBubble convertido para Button com trait e estado expanded (A11Y-007)
- [ ] Area de toque: speakerButton com frame minimo 44x44pt (A11Y-004)
- [ ] Dynamic Type: layout testado com fonte Accessibility Extra Large (A11Y-005)
- [ ] Reduce Motion: animacao do TypingIndicator desativada quando preferido (A11Y-006)
- [ ] Dark Mode: remover `.preferredColorScheme(.dark)` e testar em light mode (HIG-001)
- [ ] Tab Bar: remover UITabBarAppearance manual para preservar Liquid Glass (HIG-002)
- [ ] Terminologia: substituir "Click" por "Tap" em toda a UI (HIG-004)
- [ ] Contraste: verificar mensagem_fonte sobre amarelo_mensagem (ratio minimo 4.5:1)

---

## Priorizacao Executiva

**Sprint 1 — Critico (acessibilidade bloqueante)**
1. A11Y-001 + A11Y-002 — Splash e Onboarding inacessiveis: usuarios cegos nao passam da primeira tela
2. A11Y-007 — FeedbackBubble sem trait: funcionalidade central do AI chat invisivel para VoiceOver
3. A11Y-004 — speakerButton abaixo de 44pt: afeta usuarios com motricidade reduzida
4. HIG-004 — "Click to continue": erro basico de terminologia iOS

**Sprint 2 — Importante (conformidade e qualidade)**
5. A11Y-003 — SubscenarioCard fragmentado no VoiceOver
6. A11Y-006 — TypingIndicator sem Reduce Motion
7. HIG-001 + HIG-002 — Dark mode forcado e Tab Bar sem Liquid Glass
8. HIG-005 + HIG-006 — Color assets sem variante light/dark e cores hardcoded

**Sprint 3 — Polish**
9. A11Y-005 — Dynamic Type completo
10. UX-001 a UX-006 — Melhorias de fluxo, haptics e estados vazios
