# Plano de Trabalho Restante — GringoCria

**Data:** 2026-05-23
**Status:** Após 3 rodadas de refatoração + correções críticas de A11Y/HIG
**Notas atuais:** Arquitetura 8.1/10 | HIG 6.5/10 | A11Y 4.0/10 → ~6.0/10 após críticos

---

## ✅ Já implementado nesta sessão

- **A11Y-001/002:** SplashView, OnboardingView e IntroOverlayView com VoiceOver completo
- **A11Y-007:** FeedbackBubble convertido para Button (acessível)
- **HIG-001:** Removido `.preferredColorScheme(.dark)` forçado
- **HIG-002:** Removido `UITabBarAppearance` manual — Tab Bar volta ao Liquid Glass nativo
- **HIG-004:** "Click to continue" → "Tap to continue"
- **Arquitetura:** Property `isAIPremium` adicionada em `Subscenario`
- **Arquitetura:** Removido `AnyView` de `ScenarioView` (usa `@ViewBuilder`)

---

## 🔴 Sprint 1 — Acessibilidade restante (alto impacto)

### 1. A11Y-003 — SubscenarioCard fragmentado no VoiceOver
**Arquivo:** `Views/Home/ScenarioListView.swift`
VoiceOver lê título EN, título PT e ícone como 3 elementos separados. Adicionar `.accessibilityElement(children: .ignore)` + label composta descrevendo estado (Locked, Premium AI chat, Completed).

### 2. A11Y-004 — Botão de pronúncia abaixo de 44pt
**Arquivo:** `Views/Scenario/Components/MessageBubble.swift`
Speaker button usa `.font(.caption)` (~12pt). Trocar para `.font(.body)` e adicionar `.frame(width: 44, height: 44).contentShape(Rectangle())`.

### 3. A11Y-005 — Suporte a Dynamic Type
**Arquivos:** todos os files de View
Não há `@ScaledMetric` no projeto. Frames fixos como `.frame(maxHeight: 400)` quebram com fontes grandes. Adicionar `.dynamicTypeSize(.xSmall ... .accessibility2)` nas telas críticas e revisar frames fixos.

### 4. A11Y-006 — TypingIndicator sem Reduce Motion
**Arquivo:** `Components/TypingIndicatorView.swift`
Animação infinita ignora `@Environment(\.accessibilityReduceMotion)`. Pode causar desconforto vestibular.

---

## 🟡 Sprint 2 — HIG e Consistência Visual

### 5. HIG-003 — UINavigationBarAppearance global
**Arquivo:** `GringoCriaApp.swift`
Título branco fica invisível em telas com fundo claro (ex: `AIChatEntryView.comingSoonView`). Remover customização global ou usar `.toolbarBackground(.visible)` por tela.

### 6. HIG-005 — Color assets sem variante light/dark
**Pasta:** `Assets.xcassets`
`amarelo_mensagem`, `branco_mensagem`, `mensagem_fonte` definem a mesma cor para universal e dark. Impossibilita light mode real.

### 7. HIG-006 — Cores hardcoded espalhadas
**Arquivos:** `HomeView.swift` (DisclaimerOverlay), `ChatStyling.swift`, `GringoCriaApp.swift`
Múltiplos `Color(red:green:blue:)` hardcoded. Centralizar em color assets ou em enum estática.

### 8. HIG-007 — TipCard usa emojis como iconografia
**Arquivo:** `Views/Tips/TipsView.swift`
Emojis não escalam com Dynamic Type nem Bold Text. Adicionar campo `icon` (SF Symbol) ao modelo `Tip`. Se manter emoji, marcar com `.accessibilityHidden(true)`.

### 9. HIG-008 — Tab Bar labels não convencionais
**Arquivo:** `Views/Navigation/AuthenticatedTabView.swift`
"Scenarios" → "Home" | "Premium" → "AI Chat" | "Rio Tips" → "Tips" (HIG: tabs com 1 palavra quando possível).

---

## 🟢 Sprint 3 — UX Polish

### 10. UX-001 — DisclaimerOverlay com toque acidental
**Arquivo:** `Views/Home/HomeView.swift`
ZStack inteiro clicável → qualquer toque avança, mesmo acidental. Tornar apenas o botão clicável + adicionar `.sensoryFeedback(.impact, trigger: onContinue)`.

### 11. UX-002 — ProfileSetupView sem NavigationStack
**Arquivo:** `Views/Profile/ProfileSetupView.swift`
Sem `.navigationTitle`, sem texto contextual explicando o que acontece após "Done". Adicionar "Your nickname will appear in the chat." abaixo do campo.

### 12. UX-003 — Texto em português na conclusão do cenário
**Arquivo:** `Views/Scenario/ScenarioView.swift` (linha ~99)
`"Agora você já sabe o que esperar!"` em app voltado a anglófonos. Trocar para `"Now you know what to expect!"` ou parametrizar via JSON.

### 13. UX-004 — AIChatView sem feedback háptico
**Arquivo:** `Views/AI/AIChatView.swift`
Mensagem enviada sem feedback tátil. Adicionar `UIImpactFeedbackGenerator(style: .light).impactOccurred()` no `sendMessage()`.

### 14. UX-005 — PremiumGateView cortado em telas pequenas
**Arquivo:** `Views/Premium/PremiumGateView.swift`
VStack sem ScrollView — iPhone SE corta conteúdo. Envolver em `ScrollView`.

### 15. UX-006 — TipsView sem loading / empty state
**Arquivo:** `Views/Tips/TipsView.swift`
Sem `ProgressView` durante `.task`. Sem estado vazio se `tips` for vazio sem erro. Adicionar ambos.

---

## ⚙️ Sprint 4 — Arquitetura e Maintenance

### 16. Padronizar inicialização de ViewModels
**Arquivos:** `ScenarioView`, `ProfileView` vs resto do projeto
Hoje coexistem dois padrões sem documentação:
- **Padrão A:** `@State private var viewModel = TipsViewModel()` (a maioria)
- **Padrão B:** `@State private var viewModel: ProfileViewModel?` + init em `.task` (ScenarioView, ProfileView)

Solução: receber dependências do `@Environment` no `init` da View:
```swift
init(subscenario: Subscenario, progressService: ProgressService) {
    self.subscenario = subscenario
    _viewModel = State(initialValue: ScenarioViewModel(progressService: progressService))
}
```
Isso elimina o optional e unifica em um padrão único.

### 17. Mover mapeamento de assets para JSON
**Arquivo:** `Components/ChatStyling.swift`
`vendorIconName(for:)` e `headerImageName(for:)` têm switches hardcoded por `scriptName`. Adicionar campos `vendorIcon` e `headerImage` em `Subscenario` (vendorIcon já existe) e popular via JSON. Eliminar os switches.

### 18. Resolver TODOs prioritários
**Arquivo:** `ViewModels/AuthViewModel.swift` (linha ~68)
**Crítico para lançamento:** migração de progresso `guest → conta`. Usuário que pratica como guest e depois faz Sign In with Apple perde todo o progresso.

Outros TODOs (menores):
- `ScenarioViewModel.swift:67` — penalidade por escolhas incorretas
- `ProfileSetupViewModel.swift:55` — moderação de nickname
- `SpeechService.swift:10` — controle de velocidade de fala

### 19. Reutilizar PageDotsView
**Arquivos:** `OnboardingView`, `IntroOverlayView`
Ambas duplicam o componente de page dots + lógica de avanço por tap. Extrair `PageDotsView` reutilizável.

### 20. Normalizar nomes de assets
**Pasta:** `Assets.xcassets`
Hoje convivem 4 convenções: PascalCase PT (`BarracaFundo`), PascalCase EN (`CristoPose`), snake_case EN (`menu_background`), lowercase misto (`telaWelcome`). Padronizar para uma convenção única.

### 21. Deduplicar PremiumView e HomeView
**Arquivos:** `Views/Premium/PremiumView.swift`, `Views/Home/HomeView.swift`
Bloco de estados (loading/empty/error/lista) duplicado. Extrair `ScenarioListContainer` ou `@ViewBuilder` compartilhado.

### 22. Documentar checklist "Como adicionar um novo cenário"
**Onde:** `CLAUDE.md` ou novo `docs/ADDING-SCENARIOS.md`
Hoje o processo exige 5 passos não documentados:
1. Criar JSON do script em `Resources/scripts/`
2. Registrar em `scenarios.json`
3. Criar Persona em `personas.json` (se for AI chat)
4. Adicionar assets de imagem no xcassets
5. Atualizar `ChatStyling` (eliminado quando #17 for feito)

---

## 📊 Resumo de Esforço Estimado

| Sprint | Itens | Esforço | Prioridade |
|---|---|---|---|
| Sprint 1 — A11Y restante | 4 | ~3h | 🔴 Alta — bloqueante para App Store review séria |
| Sprint 2 — HIG e visual | 5 | ~4h | 🟡 Média — qualidade percebida |
| Sprint 3 — UX polish | 6 | ~3h | 🟢 Baixa — melhoria incremental |
| Sprint 4 — Arquitetura | 7 | ~5h | ⚙️ Maintenance — antes de novo dev pegar |
| **Total** | **22** | **~15h** | |

---

## 🎯 Recomendação de ordem

**Se vai entregar/postar agora:** Sprint 1 + UX-005 (PremiumGateView ScrollView) e UX-003 (texto PT na tela final).

**Se tem mais 1 semana:** Sprints 1 + 2 + UX-005.

**Se for passar pra outra pessoa:** Sprints 1 + 4 (arquitetura prepara o handoff).

**Se for produto comercial sério:** todos os 4 sprints + revisão de testes (ainda não há cobertura significativa).
