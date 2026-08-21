# Cálculo — Tasks

## Execution Protocol (MANDATORY — do not skip)

Implement these tasks with the `tlc-spec-driven` skill: **activate it by name and follow its Execute flow and Critical Rules.** Do not search for skill files by filesystem path. The skill is the source of truth for the full flow (per-task cycle, sub-agent delegation, adequacy review, Verifier, discrimination sensor).

**If the skill cannot be activated, STOP and tell the user — do not proceed without it.**

---

**Spec**: `.specs/features/calculo/spec.md` · **Design**: `.specs/features/calculo/design.md`
**Status**: Draft — aguardando aprovação
**Decisões ativas**: AD-001..AD-007 (`.specs/STATE.md`) + as três candidatas deste design (entidades em `core/calculo/dominio/`, política de precisão, leitura (a) de RN-10)

**Ferramentas do Execute**: só as ferramentas nativas — nenhum MCP configurado, nenhuma skill auxiliar (por isso todo `Tools:` abaixo diz `MCP: NONE` / `Skill: NONE`). **Nenhuma verificação desta spec é manual**: a camada é Dart puro e roda inteira em `flutter test`.

---

## ⛔ Fronteira de arquivos (worktree em execução paralela)

A spec 01 `design-system` está sendo implementada **ao mesmo tempo**, em outra worktree. Tocar em arquivo dela conflita no merge e derruba os dois workflows.

**Pode tocar:** `lib/core/calculo/**` · `test/core/calculo/**` · `test/fixtures/rn30_estado_inicial_tipado*.dart` (arquivos **novos**).
**Proibido:** `pubspec.yaml` (nenhuma dependência nova — nem `intl`, nem `meta`) · `lib/core/design_system/**` · `lib/core/routing/**` · `.specs/STATE.md` · `.specs/ROADMAP.md` · `.specs/LESSONS.md` · `.specs/lessons.json`.
**Intocáveis por contrato de teste:** `test/fixtures/rn30_estado_inicial.dart` e `test/fixtures/rn30_estado_inicial_test.dart` — a validação da fundação provou por mutação que aquelas asserções discriminam. Nenhuma pode ser enfraquecida, reescrita ou apagada (ver T28).

**Baseline no início do Execute:** `flutter test` = **92 testes passando**, `flutter analyze` = limpo. Toda contagem de "novos testes" abaixo é acréscimo sobre esses 92.

---

## Test Coverage Matrix

> Gerada de guidelines do projeto + spec + amostragem do repositório. **Guidelines encontradas**: `CLAUDE.md` (§Decisões de engenharia → "Unit — cobrem toda `RN-xx` em `core/calculo/`", "Os exemplos numéricos de `03` entram como casos de teste **literais**", "Teste sai do critério de aceite, nunca da implementação", "`test/` espelha a estrutura de `lib/`"). **Amostragem**: 92 testes existentes em `test/architecture/`, `test/core/{di,firebase,observability,responsive,routing}/`, `test/bootstrap/`, `test/fixtures/` — estilo `group('FUND-xx — …')` + `test('frase em minúscula descrevendo o comportamento')`, `expect` com `reason` quando a falha precisa explicar. Esta spec mantém o padrão, trocando `FUND-xx` por `CALC-xx`. Não há `CONTRIBUTING.md`, config de cobertura nem CI.

| Code Layer | Required Test Type | Coverage Expectation | Location Pattern | Run Command |
|---|---|---|---|---|
| `lib/core/calculo/regras/` (fórmulas RN-xx) | unit | **Todos os ramos; 1:1 com os ACs de `CALC-xx`; todo edge case listado na spec tem teste dedicado.** Os exemplos numéricos do arquivo 03 entram como asserção **literal**, não como ilustração | `test/core/calculo/regras/*_test.dart` | `flutter test` |
| `lib/core/calculo/dominio/` (entidades e catálogos) | unit | Construção, igualdade de valor, imutabilidade, campos anuláveis, e **conferência literal** dos dados de catálogo contra o texto do arquivo 03 | `test/core/calculo/dominio/*_test.dart` | `flutter test` |
| `lib/core/calculo/formatacao/` (RN-13) | unit | Todos os ramos + fronteiras (0, fracionário, `.5`, milhar, negativo) | `test/core/calculo/formatacao/*_test.dart` | `flutter test` |
| `lib/core/calculo/calculo.dart` (barrel) | unit | Um teste que importa **só** o barrel e reproduz o caso literal — se algo público não estiver exportado, não compila | `test/core/calculo/calculo_test.dart` | `flutter test` |
| Casos literais do arquivo 03 (transversais) | unit | Os **quatro**, num arquivo único e visível: R$ 211/≈R$ 30 · R$ 271/≈R$ 45 · Teste A · Teste B | `test/core/calculo/casos_literais_do_arquivo_03_test.dart` | `flutter test` |
| `test/fixtures/rn30_estado_inicial_tipado.dart` | unit | Campo a campo contra RN-30 + `null` preservado na Duda | `test/fixtures/rn30_estado_inicial_tipado_test.dart` | `flutter test` |
| Isolamento Dart puro de `lib/core/calculo/` | unit | **Já existe** (`test/architecture/calculo_isolation_test.dart`, FUND-06). Nenhum teste novo — mas ele roda em todo gate e reprova qualquer import de Flutter/Firebase que entre na pasta | `test/architecture/calculo_isolation_test.dart` | `flutter test` |
| Widget / integration / e2e | **fora de escopo** | Nenhum `CALC-xx` renderiza nada. `core/calculo` não pode importar Flutter (FUND-06), então widget test aqui seria impossível por construção. Os fluxos ponta-a-ponta nascem da spec 05 em diante | — | — |
| Config | none | Nenhum arquivo de config é tocado nesta spec (`pubspec.yaml` é proibido) | — | — |

## Gate Check Commands

> Derivados do `CLAUDE.md` e confirmados contra o repositório: os 92 testes atuais rodam por `flutter test`, e `flutter analyze` termina limpo.

| Gate Level | When to Use | Command |
|---|---|---|
| Quick | Após qualquer task com unit test (todas, exceto nenhuma) | `flutter test` |
| Full | Idem — **não há suíte e2e nesta spec**, então Full ≡ Quick | `flutter test` |
| Build | Fim de fase, task do barrel e task da fixture tipada | `flutter analyze && flutter test` |

**Regra em todo gate:**
1. `flutter analyze` precisa terminar com **zero issues**.
2. `test/architecture/calculo_isolation_test.dart` precisa continuar verde — é o que impede a fórmula de importar Flutter ou Firebase.
3. Nenhum teste pode ser enfraquecido, pulado (`skip`) ou apagado para o portão passar. **Se um caso literal do arquivo 03 falhar, o errado é o código** (`CLAUDE.md`).
4. A contagem total de testes só sobe. Se cair, alguma coisa foi silenciosamente removida.

---

## Execution Plan

Fases ordenadas, executadas em sequência; dentro da fase, as tasks rodam na ordem numérica.

### Phase 1: Base sem dependência (T1–T6)

Entidades-folha, o fator de duração, as primitivas de precisão e o formatador. Nada aqui depende de nada — é o chão de que todas as fórmulas dependem.

```
T1   T2   T3   T4   T5   T6
```

### Phase 2: Catálogo e quantidades automáticas (T7–T13)

O catálogo de preços-base da calculadora e uma task por família de fórmula (RN-03..RN-09).

```
T7 ──→ T8
T3, T5 ──→ T9
T5 ──→ T10   T5 ──→ T11   T5 ──→ T12   T5 ──→ T13
```

### Phase 3: Lista calculada, preferências e custo ao vivo (T14–T18)

Onde as fórmulas viram uma lista e um total — e onde o caso literal R$ 211 / R$ 271 fecha.

```
T7, T8 ──→ T14 ─┐
T1 ──→ T15 ─────┤
T4, T9..T13 ────┴→ T16 ──→ T17
T7, T8 ──→ T18
```

### Phase 4: Racha e acerto (T19–T23)

Contribuições, cota, saldos, quem-paga-quem (com os Testes A e B), split e quitação.

```
T8 ──→ T19 ─┬→ T20 ──→ T21 ──→ T23
            └→ T22
```

### Phase 5: Preço de mercado e pedido (T24–T26)

RN-11 (fonte de preço **separada**) e os totais de RN-27.

```
T7 ──→ T24 ──→ T25
T8 ──→ T26
```

### Phase 6: Superfície pública e fixture tipada (T27–T28)

```
T1..T26 ──→ T27 ──→ T28
```

---

## Task Breakdown

### T1: `Pessoa` e os enums do domínio

**What**: criar `Pessoa` e os quatro enums que ela e `Festa` usam, com `dieta` e `bebe` **anuláveis**.
**Where**: `lib/core/calculo/dominio/{dieta,papel_na_festa,status_de_presenca,status_da_festa,pessoa}.dart`, `test/core/calculo/dominio/pessoa_test.dart`
**Depends on**: None
**Reuses**: vocabulário do arquivo 01 §6/§7; chaves brutas de `test/fixtures/rn30_estado_inicial.dart`
**Requirement**: CALC-05

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `Dieta { tudo, veggie, semPorco }`, `PapelNaFesta { anfitriao, coAnfitriao, convidado, soVe }`, `StatusDePresenca { confirmado, pendente, recusou }` e `StatusDaFesta { chegando, passada }` existem, cada valor com a `chave` string do arquivo 01 §6 (`tudo`/`veggie`/`semporco`, `host`/`cohost`/`guest`/`viewer`) e um `porChave` que devolve `null` para chave desconhecida
- [x] `Pessoa` é imutável, `const`, com `nome`, `papel`, `status`, `dieta` (`Dieta?`), `bebe` (`bool?`), `voce`, `copyWith` e `String get inicial` derivado do nome
- [x] `==`/`hashCode` escritos à mão — **`package:meta` não é importado** (A-19: é dependência transitiva e derruba `flutter analyze`)
- [x] `dieta`/`bebe` `null` significa **não declarado** e é distinto de `Dieta.tudo` / `false` (A-08)
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥6 (igualdade de valor · imutabilidade via `copyWith` · `null` ≠ `false` · `null` ≠ `Dieta.tudo` · `inicial` · `porChave` de chave desconhecida)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): adiciona pessoa e os enums do domínio`

---

### T2: `Festa`

**What**: a entidade de identidade da festa, com os campos que a spec declara e **sem** os que ela não declara.
**Where**: `lib/core/calculo/dominio/festa.dart`, `test/core/calculo/dominio/festa_test.dart`
**Depends on**: None
**Reuses**: `StatusDaFesta` (T1 cria; se ainda não existir na ordem de execução, esta task não bloqueia — o enum vive em arquivo próprio)
**Requirement**: CALC-05

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `Festa` imutável e `const` com `nome`, `data` (`String`), `hora` (`String`), `local`, `duracaoHoras` (`int`), `status` (`StatusDaFesta`, default `chegando`) e `copyWith`
- [x] `data` e `hora` são **rótulos literais** (`SÁB · 18 JUL`, `14H`), não `DateTime` — A-23: converter exigiria inventar ano e fuso
- [x] **Sem** `link` e **sem** `nivelDoLink` — são RN-22/RN-23, domínio de `galera` (A-21); o doc comment diz isso
- [x] `==`/`hashCode` à mão, sem `package:meta`
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥3 (igualdade · `copyWith` não muta a original · default de `status`)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): adiciona a entidade festa`

---

### T3: `ContagemDePessoas` — RN-01

**What**: a contagem do card "CONFIRMADOS + EXTRAS SEM APP", única fonte de cabeças do produto.
**Where**: `lib/core/calculo/dominio/contagem_de_pessoas.dart`, `test/core/calculo/dominio/contagem_de_pessoas_test.dart`
**Depends on**: None
**Reuses**: —
**Requirement**: CALC-01

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `ContagemDePessoas({int homens = 0, int mulheres = 0, int criancas = 0})` com `int get adultos => homens + mulheres` e `int get pessoas => adultos + criancas`
- [x] Valor negativo em qualquer campo **lança `ArgumentError`** nomeando o campo — por isso o construtor **não é `const`** (construtor `const` não lança); o doc comment registra a troca
- [x] `copyWith` e `==`/`hashCode` presentes
- [x] Doc comment declara A-05/A-22: é **um tipo só**, cobrindo confirmados **e** extras sem app; pessoas nomeadas entram com preferências, não com cabeça, porque `Pessoa` não tem sexo
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥6 (3H+3M+1C → 6 adultos e 7 pessoas · zeros → 0 · só crianças → 0 adultos · negativo em homens/mulheres/crianças lança)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): conta adultos e pessoas`

---

### T4: `fatorDuracao` — RN-02

**What**: o fator que multiplica **todo** consumível.
**Where**: `lib/core/calculo/regras/fator_duracao.dart`, `test/core/calculo/regras/fator_duracao_test.dart`
**Depends on**: None
**Reuses**: `dart:math`
**Requirement**: CALC-02

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `double fatorDuracao(num horas)` → `math.max(0.5, horas / 4)` — **nome exigido pelo `CLAUDE.md`**, não renomear
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥6 (2h→0.5 · 4h→1.0 · 6h→1.5 · 10h→2.5 · 1h→0.5 e 0h→0.5, as duas fronteiras do piso)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): calcula o fator de duração da festa`

---

### T5: Primitivas de precisão

**What**: as três primitivas numéricas de que toda regra depende — e a que desarma a armadilha de ponto flutuante do arredondamento de 0,1 kg.
**Where**: `lib/core/calculo/regras/precisao.dart`, `test/core/calculo/regras/precisao_test.dart`
**Depends on**: None
**Reuses**: `dart:math`
**Requirement**: CALC-07 (fronteira de arredondamento), CALC-21 (tolerância)

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `double kgArredondadoEmDecimos(double gramas)` → `(gramas / 100).round() / 10` — arredonda **em gramas**, nunca em kg
- [x] O doc comment registra o porquê: `(1.15 * 10).round()` devolve **11** (o binário guarda 11,499999…) e daria 1,1 kg, quebrando o R$ 211 (risco R-1 do design)
- [x] `int unidadesComPisoDeUm(double bruto)` → `math.max(1, bruto.ceil())`
- [x] `const double toleranciaDeCentavo = 0.01` e `bool ehZeroNaTolerancia(double valor)`
- [x] Nenhum outro arquivo da camada usa literal `0.01`, `100` de arredondamento ou `.round()` de quantidade — tudo passa por aqui
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥9 (1149 g→1,1 · **1150 g→1,2** · 1151 g→1,2 · 0 g→0,0 · piso: 0,1→1, 1,0→1, 1,45→2, 17,14→18 · tolerância: 0,01 é zero, 0,011 não é)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): isola as primitivas de arredondamento e tolerância`

---

### T6: `MoneyFormatter` e rótulo de duração — RN-13

**What**: a única forma de escrever dinheiro no produto (contrato de fronteira nº 2 com a spec 01) e o rótulo de horas.
**Where**: `lib/core/calculo/formatacao/money_formatter.dart`, `lib/core/calculo/formatacao/rotulo_de_duracao.dart`, `test/core/calculo/formatacao/{money_formatter,rotulo_de_duracao}_test.dart`
**Depends on**: None
**Reuses**: nada — **`intl` não pode ser adicionado** (`pubspec.yaml` é do workflow paralelo, A-18)
**Requirement**: CALC-03, CALC-04

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `abstract final class MoneyFormatter { static String reais(num valor); }` → `R$ ` + `valor.round()`, milhar agrupado com `.` (pt-BR), **sem centavos e sem separador decimal**
- [x] `String rotuloDeDuracao(int horas)` → `2 horas` · `4 horas` · `6 horas` · `Dia todo` para 10
- [x] O doc comment declara o contrato: **a UI nunca formata dinheiro por conta própria** — recebe string pronta ou chama esta função
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥11 (0→`R$ 0` · 30,14→`R$ 30` · 210,6→`R$ 211` · 270,6→`R$ 271` · 30,5→`R$ 31` (meio para cima) · 1234→`R$ 1.234` · 1000000→`R$ 1.000.000` · negativo → sinal antes do `R$` · nenhuma saída contém `,` · rótulos 2/4/6/10)

**Tests**: unit
**Gate**: build
**Commit**: `feat(calculo): formata dinheiro e duração em pt-br`

---

### T7: `ChaveItem`, `UnidadeDeItem` e o catálogo da calculadora

**What**: os 16 itens com preço-base, unidade e passo — a fonte de preço de RN-03..RN-10, que **nunca** se mistura com a de RN-11.
**Where**: `lib/core/calculo/dominio/chave_item.dart`, `lib/core/calculo/dominio/catalogo_de_itens.dart`, `test/core/calculo/dominio/{chave_item,catalogo_de_itens}_test.dart`
**Depends on**: None
**Reuses**: preços literais de RN-03..RN-10; nomes e emojis de T-03 e RN-10/RN-21; chaves de `itensPadraoRn30`
**Requirement**: CALC-07..CALC-14 (dados-base), CALC-15 (ordem canônica), CALC-17 (passos)

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `ChaveItem` com os 16 valores e a `chave` snake_case: `bovina`, `suina`, `frango`, `paoDeAlho` (`pao_de_alho`), `refrigerante`, `suco`, `agua`, `cerveja`, `vodka`, `cachaca`, `whisky`, `legumesParaGrelha`, `carvao`, `gelo`, `salGrosso`, `coposEPratos`; `static ChaveItem? porChave(String)`
- [x] As sete chaves de `itensPadraoRn30` (`bovina`, `frango`, `pao_de_alho`, `refrigerante`, `agua`, `cerveja`, `cachaca`) resolvem — teste explícito cruzando com a fixture bruta
- [x] `UnidadeDeItem { kg, unidade, garrafa, lata, litro, saco, kit }`
- [x] `DefinicaoDeItem` com `chave`, `nome`, `emoji`, `unidade`, `precoBase`, `passoDeQuantidade`, `essencial`, `fonteDaProporcao?`, `quantidadeDefault?`, `entraNoTotal`
- [x] `catalogoDeItens` cobre os **16** com os preços literais do arquivo 03: 45 · 28 · 18 · 6 · 9 · 8 · 3 · 4 · 40 · 15 · 90 · **28** (kit veggie, A-10 — o doc comment cita a lacuna: RN-03..RN-09 não dão preço e R$ 28 é o único número que a spec associa ao item, via RN-11) · 22 · 10 · 8 · 15
- [x] Passos de RN-12 no catálogo: carnes **0,5** · cerveja **2** · demais **1**
- [x] `entraNoTotal` é `false` **só** em `coposEPratos`; o doc comment do campo registra a decisão do usuário (leitura (a) de RN-10, 2026-08-20) e diz o efeito de virá-lo: R$ 286 e ≈R$ 48/adulto
- [x] `ordemCanonicaDaLista` fixa a ordem estável de saída
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥8 (16 chaves únicas · `porChave` ida e volta · chave desconhecida → `null` · as 7 chaves da fixture resolvem · preços literais item a item · passos 0,5/2/1 · só `coposEPratos` com `entraNoTotal: false` · `ordemCanonicaDaLista` cobre o catálogo sem repetir)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): adiciona o catálogo de itens da calculadora`

---

### T8: `ItemDeLista` e `OverrideDeItem`

**What**: o item calculado, com quantidade e preço automáticos, os overrides opcionais e os valores derivados.
**Where**: `lib/core/calculo/dominio/item_de_lista.dart`, `test/core/calculo/dominio/item_de_lista_test.dart`
**Depends on**: T7
**Reuses**: `ChaveItem`, `UnidadeDeItem`
**Requirement**: CALC-05, CALC-17

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `ItemDeLista` imutável com `chave`, `nome`, `emoji`, `unidade`, `quantidadeAutomatica`, `precoBase`, `quantidadeOverride?`, `precoOverride?`, `essencial`, `fonteDaProporcao?`, `quemLeva?`, `noCarrinho`
- [x] Derivados: `quantidade` (override ?? automática), `preco` (override ?? base), `valor = quantidade × preco`, `editado` (qualquer override presente)
- [x] `OverrideDeItem { double? quantidade; double? preco; }`
- [x] `copyWith` e `==`/`hashCode`; `quemLeva` é o **nome** da pessoa (A-24) e `noCarrinho` é estado de `lista`, guardado aqui só porque o arquivo 01 §6 o declara no item — o doc comment diz isso
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥7 (`valor` com e sem override de quantidade · com e sem override de preço · `editado` falso sem override · verdadeiro com cada um dos dois · igualdade · `copyWith` não muta)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): adiciona o item de lista com overrides`

---

### T9: Quantidade de carne — RN-03

**What**: gramas totais, divisão entre as carnes selecionadas e o arredondamento a 0,1 kg com piso de 0,5 kg.
**Where**: `lib/core/calculo/regras/quantidade_de_carne.dart`, `test/core/calculo/regras/quantidade_de_carne_test.dart`
**Depends on**: T3, T5
**Reuses**: `kgArredondadoEmDecimos` (T5), `ContagemDePessoas` (T3)
**Requirement**: CALC-07

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `double gramasDeCarne({required ContagemDePessoas contagem, required double fator})` → `(H×400 + M×300 + C×200) × f`
- [x] `double kgPorCarne({required double gramasTotais, required int carnesSelecionadas})` → `max(0,5; kgArredondadoEmDecimos(gramasTotais / carnes))`
- [x] `carnesSelecionadas == 0` devolve **0,0** sem dividir — nenhuma divisão por zero
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥8 (3H+3M+1C f=1 → **2300 g** · ÷2 carnes → **1,2 kg** · ÷1 carne → 2,3 kg · ÷3 carnes → 0,8 kg · f=0,5 → 1150 g · piso: 400 g ÷ 1 → **0,5 kg** · 0 carnes → 0,0 · a fronteira 1150 g → 1,2 kg reafirmada aqui, não só em T5)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): calcula a quantidade de carne por pessoa`

---

### T10: Pão de alho e água — RN-04, RN-08

**What**: os dois consumíveis proporcionais ao total de pessoas.
**Where**: `lib/core/calculo/regras/quantidades_por_pessoa.dart`, `test/core/calculo/regras/quantidades_por_pessoa_test.dart`
**Depends on**: T5
**Reuses**: `unidadesComPisoDeUm` (T5)
**Requirement**: CALC-08, CALC-12

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `int unidadesDePaoDeAlho({required int pessoas, required double fator})` → `max(1, ceil(pessoas × 0,5 × f))`
- [x] `int garrafasDeAgua({required int pessoas, required double fator})` → `max(1, ceil(pessoas × 400 × f / 1500))`
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥8 (pão: 7 pessoas f=1 → **4 un** · 1 pessoa → 1 (piso) · 2 pessoas f=0,5 → 1 · 8 pessoas → 4 (sem `ceil` supérfluo) · água: 7 pessoas f=1 → **2 gf** (2800/1500 = 1,867) · 3 pessoas → 1 · 1 pessoa → 1 (piso) · fronteira exata 1500 ml → 1 gf)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): calcula pão de alho e água por pessoa`

---

### T11: Refrigerante e suco — RN-06, RN-07

**What**: as duas bebidas que somam adultos e crianças com volumes diferentes.
**Where**: `lib/core/calculo/regras/quantidades_de_bebida.dart`, `test/core/calculo/regras/quantidades_de_bebida_test.dart`
**Depends on**: T5
**Reuses**: `unidadesComPisoDeUm` (T5)
**Requirement**: CALC-10, CALC-11

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `int garrafasDeRefrigerante({required int adultos, required int criancas, required double fator})` → `max(1, ceil((A×400 + C×500) × f / 2000))`
- [x] `int litrosDeSuco({required int adultos, required int criancas, required double fator})` → `max(1, ceil((A×250 + C×400) × f / 1000))`
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥8 (refri: 6A+1C f=1 → **2 gf** (2900/2000 = 1,45) · 0A+0C → 1 (piso) · só crianças conta 500 ml cada · f=2,5 escala · suco: 6A+1C f=1 → 2 L (1900/1000) · piso · só adultos · fronteira exata 2000 ml → 1 gf)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): calcula refrigerante e suco`

---

### T12: Cerveja — RN-05

**What**: a única bebida que RN-21 vai redimensionar depois — por isso o parâmetro já nasce como "quem bebe", não "adultos".
**Where**: `lib/core/calculo/regras/quantidade_de_cerveja.dart`, `test/core/calculo/regras/quantidade_de_cerveja_test.dart`
**Depends on**: T5
**Reuses**: `unidadesComPisoDeUm` (T5)
**Requirement**: CALC-09

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `int latasDeCerveja({required int adultosQueBebem, required double fator})` → `max(1, ceil(bebem × 1000 × f / 350))`
- [x] `adultosQueBebem == 0` devolve **0**, não 1 — A-12: o piso existe para não comprar "0,4 lata" quando **há** plateia, não para comprar cerveja para plateia nenhuma
- [x] O nome do parâmetro é `adultosQueBebem` desde já, e o doc comment aponta RN-21/A-06 como quem o preenche
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥6 (6 adultos f=1 → **18 latas** (17,14) · 1 adulto → 3 · f=0,5 com 6 → 9 · f=2,5 com 6 → 43 · 0 que bebem → **0** · fronteira exata 350 ml → 1)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): calcula cerveja por quem bebe`

---

### T13: Destilados — RN-09

**What**: ml por destilado dividido entre os selecionados, com garrafa de 1 L.
**Where**: `lib/core/calculo/regras/quantidade_de_destilado.dart`, `test/core/calculo/regras/quantidade_de_destilado_test.dart`
**Depends on**: T5
**Reuses**: `unidadesComPisoDeUm` (T5)
**Requirement**: CALC-13

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `int garrafasPorDestilado({required int adultos, required double fator, required int destiladosSelecionados})` → `ml = adultos × 120 × f / n`; `max(1, ceil(ml / 1000))`
- [x] `adultos == 0` **ou** `destiladosSelecionados == 0` devolve **0** (A-12) — e nenhuma divisão por zero
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥6 (6 adultos f=1 n=1 → **720 ml → 1 gf** · n=2 → 360 ml → 1 gf cada · 10 adultos f=1 n=1 → 1200 ml → 2 gf · f=2,5 escala · 0 adultos → 0 · 0 selecionados → 0)

**Tests**: unit
**Gate**: build
**Commit**: `feat(calculo): calcula garrafas de destilado`

---

### T14: Essenciais automáticos — RN-10

**What**: os quatro itens que entram sozinhos e a distinção **aparecer na lista × somar no total**.
**Where**: `lib/core/calculo/regras/essenciais.dart`, `test/core/calculo/regras/essenciais_test.dart`
**Depends on**: T7, T8
**Reuses**: `catalogoDeItens` (T7), `ItemDeLista` (T8)
**Requirement**: CALC-14

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `List<ItemDeLista> essenciaisAutomaticos()` devolve **os quatro** com as quantidades default de RN-10 (1 saco de carvão · **3** sacos de gelo · 1 kg de sal · 1 kit), `essencial: true` e `fonteDaProporcao` preenchida (`kg de carne`, `volume de bebida gelada`, `kg de carne`, `nº de pessoas`)
- [x] As quantidades são **fixas nos defaults** — RN-10 dá o badge de proporcionalidade mas **nenhuma fórmula**, e inventar escala mudaria o R$ 271 (A-09, risco R-7). O doc comment declara isso
- [x] `double totalDosEssenciais(Iterable<ItemDeLista> essenciais)` soma **só** os de `entraNoTotal` verdadeiro
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥6 (quatro itens, nesta ordem · valores 22 / **30** (3 × 10) / 8 / 15 · **total = 60,00** · Copos & pratos **está na lista** e **fora do total** · todos com `essencial: true` · cada `fonteDaProporcao` literal de RN-10)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): adiciona os essenciais automáticos da lista`

---

### T15: Efeitos das preferências — RN-21

**What**: kit veggie, remoção da suína, cerveja por quem bebe, e o resumo agregado com omissão de termos zerados.
**Where**: `lib/core/calculo/regras/preferencias.dart`, `test/core/calculo/regras/preferencias_test.dart`
**Depends on**: T1
**Reuses**: `Pessoa`, `Dieta` (T1)
**Requirement**: CALC-15

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [x] `EfeitosDasPreferencias` com `veggies`, `semPorco`, `bebem`, `incluirKitVeggie`, `removerSuina`, `adultosQueBebem`
- [x] `efeitosDasPreferencias({required List<Pessoa> pessoas, required int adultos})`: `incluirKitVeggie = veggies >= 1`; `removerSuina = semPorco >= 1`; `adultosQueBebem = max(0, adultos − nomeadas com bebe == false)` (A-06)
- [x] **Os dois números que parecem um** estão separados e documentados: `bebem` (nomeadas com `bebe == true`, que alimenta o resumo de RN-21) ≠ `adultosQueBebem` (que dimensiona a cerveja)
- [x] `bebe == null` e `dieta == null` **não** contam como abstêmia nem como veggie (A-08)
- [x] Sem pessoas nomeadas, `adultosQueBebem == adultos` — RN-05 fica intacta
- [x] `String resumoDasPreferencias(EfeitosDasPreferencias)` produz a copy literal de RN-21 (`A lista já se ajusta às preferências: {n} veggie 🥗 · {n} sem porco 🚫 · {n} bebem 🍺`), **omitindo termos zerados**
- [x] Gate: `flutter test` passa
- [x] Novos testes: ≥9 (lista vazia → `adultosQueBebem == adultos` · 1 veggie → inclui kit · 1 sem porco → remove suína · 1 abstêmio entre 6 adultos → 5 · Duda (`bebe: null`) **não** reduz · `dieta: null` não conta veggie · abstêmios > adultos → 0, nunca negativo · resumo com os três termos · resumo omitindo os zerados)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): aplica as preferências da galera na lista`

---

### T16: `ComposicaoDaFesta` e o orquestrador

**What**: a entrada única do cálculo e o `CalculadoraDaFesta.calcular` que junta seleção, preferências, quantidades, overrides e essenciais numa lista.
**Where**: `lib/core/calculo/dominio/composicao_da_festa.dart`, `lib/core/calculo/regras/calculadora_da_festa.dart`, `test/core/calculo/regras/calculadora_da_festa_test.dart`
**Depends on**: T4, T8, T9, T10, T11, T12, T13, T14, T15
**Reuses**: todas as regras de quantidade, `essenciaisAutomaticos`, `efeitosDasPreferencias`, `fatorDuracao`
**Requirement**: CALC-15

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `ComposicaoDaFesta` imutável com `contagem`, `duracaoHoras`, `pessoas`, `itensSelecionados` (`Set<ChaveItem>`), `overrides` (`Map<ChaveItem, OverrideDeItem>`)
- [ ] `abstract final class CalculadoraDaFesta { static ResultadoDoCalculo calcular(ComposicaoDaFesta); }` com `ResultadoDoCalculo` expondo `itens`, `essenciais`, `contagem`, `fator`, `todosOsItens`, `temOverrides` (os totais entram em T17)
- [ ] A ordem interna é a do design: **guarda `pessoas == 0` primeiro** → fator → preferências (remove suína, injeta kit veggie) → gramas divididas entre as carnes **restantes** → quantidades na `ordemCanonicaDaLista` → overrides → essenciais
- [ ] Quantidade 0 ⇒ o item **não entra** na lista
- [ ] `pessoas == 0` ⇒ lista vazia, **sem** aplicar nenhum piso `max(1, …)` (A-11 / UC-03 E1)
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥10 (estado padrão produz os 7 itens esperados · ordem canônica estável entre duas chamadas · veggie injeta o kit · sem porco remove a suína **e** redivide as gramas entre as restantes · sem porco na única carne selecionada ≡ nenhuma carne · cerveja usa `adultosQueBebem` · 0 pessoas → lista vazia · só crianças → sem cerveja e sem destilado, com refri e água · override de quantidade e de preço chegam ao item · nenhum item de quantidade 0 na lista)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): monta a lista da festa a partir da composição`

---

### T17: Totais, estimativas e **os casos literais R$ 211 e R$ 271**

**What**: os quatro números que o `CLAUDE.md` eleva a caso de teste literal — e o critério de M0 do ROADMAP.
**Where**: `lib/core/calculo/regras/totais.dart`, `lib/core/calculo/regras/calculadora_da_festa.dart` (modificar), `test/core/calculo/regras/totais_test.dart`, `test/core/calculo/casos_literais_do_arquivo_03_test.dart`
**Depends on**: T6, T16
**Reuses**: `MoneyFormatter` (T6), `ResultadoDoCalculo` (T16), `totalDosEssenciais` (T14)
**Requirement**: CALC-16

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `ResultadoDoCalculo` passa a expor `totalDosItens`, `totalDosEssenciais`, `totalComEssenciais`, `porCabeca`, `porAdulto`
- [ ] `porCabeca = totalDosItens ÷ pessoas` e `porAdulto = totalComEssenciais ÷ adultos` (A-04) — a assimetria é deliberada e está no doc comment: são duas telas diferentes
- [ ] Total é `round` da **soma exata**, nunca soma de valores já arredondados (política de precisão, risco R-3) — e há teste que **separa as duas contas** com o Frango de R$ 21,60
- [ ] `pessoas == 0` ou `adultos == 0` ⇒ estimativa `0.0`, nunca `NaN` nem `Infinity`
- [ ] **`casos_literais_do_arquivo_03_test.dart` criado**, com o estado padrão (3H+3M+1C, 4h, bovina + frango + pão de alho + refrigerante + água + cerveja + cachaça, **sem pessoas nomeadas**) afirmando item a item: Bovina 1,2 kg `R$ 54` · Frango 1,2 kg `R$ 22` · Pão 4 un `R$ 24` · Refri 2 gf `R$ 18` · Água 2 gf `R$ 6` · Cerveja 18 latas `R$ 72` · Cachaça 1 gf `R$ 15`
- [ ] O mesmo arquivo afirma **`R$ 211` e `≈ R$ 30` por cabeça**, e **`R$ 271` e `≈ R$ 45` por adulto** — os **dois** números de cada par, porque foi a consistência entre eles que decidiu a leitura (a) de RN-10
- [ ] As asserções de dinheiro exibido comparam **string formatada**; as de valor exato usam `closeTo(v, 0.001)`
- [ ] Gate: `flutter analyze && flutter test` passa
- [ ] Novos testes: ≥12 (7 asserções de item · total 211 · por cabeça 30 · total com essenciais 271 · por adulto 45 · soma exata ≠ soma de arredondados · 0 pessoas → tudo 0 · 0 adultos → `porAdulto` 0)

**Tests**: unit
**Gate**: build
**Commit**: `feat(calculo): totaliza a festa e fecha o caso literal do arquivo 03`

---

### T18: Overrides de quantidade e preço — RN-12

**What**: os passos, os mínimos e o restaurar.
**Where**: `lib/core/calculo/regras/overrides.dart`, `test/core/calculo/regras/overrides_test.dart`
**Depends on**: T7, T8
**Reuses**: `passoDeQuantidade` do catálogo (T7), `ItemDeLista` (T8)
**Requirement**: CALC-17

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `ItemDeLista comPassoDeQuantidade(ItemDeLista item, int passos)` — soma `passos × passoDeQuantidade`, com piso de **um passo**
- [ ] `ItemDeLista comPassoDePreco(ItemDeLista item, int passos)` — passo R$ 1, piso **R$ 1**
- [ ] `ItemDeLista restaurado(ItemDeLista item)` zera os dois overrides e devolve **exatamente** o valor automático
- [ ] `Map<ChaveItem, OverrideDeItem> semOverrides()` para o "RESTAURAR" global
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥9 (carne +1 passo → +0,5 kg · cerveja +1 passo → +2 latas · demais +1 · carne descendo trava em **0,5 kg** · cerveja trava em **2 latas** · demais travam em 1 · preço trava em **R$ 1** · `editado` vira verdadeiro e volta a falso no restaurar · restaurado devolve o valor automático original)

**Tests**: unit
**Gate**: build
**Commit**: `feat(calculo): ajusta quantidade e preço por item`

---

### T19: `Despesa` e contribuições — RN-20

**What**: quanto cada pessoa já colocou — itens que ela leva mais despesas que adiantou.
**Where**: `lib/core/calculo/dominio/despesa.dart`, `lib/core/calculo/regras/contribuicoes.dart`, `test/core/calculo/dominio/despesa_test.dart`, `test/core/calculo/regras/contribuicoes_test.dart`
**Depends on**: T8
**Reuses**: `ItemDeLista.quemLeva` e `ItemDeLista.valor` (T8)
**Requirement**: CALC-18

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `Despesa` imutável com `quemPagou`, `descricao`, `valor`, `==`/`hashCode`
- [ ] `Map<String, double> contribuicoesPorPessoa({required Iterable<String> participantes, Iterable<ItemDeLista> itens, Iterable<Despesa> despesas})` soma o `valor` dos itens cujo `quemLeva` é a pessoa **mais** o das despesas que ela adiantou
- [ ] Participante sem nada continua no mapa, com **0,0** — nunca ausente, nunca `null`
- [ ] A ordem do mapa é a ordem de `participantes` — é a ordem que RN-16 vai consumir (A-14)
- [ ] `double totalDasContribuicoes(Map<String, double>)`
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥7 (só itens · só despesas · itens + despesas na mesma pessoa · participante sem nada → 0,0 · item sem `quemLeva` não entra em ninguém · nome fora de `participantes` é ignorado · ordem do mapa preservada)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): soma o que cada um levou e adiantou`

---

### T20: Cota justa e saldos — RN-14, RN-15

**What**: a cota por adulto (criança sempre de fora) e o saldo de cada pessoa com a tag RECEBE/PAGA/NO ZERO.
**Where**: `lib/core/calculo/regras/cota.dart`, `lib/core/calculo/dominio/saldo_de_pessoa.dart`, `lib/core/calculo/regras/saldos.dart`, `test/core/calculo/regras/{cota,saldos}_test.dart`
**Depends on**: T5, T19
**Reuses**: `ehZeroNaTolerancia` (T5), contribuições (T19)
**Requirement**: CALC-19, CALC-20

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `double cotaPorAdulto({required double total, required int adultos})`; `adultos == 0` ⇒ **0,0**, nunca `NaN`/`Infinity`
- [ ] O doc comment cita RN-14 e a copy "entre 4 adultos, criança de fora" — **criança nunca entra no racha**
- [ ] `SituacaoDeSaldo { recebe, paga, noZero }` e `SaldoDePessoa` com `pessoa`, `contribuicao`, `cota`, `saldo` e `situacao` (usando `ehZeroNaTolerancia`)
- [ ] `List<SaldoDePessoa> calcularSaldos({required Map<String, double> contribuicoes, required double total, required int adultos})` — `saldo = contribuição − cota`, **preservando a ordem de entrada**
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥8 (320 / 4 → **80** · 380 / 4 → **95** · `adultos == 0` → 0 · total 0 → 0 · saldos do Teste A: +120 / +40 / −80 / −80 · saldos do Teste B: +105 / +25 / −35 / −95 · situação recebe/paga/no zero · saldo de 0,005 conta como **no zero** pela tolerância)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): calcula a cota justa e o saldo de cada um`

---

### T21: Quem paga quem — RN-16 e **os Testes A e B**

**What**: o algoritmo do racha e os dois casos literais que fixam a saída — inclusive a **ordem**, que é comportamento observável.
**Where**: `lib/core/calculo/dominio/linha_de_acerto.dart`, `lib/core/calculo/regras/quem_paga_quem.dart`, `test/core/calculo/regras/quem_paga_quem_test.dart`, `test/core/calculo/casos_literais_do_arquivo_03_test.dart` (modificar)
**Depends on**: T5, T20
**Reuses**: `toleranciaDeCentavo` (T5), `SaldoDePessoa` (T20)
**Requirement**: CALC-21

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `LinhaDeAcerto` imutável com `de`, `para`, `valor`, `paga` (default `false`) e `copyWith` — **sem** campo de meio de pagamento (RN-19 é de `custos`); o doc comment registra a omissão
- [ ] `List<LinhaDeAcerto> calcularRacha(List<SaldoDePessoa> saldos)` — **nome exigido pelo `CLAUDE.md`**
- [ ] Credores (`saldo > tolerância`) e devedores (`saldo < −tolerância`) percorridos **na ordem de entrada**, nunca ordenados por valor; `parcela = min(dívida restante, crédito restante)`; avança o credor quando o crédito zera na tolerância
- [ ] Proibição explícita de ordenar registrada no doc comment (risco R-2: ordenar por valor decrescente daria `BIA→RAFA 95 · LÉO→RAFA 10 · LÉO→ANA 25` no Teste B, contra a spec)
- [ ] Nenhuma linha com valor `<= 0,01` é emitida
- [ ] **Teste A** afirmado literalmente em `casos_literais_do_arquivo_03_test.dart`: VOCÊ 200, ANA 120, LÉO 0, BIA 0 → total 320, cota 80 → **LÉO→VOCÊ 80 · BIA→VOCÊ 40 · BIA→ANA 40**, nesta ordem
- [ ] **Teste B** afirmado literalmente no mesmo arquivo: Rafa 200, Ana 120, Léo 60, Bia 0 → total 380, cota 95 → **LÉO→RAFA 35 · BIA→RAFA 70 · BIA→ANA 25**, nesta ordem
- [ ] Gate: `flutter analyze && flutter test` passa
- [ ] Novos testes: ≥10 (Teste A linha a linha e na ordem · Teste B linha a linha e na ordem · soma paga = soma recebida nos dois · lista vazia → vazio · só credores → vazio · só devedores → vazio · todos no zero → vazio · resíduo de 0,005 não gera linha · uma permutação da entrada produz a saída documentada para **aquela** ordem, provando que a ordem é preservada · nenhum valor de linha ≤ 0,01)

**Tests**: unit
**Gate**: build
**Commit**: `feat(calculo): resolve quem paga quem no acerto`

---

### T22: Split de despesa — RN-17

**What**: o "split R$ X × N" de cada despesa.
**Where**: `lib/core/calculo/regras/split_de_despesa.dart`, `test/core/calculo/regras/split_de_despesa_test.dart`
**Depends on**: T19
**Reuses**: `Despesa` (T19)
**Requirement**: CALC-22

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `class SplitDeDespesa { Despesa despesa; double valorPorAdulto; int adultos; }`
- [ ] `SplitDeDespesa splitIgualitario({required Despesa despesa, required int adultos})` — `valorPorAdulto = valor / adultos`, **0,0** quando `adultos == 0`
- [ ] O split é sempre **por adulto** (RN-14/RN-17) — criança nunca entra; doc comment registra
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥4 (R$ 80 entre 4 → R$ 20 · valor fracionário mantém a precisão exata (sem arredondar cedo) · `adultos == 0` → 0,0 · `adultos` preservado para a copy)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): divide a despesa entre os adultos`

---

### T23: Quitação e progresso — RN-18

**What**: quanto já foi pago, quantas linhas faltam, e a fração da barra verde.
**Where**: `lib/core/calculo/regras/quitacao.dart`, `test/core/calculo/regras/quitacao_test.dart`
**Depends on**: T21
**Reuses**: `LinhaDeAcerto` (T21)
**Requirement**: CALC-23

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `class ProgressoDeQuitacao { int pagas, total; double valorPago, valorDevido; double get fracao; }`
- [ ] `ProgressoDeQuitacao progressoDeQuitacao(Iterable<LinhaDeAcerto> linhas)` — `fracao = valorPago / valorDevido`
- [ ] **Sem linhas ⇒ `fracao == 1.0`**, com `pagas == 0` e `total == 0` (A-16); o doc comment declara a escolha e diz que trocá-la é uma linha
- [ ] A alternância pendente ⇄ paga é reversível (via `LinhaDeAcerto.copyWith`) e o progresso reflete
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥7 (nenhuma paga → 0.0 · todas pagas → 1.0 · metade do **valor** ≠ metade da **contagem** quando as linhas têm valores diferentes · `pagas`/`total` corretos · sem linhas → 1.0 com 0 de 0 · desmarcar volta o progresso · `valorDevido` soma todas, pagas e pendentes)

**Tests**: unit
**Gate**: build
**Commit**: `feat(calculo): mede o progresso da quitação`

---

### T24: Tabela de preços de mercado — RN-11

**What**: a **segunda** fonte de preço, literal e separada da calculadora.
**Where**: `lib/core/calculo/dominio/corredor.dart`, `lib/core/calculo/dominio/preco_de_mercado.dart`, `lib/core/calculo/dominio/tabela_de_precos_de_mercado.dart`, `test/core/calculo/dominio/tabela_de_precos_de_mercado_test.dart`
**Depends on**: T7
**Reuses**: `ChaveItem` (T7)
**Requirement**: CALC-24

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `Corredor { acougue, hortifruti, padaria, bebidas, mercearia }` — **só o atributo**; a ordem de RN-27 é de `lista` (A-17), e o doc comment diz isso
- [ ] `PrecoDeMercado` com `nome`, `emoji`, `corredor`, `rotuloDeQuantidade`, `media`, `minimo`, `maximo`, `fontes` e `chave` (**`ChaveItem?`**)
- [ ] `chave` é anulável porque a 🌭 Linguiça toscana de RN-11 **não tem chip em T-03** nem preço-base na calculadora (A-03, risco R-6) — o doc comment proíbe inventar `ChaveItem.linguica`
- [ ] `tabelaDePrecosDeMercado` com as **8 linhas literais** de RN-11 (Picanha 65/54/83/4 · Linguiça 23/18/29/3 · Legumes 28/22/35/2 · Pão de alho 24/20/30/3 · Cerveja 76/64/92/4 · Refrigerante 18/14/23/3 · Carvão 22/18/28/3 · Gelo 30/24/36/2)
- [ ] O doc comment do arquivo declara A-03: esta tabela **nunca** alimenta a calculadora, e a calculadora nunca alimenta esta tabela
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥5 (8 linhas · cada linha campo a campo contra RN-11 · corredores corretos · Linguiça com `chave == null` · Picanha com `chave == ChaveItem.bovina` mas `media` 65 ≠ preço-base 45 da calculadora — a coexistência afirmada como comportamento)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): adiciona a tabela de preços de mercado`

---

### T25: Marcador e faixa total — RN-11 (**contrato de fronteira com a spec 01**)

**What**: a posição do marcador já resolvida em `[0,1]` e o total/faixa do rodapé.
**Where**: `lib/core/calculo/regras/faixa_de_preco.dart`, `test/core/calculo/regras/faixa_de_preco_test.dart`
**Depends on**: T24
**Reuses**: `PrecoDeMercado`, `tabelaDePrecosDeMercado` (T24)
**Requirement**: CALC-25

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `double posicaoDoMarcador(PrecoDeMercado preco)` → `((media − minimo) / (maximo − minimo)).clamp(0.0, 1.0)`
- [ ] `maximo == minimo` ⇒ **0.0**, sem divisão por zero (A-15)
- [ ] O doc comment declara o **contrato de fronteira nº 1**: a spec 01 recebe um `double` pronto e **só pinta**; se o componente conhecer média/mín/máx para dividir, a fórmula vazou para a UI
- [ ] `class TotalDeMercado { double media, minimo, maximo; }` e `TotalDeMercado totalDeMercado(Iterable<PrecoDeMercado>)`
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥7 (Picanha → 11/29 ≈ 0,379 · média = mín → 0.0 · média = máx → 1.0 · `maximo == minimo` → 0.0 · média fora da faixa → `clamp` em 0 ou 1 · total da tabela: média **286** · faixa **234–356**)

**Tests**: unit
**Gate**: quick
**Commit**: `feat(calculo): posiciona o marcador da faixa de preço`

---

### T26: Totais do pedido — RN-27 (só os totais)

**What**: subtotal, frete e total da sheet de pedido; o resto de RN-27 é de `lista`.
**Where**: `lib/core/calculo/regras/total_do_pedido.dart`, `test/core/calculo/regras/total_do_pedido_test.dart`
**Depends on**: T8
**Reuses**: `ItemDeLista` (T8)
**Requirement**: CALC-26

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `double subtotalDeItens(Iterable<ItemDeLista>)` e `double subtotalDoQueFalta(Iterable<ItemDeLista>)` (só `noCarrinho == false`, para o CTA "PEDIR O QUE FALTA 🛵")
- [ ] `class TotalDoPedido { double subtotal, frete, total; }` e `TotalDoPedido totalDoPedido({required double subtotal, required double frete})`
- [ ] O doc comment declara a fronteira: **ordem de corredores, parceiros, ETAs e valores de frete ficam em `lista`** — aqui só a soma, porque o `CLAUDE.md` proíbe aritmética em widget
- [ ] Gate: `flutter test` passa
- [ ] Novos testes: ≥5 (subtotal soma `valor` de todos · subtotal do que falta ignora os marcados · lista vazia → 0 · total = subtotal + frete · **frete 0 → total = subtotal** (Zé Delivery))

**Tests**: unit
**Gate**: build
**Commit**: `feat(calculo): totaliza o pedido com frete`

---

### T27: Barrel `calculo.dart` — a superfície pública

**What**: a única porta de entrada da camada, e o teste que prova que ela basta.
**Where**: `lib/core/calculo/calculo.dart` (modificar), `test/core/calculo/calculo_test.dart`
**Depends on**: T1–T26
**Reuses**: o barrel já existe desde a fundação (T3 daquela spec), com doc comment
**Requirement**: CALC-27

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] O barrel exporta **todo** o público de `dominio/`, `regras/` e `formatacao/`
- [ ] O doc comment é atualizado: a frase "as fórmulas nascem na spec 02 `calculo`; **nenhuma** mora aqui ainda" **sai**, e entra a descrição da superfície + a regra "nenhuma outra camada recalcula"
- [ ] `test/core/calculo/calculo_test.dart` importa **só** `package:bora/core/calculo/calculo.dart` — nenhum arquivo interno — e reproduz o caso literal R$ 211 de ponta a ponta
- [ ] O mesmo teste afirma **determinismo**: a mesma `ComposicaoDaFesta` calculada duas vezes produz resultados iguais (base de UC-04, "recalcula a cada toque")
- [ ] `test/architecture/calculo_isolation_test.dart` continua verde — nenhum import de Flutter, `dart:ui`, Firebase ou `flutter_bloc` entrou na pasta
- [ ] Gate: `flutter analyze && flutter test` passa
- [ ] Novos testes: ≥3 (caso literal só pelo barrel · determinismo · `MoneyFormatter` e `posicaoDoMarcador` alcançáveis pelo barrel — os dois contratos de fronteira da spec 01)

**Tests**: unit
**Gate**: build
**Commit**: `feat(calculo): abre a superfície pública da camada de cálculo`

---

### T28: Fixture RN-30 tipada

**What**: o compromisso herdado da fundação — tipar o estado inicial **sem tocar** no dado bruto nem no teste dele.
**Where**: `test/fixtures/rn30_estado_inicial_tipado.dart`, `test/fixtures/rn30_estado_inicial_tipado_test.dart` (ambos **novos**)
**Depends on**: T27
**Reuses**: `test/fixtures/rn30_estado_inicial.dart` (fonte única), barrel (T27)
**Requirement**: CALC-06

**Tools**:
- MCP: NONE
- Skill: NONE

**Done when**:
- [ ] `festaRn30Tipada` (`Festa`), `pessoasRn30Tipadas` (`List<Pessoa>`) e `itensPadraoRn30Tipados` (`List<ChaveItem>`) são **derivados** dos mapas brutos — nenhum literal duplicado, nenhuma segunda fonte da verdade
- [ ] `test/fixtures/rn30_estado_inicial.dart` e `test/fixtures/rn30_estado_inicial_test.dart` **não são modificados** — nem uma linha, nem uma asserção
- [ ] `dieta` e `bebe` da Duda chegam como **`null`** no tipo (A-08); o teste novo afirma isso explicitamente
- [ ] A suíte antiga da fixture continua passando: a ausência de `dieta`/`bebe` na Duda e a de "todo valor bruto é primitivo" seguem valendo **palavra por palavra** (risco R-9)
- [ ] Chave desconhecida em `ChaveItem.porChave` faria o teste **falhar** em vez de inventar item
- [ ] Gate: `flutter analyze && flutter test` passa
- [ ] Novos testes: ≥7 (festa campo a campo contra RN-30 · 5 pessoas na ordem · papéis mapeados · dietas mapeadas · **Duda com `dieta == null` e `bebe == null`** · 7 itens resolvidos para `ChaveItem` · Rafa é o `voce`)
- [ ] **Verificação final da spec**: a contagem total de testes é a de 92 + a soma dos acréscimos de T1–T28; nenhuma queda

**Tests**: unit
**Gate**: build
**Commit**: `test(calculo): tipa a fixture do estado inicial rn-30`

---

## Phase Execution Map

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5 → Phase 6

Phase 1:  T1    T2    T3    T4    T5    T6
Phase 2:  T7 ──→ T8      T9    T10   T11   T12   T13
Phase 3:  T14   T15   T16 ──→ T17    T18
Phase 4:  T19 ──→ T20 ──→ T21 ──→ T23      T22
Phase 5:  T24 ──→ T25    T26
Phase 6:  T27 ──→ T28
```

Execução é estritamente sequencial — sem paralelismo dentro da fase. As setas são **dependência**, não agenda: tasks sem seta entre si ainda rodam na ordem numérica.

**Packing previsto para o Execute** (28 tasks, orçamento ~7 por lote, corte só em fronteira de fase):

| Lote | Fases | Tasks | Total |
|---|---|---|---|
| 1 | Phase 1 | T1–T6 | 6 |
| 2 | Phase 2 | T7–T13 | 7 |
| 3 | Phase 3 | T14–T18 | 5 |
| 4 | Phase 4 | T19–T23 | 5 |
| 5 | Phase 5 + Phase 6 | T24–T28 | 5 |

Mais de um lote ⇒ **a oferta de sub-agentes é apresentada no início do Execute** (offer-then-confirm; nada é despachado sem aceite). O Verifier roda automaticamente depois de T28, sem pergunta.

**Nota para os batch workers**: os quatro casos literais do arquivo 03 caem em **duas** tasks — T17 (R$ 211/≈R$ 30 e R$ 271/≈R$ 45) e T21 (Testes A e B) — e moram no mesmo arquivo, `test/core/calculo/casos_literais_do_arquivo_03_test.dart`. T21 **acrescenta** a esse arquivo; não o reescreve.

---

## Task Granularity Check

| Task | Scope | Status |
|---|---|---|
| T1 | 1 entidade + 4 enums do mesmo vocabulário | ⚠️ coeso — OK (os enums sozinhos não teriam teste próprio) |
| T2 | 1 entidade | ✅ Granular |
| T3 | 1 entidade + RN-01 | ✅ Granular |
| T4 | 1 função | ✅ Granular |
| T5 | 3 primitivas do mesmo conceito | ⚠️ coeso — OK |
| T6 | 2 formatadores da mesma RN-13 | ⚠️ 2 coesos — OK |
| T7 | 2 enums + 1 catálogo (dados de uma fonte só) | ⚠️ coeso — OK |
| T8 | 1 entidade + seu override | ✅ Granular |
| T9 | 1 regra (RN-03) | ✅ Granular |
| T10 | 2 fórmulas da mesma forma (∝ pessoas) | ⚠️ 2 coesos — OK |
| T11 | 2 fórmulas da mesma forma (adultos + crianças) | ⚠️ 2 coesos — OK |
| T12 | 1 regra | ✅ Granular |
| T13 | 1 regra | ✅ Granular |
| T14 | 1 regra + catálogo dos essenciais | ✅ Granular |
| T15 | 1 regra (RN-21) | ✅ Granular |
| T16 | 1 entrada + 1 orquestrador | ⚠️ coeso — OK (a composição sem o orquestrador não é verificável) |
| T17 | 1 módulo de totais + o arquivo de casos literais | ⚠️ coeso — OK (o total **é** o caso literal) |
| T18 | 1 módulo (RN-12) | ✅ Granular |
| T19 | 1 entidade + 1 regra que só ela alimenta | ⚠️ 2 coesos — OK |
| T20 | 2 regras encadeadas (cota → saldo) + 1 valor | ⚠️ coeso — OK (saldo sem cota não existe) |
| T21 | 1 entidade + 1 algoritmo | ⚠️ coeso — OK (a linha só nasce do algoritmo) |
| T22 | 1 função | ✅ Granular |
| T23 | 1 função | ✅ Granular |
| T24 | 1 enum + 1 entidade + 1 tabela literal | ⚠️ coeso — OK (a tabela é o motivo da entidade) |
| T25 | 2 funções da mesma RN-11 | ⚠️ 2 coesos — OK |
| T26 | 1 módulo pequeno | ✅ Granular |
| T27 | 1 arquivo | ✅ Granular |
| T28 | 1 fixture + 1 teste | ✅ Granular |

Nenhum ❌: as tasks ⚠️ agrupam de 2 a 3 arquivos do **mesmo conceito**, e o agrupamento existe para que nenhuma task produza código não verificado.

## Diagram-Definition Cross-Check

| Task | Depends On (corpo) | Diagrama mostra | Status |
|---|---|---|---|
| T1 | None | entrada da Phase 1 | ✅ |
| T2 | None | entrada da Phase 1 | ✅ |
| T3 | None | entrada da Phase 1 | ✅ |
| T4 | None | entrada da Phase 1 | ✅ |
| T5 | None | entrada da Phase 1 | ✅ |
| T6 | None | entrada da Phase 1 | ✅ |
| T7 | None | entrada da Phase 2 | ✅ |
| T8 | T7 | T7 → T8 | ✅ |
| T9 | T3, T5 | T3, T5 → T9 | ✅ |
| T10 | T5 | T5 → T10 | ✅ |
| T11 | T5 | T5 → T11 | ✅ |
| T12 | T5 | T5 → T12 | ✅ |
| T13 | T5 | T5 → T13 | ✅ |
| T14 | T7, T8 | T7, T8 → T14 | ✅ |
| T15 | T1 | T1 → T15 | ✅ |
| T16 | T4, T8, T9, T10, T11, T12, T13, T14, T15 | T4, T9..T13, T14, T15 → T16 (T8 herdado via T14) | ✅ |
| T17 | T6, T16 | T16 → T17 (T6 herdado da Phase 1) | ✅ |
| T18 | T7, T8 | T7, T8 → T18 | ✅ |
| T19 | T8 | T8 → T19 | ✅ |
| T20 | T5, T19 | T19 → T20 (T5 herdado da Phase 1) | ✅ |
| T21 | T5, T20 | T20 → T21 | ✅ |
| T22 | T19 | T19 → T22 | ✅ |
| T23 | T21 | T21 → T23 | ✅ |
| T24 | T7 | T7 → T24 | ✅ |
| T25 | T24 | T24 → T25 | ✅ |
| T26 | T8 | T8 → T26 | ✅ |
| T27 | T1–T26 | Phase 5 → T27 (fecha todas as fases anteriores) | ✅ |
| T28 | T27 | T27 → T28 | ✅ |

Nenhuma dependência aponta para fase posterior.

## Test Co-location Validation

| Task | Camada criada/modificada | Matriz exige | Task diz | Status |
|---|---|---|---|---|
| T1 | `dominio/` | unit | unit | ✅ |
| T2 | `dominio/` | unit | unit | ✅ |
| T3 | `dominio/` | unit | unit | ✅ |
| T4 | `regras/` | unit | unit | ✅ |
| T5 | `regras/` | unit | unit | ✅ |
| T6 | `formatacao/` | unit | unit | ✅ |
| T7 | `dominio/` (catálogo) | unit | unit | ✅ |
| T8 | `dominio/` | unit | unit | ✅ |
| T9 | `regras/` | unit | unit | ✅ |
| T10 | `regras/` | unit | unit | ✅ |
| T11 | `regras/` | unit | unit | ✅ |
| T12 | `regras/` | unit | unit | ✅ |
| T13 | `regras/` | unit | unit | ✅ |
| T14 | `regras/` | unit | unit | ✅ |
| T15 | `regras/` | unit | unit | ✅ |
| T16 | `dominio/` + `regras/` | unit | unit | ✅ |
| T17 | `regras/` + casos literais | unit | unit | ✅ |
| T18 | `regras/` | unit | unit | ✅ |
| T19 | `dominio/` + `regras/` | unit | unit | ✅ |
| T20 | `dominio/` + `regras/` | unit | unit | ✅ |
| T21 | `dominio/` + `regras/` + casos literais | unit | unit | ✅ |
| T22 | `regras/` | unit | unit | ✅ |
| T23 | `regras/` | unit | unit | ✅ |
| T24 | `dominio/` | unit | unit | ✅ |
| T25 | `regras/` | unit | unit | ✅ |
| T26 | `regras/` | unit | unit | ✅ |
| T27 | barrel | unit | unit | ✅ |
| T28 | fixture | unit | unit | ✅ |

Nenhuma ❌ VIOLATION e **nenhum `Tests: none`**: toda task desta spec cria código de domínio ou de regra, e a matriz exige unit para os dois. Não há deferimento de teste em lugar nenhum — os casos literais transversais (T17, T21) moram nas próprias tasks que produzem os números.

---

## Cobertura dos requisitos

| Req | Task(s) | Req | Task(s) |
|---|---|---|---|
| CALC-01 | T3 | CALC-15 | T15, T16 |
| CALC-02 | T4 | CALC-16 | T17 |
| CALC-03 | T6 | CALC-17 | T7, T8, T18 |
| CALC-04 | T6 | CALC-18 | T19 |
| CALC-05 | T1, T2, T8 | CALC-19 | T20 |
| CALC-06 | T28 | CALC-20 | T20 |
| CALC-07 | T5, T7, T9 | CALC-21 | T5, T21 |
| CALC-08 | T7, T10 | CALC-22 | T22 |
| CALC-09 | T7, T12 | CALC-23 | T23 |
| CALC-10 | T7, T11 | CALC-24 | T24 |
| CALC-11 | T7, T11 | CALC-25 | T25 |
| CALC-12 | T7, T10 | CALC-26 | T26 |
| CALC-13 | T7, T13 | CALC-27 | T27 |
| CALC-14 | T7, T14 | | |

**27 de 27 requisitos mapeados. Nenhuma task órfã.**

**Casos literais do arquivo 03 → task nomeada** (critério de M0 no ROADMAP):

| Caso literal | Task | Arquivo |
|---|---|---|
| **R$ 211 · ≈ R$ 30 / cabeça** | **T17** | `test/core/calculo/casos_literais_do_arquivo_03_test.dart` |
| **R$ 271 · ≈ R$ 45 / adulto** | **T17** | idem |
| **Teste A de RN-16** | **T21** | idem (acrescenta) |
| **Teste B de RN-16** | **T21** | idem (acrescenta) |

---

## Fora do escopo deste plano (declarado, não esquecido)

- **UI de qualquer tipo** — widget, bloc, página, token. `core/calculo` não pode importar Flutter (FUND-06), então nem seria compilável.
- **RN-19** (meio de pagamento) — `custos`. Por isso `LinhaDeAcerto` nasce **sem** o campo.
- **RN-22, RN-23** — `galera`. Aqui existe só o enum `PapelNaFesta`, como campo de `Pessoa`; a tabela de permissões não.
- **RN-24, RN-25, RN-26, RN-26b, RN-28** — `convidado`, `convite`, `home`.
- **RN-27 além dos totais** — ordem dos corredores, parceiros, ETAs e valores de frete são de `lista`; o corredor dos itens que RN-11 não declara também (A-17).
- **RN-29** — componente toast, spec 01, em execução paralela.
- **Persistência e serialização** — nenhuma entidade daqui ganha `toJson`; isso é camada `data/` de cada feature.
- **`integration_test/`** — nenhum `CALC-xx` pede fluxo ponta-a-ponta; a pirâmide do `CLAUDE.md` prevê e2e para os fluxos de produto, que nascem da spec 05 em diante.
- **Dependência nova no `pubspec.yaml`** — proibido pela fronteira de worktree; `intl` e `meta` ficam de fora por decisão registrada (A-18, A-19).
