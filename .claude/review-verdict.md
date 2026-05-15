# Veredicto de Revisão
Data: 2026-05-15
Documento avaliado: .claude/dev-commands.md
Revisão: 1 de 3

## Veredicto: APPROVE

Os comandos estão claros, acionáveis e alinhados ao contexto fechado: a IA premium já existe com Apple Foundation Models on-device; o escopo é discoverability/navegação premium dentro da `TabView` autenticada, com renomeação de `Home` para `Scenarios`. Nenhum hard reject foi encontrado.

---

## Pontuação Geral

| Critério | Score | Justificativa |
|----------|-------|---------------|
| Títulos | 10/10 | Todos começam com verbo imperativo (`Implemente`, `Refatore`, `Renomeie`) e descrevem o componente afetado. Não há bugs, então prioridade em título não se aplica. |
| Contextos | 9/10 | Os comandos citam arquivos reais, comportamento atual, comportamento esperado e dependências do AI Chat premium já implementado. O único desconto é que `PremiumView` poderia explicitar melhor a origem dos dados/loading state. |
| Ações | 8/10 | As ações são executáveis e bem delimitadas. O desconto vem da formulação de IMP-001 sobre "closures para abrir `ScenarioView` ou `AIChatEntryView`", que pode ser interpretada de mais de uma forma em SwiftUI. |
| Critérios de aceite | 9/10 | Os critérios são mensuráveis e cobrem ordem das abas, filtro premium, sheet, regressão de Profile e compilação. Poderiam incluir explicitamente estados de loading/erro da aba Premium. |
| Restrições | 10/10 | Restrições fortes impedem troca de provider de IA, backend, paywall, duplicação integral da Home e mudanças fora de escopo. |
| Completude (bugs) | N/A | O documento declara que não há bugs classificados; os comandos são feature/improvements. |
| **Média** | **9.2/10** | |

---

## Avaliação por Comando

### FEAT-001: Implemente a aba Premium na TabView autenticada existente
- **Score**: 9/10
- **Strength**: O comando delimita corretamente a superfície nova: `PremiumView` dentro de `AuthenticatedTabView`, entre `Scenarios` e `Profile`, sem criar rota paralela, backend, paywall ou nova arquitetura de IA.
- **Risk**: A ação presume que IMP-001 já definiu a composição compartilhada, mas não explicita se `PremiumView` deve instanciar seu próprio `HomeViewModel` e replicar loading/error handling da Home. Um dev pode implementar a lista feliz e esquecer estados de carregamento/erro.
- **Required change**: Nenhuma.
- **Suggestion (non-blocking)**: Adicionar um item de aceite dizendo que `PremiumView` reutiliza o carregamento de cenários via `HomeViewModel` ou outro mecanismo existente, preservando estados de loading, erro e vazio sem duplicar lógica pesada.

### IMP-001: Refatore a composição da Home para reutilizar a listagem com filtro premium
- **Score**: 8/10
- **Strength**: É o comando mais importante do pacote e identifica corretamente a causa estrutural: `ScenarioSection` e `SubscenarioCard` estão `private`, então duplicar a Home seria o caminho errado.
- **Risk**: A frase "closures para abrir `ScenarioView` ou `AIChatEntryView`" deixa margem técnica. Em SwiftUI, a navegação atual para `ScenarioView` usa `NavigationLink(value:)` com `.navigationDestination(for:)`, enquanto o chat premium usa estado local + `.sheet(item:)`. Se o dev tentar encapsular tudo em closures genéricas dentro de `ScenarioListView`, pode criar acoplamento ou quebrar a navegação por valor.
- **Required change**: Nenhuma.
- **Suggestion (non-blocking)**: Especificar a assinatura esperada em termos de responsabilidade, por exemplo: `ScenarioListView` renderiza seções/cards e recebe `onPremiumTap(Subscenario)`, enquanto a navegação gratuita continua por `NavigationLink(value:)` e o estado do sheet permanece em `HomeView`/`PremiumView`.
- **Suggestion (non-blocking)**: Declarar que os componentes extraídos devem deixar de ser `private` apenas no nível necessário para reutilização no módulo, sem expor API pública desnecessária.

### IMP-002: Renomeie a aba Home para Scenarios na TabBar
- **Score**: 10/10
- **Strength**: Comando cirúrgico, sem ambiguidade: muda somente o label visível da primeira aba, preservando `HomeView`, `NavigationStack`, título de navegação e aba `Profile`.
- **Risk**: Baixo. A única dependência é a ordem de execução, porque FEAT-001 espera a primeira aba já nomeada como `Scenarios`.
- **Required change**: Nenhuma.
- **Suggestion (non-blocking)**: Nenhuma.

---

## Riscos de Regressão e Ambiguidades de Escopo

- A maior regressão possível é quebrar a navegação gratuita ao extrair `ScenarioSection`/`SubscenarioCard`; os critérios de aceite cobrem isso, mas IMP-001 deveria ser implementado com atenção ao padrão atual de `NavigationLink(value:)`.
- A aba Premium deve filtrar exatamente `isLocked == true && scriptName.isEmpty`. Qualquer tentativa de inferir premium por título, ícone, persona existente ou serviço de assinatura violaria o escopo.
- O documento acerta ao bloquear mudanças em `AIChatView`, `AIChatEntryView`, serviços de IA, `PersonaRepository`, provider e backend. Esse limite é essencial para não transformar discoverability em refatoração de IA.
- A ordem `IMP-002 -> IMP-001 -> FEAT-001` é aceitável. A dependência real é `FEAT-001` após `IMP-001`; `IMP-002` é independente, mas executá-lo primeiro reduz conflito sem risco.

---

## Sugestões gerais (non-blocking)

- Incluir um critério explícito para `PremiumView` preservar estados de loading/erro/vazio ao carregar cenários.
- Tornar mais concreta a responsabilidade de `ScenarioListView`: renderização compartilhada e callback para premium, sem assumir controle total da navegação da árvore.
- Manter previews das novas views com os mesmos environments usados por `AuthenticatedTabView`/`HomeView`, para capturar cedo falhas de dependência.
