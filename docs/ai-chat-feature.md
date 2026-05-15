# AI Chat — Documentação da Feature

**App:** GringoCria
**Data:** 15/05/2026
**Autor:** João Victor Magno

---

## Visão Geral

A feature de AI Chat adiciona ao GringoCria a capacidade de conversação livre com personagens cariocas gerados por inteligência artificial on-device. Diferente dos cenários com scripts pré-definidos já existentes, o AI Chat permite que o estudante escreva livremente em português, receba respostas naturais do personagem e obtenha feedback linguístico imediato sobre o que escreveu — tudo sem que nenhum dado saia do dispositivo.

A primeira persona implementada é **Seu Zé**, mateiro veterano da praia de Ipanema, que vende matte gelado, água de coco e açaí. O personagem responde exclusivamente em português brasileiro informal carioca e, se o usuário escrever em inglês, "finge não entender".

O acesso ao AI Chat está estruturado como conteúdo premium (IAP non-consumable `com.gringocria.premium.ai`), mas o paywall está desabilitado durante o desenvolvimento.

---

## Arquitetura

### Framework de IA

A feature usa o **Apple FoundationModels** (iOS 26+), que executa o modelo de linguagem diretamente no dispositivo via Apple Intelligence. Não há chamada de rede, não há API key, e o histórico da conversa não é persistido entre sessões.

### Duas sessões de LanguageModelSession

O núcleo da implementação opera com duas sessões independentes criadas em `AIPersonaService`:

```
Usuário digita mensagem
        |
        |-- async let --> [Persona Session]    --> resposta do personagem (PT-BR)
        |                 LanguageModelSession
        |                 instruída com systemPrompt do personagem
        |
        |-- async let --> [Evaluator Session]  --> MessageFeedback (structured output)
                          LanguageModelSession
                          instruída como coach de português carioca
```

As duas chamadas são disparadas em paralelo com `async let` em `AIChatViewModel.send(_:persona:)`. A resposta do personagem e o feedback chegam independentemente; o feedback é anexado à mensagem do usuário assim que disponível.

### Tratamento de context window

Quando a `LanguageModelSession` lança `GenerationError.exceededContextWindowSize`, o serviço recria a sessão automaticamente e reenvia a mensagem. Isso acontece nas duas sessões (persona e avaliador) de forma independente. O histórico da conversa visível na tela não é afetado — apenas a janela de contexto do modelo é reiniciada.

### Structured Output com @Generable

O feedback linguístico usa a macro `@Generable` do FoundationModels para garantir que o modelo retorne um objeto Swift tipado em vez de texto livre:

```swift
@Generable(description: "Portuguese language feedback for a learner's message")
struct MessageFeedback {
    @Guide(description: "How natural the message sounds in Carioca context, 0-10")
    var contextScore: Int

    @Guide(description: "Grammar correctness score, 0-10")
    var grammarScore: Int

    @Guide(description: "The user's message corrected, or same if already correct")
    var correctedMessage: String

    @Guide(description: "Brief explanation in English of what was corrected and why")
    var explanationEN: String

    @Guide(description: "Whether the message feels authentically Carioca")
    var feelsCarioca: Bool

    @Guide(description: "Up to 2 nicer/more natural alternatives the user could have said")
    var nicerAlternatives: [String]
}
```

A chamada correspondente no `AIPersonaService`:

```swift
let response = try await session.respond(to: prompt, generating: MessageFeedback.self)
```

### Injeção de dependência via SwiftUI Environment

Os três novos services são instanciados como `@State` em `GringoCriaApp` e injetados via `.environment(_:)` para toda a árvore de views:

```
GringoCriaApp
  ├── AIAvailabilityService   (@Observable, @MainActor)
  ├── AIPersonaService        (@Observable, @MainActor)
  └── PremiumService          (@Observable, @MainActor)
```

---

## Fluxo de Navegação

```
HomeView
  └── card com isLocked: true (ícone wand.and.sparkles azul)
        |
        v (sheet)
  AIChatEntryView
        |
        |-- PersonaRepository.persona(for: subscenario) encontrou persona?
        |
        |-- sim --> AIChatView (chat livre com Seu Zé)
        |
        └-- não --> "Coming Soon" (personagem em desenvolvimento)
```

No `AIChatView`, ao aparecer (`.task`), o ViewModel chama `start(persona:)`, que:
1. Chama `AIPersonaService.setup(persona:)` para criar as duas sessões
2. Adiciona a `openingLine` do personagem como primeira mensagem na tela

---

## Arquivos

### Models

| Arquivo | Responsabilidade |
|---------|-----------------|
| `Models/Persona.swift` | Modelo do personagem: `id`, `subscenarioId`, `nameEN`, `namePT`, `systemPrompt`, `openingLine`, `openingLineEN` |
| `Models/MessageFeedback.swift` | Struct `@Generable` com os 6 campos de feedback linguístico |

### Resources

| Arquivo | Conteúdo |
|---------|----------|
| `Resources/personas.json` | Array de personas; contém atualmente "Seu Zé" (mateiro de Ipanema), com `subscenarioId: A2000001-0000-0000-0000-000000000001` |
| `Resources/scenarios.json` | Atualizado com subscenário "AI Mate Chat" (`isLocked: true`, `scriptName` vazio) |

### Services

| Arquivo | Responsabilidade |
|---------|-----------------|
| `Services/PersonaRepository.swift` | Carrega `personas.json` do bundle; lookup de persona por `subscenarioId`. Struct sem estado — sem injeção de dependência necessária |
| `Services/AIAvailabilityService.swift` | Verifica `SystemLanguageModel.default.availability` e expõe um `AIAvailabilityState` com 5 casos |
| `Services/AIPersonaService.swift` | Cria e gerencia as duas `LanguageModelSession`; trata `exceededContextWindowSize`; expõe `sendMessage` e `evaluateMessage`; limpa sessões no `reset()` |
| `Services/PremiumService.swift` | StoreKit 2, IAP non-consumable (`com.gringocria.premium.ai`); `purchase()`, `restore()`, `checkEntitlements()` |

### ViewModels

| Arquivo | Responsabilidade |
|---------|-----------------|
| `ViewModels/AIChatViewModel.swift` | Lista de `ChatMessage` (com `feedback` opcional), flag `isTyping`, disparo paralelo de `send` + `evaluate`, tratamento de erros inline |

### Views

| Arquivo | Responsabilidade |
|---------|-----------------|
| `Views/AI/AIChatEntryView.swift` | Roteador: carrega persona pelo subscenário e decide entre `AIChatView` ou tela "Coming Soon" |
| `Views/AI/AIChatView.swift` | UI do chat: bolhas do usuário (direita, azul) e do personagem (esquerda, cinza), barra de input com `TextField` multiline, typing indicator animado |
| `Views/AI/FeedbackBubble.swift` | Card colapsável com pills de score (verde >=7, amarelo 4-6, vermelho <4), correção em laranja, badge "Feels Carioca!", alternativas |
| `Views/AI/PremiumGateView.swift` | Paywall (não ativo): exibe features, requisitos de device, botões Buy e Restore |

### Arquivos atualizados

| Arquivo | Alteração |
|---------|-----------|
| `GringoCriaApp.swift` | Instancia e injeta `AIAvailabilityService`, `AIPersonaService` e `PremiumService` |
| `Views/Home/HomeView.swift` | Cards com `isLocked: true` abrem sheet com `AIChatEntryView`; ícone `wand.and.sparkles` azul identifica subscenários AI |

---

## Estados de disponibilidade do Apple Intelligence

`AIAvailabilityService` mapeia a resposta do framework para o enum `AIAvailabilityState`:

| Estado | Significado |
|--------|-------------|
| `checking` | Verificação em andamento (estado inicial) |
| `available` | Apple Intelligence disponível e pronto |
| `deviceNotEligible` | Hardware incompatível |
| `appleIntelligenceNotEnabled` | Recurso desabilitado nas configurações do sistema |
| `modelNotReady` | Modelo ainda sendo baixado ou instalado |
| `unknown(String)` | Estado inesperado retornado pelo framework |

A verificação é feita na inicialização do service e pode ser repetida manualmente via `check()`.

---

## Persona: Seu Zé

A primeira (e atualmente única) persona do sistema:

- **Nome:** Seu Zé
- **Cenário:** Mateiro de Ipanema, 55 anos, 20+ anos de praia
- **Subscenário vinculado:** AI Mate Chat (`A2000001-0000-0000-0000-000000000001`)
- **Linha de abertura:** "Oi, tudo bem? Matte geladinho, ó! Com limão espremido na hora. Quer um?"
- **Comportamento:** Responde apenas em português, usa expressões cariocas típicas, rejeita inglês fingindo não entender

O `systemPrompt` completo está em `personas.json` e é passado diretamente como `instructions` para a `LanguageModelSession`. Para adicionar um novo personagem, basta adicionar uma entrada ao JSON e garantir que o `subscenarioId` corresponda a um subscenário existente em `scenarios.json`.

---

## Decisões Técnicas

### On-device em vez de API externa

O Apple FoundationModels processa tudo localmente. As consequências práticas: sem latência de rede, sem custo por requisição, funciona offline, e nenhum texto digitado pelo usuário sai do dispositivo. A contra-partida é a dependência de hardware específico (iPhone 15 Pro ou mais novo) e iOS 26+.

### Duas sessões separadas em vez de uma

Usar a mesma sessão para o personagem e para o avaliador poderia contaminar o contexto — o modelo poderia "sair do personagem" ao produzir feedback técnico. Sessões separadas mantêm os papéis isolados.

### Avaliação em paralelo com a resposta

O feedback não depende da resposta do personagem para ser gerado (a avaliação é sobre a mensagem do usuário, não sobre a resposta). Disparar os dois em paralelo com `async let` reduz o tempo total de espera percebido pelo usuário.

### Sem persistência de histórico

O histórico de conversa existe apenas em memória durante a sessão. Ao fechar o chat (`reset()`), tudo é descartado. Isso simplifica a implementação e está alinhado com a proposta de privacidade do on-device: sem armazenamento de conversas.

### Paywall presente mas desabilitado

`PremiumService` está completo com StoreKit 2, mas a verificação de `isPremium` não bloqueia o acesso ao chat ainda. A decisão foi manter o gate desabilitado durante o desenvolvimento para facilitar testes, com a intenção de ativar antes do lançamento.

### PersonaRepository como struct, não @Observable

O repositório é stateless — carrega o JSON uma vez no `init` e expõe apenas leitura. Não precisa de injeção de dependência e pode ser instanciado diretamente onde for necessário (`AIChatEntryView` o instancia localmente).

---

## Requisitos de Device

Para que o AI Chat funcione:

- iPhone 15 Pro, iPhone 15 Pro Max, ou qualquer modelo mais novo
- iPad com chip M1 ou mais recente
- iOS 26 ou superior
- Apple Intelligence habilitado em Configuracoes > Apple Intelligence e Siri

Dispositivos sem suporte verão o estado `deviceNotEligible` ou `appleIntelligenceNotEnabled` em `AIAvailabilityService`.

---

## Proximos Passos

- Ativar o paywall (`PremiumGateView`) antes do lançamento, conectando `AIAvailabilityService.state` e `PremiumService.isPremium` ao roteamento em `AIChatEntryView`
- Adicionar novas personas para outros subscenarios (ex: vendedora de Biscoito Globo, atendente de boteco)
- Exibir o estado de `AIAvailabilityService` ao usuario quando o Apple Intelligence nao estiver disponivel, com instrucoes para habilitar
- Considerar contexto do perfil do usuario (nome, nivel de portugues) no `systemPrompt` para respostas mais personalizadas
- Avaliar suporte a entrada por voz via `SpeechService` (ja existente no app) para complementar o input de texto
- Investigar se vale a pena persistir o historico de sessoes anteriores para o usuario acompanhar sua evolucao
