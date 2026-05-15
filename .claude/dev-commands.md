# Comandos de Desenvolvimento
Data: 2026-05-13
Baseado em: .claude/classified-feedback.md
Total de comandos: 7

---

> Ordem de execução recomendada por dependência:
> FEAT-001 -> IMP-001 e IMP-002.
>
> Justificativa: a nova navegação autenticada via `TabView` deve ser estabelecida primeiro, para que a `ProfileView` já nasça no fluxo definitivo e com copy em inglês. As mudanças de idioma podem ser feitas em paralelo depois que a estrutura de tabs estiver definida.
>
> IMP-004 -> (IMP-005 + IMP-007) -> IMP-006.
>
> Justificativa: o modelo (`ScriptStep.swift`) deve ser atualizado antes de criar o JSON, pois os novos campos precisam existir para o decoder aceitar o arquivo. O ViewModel pode ser desenvolvido em paralelo ao JSON após o modelo estar definido, mas deve ser testado contra o JSON final.

---

## Bugs

Nenhum bug classificado em `.claude/classified-feedback.md`.

---

## Features

### FEAT-001: Implemente uma navegação autenticada com TabView incluindo Home e Profile
**Ref**: Feedback original #1

**Contexto**:
O app GringoCria já possui `ProfileSetupView` em `GringoCria/Views/Profile/ProfileSetupView.swift`, mas essa view pertence ao onboarding e é exibida apenas quando `AppState.authState == .firstAccess`. Usuários autenticados entram diretamente em `HomeView` via `AppRouter`, sem uma tela persistente para consultar ou editar dados de perfil depois do primeiro acesso. O perfil existente usa nickname salvo em `UserDefaultsKey.userNickname` e foto local em `Documents/profile_photo.jpg`.

**Comportamento atual**:
Depois que `ProfileSetupViewModel.saveDone()` define `appState.authState = .authenticated`, o usuário passa a ver apenas `HomeView`. Não existe uma navegação principal persistente entre áreas autenticadas do app. Reabrir ou editar nickname/foto exige reutilizar mentalmente um fluxo de onboarding que não está acessível como tela de perfil.

**Comportamento esperado**:
Usuários autenticados entram em uma navegação principal baseada em `TabView`, com pelo menos duas abas: `Home` e `Profile`. A aba `Profile` permite visualizar nickname e foto atuais, editar esses dados e salvar sem alterar o estado de autenticação nem refazer onboarding.

**Passos para reproduzir**:
1. Inicie o app em estado `.unauthenticated`.
2. Entre com Sign in with Apple ou continue como guest.
3. Complete a `ProfileSetupView` tocando em `Done`.
4. Observe que a área autenticada mostra apenas `HomeView`, sem uma estrutura de tabs nem uma tela de `Profile` persistente.

**Ação**:
Crie `GringoCria/Views/Profile/ProfileView.swift` e substitua a entrada autenticada única por uma área autenticada baseada em `TabView`. A `TabView` deve conter no mínimo duas abas estáveis: `Home` e `Profile`, com ícones apropriados de sistema e labels em inglês. `AppRouter` deve enviar usuários em `.authenticated` para essa área autenticada com tabs, e não mais para `HomeView` isolada. Extraia a lógica compartilhada de nickname e foto para um serviço ou view model reutilizável, evitando depender de `ProfileSetupViewModel.saveDone()`. A `ProfileView` deve carregar a foto salva em `Documents/profile_photo.jpg`, carregar o nickname de `UserDefaultsKey.userNickname`, permitir alterar foto via galeria/câmera usando o padrão já existente em `ProfileSetupView`, validar nickname com a mesma regra atual e salvar sem modificar `appState.authState`. Preserve a navegação existente de `HomeView` para `ScenarioView` dentro da aba Home, encapsulando essa aba em `NavigationStack` se necessário.

**Restrições**:
- Não trate `ProfileSetupView` como substituta da nova `ProfileView`.
- Não chame `ProfileSetupViewModel.saveDone()` a partir da tela persistente de perfil.
- Não altere o fluxo de onboarding: `ProfileSetupView` continua responsável por concluir o primeiro acesso.
- Não mude as chaves de persistência existentes para nickname e foto sem migração explícita.
- Não implemente a entrada de perfil via `ToolbarItem`, menu lateral, sheet ou push avulso de navegação; a navegação autenticada deve ser `TabView`.
- Não implemente logout, progresso de cenários, badges, estatísticas ou sincronização iCloud/backend nesta tarefa.
- Não quebre a navegação existente de `HomeView` para `ScenarioView` ao mover `HomeView` para dentro da aba correspondente.

**Critério de aceite**:
- [ ] Usuário em `.authenticated` entra em uma `TabView` com pelo menos as abas `Home` e `Profile`.
- [ ] A aba `Home` continua permitindo navegar da lista de cenários até `ScenarioView` sem regressão.
- [ ] A aba `Profile` abre `ProfileView` sem alterar `appState.authState`.
- [ ] `ProfileView` exibe o nickname salvo em `UserDefaultsKey.userNickname`; se estiver ausente, exibe fallback definido pelo fluxo atual sem crash.
- [ ] `ProfileView` exibe a foto salva em `Documents/profile_photo.jpg`; se estiver ausente, exibe placeholder de perfil.
- [ ] Alterar nickname na `ProfileView` usa a mesma validação de até 20 caracteres e caracteres permitidos já aplicada no onboarding.
- [ ] Salvar alterações persiste nickname e foto, e os dados continuam disponíveis ao fechar e reabrir o app.
- [ ] Salvar ou cancelar na `ProfileView` não muda `appState.authState`.
- [ ] Fluxo completo continua funcionando: auth/guest -> onboarding -> authenticated TabView -> Home -> Profile -> Home -> Scenario.

**Ambiente**: iOS/SwiftUI. Versão do iOS e dispositivo não informados, investigar antes de validar câmera em hardware real.

---

## Improvements

### IMP-001: Padronize os textos visíveis da interface para inglês
**Ref**: Feedback original #2

**Contexto**:
O app é para intercambistas treinarem situações do dia a dia no Rio, mas a interface principal ainda mistura português e inglês. Exemplos classificados: `AuthView` usa "Aprenda português do jeito certo"; `ScenarioView` usa "Parabéns!" e "Você completou o cenário!". A regra de produto é: inglês deve ser o idioma oficial da interface; português permanece onde for conteúdo didático de treino, como falas, pronúncia e frases simuladas.

**Ação**:
Faça uma varredura de strings visíveis ao usuário em `AuthView`, `ProfileSetupView`, nova `ProfileView`, `HomeView`, `ScenarioView`, overlays, botões, mensagens de erro, estados vazios, títulos de tela e `accessibilityLabel`. Substitua copy de interface em português por inglês claro e consistente. Separe mentalmente UI de conteúdo pedagógico: textos como `ScriptStep.textPT`, falas em português, opções de resposta em português e conteúdo dos scripts continuam em português quando representarem prática do idioma. Se o projeto ainda não usa `Localizable.strings` ou String Catalog, faça troca direta de literals nesta tarefa; não crie infraestrutura de localização sem requisito explícito.

**Restrições**:
- Não traduza automaticamente falas de treino, scripts, pronúncia, opções conversacionais ou conteúdo didático cujo objetivo seja expor o usuário ao português.
- Não renomeie modelos, campos JSON ou propriedades como `titlePT`, `titleEN`, `textPT` e `translationEN` apenas por causa da copy.
- Não implemente seletor de idioma, localização dinâmica, String Catalog ou suporte multilíngue completo nesta tarefa.
- Não altere lógica de autenticação, progresso, áudio, navegação ou persistência enquanto revisar textos.
- Não mude comentários internos de código apenas por idioma, exceto se forem exibidos na UI.

**Critério de aceite**:
- [ ] `AuthView` não exibe copy de interface em português.
- [ ] `ProfileSetupView` e `ProfileView` exibem títulos, botões, diálogos, placeholders e erros em inglês.
- [ ] `HomeView` não exibe comandos, estados ou labels de sistema em português.
- [ ] `ScenarioView` exibe toolbar, overlay de conclusão, botões de navegação e labels de acessibilidade em inglês.
- [ ] Conteúdo de treino em português continua em português, incluindo falas, áudio e opções de resposta quando fizerem parte do cenário.
- [ ] Busca manual por strings visíveis em português no código Swift não encontra copy de interface restante, exceto conteúdo didático justificado.

**Ambiente**: iOS/SwiftUI. Versão do iOS e dispositivo não informados, investigar.

---

### IMP-002: Use títulos em inglês como hierarquia primária na listagem e navegação de cenários
**Ref**: Feedback original #2

**Contexto**:
`Scenario` e `Subscenario` já possuem `titlePT` e `titleEN`. Hoje `HomeView` usa `scenario.titlePT` como título principal da seção e `subscenario.titlePT` como título principal do card, deixando `titleEN` como subtítulo. `ScenarioView` usa `subscenario.titlePT` em `.navigationTitle`. Isso contradiz a decisão de inglês como idioma oficial da interface, mesmo mantendo português como conteúdo de treino.

**Ação**:
Atualize a hierarquia visual de cenários para inglês. Em `HomeView`, renderize `scenario.titleEN` como título principal da seção e `subscenario.titleEN` como título principal do card. Defina o uso de `titlePT` como subtítulo secundário, tradução/local name ou omita-o de forma consistente; escolha a opção menos invasiva para o layout atual e documente a decisão no código apenas se ela não for óbvia. Em `ScenarioView`, troque `.navigationTitle(subscenario.titlePT)` por `.navigationTitle(subscenario.titleEN)`. Confirme que todos os itens de `GringoCria/Resources/scenarios.json` possuem `titleEN` preenchido antes de depender dele na UI.

**Restrições**:
- Não renomeie os campos `titlePT` e `titleEN` no model ou no JSON.
- Não altere `scriptName`, IDs, progresso, bloqueio, navegação ou carregamento do JSON.
- Não traduza scripts de conversa nem `textPT`; português continua sendo o conteúdo praticado.
- Não remova `titlePT` do JSON.
- Não invente novos cenários ou novos títulos além dos já existentes no arquivo de recursos.

**Critério de aceite**:
- [ ] Seções da Home exibem `scenario.titleEN` como título principal.
- [ ] Cards de subcenário exibem `subscenario.titleEN` como título principal.
- [ ] `ScenarioView` usa `subscenario.titleEN` no título de navegação.
- [ ] `titlePT` permanece disponível no JSON e no model sem quebra de decodificação.
- [ ] Todos os cenários e subcenários em `scenarios.json` têm `titleEN` não vazio.
- [ ] Navegar da Home para um subcenário continua funcionando sem alterar o valor de `Subscenario`.

**Ambiente**: iOS/SwiftUI. Versão do iOS e dispositivo não informados, investigar.

---

### IMP-004: Adicione `vendorVariation`, `auto`, `vendorVariations`, `vendorVariationsEN` e `nextStepId` ao modelo `ScriptStep`
**Ref**: IMP-004 (classified-feedback.md)

**Contexto**:
`ScriptStep.swift` está em `GringoCria/Models/ScriptStep.swift`. O enum `StepType` tem apenas dois cases — `message` e `choice` — e `ChoiceOption` não tem campo de navegação. O novo script do Matte introduz três comportamentos novos: turno do vendedor com texto sorteado entre variações (`vendorVariation`), turno do cliente narrado sem interação (`auto`), e ramificação condicional entre steps (`nextStepId` em `ChoiceOption`). Sem esses campos no modelo, o `JSONDecoder` falha silenciosamente ao carregar `matte.json` e nenhuma tela nova pode ser validada.

**Comportamento atual**:
- `StepType`: `case message`, `case choice` — dois cases.
- `ScriptStep`: campos `id`, `speaker`, `textPT`, `translationEN`, `type`, `choices` — sem `vendorVariations`, `vendorVariationsEN` ou `isTerminal`.
- `ChoiceOption`: campos `id`, `textPT`, `translationEN`, `isCorrect` — sem `nextStepId`.

**Comportamento esperado**:
- `StepType`: `case message`, `case choice`, `case vendorVariation`, `case auto`.
- `ScriptStep`: inclui `vendorVariations: [String]?`, `vendorVariationsEN: [String]?` e `isTerminal: Bool` (padrão `false` via decodificação defensiva).
- `ChoiceOption`: inclui `nextStepId: UUID?`.

**Passos para reproduzir**:
1. Abra `GringoCria/Models/ScriptStep.swift`.
2. Observe que `StepType` não tem `vendorVariation` nem `auto`.
3. Observe que `ScriptStep` não tem `vendorVariations`, `vendorVariationsEN` nem `isTerminal`.
4. Observe que `ChoiceOption` não tem `nextStepId`.

**Ação**:
Edite `GringoCria/Models/ScriptStep.swift` aplicando as quatro mudanças abaixo. Não crie arquivo novo — edite o existente.

1. Em `StepType`, adicione `case vendorVariation` e `case auto`.

2. Em `ScriptStep`, adicione os campos:
   ```swift
   let vendorVariations: [String]?
   let vendorVariationsEN: [String]?
   let isTerminal: Bool
   ```
   Como `ScriptStep` é `Codable`, implemente `init(from decoder:)` explícito: use `decodeIfPresent` para os opcionais e `(try? container.decode(Bool.self, forKey: .isTerminal)) ?? false` para `isTerminal`, garantindo que JSONs sem esse campo decodifiquem com `false`.

3. Em `ChoiceOption`, adicione o campo:
   ```swift
   let nextStepId: UUID?
   ```
   Decodifique com `decodeIfPresent` — deve ser `nil` quando ausente no JSON, garantindo compatibilidade retroativa com todos os scripts existentes.

4. O campo `isCorrect: Bool?` em `ChoiceOption` permanece. As novas choices do Matte não definem `isCorrect` — o valor será `nil` no JSON e o campo continua opcional. Não remova nem renomeie.

**Restrições**:
- Não remova campos existentes de `ScriptStep` nem de `ChoiceOption`.
- Não altere o raw value de nenhum case existente em `StepType` nem em `Speaker`.
- Não modifique `ScenarioViewModel.swift`, `matte.json` ou qualquer view nesta tarefa — escopo exclusivo de `ScriptStep.swift`.
- Não crie arquivo de model separado; todos os tipos ficam em `ScriptStep.swift`.
- Não implemente lógica de sorteio ou navegação — isso é responsabilidade do ViewModel (IMP-006).

**Critério de aceite**:
- [ ] `StepType` compila com os quatro cases: `message`, `choice`, `vendorVariation`, `auto`.
- [ ] `ScriptStep` decodifica um JSON com `"type": "vendorVariation"` sem erro de compilação nem de runtime.
- [ ] `ScriptStep` decodifica um JSON com `"type": "auto"` sem erro.
- [ ] `ScriptStep` sem o campo `isTerminal` no JSON decodifica com `isTerminal == false`.
- [ ] `ChoiceOption` sem o campo `nextStepId` no JSON decodifica com `nextStepId == nil`.
- [ ] `ChoiceOption` com `"nextStepId": "A1000007-0000-0000-0000-000000000007"` no JSON decodifica com o UUID correto.
- [ ] O script atual `matte.json` (antes de IMP-005 ser aplicado) continua decodificando sem erro após esta mudança.
- [ ] O projeto compila sem warnings de `switch` não-exaustivo introduzidos pelos novos cases — audite todos os `switch` sobre `StepType` no projeto e adicione os cases faltantes.

**Ambiente**: Swift 6, iOS 17+, Xcode 16+.

---

### IMP-005 + IMP-007: Reescreva `matte.json` com os 11 steps, UUIDs fixos, variações do vendedor, ramificação e traduções EN completas
**Ref**: IMP-005 e IMP-007 (classified-feedback.md)

**Contexto**:
`GringoCria/Resources/scripts/matte.json` tem 6 steps lineares, sem variação do vendedor, sem ramificação condicional, sem steps de ação física e com conteúdo desatualizado. O novo script do Matte define 11 steps (incluindo os condicionais 6a e 6b), com sorteio de fala do vendedor, duas perguntas opcionais de sabor que desviam do caminho principal e retornam ao step 7, e dois steps de ação física sem interação. Todos os UUIDs do script atual devem ser descartados — a estrutura é completamente diferente e reutilizar UUIDs causaria risco de colisão em features futuras de analytics ou histórico.

Este comando cobre IMP-005 (estrutura e conteúdo) e IMP-007 (traduções EN) simultaneamente porque as traduções são campos do mesmo JSON — não é possível entregar o arquivo sem ambos.

**Comportamento atual**:
`matte.json` tem 6 steps com UUIDs raiz `C3D4E5F6-...`, `D4E5F6A7-...`, `E5F6A7B8-...`, `F6A7B8C9-...`, `A7B8C9D0-...`, `B8C9D0E1-...` — todos a descartar.

**Comportamento esperado**:
`matte.json` com 11 steps na sequência abaixo, usando os UUIDs fixos definidos neste comando, decodificável pelo `ScriptStep` atualizado em IMP-004.

**Ação**:
Substitua o conteúdo completo de `GringoCria/Resources/scripts/matte.json` pelo JSON a seguir. Não edite parcialmente — reescreva o arquivo inteiro.

```json
[
  {
    "id": "A1000001-0000-0000-0000-000000000001",
    "speaker": "vendor",
    "textPT": "Olha o Matte!!! Olha o Matte!!!",
    "translationEN": "Mate drink! Mate drink!",
    "type": "message",
    "choices": null,
    "vendorVariations": null,
    "vendorVariationsEN": null,
    "isTerminal": false
  },
  {
    "id": "A1000002-0000-0000-0000-000000000002",
    "speaker": "customer",
    "textPT": "",
    "translationEN": "",
    "type": "choice",
    "choices": [
      {
        "id": "B2000001-0000-0000-0000-000000000001",
        "textPT": "*Faz sinal para chamar o vendedor*",
        "translationEN": "*Waves to call the vendor*",
        "isCorrect": null,
        "nextStepId": null
      },
      {
        "id": "B2000001-0000-0000-0000-000000000002",
        "textPT": "Ou do Matte!!",
        "translationEN": "Hey, Mate!!",
        "isCorrect": null,
        "nextStepId": null
      }
    ],
    "vendorVariations": null,
    "vendorVariationsEN": null,
    "isTerminal": false
  },
  {
    "id": "A1000003-0000-0000-0000-000000000003",
    "speaker": "vendor",
    "textPT": "",
    "translationEN": "",
    "type": "vendorVariation",
    "choices": null,
    "vendorVariations": ["Fala chefe", "Fala tu", ""],
    "vendorVariationsEN": ["What's up chief", "What's up", ""],
    "isTerminal": false
  },
  {
    "id": "A1000004-0000-0000-0000-000000000004",
    "speaker": "customer",
    "textPT": "",
    "translationEN": "",
    "type": "choice",
    "choices": [
      {
        "id": "B2000004-0000-0000-0000-000000000001",
        "textPT": "Coé ta quanto aí?",
        "translationEN": "Yo how much is it?",
        "isCorrect": null,
        "nextStepId": null
      },
      {
        "id": "B2000004-0000-0000-0000-000000000002",
        "textPT": "E aí paizão ta quanto o matte?",
        "translationEN": "Hey man how much is the mate?",
        "isCorrect": null,
        "nextStepId": null
      },
      {
        "id": "B2000004-0000-0000-0000-000000000003",
        "textPT": "Fala paizão vê um matte",
        "translationEN": "Hey man give me a mate",
        "isCorrect": null,
        "nextStepId": null
      }
    ],
    "vendorVariations": null,
    "vendorVariationsEN": null,
    "isTerminal": false
  },
  {
    "id": "A1000005-0000-0000-0000-000000000005",
    "speaker": "vendor",
    "textPT": "Tem de 12 e tem o 15",
    "translationEN": "Got the R$12 and the R$15",
    "type": "message",
    "choices": null,
    "vendorVariations": null,
    "vendorVariationsEN": null,
    "isTerminal": false
  },
  {
    "id": "A1000006-0000-0000-0000-000000000006",
    "speaker": "customer",
    "textPT": "",
    "translationEN": "",
    "type": "choice",
    "choices": [
      {
        "id": "B2000006-0000-0000-0000-000000000001",
        "textPT": "Tem maracujá e limão?",
        "translationEN": "Got passion fruit and lemon?",
        "isCorrect": null,
        "nextStepId": "A100006A-0000-0000-0000-00000000006A"
      },
      {
        "id": "B2000006-0000-0000-0000-000000000002",
        "textPT": "Tem sem açúcar?",
        "translationEN": "Got sugar-free?",
        "isCorrect": null,
        "nextStepId": "A100006A-0000-0000-0000-00000000006A"
      },
      {
        "id": "B2000006-0000-0000-0000-000000000003",
        "textPT": "Quero o de 12",
        "translationEN": "I'll take the R$12",
        "isCorrect": null,
        "nextStepId": "A1000007-0000-0000-0000-000000000007"
      },
      {
        "id": "B2000006-0000-0000-0000-000000000004",
        "textPT": "Quero o de 15",
        "translationEN": "I'll take the R$15",
        "isCorrect": null,
        "nextStepId": "A1000007-0000-0000-0000-000000000007"
      }
    ],
    "vendorVariations": null,
    "vendorVariationsEN": null,
    "isTerminal": false
  },
  {
    "id": "A1000007-0000-0000-0000-000000000007",
    "speaker": "vendor",
    "textPT": "Aceito pix, dinheiro ou cartão",
    "translationEN": "I take pix, cash or card",
    "type": "message",
    "choices": null,
    "vendorVariations": null,
    "vendorVariationsEN": null,
    "isTerminal": false
  },
  {
    "id": "A1000008-0000-0000-0000-000000000008",
    "speaker": "customer",
    "textPT": "*Paga o matte*",
    "translationEN": "*Pays for the mate*",
    "type": "auto",
    "choices": null,
    "vendorVariations": null,
    "vendorVariationsEN": null,
    "isTerminal": false
  },
  {
    "id": "A1000009-0000-0000-0000-000000000009",
    "speaker": "customer",
    "textPT": "*Estica o copo para botar o matte e escolhe se quer limão ou maracujá ou sem açúcar*",
    "translationEN": "*Holds out the cup for the mate and picks lemon, passion fruit or no sugar*",
    "type": "auto",
    "choices": null,
    "vendorVariations": null,
    "vendorVariationsEN": null,
    "isTerminal": true
  },
  {
    "id": "A100006A-0000-0000-0000-00000000006A",
    "speaker": "vendor",
    "textPT": "Sim",
    "translationEN": "Yes",
    "type": "message",
    "choices": null,
    "vendorVariations": null,
    "vendorVariationsEN": null,
    "isTerminal": false
  },
  {
    "id": "A100006B-0000-0000-0000-00000000006B",
    "speaker": "customer",
    "textPT": "",
    "translationEN": "",
    "type": "choice",
    "choices": [
      {
        "id": "B200006B-0000-0000-0000-000000000001",
        "textPT": "Quero o de 12",
        "translationEN": "I'll take the R$12",
        "isCorrect": null,
        "nextStepId": "A1000007-0000-0000-0000-000000000007"
      },
      {
        "id": "B200006B-0000-0000-0000-000000000002",
        "textPT": "Quero o de 15",
        "translationEN": "I'll take the R$15",
        "isCorrect": null,
        "nextStepId": "A1000007-0000-0000-0000-000000000007"
      }
    ],
    "vendorVariations": null,
    "vendorVariationsEN": null,
    "isTerminal": false
  }
]
```

**Mapa de UUIDs fixos para referência cruzada com IMP-006**:

| Step | UUID |
|------|------|
| Step 1 (vendor / message) | `A1000001-0000-0000-0000-000000000001` |
| Step 2 (customer / choice) | `A1000002-0000-0000-0000-000000000002` |
| Step 3 (vendor / vendorVariation) | `A1000003-0000-0000-0000-000000000003` |
| Step 4 (customer / choice) | `A1000004-0000-0000-0000-000000000004` |
| Step 5 (vendor / message) | `A1000005-0000-0000-0000-000000000005` |
| Step 6 (customer / choice com nextStepId) | `A1000006-0000-0000-0000-000000000006` |
| Step 7 (vendor / message — destino de convergência) | `A1000007-0000-0000-0000-000000000007` |
| Step 8 (customer / auto) | `A1000008-0000-0000-0000-000000000008` |
| Step 9 (customer / auto / isTerminal) | `A1000009-0000-0000-0000-000000000009` |
| Step 6a (vendor / message condicional) | `A100006A-0000-0000-0000-00000000006A` |
| Step 6b (customer / choice condicional) | `A100006B-0000-0000-0000-00000000006B` |

**Posicionamento dos steps condicionais no array**: Steps 6a e 6b ficam ao final do array (posições 10 e 11, índices 9 e 10), depois do step 9. Isso garante que o loop `while` linear de `revealNextVendorMessage` nunca alcance 6a ou 6b por incremento sequencial — o loop interrompe no step 6 (`type == .choice`) antes de avançar para eles. Esses steps são acessíveis exclusivamente via `nextStepId`.

**Restrições**:
- Não reutilize nenhum UUID do `matte.json` atual.
- Não altere `scenarios.json` nem qualquer outro arquivo de recurso.
- Não invente traduções alternativas — use exatamente os textos EN do script de referência deste comando.
- Não use UUIDs gerados em runtime — todos os UUIDs devem ser literais fixos no JSON.
- Não omita o campo `isTerminal` de nenhum step — declare explicitamente `true` ou `false`.
- Não modifique `ScriptStep.swift` nem `ScenarioViewModel.swift` nesta tarefa.

**Critério de aceite**:
- [ ] `JSONDecoder().decode([ScriptStep].self, from: Data(contentsOf: matte.json))` decodifica sem erro após IMP-004 estar aplicado.
- [ ] O array decodificado tem exatamente 11 elementos.
- [ ] Steps 6a e 6b estão nas posições 10 e 11 do array (índices 9 e 10), depois do step 9 (`isTerminal: true`).
- [ ] As choices de "Tem maracujá e limão?" e "Tem sem açúcar?" têm `nextStepId == UUID("A100006A-0000-0000-0000-00000000006A")`.
- [ ] As choices "Quero o de 12" e "Quero o de 15" no step 6 têm `nextStepId == UUID("A1000007-0000-0000-0000-000000000007")`.
- [ ] As choices do step 6b têm `nextStepId == UUID("A1000007-0000-0000-0000-000000000007")`.
- [ ] O step 9 tem `isTerminal == true`; todos os demais têm `isTerminal == false`.
- [ ] `vendorVariations` do step 3 é `["Fala chefe", "Fala tu", ""]` — array com três elementos, o terceiro sendo string vazia.
- [ ] `vendorVariationsEN` do step 3 é `["What's up chief", "What's up", ""]` — mesma cardinalidade que `vendorVariations`.
- [ ] Todos os steps têm `translationEN` preenchido, incluindo os steps `auto` e os condicionais.

**Ambiente**: JSON puro. Valide o JSON com `jq . matte.json` ou `swift package` antes de commitar.

---

### IMP-006: Atualize `ScenarioViewModel` para suportar `vendorVariation`, step silencioso, `auto` e ramificação por `nextStepId`
**Ref**: IMP-006 (classified-feedback.md)

**Contexto**:
`ScenarioViewModel.swift` está em `GringoCria/ViewModels/ScenarioViewModel.swift`. O avanço é estritamente linear por `currentIndex`. O loop `while` em `revealNextVendorMessage()` (linha 91–101) quebra em qualquer step que não seja `message` do vendor. `selectChoice(_:)` (linha 60) sempre faz `currentIndex += 1` sem verificar `nextStepId`. `isCompleted` (linha 103) usa `currentIndex >= steps.count`, o que não dispara corretamente quando o fluxo termina em um step `isTerminal == true` com índice numérico menor que `steps.count` — no script novo, o array tem 11 elementos mas o fluxo encerra no step 9 (índice 8). Adicionalmente, o init memberwise de `ScriptStep` em `selectChoice` (linhas 51–58) ficará desatualizado após IMP-004 adicionar `vendorVariations`, `vendorVariationsEN` e `isTerminal`, impedindo a compilação do projeto.

**Comportamento atual**:
- `revealNextVendorMessage`: loop `while` com `guard step.type == .message, step.speaker == .vendor else { break }` — quebra silenciosamente em `vendorVariation` e em `auto`.
- `selectChoice`: `currentIndex += 1` sem verificação de `nextStepId`. O `ScriptStep(...)` memberwise nas linhas 51–58 não tem os parâmetros `vendorVariations`, `vendorVariationsEN` e `isTerminal`.
- `isCompleted`: `currentIndex >= steps.count` — não dispara quando o último step é alcançado por posicionamento via ID, porque `currentIndex` (8) nunca alcança `steps.count` (11).
- `currentChoices`: filtra `step.type == .choice` — correto, sem alteração necessária.

**Comportamento esperado**:
- `revealNextVendorMessage` trata `vendorVariation` sorteando uma variação e trata `auto` exibindo o step diretamente — ambos continuam o loop sem quebrar. Imediatamente após appendar cada step em `revealedSteps`, o loop verifica `step.isTerminal`: se `true`, seta `isCompleted = true`, chama `onCompleted?()` e executa `return` — não incrementa `currentIndex` nem continua iterando.
- `selectChoice` resolve `nextStepId` para o índice do step destino quando presente; mantém `currentIndex += 1` quando `nextStepId == nil`. O init memberwise de `ScriptStep` em `selectChoice` inclui os três novos parâmetros com valores padrão.
- `isCompleted` dispara quando `step.isTerminal == true` é detectado dentro do loop, independente de posição no array.

**Passos para reproduzir**:
1. Aplique IMP-004 e IMP-005 (modelo e JSON novos).
2. Observe que o projeto não compila: o `ScriptStep(...)` em `selectChoice` não tem `vendorVariations`, `vendorVariationsEN` e `isTerminal`.
3. Corrija o erro de compilação e rode o app; abra o cenário Matte.
4. Observe que o loop trava no step 3 (`vendorVariation`) porque o `guard` não reconhece o tipo.
5. No step 6, selecione "Tem maracujá e limão?" — `currentIndex` vai para o índice 6 (step 7 no array) em vez do step 6a pelo UUID.
6. Ao concluir o path via step 9 (`isTerminal: true`, índice 8), `isCompleted` não dispara porque a verificação pós-loop encontra `currentIndex` em 9, que aponta para o step 6a (índice 9) com `isTerminal == false`.

**Ação**:
Edite `GringoCria/ViewModels/ScenarioViewModel.swift` aplicando as cinco mudanças abaixo. Não crie arquivo novo — edite o existente.

**Mudança A — sorteio de `vendorVariation` em `revealNextVendorMessage`**

Dentro do loop `while`, após o `guard` existente que quebra o loop para steps não-vendor-message, adicione tratamento para `vendorVariation`. A estrutura recomendada é substituir o `guard` atual por blocos `if/else if` em sequência:

```swift
if step.type == .vendorVariation {
    guard let variations = step.vendorVariations, !variations.isEmpty else {
        // Fallback seguro: sem variações declaradas — avança sem exibir balão
        currentIndex += 1
        continue
    }
    let pickedIndex = Int.random(in: 0..<variations.count)
    let picked = variations[pickedIndex]

    if !picked.isEmpty {
        let pickedEN = step.vendorVariationsEN?.indices.contains(pickedIndex) == true
            ? step.vendorVariationsEN![pickedIndex]
            : ""

        isTyping = true
        try? await Task.sleep(for: .seconds(1.2))
        isTyping = false

        let ephemeral = ScriptStep(
            id: UUID(),
            speaker: step.speaker,
            textPT: picked,
            translationEN: pickedEN,
            type: step.type,
            choices: nil,
            vendorVariations: nil,
            vendorVariationsEN: nil,
            isTerminal: false
        )
        revealedSteps.append(ephemeral)

        if ephemeral.isTerminal {
            isCompleted = true
            onCompleted?()
            return
        }
    }
    // Se picked == "", step silencioso: não appenda balão, apenas avança
    currentIndex += 1
    continue
}
```

**Mudança B — auto-avanço de `auto` em `revealNextVendorMessage` com verificação de `isTerminal` interna**

No mesmo loop, adicione tratamento para `step.type == .auto`. A verificação de `isTerminal` deve ocorrer imediatamente após o append e antes de incrementar `currentIndex` ou continuar — quando `true`, o loop para com `return`:

```swift
if step.type == .auto {
    isTyping = true
    try? await Task.sleep(for: .seconds(1.2))
    isTyping = false

    revealedSteps.append(step)
    currentIndex += 1

    if step.isTerminal {
        isCompleted = true
        onCompleted?()
        return
    }
    continue
}
```

Steps `auto` usam o `step.id` original ao appendar em `revealedSteps` — cada step `auto` é único no array por UUID fixo, sem risco de duplicata.

Aplique o mesmo padrão de verificação interna ao bloco de `message` do vendor (se houver): após `revealedSteps.append(step)` e `currentIndex += 1`, verifique `if step.isTerminal { isCompleted = true; onCompleted?(); return }`.

**Mudança C — navegação por `nextStepId` em `selectChoice`**

Substitua a linha `currentIndex += 1` em `selectChoice(_:)` pelo bloco com fallback e log:

```swift
if let nextId = choice.nextStepId {
    if let targetIndex = steps.firstIndex(where: { $0.id == nextId }) {
        currentIndex = targetIndex
    } else {
        print("[ScenarioViewModel] nextStepId \(nextId) não encontrado — avançando linearmente.")
        currentIndex += 1
    }
} else {
    currentIndex += 1
}
```

**Mudança D — atualização do init memberwise de `ScriptStep` em `selectChoice`**

O `ScriptStep(...)` nas linhas 51–58 de `selectChoice` constrói um step revelado para a escolha do cliente. Após IMP-004, `ScriptStep` terá os campos `vendorVariations`, `vendorVariationsEN` e `isTerminal` no memberwise init. Sem atualização, o projeto não compila. Atualize o bloco para incluir os três novos parâmetros com valores padrão:

```swift
let choiceRevealed = ScriptStep(
    id: UUID(),
    speaker: .customer,
    textPT: choice.textPT,
    translationEN: choice.translationEN,
    type: .choice,
    choices: nil,
    vendorVariations: nil,
    vendorVariationsEN: nil,
    isTerminal: false
)
```

Use os valores `vendorVariations: nil`, `vendorVariationsEN: nil` e `isTerminal: false` — a escolha do cliente nunca é terminal e nunca tem variações.

**Mudança E — `isCompleted` pós-loop como fallback de segurança**

Mantenha a verificação após o `while` como fallback para o caso de `steps.count` ser atingido por esgotamento do array, mas remova a lógica de `isTerminal` desse ponto — ela agora é tratada dentro do loop pelas Mudanças A e B:

```swift
// Fallback pós-loop: array esgotado sem step terminal
if currentIndex >= steps.count {
    isCompleted = true
    onCompleted?()
}
```

**Restrições**:
- Não altere `currentChoices` — o filtro por `step.type == .choice` está correto e não precisa mudar.
- Não altere `loadScript`, `start` nem nenhuma assinatura pública do ViewModel.
- Não quebre o padrão de UUID efêmero estabelecido nos comentários das linhas 47–51 do arquivo atual: qualquer step do vendor appendado manualmente em `revealedSteps` deve ter `id: UUID()` novo para evitar `Duplicate ID` no `ForEach`. A exceção são steps `auto`, que usam o `step.id` original por serem únicos no array.
- Não use delay diferente de 1.2s para steps `auto` — usar o mesmo valor dos steps do vendor.
- Não deixe `nextStepId` inválido causar crash em produção — use fallback para `currentIndex += 1` com log.
- Não modifique `ScriptStep.swift` nem `matte.json` nesta tarefa.
- Não mova a verificação de `isTerminal` para fora do loop como mecanismo principal de término — ela deve ser verificada imediatamente após cada `revealedSteps.append(step)`, antes de incrementar ou continuar.

**Critério de aceite**:
- [ ] O projeto compila sem erros após IMP-004 estar aplicado — o `ScriptStep(...)` em `selectChoice` inclui `vendorVariations: nil`, `vendorVariationsEN: nil` e `isTerminal: false`.
- [ ] Ao abrir o cenário Matte (após IMP-004 e IMP-005 aplicados), o step 1 (vendor / message) exibe "Olha o Matte!!! Olha o Matte!!!" normalmente.
- [ ] O step 3 (vendor / vendorVariation) exibe um dos dois textos sorteados ("Fala chefe" ou "Fala tu") OU não exibe balão algum (quando a string vazia é sorteada).
- [ ] Selecionar "Tem maracujá e limão?" ou "Tem sem açúcar?" no step 6 navega para o step 6a (UUID `A100006A-0000-0000-0000-00000000006A`) e exibe "Sim".
- [ ] Selecionar "Quero o de 12" ou "Quero o de 15" no step 6 navega diretamente para o step 7 (UUID `A1000007-0000-0000-0000-000000000007`) e exibe "Aceito pix, dinheiro ou cartão".
- [ ] Após o step 7, o step 8 (`auto`) exibe "*Paga o matte*" sem interação do usuário, após aproximadamente 1.2s.
- [ ] Após o step 8, o step 9 (`auto`, `isTerminal: true`) exibe "*Estica o copo...*" sem interação do usuário, após aproximadamente 1.2s.
- [ ] Imediatamente após appendar o step 9 em `revealedSteps`, o loop detecta `step.isTerminal == true`, seta `isCompleted = true`, chama `onCompleted?()` e retorna — sem incrementar `currentIndex` para 9 nem processar o step 6a.
- [ ] Step 6a (`A100006A-0000-0000-0000-00000000006A`) nunca aparece em `revealedSteps` quando o usuário seleciona "Quero o de 12" ou "Quero o de 15" diretamente no step 6.
- [ ] O path pelo ramo condicional (step 6 → 6a → 6b → 7 → 8 → 9) também resulta em `isCompleted == true`.
- [ ] O app não crasha quando `vendorVariations` é `nil` em um step do tipo `vendorVariation` — exibe nenhum balão e avança.
- [ ] O app não crasha quando `nextStepId` aponta para um UUID inexistente — avança linearmente e emite log no console.

**Ambiente**: Swift 6, iOS 17+, `@Observable`, `@MainActor`. Todos os métodos assíncronos já estão no `MainActor` — não é necessário `Task { @MainActor in }` adicional.
