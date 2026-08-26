# Home — Tasks

## Execution Protocol (MANDATORY — do not skip)

Implemente estas tasks com a skill `tlc-spec-driven`: **ative-a pelo nome e siga o Execute flow e as Critical Rules dela.** Não procure os arquivos da skill por caminho de filesystem. A skill é a fonte da verdade do fluxo completo (ciclo por task, delegação a sub-agentes, adequacy review, Verifier, sensor de discriminação).

**Se a skill não puder ser ativada, PARE e avise o usuário — não prossiga sem ela.**

---

**Spec**: `.specs/features/home/spec.md`
**Design**: `.specs/features/home/design.md` (**Aprovado** — AD-022 gravada em 2026-08-26)
**Status**: **Execute concluído** — 16 tasks (13 planejadas + T3a, T4a, T9a), dois `code-review` e duas iterações de Verifier. **1136 testes verdes**, `flutter analyze` limpo. Verifier independente: **PASS** na iteração 3, 19/19 com evidência.
**Ferramentas** (confirmadas em 2026-08-26): skill `run` nas tasks de tela (**T10** mobile, **T11** web) para conferência visual; skill `code-review` ao fim de cada batch (após T7 e após T13). Execução das tasks **inline**; **Verifier como sub-agente**, já autorizado no handoff.
**Baseline**: `flutter test` = **947 passando** · `flutter analyze` = zero issues (`feature/home`, medido em 2026-08-26)
**Branch**: `feature/home`, nascida de `feature/entrar` — a spec 03 ainda não foi mergeada e `home` depende da porta de sessão e da guarda dela

---

## Test Coverage Matrix

> Gerada do codebase, das guidelines do projeto e da spec — confirmar antes do Execute.
> **Guidelines encontradas**: `CLAUDE.md` §Testes (pirâmide completa; "teste sai do critério de aceite, nunca da implementação"; `test/` espelha `lib/`), `README.md` §Comandos, `analysis_options.yaml` (`flutter_lints`). **Sem** threshold de cobertura e **sem** CI — o `CLAUDE.md` proíbe criar pipeline sem pedido.
> **Amostragem**: 12 arquivos de `test/` — `features/entrar/**` (o precedente mais próximo: bloc, page, widgets, fluxo), `core/routing/{app_router_shell,placeholder_page,route_error_page_tokens}_test.dart`, `core/responsive/`, `fixtures/`, `app_test.dart`.

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
|---|---|---|---|---|
| Domínio da feature — `ResumoDeFesta` (valor puro, derivações) | unit | Todos os ramos; 1:1 com os ACs; toda fronteira do `clamp` afirmada (acima, igual, abaixo) | `test/features/home/domain/*_test.dart` | `flutter test` |
| Porta + implementação de dados — `FestaRepositoryEmMemoria` | unit | Semente, emissão nova, assinante tardio, `dispose`; **mais** a varredura de import provando que `lib/` não importa `test/` | `test/features/home/data/*_test.dart` | `flutter test` |
| BLoC | unit | Uma transição afirmada por emissão + todo ramo de estado (`comFestas`/`vazia`/`falhou`) + o par "logger gravou × não gravou" | `test/features/home/presentation/bloc/*_test.dart` | `flutter test` |
| Widget de tela e componente de feature | widget | Cada AC de UI **com par discriminante** (presente × ausente); cada literal de copy da spec afirmado; fontes reais carregadas (`carregarFontesArchivo`) | `test/features/home/presentation/**/*_test.dart` | `flutter test` |
| Chrome compartilhado — `AppShell`, `PlaceholderPage` | widget | Presença, ordem e **token** de cada elemento; `chromeKey`/`keyFor` preservadas; par compacto × expandido para a ação contextual | `test/core/routing/{app_shell,placeholder_page}*_test.dart` | `flutter test` |
| Roteamento — destino de `/roles` | widget (integração dentro de `flutter test`) | O teste **abre a rota e afirma o destino final**; par com sessão × sem sessão preservado da spec 03 | `test/core/routing/app_router_*_test.dart`, `test/app_test.dart` | `flutter test` |
| Guarda de pureza — varredura de arquivo | unit | A regra **mais** o teste anti-vácuo com mutação injetada; a varredura casa em **linha de `import`**, nunca em texto solto — o padrão que produziu três falsos na spec 03 | `test/features/home/**`, `test/core/routing/app_shell_*_test.dart` | `flutter test` |
| Fixture de teste | unit | Todo valor acrescentado afirmado; o que é **literal de spec** separado por asserção do que é **assumption** (A-04) | `test/fixtures/*_test.dart` | `flutter test` |
| Porta abstrata, barrel, declaração sem comportamento | none | — (gate de build) | — | `flutter analyze` |

**Regra de asserção herdada do `design.md` §Estratégia de teste** — o teste aponta para a **fonte da verdade daquele valor**:

- **copy da spec** → afirmar o **literal escrito no teste** (`find.text('MONTAR LISTA →')`).
- **token do design system** → afirmar o **token** (`expect(borda.color, BoraColors.ink)`), nunca o hexadecimal.
- **contador** → afirmar a **transição** (`4/2 → 5/1`), nunca só a string estática: ela passa igual numa implementação derivada errada (AD-022, aperto 2).

## Gate Check Commands

> Geradas do codebase — confirmar antes do Execute. A suíte inteira roda em ~15s, então "full" não é caro.

| Gate Level | When to Use | Command |
|---|---|---|
| Quick | Task com testes de arquivo isolado, sem tocar rota, DI ou fixture | `flutter test test/<caminho do arquivo de teste>` |
| Full | Task que toca `AppShell`, `PlaceholderPage`, fixture ou layout — o que a suíte inteira observa | `flutter test` |
| Build | Task que toca `app_router.dart`, `injector.dart` ou fecha fase | `flutter analyze && flutter test` |

Toda task fecha com `flutter analyze` limpo. **Nenhuma task pode reduzir a contagem de testes** — a baseline de 947 só cresce.

---

## Emendas de fronteira acrescentadas no Tasks

O `design.md` registrou E-1 (estender a fixture) e E-2 (revestir `AppShell`/`PlaceholderPage`). O corte em tasks encontrou duas fronteiras que nenhum dos dois documentos previu. Ficam declaradas aqui **antes** do Execute, e não descobertas no meio dele.

| # | Arquivo | Mudança | Por que é inevitável |
|---|---|---|---|
| **E-3** | `lib/core/routing/app_router.dart`, `test/support/app_de_teste.dart` | `buildAppRouter` passa a receber a porta `FestaRepository` e repassá-la à `HomePage`, e a entregar `autenticacao.sessaoAtual` ao `AppShell`. `abrirApp` ganha o parâmetro opcional correspondente | A `spec.md` marca `app_router.dart` como intocável, mas o roteador monta `const HomePage()` e `AppShell(child: child)` **sem argumento nenhum** — não há por onde a porta nem o usuário chegarem. A alternativa (a página resolver `getIt` por dentro) é **recusada pelo precedente explícito da spec 03**, documentado em `entrar_page.dart`: a página não busca no container porque isso faria todo teste de rota configurar DI para montar uma tela. A spec 03 já alterou estes dois arquivos exatamente assim para a porta de sessão |
| **E-5** | `lib/core/design_system/components/bora_avatar.dart` e seu teste | `BoraAvatar` ganha o par de cores opcional (**T3a**) | `06` fixa o avatar de conta em `#FFD23F`, mas o componente derivava a cor do nome. Usar o par do nome contraria `06` e A-08; desenhar o círculo à mão no shell quebra a guarda de forma de §3, que varre `lib/` inteira. Mesma forma do `obscureText` que a spec 03 acrescentou ao `BoraTextField` |
| **E-6** | `lib/core/design_system/components/bora_marca.dart` (novo), o barrel, o catálogo, `lib/features/entrar/presentation/widgets/*` e os testes correspondentes | `MarcaBora` promovida a `BoraMarca` com o construtor `.header()` de 20px (**T4a**) | O doc do original marcava este momento: "quando a spec 04 precisar do logo 20px do header de app, aparece o segundo uso real e a promoção passa a valer a pena". Decisão do usuário em 2026-08-26; a alternativa era uma segunda marca no código, que divergiria da primeira |
| **E-4** | `test/app_test.dart`, `test/core/routing/app_router_shell_test.dart` | Trocar `PlaceholderPage.keyFor('home')` por `HomePage.pageKey` nas asserções que identificam a Home | Cinco asserções em dois arquivos identificam a Home **pela chave do placeholder**. Quando a Home deixa de ser placeholder, elas param de encontrá-la. Não é enfraquecer: é a mesma migração que a spec 03 fez ao criar `EntrarPage.pageKey`. **A asserção continua sendo "a Home está montada"** — muda só por qual chave. Nenhum par discriminante é removido: o par com sessão × sem sessão de ENT-15/16 fica intacto |

## Decisão tomada no corte de tasks

| # | Questão que o design deixou aberta | Escolha | Rationale |
|---|---|---|---|
| **D-1** | T-02 diz "**quando existe confirmação nova** … entra o botão amarelo", mas nem `ResumoDeFesta` nem `FestaRepository` carregam a noção de "nova" | O flag **nasce no `HomeBloc`**: `confirmacaoNova` vira `true` quando uma emissão posterior aumenta o `confirmados` de uma festa em relação à anterior. `ResumoDeFesta` continua um retrato puro e o card recebe um `bool` | "Nova" é propriedade de **duas emissões**, e o bloc é a única camada que vê as duas. Pôr o flag em `ResumoDeFesta` obrigaria a fonte de dados — Firestore, no M2 — a saber o que o anfitrião já tinha visto: estado de UI vazando para o banco. Coerente com a AD-022: o contador é dado; a **transição** é derivação, e é do consumidor |

---

## Execution Plan

Fases ordenadas, executadas em sequência; tasks dentro de uma fase executam em ordem.

### Fase 1 — Contrato e dado (3 tasks) — ✅ **CONCLUÍDA**

O vocabulário da Home e a fonte que a alimenta. Nada aqui é Flutter de tela.

```
T1 → T2 → T3
```

### Fase 2 — O chrome (3 tasks + T3a e T4a) — ✅ **CONCLUÍDA**

A metade da AD-013 que sobrou. Toca arquivos que sete rotas usam.

```
T3a → T4a → T4 → T5 → T6
```

### Fase 3 — O bloc (1 task) — ✅ **CONCLUÍDA**

Onde o stream vira estado — e onde D-1 mora.

```
T7
```

### Fase 4 — As telas (6 tasks)

T-02, W-02, o arquivo e o estado vazio.

```
T8 → T9 → T10 → T11 → T12 → T13
```

## Tasks acrescentadas durante o Execute

Duas, ambas na Fase 2, ambas porque a tela precisava de uma capacidade que o
design system não tinha — o mesmo motivo que fez a spec 03 acrescentar o
`obscureText` no meio do Execute dela.

| # | Task | Por quê | Commit |
|---|---|---|---|
| **T3a** | `BoraAvatar` aceita o par de cores do contexto | O avatar de conta de `06` é sempre amarelo; o componente derivava a cor do nome | `c578218` |
| **T4a** | `MarcaBora` promovida a `BoraMarca` com `.header()` | Segundo uso real do logo; a promoção estava marcada no doc do original | `d9873c4` |

## Rodada de `code-review` do batch 1

14 achados, quatro deles verificados com probe em árvore pelo revisor. Sete
eram defeito real e foram fechados em `bf55f82` e `e2ab3e3`:

| Achado | Fechado em |
|---|---|
| Header sem `Material` acima: todo texto herdava o `_errorTextStyle` do `MaterialApp` e sairia com sublinhado duplo amarelo no app real | `bf55f82` |
| Barra renderizando em compacto, contra P1-1 AC1 e A-07 — T-03 apareceria com dois headers | `bf55f82` |
| Barra sem `SafeArea`, desenhada atrás da status bar | `bf55f82` |
| `async*` do repositório perdia emissão que chegasse durante a entrega da semente | `e2ab3e3` |
| Falha do stream zerava o estado e apagava o atalho do acerto para sempre | `e2ab3e3` |
| `HomeState` sem igualdade por valor: `emit` nunca descartava emissão repetida | `e2ab3e3` |
| `comConfirmacaoNova` só crescia: festa nova com nome repetido nascia com o atalho aceso | `e2ab3e3` |

> **Correção de uma afirmação minha.** A frase original desta seção dizia que os
> sete achados foram fechados "cada um com teste de regressão que falha sem a
> correção". O Verifier conferiu e mostrou que, **para os dois de `SafeArea`/
> inset, isso era falso**: removendo o `SafeArea` a suíte inteira continuava
> verde, porque `setSurfaceSize` reporta inset zero e nenhum teste montava um
> `MediaQuery` com notch. A rede só passou a existir na iteração 2 do Verifier
> (`app_shell_test.dart`, grupo "o inset do topo é consumido uma vez só").
> Correção feita porque a afirmação era verificável e estava errada — não
> porque o achado voltou.

**Requisito deferido, não imprecisão de spec.** W-02 pede "avatares 40px
empilhados" e define os 40px com precisão — não é caso de spec omissa. É um
**degrau de HOME-05 por entregar**, e está anotado como DEFERIDO em
`card_da_festa.dart`: subi-lo exige acrescentar um parâmetro de tamanho a
`BoraStackedAvatars`, que é extensão do design system e pede emenda de
fronteira própria. Arquivá-lo entre os spec-precision gaps esconderia trabalho
pendente atrás de "a spec não define", e por isso ele entra no relatório final
como pendência declarada.

Não acatados, com razão registrada: a generalização de `_temAcao` por rota
(uma ação existe hoje — generalizar antes da segunda é inventar contrato); o
`late final` da inscrição do bloc (defesa para cenário que nenhuma impl atual
produz); a varredura de pureza local no `app_shell.dart` (as guardas globais de
`token_purity_guard_test.dart` e `shape_and_shadow_guard_test.dart` já varrem
`lib/` inteira — duplicar seria o que o Check C manda remover); e a
identificação de festa por nome (limitação declarada no código, que se resolve
quando a spec 09 criar a identidade da festa).

---

## Task Breakdown

### T1: `ResumoDeFesta`

**What**: a festa como a Home precisa dela — a entidade composta mais os números que só esta tela mostra.
**Where**: `lib/features/home/domain/resumo_de_festa.dart`
**Depends on**: None
**Reuses**: `Festa`, `StatusDaFesta` (`core/calculo/dominio/`, AD-008) · o padrão de `==`/`hashCode` à mão de `festa.dart` e `usuario_logado.dart`
**Requirement**: HOME-19 (contrato) · base de HOME-04 e HOME-14

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Campos exatamente os do `design.md` §Data Models: `festa`, `confirmados`, `pendentes`, `iniciais`, `pessoas?`, `total?`
- [ ] `ehPassada` deriva de `festa.status`; `excedenteDeAvatares(visiveis)` usa `clamp` e **nunca** devolve negativo
- [ ] Igualdade por valor escrita à mão — o `Stream` compara emissões; `iniciais` comparada por conteúdo, não por identidade de lista
- [ ] O doc do campo cita a **AD-022** e o aperto 1: a divergência de RN-30 é só do `pendentes`
- [ ] Gate: `flutter test test/features/home/domain/resumo_de_festa_test.dart`
- [ ] Test count: 947 + novos, nenhum removido

**Tests**: unit · **Gate**: quick
**Commit**: `feat(home): resumo de festa como a home precisa dela`

---

### T2: Porta `FestaRepository` e a implementação em memória

**What**: o contrato de leitura da Home (um método) e a implementação que o M1 roda de verdade.
**Where**: `lib/features/home/domain/festa_repository.dart`, `lib/features/home/data/festa_repository_em_memoria.dart`
**Depends on**: T1
**Reuses**: o formato de porta de `core/autenticacao/dominio/autenticacao_repository.dart` (AD-019) — abstrata, sem Flutter na assinatura, com `dispose()`
**Requirement**: HOME-19 · A-01, A-02

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `Stream<List<ResumoDeFesta>> observarFestas()` e `Future<void> dispose()` — **um método de leitura só**; nada de criar, editar ou apagar, que é da spec 05
- [ ] `FestaRepositoryEmMemoria({List<ResumoDeFesta> inicial = const []})` — a semente entra **por injeção**, para `lib/` nunca importar `test/`
- [ ] `emitir(List<ResumoDeFesta>)` empurra estado novo a quem já assina
- [ ] Quem assina **depois** da primeira emissão recebe o último estado — sem isso o bloc perde a semente e o teste vira flaky por ordem
- [ ] `dispose()` fecha o controller; assinar depois de `dispose` não estoura
- [ ] Varredura afirmando que o arquivo de `lib/` não tem **linha de `import`** para `test/`, `fixtures` ou `flutter_test` — a varredura casa no import, **não** em texto do doc comment
- [ ] Gate: `flutter test test/features/home/data/festa_repository_em_memoria_test.dart`

**Tests**: unit · **Gate**: quick
**Commit**: `feat(home): porta de festas e implementação em memória`

---

### T3: Fixture estendida — as duas festas passadas (E-1)

**What**: acrescentar ao dado bruto de RN-30 as duas festas concluídas e montar a lista tipada que semeia os testes da Home.
**Where**: `test/fixtures/rn30_estado_inicial.dart` (**acrescentar**), `test/fixtures/festas_da_home.dart` (novo), `test/fixtures/festas_da_home_test.dart` (novo)
**Depends on**: T1
**Reuses**: `festaRn30`, `festaRn30Tipada` — lidos, **nunca** copiados (o padrão de `rn30_estado_inicial_tipado.dart`)
**Requirement**: HOME-14 · A-04

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Nada do que já existe em `rn30_estado_inicial.dart` é alterado — só acrescentado (**E-1**: reescrever apagaria a prova por mutação da fundação)
- [ ] `rn30_estado_inicial_test.dart` continua **intocado** e verde, incluindo a asserção de que 4+2 não fecha com as 5 pessoas
- [ ] "Churras da laje · 14 pessoas · R$ 612" documentada no código como **literal de UC-24**; a segunda festa documentada como **assumption A-04**, com as palavras "não é literal de spec"
- [ ] `festasDaHome` monta a lista de `ResumoDeFesta` da Home: a festa RN-30 (`confirmados: 4`, `pendentes: 2`, iniciais dos avatares) mais as duas passadas com `pessoas` e `total`
- [ ] Os números da Home são **lidos do bruto** (`confirmadosNaHome`/`pendentesNaHome`), não redigitados
- [ ] Gate: `flutter test` — a fixture é usada pela suíte inteira

**Tests**: unit · **Gate**: full
**Commit**: `test(fixtures): acrescenta as festas passadas de UC-24`

---

### T4: `AppShell` revestido — a barra de `06`

**What**: trocar o `KeyedSubtree` vazio pelo header de app de `06`: barra sticky, logo e avatar do usuário.
**Where**: `lib/core/routing/app_shell.dart` (modificar)
**Depends on**: None
**Reuses**: `BoraColors.paper/ink/yellow`, `BoraTextStyles`, `BoraBorders`, `BoraAvatar` · `UsuarioLogado.inicial` (AD-019) — a propriedade **já existe e já foi escrita para este AC**
**Requirement**: HOME-01, HOME-03

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `AppShell({required Widget child, UsuarioLogado? usuario})` — o usuário chega por parâmetro; o shell **não** resolve `getIt` nem observa a porta
- [ ] Barra no topo: fundo `paper`, borda inferior de **2px** `ink`, logo "BORA." e, à direita, o avatar de 36px amarelo com borda de 2px e a **inicial do usuário**
- [ ] `AppShell.chromeKey` **preservada** — os testes de FUND-08 dependem dela
- [ ] Zero literal de cor, fonte ou sombra no arquivo, afirmado por varredura de import/valor
- [ ] Gate: `flutter test`

**Tests**: widget · **Gate**: full *(o shell envolve sete rotas — a suíte inteira o observa)*
**Commit**: `feat(home): reveste o chrome do app com o header de 06`

---

### T5: Ação contextual "+ NOVO ROLÊ" e a ausência do voltar (E-3, primeira metade)

**What**: a ação do header que só existe na Home e só em expandido, e a fiação que leva a sessão até o shell.
**Where**: `lib/core/routing/app_shell.dart` (modificar), `lib/core/routing/app_router.dart` (**E-3**), `test/support/app_de_teste.dart` (**E-3**)
**Depends on**: T4
**Reuses**: `Routes.novoRole` · `LayoutMode`/`layoutModeForWidth` (AD-007) · a sessão já está no roteador desde a spec 03
**Requirement**: HOME-02 · A-06, A-07

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Em **expandido** e na Home, o header mostra "+ NOVO ROLÊ" e o toque navega para `/roles/novo`
- [ ] Em **compacto** a ação **não** renderiza (A-07 — T-02 não desenha barra de app nenhuma)
- [ ] Em rota logada que **não** é a Home, a ação não renderiza — o par que discrimina "contextual"
- [ ] Na Home **não** há botão voltar
- [ ] `buildAppRouter` passa `autenticacao.sessaoAtual` ao `AppShell`; `abrirApp` continua montando qualquer rota sem parâmetro novo obrigatório
- [ ] Gate: `flutter analyze && flutter test`

**Tests**: widget (rota) · **Gate**: build *(toca `app_router.dart`)*
**Commit**: `feat(home): ação contextual do header na home`

---

### T6: `PlaceholderPage` revestido

**What**: dar tokens ao destino provisório — quatro rotas alcançáveis da Home ainda caem nele no M1.
**Where**: `lib/core/routing/placeholder_page.dart` (modificar)
**Depends on**: None
**Reuses**: `BoraColors.paper`, `BoraTextStyles` (Archivo Black, caixa alta) · o padrão de revestimento de `route_error_page.dart` (spec 03, T16)
**Requirement**: HOME-18

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Fundo `paper`, título em Archivo Black caixa alta, tudo por token — **nenhum** literal de cor ou fonte
- [ ] `PlaceholderPage.keyFor(id)` **preservada**, com o teste existente de rota continuando verde
- [ ] O teste afirma os tokens **na árvore renderizada**, não a chamada
- [ ] Gate: `flutter test`

**Tests**: widget · **Gate**: full
**Commit**: `feat(home): reveste o placeholder com os tokens`

---

### T7: `HomeBloc`

**What**: o stream virando estado — e a derivação de "confirmação nova" (D-1).
**Where**: `lib/features/home/presentation/bloc/{home_bloc,home_event,home_state}.dart`
**Depends on**: T2, T3
**Reuses**: o formato de `entrar_bloc.dart` — estados explícitos, sem navegação · `AppLogger` (AD-005) · `RecordingAppLogger` (`test/support/`)
**Requirement**: HOME-16, HOME-19 · D-1

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Assina `observarFestas()` na criação e cancela em `close()` — inscrição vazada contamina o teste seguinte
- [ ] Estados `carregando | comFestas(ativas, passadas) | vazia | falhou`, separando por `ehPassada`
- [ ] **D-1**: `comFestas` carrega `confirmacaoNova` — `true` quando a emissão aumenta o `confirmados` de uma festa em relação à anterior; a **primeira** emissão é sempre `false`
- [ ] Erro do stream → estado `falhou` **e** `AppLogger.logError` chamado (HOME-16)
- [ ] O bloc **não navega** — a AD-020 vale igual aqui
- [ ] Par discriminante do logger: no caminho feliz, o `RecordingAppLogger` não gravou nada
- [ ] Gate: `flutter test test/features/home/presentation/bloc/home_bloc_test.dart`

**Tests**: unit · **Gate**: quick
**Commit**: `feat(home): bloc da home sobre o stream de festas`

---

### T8: `CardDaFesta` — o card de T-02

**What**: o card branco da festa que está chegando, com contadores, avatares e as três ações.
**Where**: `lib/features/home/presentation/widgets/card_da_festa.dart`
**Depends on**: T1
**Reuses**: `BoraSurface`, `BoraRotatedTag`, `BoraAvatar`, `BoraPrimaryButton`, `BoraSecondaryButton`, `BoraDashedNote` · `carregarFontesArchivo`, `pumpComponent` (`test/core/design_system/support/`)
**Requirement**: HOME-04 · HOME-09 (AC5) · HOME-10 (AC2, AC3)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Tag de data rotacionada **+3°** vazando o topo, título do rolê, avatares empilhados com o "+N" **tracejado**, linha "{n} confirmados · {n} pendentes" com **pendentes em vermelho**, "+ CONVIDAR" (secundário) e "MONTAR LISTA →" (primário)
- [ ] Atalho amarelo full-width "💸 VER O ACERTO DA FESTA →" renderiza **só** quando `confirmacaoNova`, com o par ausente afirmado — sem ele, um botão sempre visível passaria
- [ ] "+N": com 4 confirmados e 3 avatares visíveis lê "+1"; com 3 ou menos, **não** renderiza
- [ ] Com 0 pendentes a linha lê "0 pendentes" — sem esconder o termo e sem texto especial
- [ ] Nome longo quebra ou trunca **sem overflow** e sem scroll horizontal (W-R4)
- [ ] O card **não navega**: devolve os toques por callback
- [ ] Fontes reais carregadas no teste (`carregarFontesArchivo`) — sem elas o layout estoura por artefato
- [ ] Gate: `flutter test test/features/home/presentation/widgets/card_da_festa_test.dart`

**Tests**: widget · **Gate**: quick
**Commit**: `feat(home): card da festa que está chegando`

---

### T9: Seção "COMEÇAR OUTRA"

**What**: o grid de dois cards — CHURRASCO clicável e NIVER explicitamente inerte.
**Where**: `lib/features/home/presentation/widgets/comecar_outra.dart`
**Depends on**: None
**Reuses**: `BoraSurface`, `BoraDashedNote` · `carregarFontesArchivo`
**Requirement**: HOME-12, HOME-13

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Grid de 2 colunas com "🔥 CHURRASCO" e "🎈 NIVER · EM BREVE"
- [ ] CHURRASCO devolve o toque por callback; NIVER renderiza **tracejado e esmaecido** e é **inerte**: sem callback, sem toast, sem mudança de estado
- [ ] O par é o que discrimina: um teste que só afirmasse o toque do CHURRASCO passaria com o NIVER clicável
- [ ] Gate: `flutter test test/features/home/presentation/widgets/comecar_outra_test.dart`

**Tests**: widget · **Gate**: quick
**Commit**: `feat(home): seção começar outra com o niver inerte`

---

### T10: `HomePage` + `HomeCompacta` — T-02 montado e ligado (E-3, E-4)

**What**: a Home deixa de ser placeholder — página com bloc, layout compacto de T-02, navegação por toque, fiação no roteador e no DI, e a baseline migrada.
**Where**: `lib/features/home/presentation/pages/home_page.dart` (substituir o corpo), `lib/features/home/presentation/widgets/home_compacta.dart`, `lib/core/routing/app_router.dart` (**E-3**), `lib/core/di/injector.dart`, `test/support/app_de_teste.dart` (**E-3**), `test/app_test.dart` e `test/core/routing/app_router_shell_test.dart` (**E-4**)
**Depends on**: T7, T8, T9
**Reuses**: o padrão de `entrar_page.dart` — bloc e estado **acima** do `ResponsiveBuilder`, layouts só desenham · `Routes.montar/whatsapp/custos/novoRole`
**Requirement**: HOME-06, HOME-07, HOME-08, HOME-09, HOME-10, HOME-11, HOME-17

**Tools**: MCP: NONE · Skill: `run` (conferência visual de T-02)

**Done when**:
- [ ] `HomePage.pageKey` existe e a porta chega **pelo roteador** (`HomePage(festas: …)`), como `EntrarPage` recebe a de sessão
- [ ] Ordem de T-02 em compacto: "SEUS ROLÊS" → subtítulo → card da festa → "COMEÇAR OUTRA"
- [ ] Subtítulo **derivado** (A-05) com singular/plural certo; com a fixture lê exatamente "1 festa chegando · 2 passadas"
- [ ] Com a fixture, a linha de contadores lê exatamente "4 confirmados · 2 pendentes"
- [ ] **A transição de RN-28**: com a tela montada, `emitir` uma festa com um confirmado a mais leva a "5 confirmados · 1 pendente" **e** faz o atalho amarelo aparecer — sem `pumpWidget` novo e sem ação do usuário. É o aceite dos contadores (AD-022, aperto 2)
- [ ] Navegação por toque: "MONTAR LISTA →" → `/roles/{id}/montar`; "+ CONVIDAR" → `/roles/{id}/whatsapp`; atalho amarelo → `/roles/{id}/custos`; "🔥 CHURRASCO" → `/roles/novo`. O teste **abre e afirma o destino**, não o `context.go`
- [ ] Toque duplo em "MONTAR LISTA →" navega **uma** vez (HOME-17)
- [ ] `injector.dart` registra `FestaRepository` — em produção com semente **vazia**, porque a fixture é de teste e `lib/` não a importa; o app rodando abre no estado vazio de HOME-15 até a spec 05 criar festa
- [ ] **E-4**: as asserções que identificavam a Home por `PlaceholderPage.keyFor('home')` passam a usar `HomePage.pageKey`; o par com sessão × sem sessão de ENT-15/16 continua intacto e nenhuma asserção é removida
- [ ] Gate: `flutter analyze && flutter test`

**Tests**: widget + rota · **Gate**: build
**Commit**: `feat(home): tela seus rolês no mobile`

---

### T11: `HomeExpandida` — W-02

**What**: o layout web — linha de título com o subtítulo à direita e o grid de duas colunas.
**Where**: `lib/features/home/presentation/widgets/home_expandida.dart`
**Depends on**: T10
**Reuses**: `ResponsiveBuilder`/`LayoutMode` (AD-007) · os widgets de T8 e T9 — **os mesmos**, não cópias
**Requirement**: HOME-05 · HOME-10 (AC6)

**Tools**: MCP: NONE · Skill: `run` (conferência visual de W-02)

**Done when**:
- [ ] "SEUS ROLÊS" à esquerda e o subtítulo à direita **na mesma linha**; grid `1.15fr / 0.85fr` com o card à esquerda e "COMEÇAR OUTRA" à direita
- [ ] RN-28 vale igual em expandido: a mesma transição `4/2 → 5/1` e o mesmo atalho — W-02 diz literalmente "Regra RN-28 vale igual"
- [ ] Cruzar 900px com a Home montada troca o layout **preservando o estado do stream**, sem reassinar o repositório
- [ ] Nenhum scroll horizontal em 1180×800 (W-R4)
- [ ] Gate: `flutter test`

**Tests**: widget · **Gate**: full
**Commit**: `feat(home): tela seus rolês no web`

---

### T12: Seção "ARQUIVO"

**What**: as linhas das festas passadas, com o total formatado por RN-13.
**Where**: `lib/features/home/presentation/widgets/arquivo_de_festas.dart`
**Depends on**: T3, T11
**Reuses**: `MoneyFormatter` (`core/calculo/formatacao/`, RN-13) · `BoraSurface`
**Requirement**: HOME-14

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Uma linha por festa concluída: emoji · nome + "· {n} pessoas" · valor **em vermelho à direita**
- [ ] Com a fixture, uma linha lê "Churras da laje · 14 pessoas" com total "R$ 612" — o literal de UC-24
- [ ] O total vem do `MoneyFormatter` (inteiro, sem centavos, `pt-BR`); o teste afirma que passou pelo formatador, não um texto escrito à mão
- [ ] Em **compacto** a seção **não** renderiza; só conta no subtítulo (A-11)
- [ ] Tocar numa linha **não** navega (A-12) — par afirmado contra a rota corrente inalterada
- [ ] Gate: `flutter test test/features/home/presentation/widgets/arquivo_de_festas_test.dart`

**Tests**: widget · **Gate**: quick
**Commit**: `feat(home): arquivo de festas passadas`

---

### T13: A Home de quem não tem festa

**What**: o estado vazio nos dois layouts — o primeiro contato de todo usuário recém-cadastrado.
**Where**: `lib/features/home/presentation/widgets/{home_compacta,home_expandida}.dart` (modificar)
**Depends on**: T11, T12
**Reuses**: `ComecarOutra` (T9) — é o único caminho adiante e continua funcional
**Requirement**: HOME-15 · A-03

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Sem festa nenhuma: o card **não** renderiza, o subtítulo lê "nenhuma festa chegando", "COMEÇAR OUTRA" continua presente **e funcional** (o toque ainda navega) e a tela renderiza **sem exceção**
- [ ] Sem festa passada, o ARQUIVO renderiza vazio — sem linha e sem erro
- [ ] Com passadas e nenhuma chegando, o subtítulo lê "nenhuma festa chegando · 2 passadas" (A-05 nas duas metades)
- [ ] Vale nos dois viewports
- [ ] Gate: `flutter analyze && flutter test`

**Tests**: widget · **Gate**: build *(fecha a fase)*
**Commit**: `feat(home): estado vazio da home`

---

## Phase Execution Map

```
Fase 1 → Fase 2 → Fase 3 → Fase 4

Fase 1:  T1 ──→ T2 ──→ T3
Fase 2:  T4 ──→ T5 ──→ T6
Fase 3:  T7
Fase 4:  T8 ──→ T9 ──→ T10 ──→ T11 ──→ T12 ──→ T13
```

Dependências reais (o que bloqueia o quê):

```
T1 ──┬──→ T2 ──┬──→ T7 ──┐
     │         │         │
     ├──→ T3 ──┘         ├──→ T10 ──→ T11 ──┬──→ T12 ──┐
     │                   │                  │          ├──→ T13
     └──→ T8 ────────────┤                  └──────────┘
                         │
           T9 ───────────┘
           T3 ─────────────────────────────→ T12

T4 ──→ T5          (fiação do chrome, independente da cadeia de dado)
T6                 (revestimento isolado)
```

Execução estritamente sequencial — não há paralelismo dentro da fase.

**Empacotamento**: 13 tasks → dois batches de fases inteiras.

| Batch | Fases | Tasks | Total |
|---|---|---|---|
| 1 | 1 + 2 + 3 | T1–T7 | 7 |
| 2 | 4 | T8–T13 | 6 |

Mais de um batch ⇒ a oferta de sub-agentes se aplica. **Combinado registrado no handoff do `STATE.md`**: execução das tasks é **inline**; o **Verifier é sub-agente** e já está autorizado. Vale para esta spec.

---

## Task Granularity Check

| Task | Escopo | Status |
|---|---|---|
| T1: `ResumoDeFesta` | 1 classe de valor | ✅ Granular |
| T2: porta + impl em memória | 2 arquivos coesos — contrato + a única impl | ⚠️ OK — separá-los deixaria a porta sem teste (a matriz diz `none` para declaração pura) |
| T3: fixture estendida | 1 fixture + 1 derivação tipada | ✅ Granular |
| T4: `AppShell` revestido | 1 widget | ✅ Granular |
| T5: ação contextual + fiação | 1 comportamento do mesmo widget + 2 linhas de fiação | ✅ Granular |
| T6: `PlaceholderPage` revestido | 1 widget | ✅ Granular |
| T7: `HomeBloc` | 1 bloc (3 arquivos do mesmo conceito) | ✅ Granular |
| T8: `CardDaFesta` | 1 widget | ✅ Granular |
| T9: `ComecarOutra` | 1 widget | ✅ Granular |
| T10: `HomePage` + `HomeCompacta` + fiação | 1 tela e a ligação que a torna alcançável | ⚠️ OK — a task mais pesada; separar a fiação criaria uma task cujo código não é testável sozinho, e a Home ligada é o que se afirma |
| T11: `HomeExpandida` | 1 layout | ✅ Granular |
| T12: `ArquivoDeFestas` | 1 widget | ✅ Granular |
| T13: estado vazio | 1 comportamento nos dois layouts | ✅ Granular |

---

## Diagram-Definition Cross-Check

| Task | Depends on (corpo) | Diagrama mostra | Status |
|---|---|---|---|
| T1 | None | raiz | ✅ |
| T2 | T1 | T1 → T2 | ✅ |
| T3 | T1 | T1 → T3 | ✅ |
| T4 | None | raiz | ✅ |
| T5 | T4 | T4 → T5 | ✅ |
| T6 | None | raiz | ✅ |
| T7 | T2, T3 | T2 → T7, T3 → T7 | ✅ |
| T8 | T1 | T1 → T8 | ✅ |
| T9 | None | raiz | ✅ |
| T10 | T7, T8, T9 | T7 → T10, T8 → T10, T9 → T10 | ✅ |
| T11 | T10 | T10 → T11 | ✅ |
| T12 | T3, T11 | T3 → T12, T11 → T12 | ✅ |
| T13 | T11, T12 | T11 → T13, T12 → T13 | ✅ |

Nenhuma task depende de task em fase posterior.

---

## Test Co-location Validation

| Task | Camada criada/modificada | Matriz exige | Task diz | Status |
|---|---|---|---|---|
| T1 | Domínio da feature | unit | unit | ✅ |
| T2 | Porta (`none`) + dados (`unit`) → o maior vence | unit | unit | ✅ |
| T3 | Fixture de teste | unit | unit | ✅ |
| T4 | Chrome compartilhado + guarda de pureza | widget | widget | ✅ |
| T5 | Chrome + roteamento | widget | widget | ✅ |
| T6 | Chrome compartilhado | widget | widget | ✅ |
| T7 | BLoC | unit | unit | ✅ |
| T8 | Widget de feature | widget | widget | ✅ |
| T9 | Widget de feature | widget | widget | ✅ |
| T10 | Widget de tela + roteamento + DI | widget | widget + rota | ✅ |
| T11 | Widget de tela | widget | widget | ✅ |
| T12 | Widget de feature | widget | widget | ✅ |
| T13 | Widget de tela | widget | widget | ✅ |

Nenhuma task carrega `Tests: none`. Nenhum teste é adiado para task posterior.

---

## Cobertura de requisitos

| Requisito | Task |
|---|---|
| HOME-01 | T4 |
| HOME-02 | T5 |
| HOME-03 | T4 |
| HOME-04 | T8 |
| HOME-05 | T11 |
| HOME-06 | T10 |
| HOME-07 | T10 |
| HOME-08 | T10 |
| HOME-09 | T8 (avatares) + T10 (transição) |
| HOME-10 | T8 (par do atalho) + T10 (compacto) + T11 (expandido) |
| HOME-11 | T10 |
| HOME-12 | T9 |
| HOME-13 | T9 |
| HOME-14 | T12 |
| HOME-15 | T13 |
| HOME-16 | T7 |
| HOME-17 | T10 |
| HOME-18 | T6 |
| HOME-19 | T1, T2 |

**19/19 mapeados · 0 órfãos.**

### Edge cases da spec → onde são afirmados

| Edge case | Task |
|---|---|
| Mais de uma festa chegando — um card por festa, plural certo | T10 |
| 0 pendentes lê "0 pendentes" | T8 |
| "+N" mostra o excedente | T8 |
| 3 ou menos confirmados → sem "+N" | T8 |
| Cruzar 900px preserva o estado do stream | T11 |
| Nome longo sem overflow e sem scroll horizontal | T8 |
