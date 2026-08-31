# Montar — Tasks

## Execution Protocol (MANDATORY — do not skip)

Implement these tasks with the `tlc-spec-driven` skill: **activate it by name and follow its Execute flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the source of truth for the full flow (per-task cycle, sub-agent delegation, adequacy review, Verifier, discrimination sensor).

**If the skill cannot be activated, STOP and tell the user — do not proceed without it.**

---

**Spec**: `.specs/features/montar/spec.md`
**Design**: `.specs/features/montar/design.md`
**Status**: Draft
**Baseline na `main`**: **1137 testes verdes**, `flutter analyze` com zero issues. Nenhuma task pode reduzir esse número.

---

## Test Coverage Matrix

> Gerada do codebase, das diretrizes do projeto e da spec — confirmar antes do Execute.
> **Diretrizes encontradas**: `CLAUDE.md` §Testes (pirâmide completa: unit cobre toda `RN-xx`; cada critério de aceite de `UC-xx` vira widget test; `test/` espelha `lib/`; teste sai do critério de aceite, nunca da implementação) · `.specs/STATE.md` AD-005 (log afirmável por duplo), AD-014 (rota nova ⇒ teste que afirma o destino), AD-021 (`mocktail` só para SDK de terceiro; porta de domínio usa fake à mão) · `analysis_options.yaml` (`flutter_lints ^6.0.0`) · `pubspec.yaml` (`flutter_test`, `mocktail`; **sem** `bloc_test` — bloc é testado com `flutter_test` puro, como `test/features/home/presentation/bloc/home_bloc_test.dart`).
> **Sem cobertura por percentual** em lugar nenhum do projeto: o alvo é AC-a-AC, e é ele que vale.

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
|---|---|---|---|---|
| Domínio puro (`lib/core/festas/dominio/**`, `lib/features/montar/domain/**`) | unit | Todos os ramos; 1:1 com os AC da spec; **todo** edge case listado tem teste | `test/core/festas/dominio/*_test.dart` · `test/features/montar/domain/*_test.dart` | `flutter test` |
| Formatação em `core/calculo/formatacao/**` | unit | Todos os ramos + os casos-limite do formato (zero, inteiro, fracionário, plural) | `test/core/calculo/formatacao/*_test.dart` | `flutter test` |
| Repositório / porta de dado (`festa_repository_em_memoria.dart`) | unit | Caminhos de leitura e escrita + inexistente + a propriedade "criar em montar aparece na Home" | `test/features/home/data/*_test.dart` | `flutter test` |
| BLoC (`lib/features/montar/presentation/bloc/**`) | unit | Um teste por transição de estado; 1:1 com os AC; ordenação e falha inclusas | `test/features/montar/presentation/bloc/*_test.dart` | `flutter test` |
| Widget de tela (`lib/features/montar/presentation/{pages,widgets}/**`) | widget | Cada AC de UC-03/UC-04 que é observável na árvore, nas **duas** viewports (390×820 e 1180×800) | `test/features/montar/presentation/{pages,widgets}/*_test.dart` | `flutter test` |
| Rota (`lib/core/routing/app_router.dart`) | widget (rota) | Destino afirmado por `rotaAtual()`, **não** pelo widget montado — duas rotas montam a mesma tela | `test/core/routing/*_test.dart` | `flutter test` |
| Fronteira / varredura (guards) | unit (varredura de arquivo) | A violação quebra a suíte **nomeando o arquivo infrator** | `test/features/montar/architecture/*_test.dart` | `flutter test` |
| Copy (`*_textos.dart`) | unit | Todo literal da spec afirmado; toast comparado com o **token**, nunca com o literal *(L-008)* | `test/features/montar/presentation/*_test.dart` | `flutter test` |
| Documentação / spec (`.specs/**`) | none | — (sem gate de teste) | — | — |

## Gate Check Commands

> Descobertas do repositório (`pubspec.yaml`, `analysis_options.yaml`, `CLAUDE.md`) — **não há CI**, tudo roda local.

| Gate Level | When to Use | Command |
|---|---|---|
| **Quick** | Depois de task com teste unit/bloc só | `flutter test test/<caminho do arquivo de teste da task>` |
| **Full** | Depois de task com teste de widget ou de rota | `flutter test test/features/montar test/core/festas test/core/routing test/features/home` |
| **Build** | Fim de fase, e em toda task que toca `core/**` | `flutter analyze && flutter test` |

**Regra de ouro do handoff da spec 04, obrigatória aqui:** **confira o exit code do `flutter test` explicitamente.** `flutter test | tail` engole o código de saída, e isso já produziu um commit com o gate vermelho neste projeto. Use `flutter test; echo "exit=$?"` ou equivalente.

**Cota:** rodar `python .claude/scripts/cota.py` ao fim de cada task e em toda fronteira de fase (combinado ativo do projeto).

---

## Execution Plan

Fases ordenadas, executadas em sequência; tasks dentro de uma fase executam em ordem.

### Phase 1: A porta compartilhada e o formatador que falta (5 tasks)

Tudo que `montar` consome e ainda não existe. Nenhuma linha de UI.

```
T1 → T2 → T3 → T4 → T5
```

### Phase 2: O domínio de montar (3 tasks)

Dart puro, sem Flutter: seções, data default, rascunho.

```
T6 → T7 → T8
```

### Phase 3: O bloc (3 tasks)

O único lugar que chama a calculadora.

```
T9 → T10 → T11
```

### Phase 4: Widgets do formulário (4 tasks)

Compartilhados pelas duas plataformas — é o que faz W-R1 ser estrutural.

```
T12 → T13 → T14 → T15
```

### Phase 5: T-03, a tela compacta (3 tasks)

```
T16 → T17 → T18
```

### Phase 6: W-03, a tela expandida (3 tasks)

```
T19 → T20 → T21
```

### Phase 7: Página, rota e o guard que impede a fórmula de vazar (3 tasks)

```
T22 → T23 → T24
```

**Empacotamento previsto para o Execute** (~7 tasks por worker, fases inteiras, nunca partidas):

| Batch | Fases | Tasks |
|---|---|---|
| 1 | Phase 1 | T1–T5 (5) |
| 2 | Phase 2 + Phase 3 | T6–T11 (6) |
| 3 | Phase 4 + Phase 5 | T12–T18 (7) |
| 4 | Phase 6 + Phase 7 | T19–T24 (6) |

Batches rodam **em sequência** — nenhum começa antes de o anterior reportar todas as tasks completas. Ao fim do último, o **Verifier** roda automaticamente (autor ≠ verificador, evidence-or-zero).

---

## Task Breakdown

### T1: Registrar AD-029 no `STATE.md`

**What**: Acrescentar a decisão AD-029 (porta de edição de festa em `lib/core/festas/`) à seção `## Decisions` do `.specs/STATE.md`, com o texto que o `design.md` §12 já redigiu.
**Where**: `.specs/STATE.md` (só a seção `## Decisions`, ao fim)
**Depends on**: None
**Reuses**: O formato das AD-019 e AD-022 (Decision / Reason / Trade-off / Scope / Date / Status)
**Requirement**: pré-condição estrutural de MONT-16..MONT-18

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `AD-029` existe com os seis campos, `Status: active`, `Date: 2026-08-27`
- [x] Nenhuma AD existente é editada (nada vira `superseded`)
- [x] Nenhum arquivo de código é tocado

**Tests**: none (camada "Documentação / spec")
**Gate**: none
**Commit**: `docs(montar): registra a AD-029 da porta de edição de festa`

---

### T2: `FestaEmEdicao` e o barrel `core/festas`

**What**: O valor `{Festa festa, ComposicaoDaFesta composicao}` com `copyWith`, `==` e `hashCode` à mão, mais o barrel `festas.dart` como única porta de entrada.
**Where**: `lib/core/festas/festas.dart`, `lib/core/festas/dominio/festa_em_edicao.dart`
**Depends on**: T1
**Reuses**: `core/calculo/calculo.dart` (`Festa`, `ComposicaoDaFesta`); a forma de barrel de `autenticacao.dart` e `calculo.dart`; `==`/`hashCode` à mão como em `usuario_logado.dart` e `resumo_de_festa.dart`
**Requirement**: MONT-16, MONT-17, MONT-18

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `FestaEmEdicao` importa **só** de `core/calculo` — nenhum import de `features/**`, de Flutter ou de Firebase
- [x] `==` é por valor profundo: duas instâncias com a mesma festa e a mesma composição são iguais; trocar **qualquer** um dos dois campos as separa
- [x] `copyWith` preserva o campo não informado
- [x] O barrel exporta os dois arquivos de `dominio/` e nada mais
- [x] Gate `quick` passa; exit code conferido
- [x] ≥ 6 testes novos, suíte total ≥ 1143

**Tests**: unit
**Gate**: quick
**Commit**: `feat(festas): cria a festa em edição e o barrel da porta`

---

### T3: A porta `FestaEmEdicaoRepository` e a composição no `ResumoDeFesta`

**What**: A interface abstrata (`observarFesta` / `criarFesta` / `salvarFesta`) e o campo aditivo `composicao` em `ResumoDeFesta` (emenda **E-3**).
**Where**: `lib/core/festas/dominio/festa_em_edicao_repository.dart` (novo) · `lib/features/home/domain/resumo_de_festa.dart` (modifica) · `lib/core/festas/festas.dart` (export)
**Depends on**: T2
**Reuses**: A forma da porta de `FestaRepository` (Stream, doc explicando por que Stream e não Future — AD-016)
**Requirement**: MONT-16, MONT-17, MONT-18

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] A porta declara os três métodos com a assinatura do `design.md` §6.2 e **não** declara `dispose` (o ciclo de vida é da porta de leitura)
- [x] `ResumoDeFesta.composicao` tem default (composição vazia, 4h) e entra em `==` e `hashCode`
- [x] Dois `ResumoDeFesta` sem composição continuam iguais — a suíte da spec 04 roda **intacta**, sem edição de teste nenhum
- [x] Dois `ResumoDeFesta` que só diferem na composição **não** são iguais
- [x] `flutter analyze` limpo (o campo novo não quebra nenhum call site)
- [x] ≥ 4 testes novos; **nenhum** teste existente editado ou removido

**Tests**: unit
**Gate**: build (toca `core/**` e `features/home/domain/**`)
**Commit**: `feat(festas): declara a porta de edição e leva a composição para o resumo`

---

### T4: `FestaRepositoryEmMemoria` implementa a segunda porta

**What**: O store em memória passa a implementar `FestaEmEdicaoRepository` além de `FestaRepository` — uma instância, duas portas, o mesmo store (emenda **E-2**).
**Where**: `lib/features/home/data/festa_repository_em_memoria.dart` (modifica)
**Depends on**: T3
**Reuses**: O `Stream.multi` que já entrega o estado corrente antes de acompanhar as mudanças (o mesmo cuidado da janela de emissão perdida)
**Requirement**: MONT-16, MONT-17, MONT-18, MONT-21

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `observarFesta(id)` entrega o estado corrente **antes** de acompanhar mudanças, e emite de novo a cada `salvarFesta`
- [x] `observarFesta(id)` de festa inexistente emite `null` — não lança e não fica em silêncio
- [x] `criarFesta` devolve um id **novo e único** a cada chamada e a festa criada aparece em `observarFestas()` — a propriedade que faz o rolê de `/roles/novo` chegar na Home
- [x] `salvarFesta` de id inexistente é no-op observável (não cria festa fantasma) — comportamento declarado no doc
- [x] `salvarFesta` preserva `confirmados`, `pendentes` e `iniciais` do resumo: montar grava identidade e composição, **não** contadores (AD-022)
- [x] `observarFestas()` continua com o comportamento e a cobertura de antes — nenhum teste da spec 04 editado
- [x] Gate `build` passa; exit code conferido
- [x] ≥ 10 testes novos

**Tests**: unit
**Gate**: build
**Commit**: `feat(festas): o store em memória passa a criar e salvar festa`

---

### T5: `rotuloDeQuantidade` em `core/calculo/formatacao/`

**What**: `String rotuloDeQuantidade(double quantidade, UnidadeDeItem unidade)` — o rótulo "1,2 kg" / "8 latas" / "2 garrafas" / "1 kit" que a lista viva de W-03 exibe.
**Where**: `lib/core/calculo/formatacao/rotulo_de_quantidade.dart` (novo) · `lib/core/calculo/calculo.dart` (export)
**Depends on**: T4
**Reuses**: A forma e o contrato de `MoneyFormatter` e `rotuloDeDuracao` — "a UI recebe o rótulo pronto"
**Requirement**: MONT-11

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] O doc do arquivo abre com o **SPEC_DEVIATION** declarado: nenhuma RN define este rótulo, e ele nasce aqui porque a `spec.md` de `montar` proíbe formatação de número em `lib/features/montar/**`
- [x] Quantidade inteira sai **sem** casa decimal (`2 garrafas`, não `2,0 garrafas`)
- [x] Quantidade fracionária sai com **uma** casa decimal e vírgula do pt-BR (`1,2 kg`)
- [x] Plural correto por unidade nas sete de `UnidadeDeItem`, com o singular em 1 (`1 lata` / `2 latas`)
- [x] Zero tem rótulo definido e não quebra
- [x] O arquivo continua Dart puro — `calculo_isolation_test.dart` segue verde
- [x] Gate `build` passa; ≥ 12 testes novos (todas as sete unidades × inteiro/fracionário/singular)

**Tests**: unit
**Gate**: build
**Commit**: `feat(calculo): formata a quantidade de um item da lista`

---

### T6: `SecaoDaMontagem` — as seções e o mapa dos chips

**What**: O enum das três seções, o mapa `chipsPorSecao` com os 11 chips e a função `secaoDe(ChaveItem)` que resolve também o que não tem chip.
**Where**: `lib/features/montar/domain/secao_da_montagem.dart`
**Depends on**: T5
**Reuses**: `ChaveItem`, `ordemCanonicaDaLista`, `catalogoDeItens` de `core/calculo`
**Requirement**: MONT-01, MONT-11 (A-07, A-08), AD-018

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] Dart puro: nenhum import de Flutter (varredura própria ou asserção de import no teste)
- [x] `chipsPorSecao` tem exatamente 3 + 5 + 3 = **11** chips, na ordem literal de T-03/W-03
- [x] `PROS FORTES` existe (AD-018) com vodka, cachaça e whisky
- [x] `secaoDe(legumesParaGrelha)` = `naGrelha` **sem** que ele apareça em `chipsPorSecao` (A-08)
- [x] `secaoDe` dos quatro essenciais de RN-10 devolve `null` (A-06: não aparecem na lista viva)
- [x] Teste exaustivo: **todo** valor de `ChaveItem` tem resultado declarado — um item novo no enum quebra a suíte em vez de sumir da tela
- [x] Gate `quick` passa; ≥ 8 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(montar): declara as seções do formulário e da lista viva`

---

### T7: `proximoSabado` e o rótulo de data do rascunho

**What**: A data default do rascunho: o próximo sábado a partir de uma data injetada, formatado como `SÁB · 18 JUL`.
**Where**: `lib/features/montar/domain/data_do_role.dart`
**Depends on**: T6
**Reuses**: O formato literal de `Festa.data` (A-23 de `calculo`: rótulo, não `DateTime`)
**Requirement**: MONT-15 (A-04)

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `hoje` entra **por parâmetro** — nenhuma chamada a `DateTime.now()` dentro da função (é o que torna o default testável sem esperar sábado)
- [x] Sábado devolve o **próximo** sábado, não hoje — o caso que decide a regra
- [x] Domingo devolve o sábado dali a 6 dias
- [x] Virada de mês e virada de ano produzem o rótulo certo
- [x] O rótulo casa com o formato de `Festa.data` de T-02 (`SÁB · 18 JUL`), com o mês abreviado em CAIXA ALTA e em pt-BR
- [x] Os 12 meses têm abreviação declarada e testada
- [x] Dart puro, sem Flutter
- [x] Gate `quick` passa; ≥ 10 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(montar): calcula a data default do rolê novo`

---

### T8: `rascunhoInicial` — o rolê que `/roles/novo` abre

**What**: A `FestaEmEdicao` default: nome "CHURRAS NOVO", data do próximo sábado, contagem 0/0/0, os itens padrão de RN-30 e 4h.
**Where**: `lib/features/montar/domain/rascunho_inicial.dart`
**Depends on**: T7
**Reuses**: `FestaEmEdicao` (T2), `proximoSabado` (T7), `ChaveItem`
**Requirement**: MONT-15 (A-04), MONT-17

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] Nome = `CHURRAS NOVO`; data = próximo sábado; `hora` e `local` **vazios**, com o SPEC_PRECISION_GAP declarado no doc
- [x] Contagem = 0/0/0 e duração = 4
- [x] `itensSelecionados` = os sete itens padrão de RN-30 (bovina, frango, pão de alho, refrigerante, água, cerveja, cachaça)
- [x] **Teste de amarração**: `itensSelecionados` é igual a `itensPadraoRn30Tipados` da fixture — a declaração em `lib/` e a fixture não podem divergir
- [x] `lib/` continua sem importar `test/fixtures/` (a varredura existente segue verde)
- [x] `Festa.duracaoHoras` e `ComposicaoDaFesta.duracaoHoras` nascem iguais
- [x] Gate `quick` passa; ≥ 6 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(montar): abre o rolê novo com os itens padrão`

---

### T9: `MontarBloc` — o custo muda embaixo do dedo

**What**: Estado, eventos e os handlers de contagem, chip e duração, cada um terminando no **único** ponto que chama `CalculadoraDaFesta.calcular`.
**Where**: `lib/features/montar/presentation/bloc/{montar_bloc,montar_event,montar_state}.dart`
**Depends on**: T8
**Reuses**: `CalculadoraDaFesta`, `ComposicaoDaFesta`, `ContagemDePessoas.copyWith`; o padrão de `HomeBloc` (bloc não navega, AD-020) e de `home_bloc_test.dart` (`flutter_test` puro, sem `bloc_test`)
**Requirement**: MONT-04, MONT-05, MONT-07, MONT-14, MONT-20, MONT-24

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] `MontarState` carrega `festaId?`, `festa`, `composicao`, `resultado` e `falhouAoSalvar`, com `==` por valor
- [x] **Não existe** caminho de emissão que não passe por `_emitirComCalculo` — teste percorre todos os eventos e afirma que `resultado` mudou junto com `composicao`
- [x] **MONT-05, o aceite de UC-03**: com a composição de RN-30 (3H+3M+1C, 4h, os sete itens padrão), `resultado.totalDosItens` arredonda para `R$ 211` por `MoneyFormatter.reais` e `resultado.porCabeca` para `R$ 30` — afirmado contra o **token**, não contra o literal *(L-008)*
- [x] Stepper não desce de 0: `ContagemAlterada(homens, -1)` em 0 mantém 0 e **não** lança (MONT-14)
- [x] Zerar os três dá `totalDosItens == 0`, `porCabeca == 0` e `itens` vazia mesmo com chips marcados (UC-03 E1)
- [x] Alternar o mesmo chip duas vezes volta ao estado inicial — determinístico (MONT-20)
- [x] Duração 2h / 6h / 10h muda `resultado.fator` conforme RN-02 vindo da camada
- [x] Composição com pessoas nomeadas veggie / sem porco / que não bebem produz os efeitos de RN-21 em `resultado.itens` (MONT-24, lado consumo)
- [x] Gate `quick` passa; ≥ 20 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(montar): recalcula o custo a cada mudança do formulário`

---

### T10: `MontarBloc` — identidade e ciclo de vida da festa

**What**: Nome e data editáveis, abertura por `festaId` (carrega o salvo), abertura sem id (rascunho), e a criação da festa na primeira mudança.
**Where**: `lib/features/montar/presentation/bloc/montar_bloc.dart` (modifica) + eventos
**Depends on**: T9
**Reuses**: `FestaEmEdicaoRepository` (T3), `rascunhoInicial` (T8), o padrão de assinatura de stream na construção do `HomeBloc`
**Requirement**: MONT-15, MONT-16, MONT-17, MONT-18

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [x] Construído **sem** `festaId`: emite o rascunho e **não** grava nada — abrir `/roles/novo` não cria festa
- [x] Primeira mudança no rascunho: chama `criarFesta` **uma vez**, com a mudança já dentro, e o estado passa a ter `festaId`
- [x] Segunda mudança no mesmo rascunho **não** chama `criarFesta` de novo — chama `salvarFesta`
- [x] Construído **com** `festaId`: carrega a composição salva, não um rascunho novo (MONT-16)
- [x] `festaId` inexistente: emite rascunho em vez de quebrar; nenhuma exceção sobe
- [x] Nome apagado por completo volta ao default `CHURRAS NOVO` (P1-5 AC6) — e o teste falha se a defesa sair
- [x] Data editada é normalizada para CAIXA ALTA
- [x] Mudar a duração mantém `Festa.duracaoHoras` e `ComposicaoDaFesta.duracaoHoras` **iguais** no que é gravado
- [x] Emissão do repositório com a tela aberta atualiza o estado (é o contrato que sobrevive ao Firestore do M2)
- [x] Gate `quick` passa; ≥ 16 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(montar): cria e carrega o rolê que a tela edita`

---

### T11: `MontarBloc` — gravação coalescida, falha e "SALVAR ROLÊ"

**What**: O single-flight com coalescência do `design.md` §8.2, o caminho de falha (loga, preserva, não trava) e o evento do botão do rail.
**Where**: `lib/features/montar/presentation/bloc/montar_bloc.dart` (modifica)
**Depends on**: T10
**Reuses**: `AppLogger` (AD-005) e `RecordingAppLogger` de `test/support/`; o `copyWith` de `HomeBloc._aoFalhar` (falha não zera o que já chegou)
**Requirement**: MONT-19, MONT-21, MONT-23

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] N mudanças em rajada produzem **no máximo 2 gravações em voo**, e a **última** gravação carrega o estado mais novo — teste com repositório lento que registra a ordem e o payload de cada escrita (MONT-21)
- [ ] Nenhuma gravação com valor antigo chega depois de uma com valor novo — o teste falha se a coalescência sair
- [ ] Falha ao gravar: `logger.logError` recebe o erro **e** o stack, com `name: 'montar'`; `composicao` e `festa` do estado **não** são revertidas; `falhouAoSalvar` fica `true`
- [ ] Depois de uma falha a interação continua: a mudança seguinte recalcula e tenta gravar de novo, e `falhouAoSalvar` volta a `false` no sucesso
- [ ] Falha do stream de `observarFesta` segue o mesmo caminho e **mantém** o último estado bom
- [ ] `SalvarPedido` grava e sinaliza sucesso no estado, sem navegar (quem mostra o toast é a página)
- [ ] `close()` cancela a inscrição — nenhuma inscrição vazada entre testes
- [ ] Gate `quick` passa; ≥ 14 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(montar): grava o rolê sem perder a mudança mais nova`

---

### T12: `MontarTextos` — a copy literal das duas plataformas

**What**: Todos os literais de T-03 e W-03 num arquivo só, com os quatro rótulos que divergem declarados **em par** (A-09).
**Where**: `lib/features/montar/presentation/montar_textos.dart`
**Depends on**: T11
**Reuses**: A forma de `home_textos.dart` e `entrar_textos.dart`; `BoraToastTexts.roleSalvo`
**Requirement**: MONT-01, MONT-03, MONT-06, MONT-09, MONT-10, MONT-23

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Os literais da tabela do `design.md` §9 estão todos declarados, sem paráfrase
- [ ] Os quatro pares por plataforma existem separados: `CONFIRMADOS + EXTRAS SEM APP` / `QUEM CONFIRMOU` e `QUANTO TEMPO DE FESTA?` / `ATÉ QUE HORAS?`
- [ ] A frase do dinheiro difere por plataforma (`≈ R$ {x} / cabeça` × `dividido dá R$ {x} por cabeça`) e **as duas** recebem o valor já formatado
- [ ] O rótulo do card-herói monta `SAI POR · {N} PESSOAS · {duração}` com a duração vinda de `rotuloDeDuracao`
- [ ] Toast: o arquivo **referencia** `BoraToastTexts.roleSalvo`; nenhum literal `ROLÊ SALVO` é redigitado, e o teste compara com o token *(L-008)*
- [ ] Nenhum `R$` literal (RN-13 é da camada)
- [ ] Gate `quick` passa; ≥ 10 testes novos

**Tests**: unit
**Gate**: quick
**Commit**: `feat(montar): fixa a copy literal de T-03 e W-03`

---

### T13: `CardDeContagem` — os três steppers

**What**: O card com as linhas 👨 Homens / 👩 Mulheres / 🧒 Crianças, com o piso 0 refletido no controle.
**Where**: `lib/features/montar/presentation/widgets/card_de_contagem.dart`
**Depends on**: T12
**Reuses**: `BoraStepper` (o `onDecrementar: null` já entrega `opacity .7`), `BoraSurface`, `BoraTextStyles`
**Requirement**: MONT-01, MONT-02, MONT-14

**Tools**: MCP: NONE · Skill: `run` (conferência visual, se o caminho de captura estiver disponível)

**Done when**:
- [ ] As três linhas na ordem de T-03, com os emojis e os rótulos literais
- [ ] `+` e `−` emitem a intenção com o tipo de cabeça certo — teste que troca dois steppers e afirma que **não** cruzaram
- [ ] Em 0, o `−` daquela linha vem com `onDecrementar: null` e **não emite** ao ser tocado; as outras linhas seguem ativas
- [ ] O valor exibido é o recebido — o widget não guarda contagem própria
- [ ] Zero conta e zero `R$` no arquivo
- [ ] Gate `full` passa; ≥ 8 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(montar): desenha o card de quem vai`

---

### T14: `SecaoDeChips` e `SecaoDeDuracao`

**What**: Os dois blocos de controle do formulário: label + `Wrap` de chips dirigido por `chipsPorSecao`, e label + segmented de 2h/4h/6h/Dia.
**Where**: `lib/features/montar/presentation/widgets/{secao_de_chips,secao_de_duracao}.dart`
**Depends on**: T13
**Reuses**: `BoraSelectionChip`, `BoraSegmentedControl`, `SecaoDaMontagem` (T6), `catalogoDeItens` (nome e emoji)
**Requirement**: MONT-01, MONT-02

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Nome e emoji de cada chip vêm de `catalogoDeItens` — **nenhum** redigitado no widget
- [ ] Tocar um chip emite a `ChaveItem` dele; o chip selecionado renderiza o par `ink`/`cream` de §5 e o não selecionado o par branco/`ink` — afirmado contra o contrato do componente, **não** contra um literal de cor (**SPEC_DEVIATION** do `design.md` §11: a `spec.md` dizia "vermelho")
- [ ] O segmented tem exatamente uma opção ativa; tocar outra emite o índice tocado e o widget **não** muda sozinho
- [ ] `Dia` mapeia para 10 horas (RN-02) e o mapeamento é afirmado
- [ ] Os chips quebram linha (`Wrap`) sem estourar a largura em 390px — nenhum overflow em viewport compacta
- [ ] Zero conta e zero `R$` nos dois arquivos
- [ ] Gate `full` passa; ≥ 12 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(montar): desenha os chips e a duração da festa`

---

### T15: `FormularioDeMontagem` — as cinco seções, uma vez só

**What**: O formulário compartilhado pelas duas plataformas, recebendo por parâmetro os quatro rótulos que divergem.
**Where**: `lib/features/montar/presentation/widgets/formulario_de_montagem.dart`
**Depends on**: T14
**Reuses**: T13, T14, `MontarTextos` (T12), `SecaoDaMontagem` (T6)
**Requirement**: MONT-01, MONT-09, W-R1

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Ordem literal: contagem → NA GRELHA → NA GELADEIRA → PROS FORTES → duração
- [ ] Montado com os rótulos mobile, exibe `CONFIRMADOS + EXTRAS SEM APP` e `QUANTO TEMPO DE FESTA?`; com os rótulos web, exibe `QUEM CONFIRMOU` e `ATÉ QUE HORAS?` — **e o resto da árvore é o mesmo** (é a prova de W-R1)
- [ ] Os 11 chips estão presentes nas duas configurações, incluindo PROS FORTES no mobile (AD-018)
- [ ] Todo callback chega a quem montou, sem transformação
- [ ] Gate `full` passa; ≥ 8 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(montar): monta o formulário compartilhado pelas duas telas`

---

### T16: `CabecalhoDoRole` — nome e data editáveis

**What**: O bloco de identidade do rolê: rótulo que vira `BoraTextField` no toque, commit ao confirmar, volta ao default quando o nome é apagado.
**Where**: `lib/features/montar/presentation/widgets/cabecalho_do_role.dart`
**Depends on**: T15
**Reuses**: `BoraTextField`, `BoraTextStyles`; o `FocusNode` opcional que o componente já aceita
**Requirement**: MONT-15

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Fora de edição mostra nome e data como texto; ao ser acionado, vira campo **na própria tela**, sem navegação e sem tela nova (A-03)
- [ ] Confirmar emite o novo valor; o widget **não** guarda o valor como verdade — ele reflete o que recebe
- [ ] Nome apagado por completo emite vazio, e é o bloc que devolve o default (a divisão de responsabilidade é afirmada nos dois lados)
- [ ] Data editada é emitida em CAIXA ALTA
- [ ] Sair do campo sem confirmar não perde o que foi digitado nem grava lixo — comportamento declarado e testado
- [ ] Gate `full` passa; ≥ 8 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(montar): deixa nome e data do rolê editáveis no header`

---

### T17: `RodapeDoCusto` — o "SAI POR" de T-03

**What**: O rodapé fixo com label, total, a linha `≈ R$ {x} / cabeça` e o CTA `FECHAR LISTA →`.
**Where**: `lib/features/montar/presentation/widgets/rodape_do_custo.dart`
**Depends on**: T16
**Reuses**: `BoraFooterBar`, `BoraPrimaryButton`, `MoneyFormatter`, `MontarTextos`
**Requirement**: MONT-03, MONT-05, MONT-06, MONT-07

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Exibe `SAI POR`, o total e a sublinha, com os dois valores vindos de `MoneyFormatter.reais` — comparados no teste com o **token**, nunca com um literal *(L-008)*
- [ ] Com a composição de RN-30, a árvore renderizada contém `R$ 211` e `≈ R$ 30 / cabeça` — **o aceite de UC-03 na tela**
- [ ] O divisor é **pessoas** (criança inclusive) e o rótulo é `/ cabeça`; um teste com composição em que "por cabeça" e "por adulto" **divergem** prova que a tela mostra o primeiro (RN-14, A-05)
- [ ] Total com centavos exibe o inteiro de RN-13
- [ ] O CTA emite uma vez por toque
- [ ] Gate `full` passa; ≥ 10 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(montar): mostra o SAI POR no rodapé de T-03`

---

### T18: `MontarCompacto` — T-03 inteiro

**What**: A tela compacta: header com voltar + `A CONTA DO ROLÊ` + identidade, formulário rolando, rodapé fixo.
**Where**: `lib/features/montar/presentation/widgets/montar_compacto.dart`
**Depends on**: T17
**Reuses**: T15, T16, T17; a forma de `home_compacta.dart`
**Requirement**: MONT-01, MONT-02, MONT-03, MONT-14

**Tools**: MCP: NONE · Skill: `run`

**Done when**:
- [ ] Em 390×820 renderiza, na ordem de T-03: voltar, título, identidade, as cinco seções, rodapé fixo
- [ ] O rodapé fica **fixo** — o formulário rola por baixo dele, e o teste prova rolando
- [ ] Zerar os três steppers deixa o rodapé em `R$ 0` e o `−` inerte nas três linhas (UC-03 E1 na tela)
- [ ] Nenhum overflow em 390×820, com todos os chips e as quatro seções (AD-018 alonga a rolagem)
- [ ] O voltar emite a intenção de voltar (quem navega é a página)
- [ ] Gate `full` passa; ≥ 10 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(montar): entrega a tela T-03 no compacto`

---

### T19: `ListaViva` — as categorias com subtotal

**What**: A lista do rail: uma seção por categoria não vazia, com linha por item (emoji, nome, quantidade, valor) e uma linha `SUBTOTAL`, rolando dentro de 330px.
**Where**: `lib/features/montar/presentation/widgets/lista_viva.dart`
**Depends on**: T18
**Reuses**: `BoraListCard`/`BoraListRow`, `secaoDe` (T6), `totalExato` (`core/calculo`), `rotuloDeQuantidade` (T5), `MoneyFormatter`
**Requirement**: MONT-11, MONT-13, MONT-24

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] Agrupa por `SecaoDaMontagem` na ordem NA GRELHA → NA GELADEIRA → PROS FORTES, e dentro de cada uma na ordem de `ordemCanonicaDaLista` (A-07)
- [ ] Subtotal por categoria vem de `totalExato` — o arquivo **não** contém `fold`, `reduce`, `*`, `/` nem `R$`
- [ ] **Sem** botão `QUEM LEVA?` e **sem** a dica 💡 (A-02, AD-018)
- [ ] **Sem** essenciais: com a composição de RN-30, carvão, gelo, sal grosso e copos & pratos **não** aparecem, e a soma dos subtotais bate com o total do card-herói (A-05, A-06)
- [ ] Categoria sem item selecionado **não** renderiza seção vazia
- [ ] Lista vazia (0 pessoas) não renderiza card nenhum e não quebra
- [ ] Com pessoas veggie, `Legumes p/ grelha` aparece em NA GRELHA sem ter chip (A-08, MONT-24)
- [ ] Excedendo 330px, rola **dentro do próprio contêiner** — o teste prova rolando a lista sem rolar a página
- [ ] Gate `full` passa; ≥ 14 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(montar): desenha a lista viva agrupada por categoria`

---

### T20: `RailDoCusto` — o rail sticky de W-03

**What**: Card-herói escuro + lista viva + `MANDAR NO GRUPO 📲` + `SALVAR ROLÊ`, nesta ordem.
**Where**: `lib/features/montar/presentation/widgets/rail_do_custo.dart`
**Depends on**: T19
**Reuses**: `BoraHeroCard`, `BoraPrimaryButton`, `BoraSecondaryButton`, `ListaViva` (T19), `rotuloDeDuracao`, `MoneyFormatter`
**Requirement**: MONT-10, MONT-13, MONT-23

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] A ordem dos blocos é afirmada por posição na árvore, não por presença
- [ ] O card-herói exibe `SAI POR · {N} PESSOAS · {duração}`, o total e `dividido dá R$ {x} por cabeça` — todos os valores por `MoneyFormatter` / `rotuloDeDuracao`
- [ ] Duração 10h exibe `Dia todo`, não `10 horas` (A-15)
- [ ] `SALVAR ROLÊ` é ação secundária e emite sem navegar; `MANDAR NO GRUPO 📲` emite a saída
- [ ] O rail tem 370px e **não rola com a página** — sticky por construção
- [ ] Zero conta e zero `R$` literal no arquivo
- [ ] Gate `full` passa; ≥ 10 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(montar): monta o rail sticky do custo`

---

### T21: `MontarExpandido` — W-03 inteiro

**What**: A tela expandida: linha de título com a identidade à direita, grid `1fr / 370px`, formulário à esquerda, rail à direita, **sem** rodapé fixo.
**Where**: `lib/features/montar/presentation/widgets/montar_expandido.dart`
**Depends on**: T20
**Reuses**: T15, T16, T20; a forma de `home_expandida.dart` (container, padding, flex em inteiros)
**Requirement**: MONT-09, MONT-10, MONT-12, MONT-13

**Tools**: MCP: NONE · Skill: `run`

**Done when**:
- [ ] Em 1180×800 renderiza `A CONTA DO ROLÊ` à esquerda e `{NOME} · {DATA}` à direita da linha de título
- [ ] Usa os rótulos de W-03 (`QUEM CONFIRMOU`, `ATÉ QUE HORAS?`), não os do mobile
- [ ] **Não existe** `BoraFooterBar` na árvore (W-R2, MONT-13) — asserção de ausência
- [ ] **Zero scroll horizontal** em 1180×800 e em 900×800 (W-R4) — afirmado pela extensão do scrollable, não por inspeção visual
- [ ] Mudar um chip atualiza card-herói **e** lista viva na mesma interação (MONT-12), provado com um único `pump`
- [ ] Gate `full` passa; ≥ 10 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(montar): entrega a tela W-03 no expandido`

---

### T22: `MontarPage` — bloc, responsivo, navegação e toast

**What**: A página que substitui o placeholder: provê o bloc acima do `ResponsiveBuilder`, troca de layout, navega e mostra o toast.
**Where**: `lib/features/montar/presentation/pages/montar_page.dart` (substitui o placeholder)
**Depends on**: T21
**Reuses**: A forma inteira de `home_page.dart` (bloc acima do responsivo, deps pelo roteador, `context.go` em toque de botão), `BoraToast`, `BoraToastTexts.roleSalvo`
**Requirement**: MONT-12, MONT-17, MONT-22, MONT-23

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `MontarPage({String? festaId, required FestaEmEdicaoRepository festas, required AppLogger logger})` com `static const Key pageKey = Key('montar')`
- [ ] O bloc vive **acima** do `ResponsiveBuilder`: cruzar 900px com a tela montada preserva a composição inteira (W-R3 + W-R1) — o teste redimensiona e afirma o estado
- [ ] `FECHAR LISTA →` chama `Routes.lista(festaId)`; `MANDAR NO GRUPO 📲` chama `Routes.whatsapp(festaId)`; o voltar chama `Routes.roles` (MONT-22)
- [ ] Toque duplo no CTA navega **uma vez** (MONT-20)
- [ ] `SALVAR ROLÊ` concluído mostra o toast comparado com `BoraToastTexts.roleSalvo` — 1 por vez, some sozinho (RN-29)
- [ ] Ganhar `festaId` dispara `context.replace` para `/roles/{festaId}/montar` — **não** `go`, para o rascunho não ficar no histórico
- [ ] Gate `full` passa; ≥ 12 testes novos

**Tests**: widget
**Gate**: full
**Commit**: `feat(montar): liga a tela ao bloc e às saídas`

---

### T23: Fiação de rota e injeção (E-4, E-5)

**What**: O roteador passa a construir `MontarPage` com o `festaId` da rota e a porta injetada; o injector registra a segunda porta sobre a **mesma** instância; `abrirApp` ganha o parâmetro.
**Where**: `lib/core/routing/app_router.dart` (modifica) · `lib/core/di/injector.dart` (modifica) · `test/support/app_de_teste.dart` (modifica)
**Depends on**: T22
**Reuses**: O precedente de `HomePage(festas:, logger:)` no mesmo roteador; o registro `registerLazySingleton` com `dispose` do injector
**Requirement**: MONT-16, MONT-17, MONT-22

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] `/roles/novo` monta `MontarPage(festaId: null, …)` e `/roles/:festaId/montar` monta com o id **da URL** — o `const MontarPage()` some das duas rotas
- [ ] O comentário do desvio (**E-4**) fica no roteador, no formato `SPEC_DEVIATION` que o arquivo já usa
- [ ] `FestaRepository` e `FestaEmEdicaoRepository` resolvem para a **mesma instância** — teste que cria festa pela porta de edição e a vê em `observarFestas()`
- [ ] O `dispose` continua registrado **uma vez só** — nenhum controller fechado duas vezes
- [ ] `abrirApp` aceita a porta de edição com **default**; nenhum teste existente muda
- [ ] Testes de rota afirmam `rotaAtual()`, não o widget montado — as duas rotas montam a mesma tela
- [ ] `/roles/novo` sem sessão continua indo para `/entrar` (AD-017 herdada)
- [ ] Da Home, `🔥 CHURRASCO` chega em `/roles/novo` montável; a primeira mudança leva a rota a `/roles/{id}/montar` **e a composição segue igual** (MONT-17 + MONT-18 ponta a ponta)
- [ ] Gate `build` passa; ≥ 12 testes novos; suíte inteira verde
**Tests**: widget (rota)
**Gate**: build
**Commit**: `feat(montar): liga as rotas de montar à porta de edição`

---

### T24: O guard que impede a fórmula de vazar

**What**: A varredura de `lib/features/montar/**` do `design.md` §13 mais o teste comportamental que mata um formatador escrito à mão.
**Where**: `test/features/montar/architecture/formula_nao_vaza_test.dart`
**Depends on**: T23
**Reuses**: A mecânica de `test/architecture/calculo_isolation_test.dart` e `design_system_boundary_test.dart` (varredura que **nomeia o arquivo infrator**)
**Requirement**: MONT-08

**Tools**: MCP: NONE · Skill: NONE

**Done when**:
- [ ] A varredura remove comentários (`//`, `///`, `/* */`) e literais de string antes de procurar operador — `import '../../x.dart'` não é falso positivo
- [ ] As cinco regras do `design.md` §13 estão implementadas e **cada uma** tem teste próprio provando que ela pega o caso que devia pegar (a varredura é exercitada contra um trecho sintético infrator, não só contra o código limpo)
- [ ] A mensagem de falha nomeia o **arquivo e a regra** violada
- [ ] **Teste comportamental**: uma composição com total fracionário renderiza o valor igual a `MoneyFormatter.reais(resultado.totalDosItens)` — um formatador próprio que arredondasse diferente morre aqui, mesmo passando na varredura
- [ ] `lib/features/montar/**` passa nas cinco regras **sem exceção declarada**
- [ ] Gate `build` passa; suíte inteira verde; `flutter analyze` zero issues
- [ ] ≥ 8 testes novos

**Tests**: unit (varredura) + widget (comportamental)
**Gate**: build
**Commit**: `test(montar): impede a fórmula de vazar para a tela`

---

## Phase Execution Map

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6 → Phase 7

Phase 1:  T1 ──→ T2 ──→ T3 ──→ T4 ──→ T5
Phase 2:  T6 ──→ T7 ──→ T8
Phase 3:  T9 ──→ T10 ──→ T11
Phase 4:  T12 ──→ T13 ──→ T14 ──→ T15
Phase 5:  T16 ──→ T17 ──→ T18
Phase 6:  T19 ──→ T20 ──→ T21
Phase 7:  T22 ──→ T23 ──→ T24
```

Execução estritamente sequencial — não há paralelismo dentro da fase. As tasks formam **uma cadeia**: cada uma depende da anterior, o que torna qualquer corte de batch seguro desde que caia em fronteira de fase.

---

## Task Granularity Check

| Task | Escopo | Status |
|---|---|---|
| T1 | 1 bloco de doc | ✅ Granular |
| T2 | 1 valor + 1 barrel | ✅ Granular |
| T3 | 1 interface + 1 campo | ✅ Granular (coesos: o campo existe para a interface) |
| T4 | 1 classe (modifica) | ✅ Granular |
| T5 | 1 função | ✅ Granular |
| T6 | 1 enum + 1 mapa + 1 função, mesmo arquivo | ✅ Granular (coeso) |
| T7 | 1 função + tabela de meses | ✅ Granular |
| T8 | 1 função | ✅ Granular |
| T9 | 1 bloc (estado, eventos, cálculo) | ⚠️ 3 arquivos, mas é **um** conceito indivisível — estado sem evento não compila |
| T10 | 1 bloc (modifica) | ✅ Granular |
| T11 | 1 bloc (modifica) | ✅ Granular |
| T12 | 1 arquivo de copy | ✅ Granular |
| T13 | 1 widget | ✅ Granular |
| T14 | 2 widgets irmãos | ⚠️ OK — mesma seção do formulário, mesma dependência |
| T15 | 1 widget composto | ✅ Granular |
| T16 | 1 widget | ✅ Granular |
| T17 | 1 widget | ✅ Granular |
| T18 | 1 widget de tela | ✅ Granular |
| T19 | 1 widget | ✅ Granular |
| T20 | 1 widget | ✅ Granular |
| T21 | 1 widget de tela | ✅ Granular |
| T22 | 1 página | ✅ Granular |
| T23 | 1 fiação (3 arquivos, 1 conceito) | ⚠️ OK — rota, injeção e o helper de teste são **a mesma** ligação; separá-los deixaria código não testável |
| T24 | 1 arquivo de guard | ✅ Granular |

Nenhum ❌. Os três ⚠️ são coesão legítima, não agrupamento preguiçoso.

---

## Diagram-Definition Cross-Check

| Task | Depends On (corpo) | Diagrama mostra | Status |
|---|---|---|---|
| T1 | None | (início) | ✅ Match |
| T2 | T1 | T1 → T2 | ✅ Match |
| T3 | T2 | T2 → T3 | ✅ Match |
| T4 | T3 | T3 → T4 | ✅ Match |
| T5 | T4 | T4 → T5 | ✅ Match |
| T6 | T5 | T5 → T6 (fronteira P1→P2) | ✅ Match |
| T7 | T6 | T6 → T7 | ✅ Match |
| T8 | T7 | T7 → T8 | ✅ Match |
| T9 | T8 | T8 → T9 (fronteira P2→P3) | ✅ Match |
| T10 | T9 | T9 → T10 | ✅ Match |
| T11 | T10 | T10 → T11 | ✅ Match |
| T12 | T11 | T11 → T12 (fronteira P3→P4) | ✅ Match |
| T13 | T12 | T12 → T13 | ✅ Match |
| T14 | T13 | T13 → T14 | ✅ Match |
| T15 | T14 | T14 → T15 | ✅ Match |
| T16 | T15 | T15 → T16 (fronteira P4→P5) | ✅ Match |
| T17 | T16 | T16 → T17 | ✅ Match |
| T18 | T17 | T17 → T18 | ✅ Match |
| T19 | T18 | T18 → T19 (fronteira P5→P6) | ✅ Match |
| T20 | T19 | T19 → T20 | ✅ Match |
| T21 | T20 | T20 → T21 | ✅ Match |
| T22 | T21 | T21 → T22 (fronteira P6→P7) | ✅ Match |
| T23 | T22 | T22 → T23 | ✅ Match |
| T24 | T23 | T23 → T24 | ✅ Match |

Nenhuma dependência aponta para fase posterior.

---

## Test Co-location Validation

| Task | Camada criada/modificada | Matriz exige | Task diz | Status |
|---|---|---|---|---|
| T1 | Documentação / spec | none | none | ✅ OK |
| T2 | Domínio puro (`core/festas/dominio`) | unit | unit | ✅ OK |
| T3 | Domínio puro + entidade de `home/domain` | unit | unit | ✅ OK |
| T4 | Repositório / porta de dado | unit | unit | ✅ OK |
| T5 | Formatação em `core/calculo/formatacao` | unit | unit | ✅ OK |
| T6 | Domínio puro (`montar/domain`) | unit | unit | ✅ OK |
| T7 | Domínio puro | unit | unit | ✅ OK |
| T8 | Domínio puro | unit | unit | ✅ OK |
| T9 | BLoC | unit | unit | ✅ OK |
| T10 | BLoC | unit | unit | ✅ OK |
| T11 | BLoC | unit | unit | ✅ OK |
| T12 | Copy (`*_textos.dart`) | unit | unit | ✅ OK |
| T13 | Widget de tela | widget | widget | ✅ OK |
| T14 | Widget de tela | widget | widget | ✅ OK |
| T15 | Widget de tela | widget | widget | ✅ OK |
| T16 | Widget de tela | widget | widget | ✅ OK |
| T17 | Widget de tela | widget | widget | ✅ OK |
| T18 | Widget de tela | widget | widget | ✅ OK |
| T19 | Widget de tela | widget | widget | ✅ OK |
| T20 | Widget de tela | widget | widget | ✅ OK |
| T21 | Widget de tela | widget | widget | ✅ OK |
| T22 | Widget de tela (página) | widget | widget | ✅ OK |
| T23 | Rota + injeção | widget (rota) | widget (rota) | ✅ OK |
| T24 | Fronteira / varredura | unit (varredura) | unit + widget | ✅ OK (acima do mínimo) |

Nenhuma ❌ VIOLATION. Nenhuma task adia teste para outra.

---

## Ferramentas por task (MCP e Skills)

Não há MCP configurado neste projeto — todas as tasks usam as ferramentas nativas. As skills que se aplicam:

| Skill | Onde | Por quê |
|---|---|---|
| `tlc-spec-driven` | **todas** | O protocolo de execução, obrigatório |
| `run` | T13, T18, T21 | Conferência visual da tela real, como os combinados da spec 04 pedem. **Bloqueio de acesso**: se a captura em 390×820 continuar cortando (a pendência aberta de T-02), **pular e anotar no relatório final** — não travar a task |
| `cota` | fim de cada task e de cada fase | Combinado ativo do projeto |
| `code-review` | fim de cada batch | Combinado ativo; os dois padrões que ele achou na spec 04 estão em §Risks do `design.md` |

---

## Rastreabilidade — requisito → task

| Requisito | Task(s) |
|---|---|
| MONT-01 | T6, T12, T13, T14, T15, T18 |
| MONT-02 | T13, T14, T18 |
| MONT-03 | T12, T17, T18 |
| MONT-04 | T9 |
| MONT-05 | T9, T17 |
| MONT-06 | T12, T17 |
| MONT-07 | T9, T17 |
| MONT-08 | T24 |
| MONT-09 | T12, T15, T21 |
| MONT-10 | T12, T20 |
| MONT-11 | T5, T6, T19 |
| MONT-12 | T21, T22 |
| MONT-13 | T19, T20, T21 |
| MONT-14 | T9, T13, T18 |
| MONT-15 | T7, T8, T10, T16 |
| MONT-16 | T2, T3, T4, T10, T23 |
| MONT-17 | T2, T3, T4, T8, T10, T22, T23 |
| MONT-18 | T2, T3, T4, T10, T23 |
| MONT-19 | T11 |
| MONT-20 | T9, T22 |
| MONT-21 | T4, T11 |
| MONT-22 | T22, T23 |
| MONT-23 | T11, T12, T20, T22 |
| MONT-24 | T6, T9, T19 |

**Cobertura**: 24 de 24 requisitos com task dona. **0 órfãos**, **0 tasks sem requisito**.

---

## Success Criteria da feature (da `spec.md`, conferidos ao fim)

- [ ] `flutter analyze` zero issues · suíte verde · **≥ 1137 + ~230 testes novos**, baseline preservada
- [ ] Aceite de UC-03 **na tela**, nas duas plataformas: `R$ 211` e `≈ R$ 30 / cabeça` renderizados
- [ ] Aceite de UC-04: nenhum botão "calcular"; qualquer toque atualiza total e per capita
- [ ] Guard de MONT-08 verde, sem exceção declarada
- [ ] W-03 funcional: rail sticky, lista viva rolando dentro de si, zero scroll horizontal, sem rodapé fixo
- [ ] Zerar a festa dá `R$ 0` e lista vazia; steppers não descem de 0
- [ ] AD-029 registrada no `STATE.md`
