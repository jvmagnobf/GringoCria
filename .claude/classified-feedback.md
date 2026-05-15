# Feedback Classificado
Data: 2026-05-13
Total de feedbacks recebidos: 1 (requisito técnico com 4 superfícies afetadas)
Itens gerados: 4

---

## Bugs (0 itens)

Nenhum bug identificado. O requisito descreve expansão deliberada de comportamento e substituição de conteúdo, não falha no funcionamento atual.

---

## Feature Requests (0 itens)

Nenhum.

---

## Improvements (4 itens)

### IMP-004: Adicionar `vendorVariation`, `auto` e campo `vendorVariations` ao modelo `ScriptStep`

- **Componente/Tela**: `GringoCria/Models/ScriptStep.swift`
- **Estado atual**: `StepType` tem apenas dois cases — `message` e `choice`. `ScriptStep` não tem campo para variações de texto do vendedor. `ChoiceOption` não tem `nextStepId` para ramificação condicional.
- **Melhoria sugerida**:

  **1. Novo case `vendorVariation` em `StepType`**
  Representa um turno do vendedor em que o app sorteia uma das variações antes de exibir. É semanticamente distinto de `message` (texto fixo) e precisa de case próprio para que o ViewModel possa tratá-lo diferentemente.

  **2. Novo case `auto` em `StepType`**
  O contexto do prompt diz que `auto` já existe — mas o arquivo atual (linha 15–18) mostra apenas `message` e `choice`. O case precisa ser adicionado. Representa um turno do cliente que avança sem interação do usuário (ação física narrada).

  **3. Novo campo `vendorVariations: [String]?` em `ScriptStep`**
  Armazena as variações candidatas ao sorteio. Manter separado de `choices` é correto: `choices` é sempre uma lista de opções para o cliente interagir; `vendorVariations` é uma lista de candidatos internos do vendedor. Misturar os dois no mesmo campo quebraria a semântica e dificultaria a leitura do JSON.

  **4. Novo campo `nextStepId: UUID?` em `ChoiceOption`**
  Necessário para que o step 6 aponte para destinos diferentes dependendo da escolha. Quando `nil`, o comportamento padrão (próximo step na sequência) é mantido — compatível com todos os steps existentes e futuros que sejam lineares.

- **Decisão de produto já tomada**: campo `vendorVariations` separado de `choices`, conforme enunciado. Não questionar.
- **Info faltante**:
  - `isCorrect` em `ChoiceOption`: o modelo atual tem o campo mas o novo script não define respostas certas/erradas. Dev decide se todas as novas choices recebem `isCorrect: true`, `false` ou `null`. Isso afeta qualquer lógica de penalidade futura referenciada no TODO na linha 41 do ViewModel.
  - Tratamento de `vendorVariations` vazio ou nulo em tempo de decodificação: o campo é opcional, mas o ViewModel precisa saber o que fazer se um step do tipo `vendorVariation` vier sem o campo preenchido (fallback para string vazia, log de aviso, ou `preconditionFailure` em debug).

---

### IMP-005: Reescrever `matte.json` com os 9–11 steps, UUIDs fixos, `vendorVariations`, `nextStepId` e traduções EN

- **Componente/Tela**: `GringoCria/Resources/scripts/matte.json`
- **Estado atual**: Script de 6 steps lineares, sem variação do vendedor, sem ramificação, sem perguntas de sabor, sem steps de ação física. A segunda choice do step 2 ("Ou do Matte!!") já existe no novo script — manter UUID ou gerar novo.
- **Melhoria sugerida**: Substituição completa do arquivo com a seguinte estrutura:

  | # | Speaker | Tipo | Conteúdo PT |
  |---|---------|------|-------------|
  | 1 | vendor | `message` | "Olha o Matte!!! Olha o Matte!!!" |
  | 2 | customer | `choice` | 2 choices: ação física + frase |
  | 3 | vendor | `vendorVariation` | 3 variações: "Fala chefe" / "Fala tu" / "" (silêncio) |
  | 4 | customer | `choice` | 3 choices: formas de perguntar preço |
  | 5 | vendor | `message` | "Tem de 12 e tem o 15" |
  | 6 | customer | `choice` com `nextStepId` | 4 choices com destinos diferentes |
  | 6a | vendor | `message` condicional | "Sim" |
  | 6b | customer | `choice` condicional | 2 choices: preço |
  | 7 | vendor | `message` | "Aceito pix, dinheiro ou cartão" |
  | 8 | customer | `auto` | "*Paga o matte*" |
  | 9 | customer | `auto` | "*Estica o copo...*" |

  **Choices com traduções EN completas:**

  Step 2:
  - PT: "*Faz sinal para chamar o vendedor*" / EN: "Waves to get the vendor's attention"
  - PT: "Ou do Matte!!" / EN: "Hey, Mate!!"

  Step 4:
  - PT: "Coé ta quanto aí?" / EN: "Hey, how much is it?"
  - PT: "E aí paizão ta quanto o matte?" / EN: "Hey man, how much is the mate?"
  - PT: "Fala paizão vê um matte" / EN: "What's up man, hook me up with a mate"

  Step 6 (com `nextStepId`):
  - PT: "Tem maracujá e limão?" / EN: "Do you have passion fruit and lime?" → `nextStepId`: UUID do step 6a
  - PT: "Tem sem açúcar?" / EN: "Do you have it without sugar?" → `nextStepId`: UUID do step 6a
  - PT: "Quero o de 12" / EN: "I'll take the R$12 one" → `nextStepId`: UUID do step 7
  - PT: "Quero o de 15" / EN: "I'll take the R$15 one" → `nextStepId`: UUID do step 7

  Step 6b:
  - PT: "Quero o de 12" / EN: "I'll take the R$12 one"
  - PT: "Quero o de 15" / EN: "I'll take the R$15 one"

  Step 8: PT: "*Paga o matte*" / EN: "Pays for the mate"
  Step 9: PT: "*Estica o copo para botar o matte e escolhe se quer limão ou maracujá ou sem açúcar*" / EN: "Extends the cup to receive the mate and picks lime, passion fruit, or no sugar"

- **Info faltante**:
  - UUIDs definitivos: gerar com `uuidgen` antes de commitar. Nunca reutilizar os UUIDs do script atual — os steps têm estrutura completamente diferente e reutilizar causaria risco de colisão em futuras features de analytics ou histórico.
  - O silêncio do vendedor no step 3 é representado como `""` (string vazia) dentro de `vendorVariations`. Confirmar com autor se o array fica `["Fala chefe", "Fala tu", ""]` ou se o step silencioso usa outro mecanismo (ex.: `null` no array).
  - Steps 6a e 6b são condicionais — existem no JSON mas o ViewModel precisa saber ignorá-los no fluxo linear (só chegam a eles via `nextStepId`). Confirmar como o JSON organiza esses steps: inline na sequência numerada (e o ViewModel pula por ID) ou em uma seção separada de steps auxiliares.

---

### IMP-006: Atualizar `ScenarioViewModel` para suportar variação aleatória, step silencioso, ramificação por `nextStepId` e auto-avanço

- **Componente/Tela**: `GringoCria/ViewModels/ScenarioViewModel.swift`
- **Estado atual**: Avanço estritamente linear por `currentIndex`. `revealNextVendorMessage()` usa loop `while` que quebra em qualquer step que não seja `message` do vendor. `selectChoice(_:)` faz `currentIndex += 1` sem verificar `nextStepId`. `currentChoices` filtra por `step.type == .choice`.
- **Melhoria sugerida**: Quatro mudanças independentes, listadas por ordem de impacto:

  **a) Sorteio de `vendorVariation` (dentro de `revealNextVendorMessage`)**
  Detectar `step.type == .vendorVariation`, sortear índice aleatório em `step.vendorVariations`, construir `ScriptStep` efêmero com UUID novo (padrão já estabelecido na linha 51 para evitar `Duplicate ID` em `ForEach`), appender em `revealedSteps`, incrementar `currentIndex`, continuar o loop.

  **b) Step silencioso (extensão do caso acima)**
  Se a variação sorteada for `""`, não appender nenhum `ScriptStep` em `revealedSteps` — apenas incrementar `currentIndex` e continuar o loop. A View não exibe balão algum.

  **c) Auto-avanço do cliente (`auto`)**
  Dentro do mesmo `while`, detectar `step.type == .auto`, appender o step diretamente em `revealedSteps` (sem sortear, sem botão), aplicar `Task.sleep` de 1.2s (mesmo delay já usado para mensagens do vendor na linha 96), incrementar `currentIndex`, continuar o loop.

  **d) Navegação por `nextStepId` em `selectChoice(_:)`**
  Após exibir a choice selecionada, verificar se `choice.nextStepId != nil`. Se sim, encontrar o índice do step com esse ID em `steps` e atribuir a `currentIndex`. Se não, manter o comportamento atual (`currentIndex += 1`). A busca é `steps.firstIndex(where: { $0.id == nextStepId })` — O(n) sobre um array pequeno, aceitável.

  **`currentChoices`**: nenhuma alteração necessária. Já filtra `step.type == .choice` — não exibe botões para `vendorVariation` nem `auto`.

- **Risco arquitetural — troca de navegacao linear por ID:**

  A mudança em `selectChoice(_:)` é cirúrgica quando `nextStepId` está presente — apenas a resolução do índice muda, não a estrutura do loop nem o contrato do ViewModel. Porém há três pontos de atenção que o dev deve verificar antes de implementar:

  1. **`isCompleted` usa `currentIndex >= steps.count` (linha 103).** Com navegação por ID, um `nextStepId` apontando para um step fora da sequência linear nunca incrementará `currentIndex` além do último elemento de forma previsível. O dev deve auditar se `isCompleted` continua sendo acionado corretamente após a última choice ramificada. Uma alternativa mais robusta é marcar um step como `isTerminal: Bool` no modelo e usar isso como condição de conclusão.

  2. **Steps condicionais (6a, 6b) devem ser alcançáveis apenas por `nextStepId`, nunca por incremento sequencial.** Se esses steps ficarem inline no array `steps`, o loop `while` de `revealNextVendorMessage` pode alcançá-los acidentalmente após o step 6 caso o dev esqueça de ajustar o fluxo. Mitigação: garantir que o JSON posicione os steps condicionais após o step 7 no array (fora do caminho linear), ou marcar o step 6 com `type: "choice"` para que o loop quebre antes de avançar.

  3. **`revealNextVendorMessage` usa `currentIndex` para iterar.** Após `selectChoice` definir `currentIndex` via ID lookup, o loop recomeça do índice correto — isso é seguro. Mas se dois paths diferentes convergirem no mesmo step 7 (como o script define), o índice resolvido para o step 7 deve ser idêntico nos dois casos, o que é garantido porque o UUID é fixo no JSON. Não há risco aqui desde que os UUIDs não sejam gerados em runtime.

- **Info faltante**:
  - Delay dos steps `auto`: o enunciado sugere 1.2s (mesmo delay do vendor). Confirmar se é o mesmo valor ou se produto quer delay diferente para ações físicas do cliente.
  - Estilo visual dos steps `auto` na View: em itálico? Com cor diferente? O ViewModel já expõe o tipo via `revealedSteps` — a View pode ler `step.type` diretamente. Mas se houver estilo especial, a View precisa saber tratar `auto` antes de o ViewModel ser entregue.
  - Tratamento de `nextStepId` que não encontra match no array: log silencioso e fallback para `currentIndex += 1`, ou crash em debug via `preconditionFailure`?

---

### IMP-007: Adicionar traduções EN para todas as falas e choices do novo script do Matte

- **Componente/Tela**: `GringoCria/Resources/scripts/matte.json` (campo `translationEN` nos steps e `translationEN` nas choices)
- **Estado atual**: O script atual tem `translationEN` em todos os steps e choices, mas o conteúdo está desatualizado — as falas do novo script são diferentes e as choices adicionadas (sabores, ramificação) não existem.
- **Melhoria sugerida**: Garantir que todos os 9–11 steps e todas as choices do novo script tenham `translationEN` preenchido antes do commit. Os textos EN sugeridos estão listados no IMP-005. Atenção especial para:
  - Steps `auto` de cliente: a tradução deve preservar o tom de narração de ação física (ex.: "Pays for the mate", não "Pay for the mate").
  - Choices em gíria carioca: as traduções devem ser naturais em inglês, não literais. "Coé ta quanto aí?" não é "What is it worth there?" — é "Hey, how much is it?". Revisar com falante nativo ou autor do conteúdo antes de publicar.
  - Variações do vendedor no step 3: `vendorVariations` é um array de strings — definir se as traduções ficam em um campo paralelo `vendorVariationsEN: [String]?` ou se cada variação é um objeto `{ textPT, translationEN }`. Essa decisão afeta o modelo (IMP-004) e o JSON (IMP-005).

- **Info faltante**:
  - Estrutura das traduções para `vendorVariations`: strings paralelas ou objetos? Bloqueia IMP-004 e IMP-005.
  - Revisão humana das traduções de gíria — não é bloqueante para desenvolvimento mas é bloqueante para QA de conteúdo.

---

## Duplicatas

IMP-004, IMP-005, IMP-006 e IMP-007 são a mesma iniciativa de produto vista por quatro superfícies técnicas distintas. Não são duplicatas entre si — cada item descreve um arquivo diferente com mudanças independentes. Um dev pode implementar IMP-004 sem tocar IMP-006, por exemplo.

IMP-004 a IMP-007 não têm sobreposição com IMP-001, IMP-002 (idioma da interface, sessão anterior) nem com IMP-003 (classificação anterior que tratava uma versão menos detalhada do mesmo requisito e agora é substituída por estes quatro itens).

---

## Itens de Suporte (não geram tarefas de dev)

Nenhum.

---

## Ordem de implementação sugerida

1. **IMP-004 primeiro** — a decisão sobre `vendorVariationsEN` (strings paralelas vs. objetos) desbloqueia IMP-005 e IMP-007. A decisão sobre `nextStepId` desbloqueia IMP-006.
2. **IMP-005 em paralelo com IMP-006** — uma vez que o modelo está definido, JSON e ViewModel podem ser desenvolvidos simultaneamente.
3. **IMP-007 junto com IMP-005** — as traduções são parte do JSON, não um passo separado.
4. Testar fluxo completo: path linear (step 6 → step 7 direto), path com ramificação (step 6 → 6a → 6b → 7), variação do vendedor no step 3, step silencioso, e auto-avanço dos steps 8 e 9.
