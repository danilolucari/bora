# Cálculo — Specification

**ID prefix:** `CALC` · **Porte:** Grande
**Design:** `.specs/features/calculo/design.md`
**Tasks:** `.specs/features/calculo/tasks.md`
**Roadmap:** `.specs/ROADMAP.md` — spec 02, marco M0
**Spec-fonte:** `.specs/init-spec/03-regras-de-negocio.md` (RN-01..RN-21, RN-27 parcial, RN-30) e `.specs/init-spec/01-produto-e-fluxos.md` §6/§7

## Problem Statement

Toda a promessa do BORA. é aritmética: "SAI POR R$ X", "≈ R$ 30 / cabeça", "cota justa R$ 80 — entre 4 adultos, criança de fora", "LÉO → VOCÊ · R$ 80". Hoje essas fórmulas existem só como prosa no arquivo 03. Enquanto não virarem código Dart puro, testável sozinho, cada tela vai reimplementar a sua versão da conta — e duas telas com contas diferentes é exatamente a treta que o produto promete eliminar. Esta spec cria a **única** camada que faz aritmética no projeto: `lib/core/calculo/`, sem Flutter e sem Firebase, com as RN-xx 1:1 em funções puras e os exemplos numéricos do arquivo 03 como testes literais.

## Goals

- [ ] RN-01..RN-21 implementadas em `lib/core/calculo/`, cada regra com teste próprio e nome de função no vocabulário da spec (`fatorDuracao`, `calcularRacha`).
- [ ] Os quatro casos literais do arquivo 03 passam exatamente: **R$ 211 / ≈R$ 30 por cabeça**, **R$ 271 / ≈R$ 45 por adulto**, **Teste A** e **Teste B** de RN-16.
- [ ] As entidades de domínio do arquivo 01 §6 (`Festa`, `Pessoa`, `ItemDeLista`, `Despesa`, …) existem em PT-BR, em Dart puro, e são o vocabulário compartilhado das dez specs de tela.
- [ ] A fixture RN-30, hoje mapa de primitivos, ganha uma **visão tipada** — sem que nenhuma asserção da fixture bruta seja enfraquecida.
- [ ] Nenhuma outra camada precisa recalcular nada: o resultado sai pronto, inclusive as strings de dinheiro (RN-13) e a posição do marcador da barra de faixa (RN-11).

## Out of Scope

Explicitamente excluído. Cada linha tem uma spec dona — invadir aqui gera conflito de merge e regra duplicada.

| Item | Razão |
|---|---|
| Qualquer UI, widget, bloc, página ou token | `core/calculo/` é Dart puro; a camada de apresentação é das specs 01 e 03–10 |
| RN-19 (meio de pagamento) | Estado de UI — spec 10 `custos` |
| RN-22, RN-23 (papéis, nível do link) | Domínio de `galera` (spec 07). O **enum de papel** nasce aqui porque `Pessoa` o carrega; a **tabela de permissões** não |
| RN-24, RN-25, RN-26, RN-26b (RSVP, grupo, enquetes) | Specs 08 `convite` e 09 `convidado` |
| RN-27 — ordem dos corredores e catálogo de parceiros de delivery | Spec 06 `lista`. Só os **totais** (subtotal + frete) são desta spec (ROADMAP §5) |
| RN-28 (sincronização realtime) | Spec 09 `convidado` (origem) e 04 `home` (consumo) |
| RN-29 (componente toast) | Spec 01 `design-system`, rodando em paralelo |
| RN-30 como dado bruto | Já existe (`test/fixtures/rn30_estado_inicial.dart`, FUND-18/19). Esta spec **só a tipa** |
| Persistência, Firestore, serialização | Specs de feature (camada `data/`). Nenhuma entidade daqui conhece `toJson` |
| `pubspec.yaml`, `lib/core/design_system/`, `lib/core/routing/` | Território do workflow paralelo (spec 01) — colidiriam no merge |

---

## Assumptions & Open Questions

Toda ambiguidade resolvida ou registrada aqui. As linhas marcadas **decidida pelo usuário** têm data e dono porque a spec-fonte continua com o texto contraditório — o rastro precisa sobreviver ao merge.

| # | Assumption / decisão | Default escolhido | Rationale | Confirmado? |
|---|---|---|---|---|
| A-01 | **Contradição de RN-10**: o texto diz "Com essenciais (22+30+8+15) → R$ 271 · ≈R$ 45/adulto", mas 22+30+8+15 = 75 e 211+75 = **286**, não 271. Duas leituras: **(a)** o total R$ 271 manda e o parêntese está errado — entram Carvão 22 + Gelo 30 + Sal 8 = 60, e Copos & pratos (15) fica de fora; **(b)** o parêntese manda e o total seria R$ 286 | **Leitura (a)** — **decidida pelo usuário em 2026-08-20** | (a) é a única internamente consistente em **dois números independentes**: 210,6 + 60 = 270,6 → R$ 271 **e** 270,6 ÷ 6 adultos = 45,1 → ≈R$ 45, exatamente o que a frase afirma. Sob (b) seriam R$ 286 e ≈R$ 48, contradizendo o "≈R$ 45" da mesma frase. O `CLAUDE.md` eleva R$ 271/≈R$ 45 a caso de teste literal | **y** |
| A-02 | Consequência de A-01: "entrar na lista" e "entrar no total do exemplo canônico" passam a ser **duas coisas diferentes** para Copos & pratos | Cada essencial carrega um dado declarado `entraNoTotal`; os quatro aparecem na lista (RN-10), três somam no total. Trocar de leitura = trocar **um booleano** | Sem o dado declarado, os R$ 60 viram número mágico e a decisão do usuário some no código. Ver `design.md` §Essenciais | **y** |
| A-03 | **Tensão de preços RN-03 × RN-11**: RN-03 dá Bovina R$ 45/kg (1,2 kg → R$ 54) e RN-11 lista "🥩 Picanha bovina, 1,2 kg, média 65, mín 54, máx 83" | **Duas fontes coexistem de propósito e nunca são unificadas**: RN-03 governa a **calculadora** (tela Montar, o "SAI POR" que produz o R$ 211); RN-11 governa a **tela Lista no modo PLANEJAR** (média real de mercados) | Mesmo padrão que o `CLAUDE.md` já impõe aos dois números "por cabeça" e "por adulto": coexistem, não se unificam. Unificar quebraria o R$ 211 ou o R$ 286 da tabela RN-11. As duas tabelas nem cobrem o **mesmo conjunto**: RN-11 traz 🌭 Linguiça toscana, que não existe nos chips de T-03, e não traz água, suco, sal, copos nem destilados | n |
| A-04 | O `≈ R$ X / cabeça` sai do total **sem** essenciais; o `≈ R$ X / adulto` sai do total **com** essenciais | `porCabeca = totalDosItens ÷ pessoas` (211/7 → 30); `porAdulto = totalComEssenciais ÷ adultos` (270,6/6 → 45) | É a leitura literal das duas frases de RN-10, e cada uma pertence a uma tela distinta (Montar × Lista). Os dois pares de números do arquivo 03 só fecham assim | n |
| A-05 | RN-01 diz "as pessoas vêm de: confirmados nomeados + steppers extras", mas `adultos = homens + mulheres` e o modelo de `Pessoa` (arquivo 01 §6) **não tem sexo nem idade** — uma pessoa nomeada não pode entrar em `homens`/`mulheres` | A **contagem** vem exclusivamente dos steppers H/M/C, que cobrem confirmados **e** extras (o título da seção em T-03 é literalmente "CONFIRMADOS + EXTRAS SEM APP"). As pessoas nomeadas entram com **preferências e identidade** (RN-15..RN-21), não com cabeça | É a única leitura que não fabrica dado: somar nomeados a `adultos` exigiria inventar gramas para eles em RN-03. Manter os steppers coerentes com os confirmados é trabalho da tela (spec 05) | n |
| A-06 | RN-21 diz "cerveja dimensiona por quem bebe (substitui `adultos` em RN-05 por nº que bebem, quando houver pessoas nomeadas)" — mas `adultos` já conta todo mundo (A-05) | `adultosQueBebem = max(0, adultos − nº de pessoas nomeadas com bebe == false)`. Sem pessoas nomeadas, reduz exatamente a `adultos` (RN-05 intacta) | Subtrair os abstêmios conhecidos é contínuo: nenhum degrau ao nomear a primeira pessoa. A leitura alternativa ("só os nomeados que bebem") faria 6 adultos virarem 3 latas ao nomear uma pessoa, absurdo que RN-05 não autoriza | n |
| A-07 | Pessoa nomeada é sempre **adulta**; criança só existe no stepper | O modelo de `Pessoa` não tem idade e todas as personas do arquivo 01 §7 são adultas | Sem isso, "criança fica de fora do racha" (RN-14) ficaria indecidível para nomeados | n |
| A-08 | `dieta` e `bebe` da Duda são **ausentes** na fixture RN-30 (o arquivo 01 §7 não os declara) | O tipo é **anulável** (`Dieta?`, `bool?`). Ausente ≠ `false`: a Duda **não** conta como "não bebe" em A-06 nem como veggie em RN-21 | A fixture bruta já recusa inventar esses campos (commit `9918b04`) e o teste dela afirma a ausência; tipar não pode desfazer isso | **y** |
| A-09 | RN-10 dá aos essenciais um badge `AUTO ∝ <fonte>` mas **nenhuma fórmula** de proporcionalidade | Quantidades **fixas nos defaults** de RN-10 (1 saco de carvão, 3 sacos de gelo, 1 kg de sal, 1 kit); a fonte da proporção é **metadado** do item (para o badge), não fórmula | O exemplo canônico (R$ 271) usa exatamente os defaults. Inventar uma fórmula mudaria o caso literal e seria fabricação | n |
| A-10 | RN-21 manda adicionar "Legumes p/ grelha (kit veggie)" quando houver veggie, mas **RN-03..RN-09 não dão preço** para ele | Preço-base **R$ 28**, quantidade **1 kit**, sem fator de duração | R$ 28 é o único número que a spec associa ao item (RN-11, "Legumes p/ grelha · kit veggie · média 28"). Fica declarado como constante nomeada, citando a lacuna | n |
| A-11 | UC-03 E1 ("0 pessoas → lista vazia e total R$ 0") colide com os pisos `max(1, …)` de RN-04..RN-09 e o `max(0,5 kg)` de RN-03 | **Guarda global**: `pessoas == 0` ⇒ lista vazia e todos os totais 0. Os pisos só valem quando há ≥1 pessoa | O piso existe para não comprar "0,4 lata" quando há plateia, não para comprar cerveja para plateia nenhuma. UC-03 E1 é critério de aceite explícito | n |
| A-12 | `adultos == 0` com `pessoas > 0` (festa só de crianças): RN-05 e RN-09 são "só adultos" mas o `max(1, …)` devolveria 1 lata | Consumível restrito a adultos com `adultos == 0` ⇒ **quantidade 0** (item não entra na lista) | Mesmo raciocínio de A-11, aplicado ao subconjunto. Registrado porque a leitura estritamente literal daria 1 | n |
| A-13 | RN-16 fala em "tolerância 1 centavo" enquanto RN-13 manda exibir dinheiro **inteiro** | A tolerância vive na **aritmética** (`0.01`, resíduo abaixo disso é considerado quitado e não gera linha); a exibição continua `R$ + round(valor)` inteiro. As duas convivem em camadas diferentes | Sem tolerância, ruído de `double` gera linha fantasma de R$ 0,004; sem inteiro na exibição, quebra RN-13 | n |
| A-14 | RN-16 não diz em que ordem percorrer credores e devedores | **Ordem de entrada**, nunca ordenada por valor | O Teste B discrimina: por valor decrescente sairia `BIA→RAFA 95 · LÉO→RAFA 10 · LÉO→ANA 25`, e a spec exige `LÉO→RAFA 35 · BIA→RAFA 70 · BIA→ANA 25`. A ordem é comportamento observável, não detalhe | **y** (provado pelo próprio Teste B) |
| A-15 | RN-11 não define a posição do marcador quando `máx == mín` | `0.0`, e o resultado é sempre limitado a `[0,1]` | Divisão por zero precisa de saída declarada; a barra tem comprimento zero, então qualquer ponto é o mesmo ponto | n |
| A-16 | RN-18 não define o progresso quando não há nenhuma linha de acerto | `fracao = 1.0` ("nada pendente"), com `pagas = 0` e `total = 0` | UC-22 define 100% como "todas as linhas pagas"; com zero linhas isso é vacuamente verdade. Escolha declarada e testada — trocar é uma linha | n |
| A-17 | RN-11 dá `Corredor` só para os 8 itens da sua tabela; o modo COMPRAR agrupa **todos** os itens | O corredor é atributo **da tabela de preços de mercado**, não do catálogo geral de itens. Itens sem corredor declarado ficam sem corredor aqui | Atribuir corredor aos demais (água, sal, copos, cachaça…) seria fabricação. Preencher a lacuna é decisão da spec 06 `lista`, dona de RN-27 | n |
| A-18 | Não há `intl` no `pubspec.yaml` e o `pubspec.yaml` é **território do workflow paralelo** — não pode ser tocado | RN-13 é implementada à mão: `R$ ` + inteiro com separador de milhar `.` (pt-BR), sem centavos | Zero dependência nova, zero conflito de merge, e mantém `core/calculo` sem pacote de terceiros | **y** |
| A-19 | `package:meta` (`@immutable`) não é dependência direta do projeto | Não é importado. Entidades usam construtor `const` e `==`/`hashCode` escritos à mão | Importar pacote transitivo dispara `depend_on_referenced_packages` e quebra `flutter analyze` (gate obrigatório) | n |
| A-20 | Onde vivem as entidades compartilhadas (`Festa`, `Pessoa`, `ItemDeLista`, `Despesa`) — o ROADMAP deixou em aberto | `lib/core/calculo/dominio/`, reexportadas pelo barrel `calculo.dart` | Candidato natural do ROADMAP; é a única pasta Dart pura, e as regras já dependem das entidades. Proposta de **AD** no relatório | n |
| A-21 | `Festa` (arquivo 01 §6) cita `link` e `nível do link` | Ficam **fora** desta spec; `Festa` nasce com nome, data, hora, local, duração e status | Link e nível são RN-22/RN-23, domínio de `galera`. A entidade é estendida por quem precisar, sem recalcular nada | n |
| A-22 | O arquivo 01 §6 nomeia "Extras sem app" como contadores anônimos **separados** dos confirmados nomeados | Existe **um único** tipo, `ContagemDePessoas` (homens/mulheres/crianças), que é o card "CONFIRMADOS + EXTRAS SEM APP" de T-03 inteiro | Consequência direta de A-05: dois tipos implicariam somar duas populações, e somar exigiria gramas para os nomeados, que a spec não dá. Um tipo só torna a fabricação impossível | n |
| A-23 | `Festa.data` e `Festa.hora` — a spec só declara rótulos ("SÁB · 18 JUL", "14H"), sem ano nem fuso | Campos `String` com o rótulo literal | Converter para `DateTime` exigiria inventar ano e fuso. Quem precisar de data real (agenda, festa passada) troca o tipo na sua spec, com a informação em mãos | n |
| A-24 | `Pessoa` não tem identificador — o modelo do arquivo 01 §6 só dá `nome` | A identidade nas contribuições, saldos e linhas de acerto é o **nome** | É o que os Testes A e B usam ("VOCÊ", "ANA", "LÉO", "BIA"). Um `id` real nasce quando o Firestore entrar (spec 09) | n |

**Open questions:** nenhuma — tudo acima está resolvido, decidido pelo usuário (A-01, A-02) ou registrado como assumption com o default explícito.

---

## Dimensions Sweep (obrigatório para porte Grande)

| Dimensão | Resolução |
|---|---|
| Input validation & bounds | **CALC-01** (contagens negativas rejeitadas), **CALC-16** (guarda `pessoas == 0`), **CALC-17** (mínimos de quantidade e preço), **CALC-19** (`adultos == 0`) |
| Failure / partial-failure states | `N/A porque` a camada é determinística e não faz I/O: não há timeout, gravação parcial nem rollback. Entrada inválida é barrada por guarda de domínio (CALC-01/CALC-16), não por recuperação de falha |
| Idempotency / retry / duplicate handling | **CALC-27** — funções puras e sem estado global: recalcular a mesma entrada N vezes devolve resultado igual. É o que sustenta UC-04 ("recalcula a cada toque, sem botão calcular") |
| Auth boundaries & rate limits | `N/A porque` nenhuma função aqui é chamada por rede nem conhece usuário autenticado. Papéis e permissões (RN-22) são de `galera`; o enum de papel é só um campo de `Pessoa` |
| Concurrency / ordering | **CALC-21** — a ordem de credores/devedores é a ordem de entrada e é comportamento observável (A-14); **CALC-15** — a ordem dos itens da lista é a ordem canônica do catálogo, determinística |
| Data lifecycle / expiry | `N/A porque` a camada não persiste nada. "Overrides sobrevivem à navegação" (UC-06) é responsabilidade do estado da feature `lista`; aqui o override é só um campo do valor imutável |
| Observability | `N/A porque` `core/calculo` é Dart puro e não pode importar o `AppLogger` sem quebrar o isolamento (FUND-06). Quem observa é o bloc consumidor, via `AppBlocObserver` (AD-005) |
| External-dependency failure | `N/A porque` a camada não tem dependência externa alguma — nem pacote de terceiros (A-18, A-19). Só `dart:math` |
| State-transition integrity | **CALC-17** (item: automático → editado → restaurado) e **CALC-23** (linha de acerto: pendente ⇄ paga). Transições declaradas, reversíveis e testadas |

---

## User Stories

### P1-1: Contagem, tempo e formatação ⭐ MVP

**User Story**: Como anfitrião, quero que o app saiba quantos somos, quanto tempo vai durar e como escrever dinheiro, para que toda quantidade e todo valor da festa partam da mesma base.

**Why P1**: RN-01, RN-02 e RN-13 são insumo de todas as outras regras. Nada calcula sem elas.

**Acceptance Criteria**:

1. WHEN a contagem recebe homens, mulheres e crianças THEN o sistema SHALL expor `adultos = homens + mulheres` e `pessoas = adultos + crianças`; para 3H+3M+1C, 6 adultos e 7 pessoas. *(CALC-01)*
2. WHEN qualquer contagem recebe valor negativo THEN o sistema SHALL rejeitar a construção com erro de argumento — nunca produzir contagem negativa. *(CALC-01)*
3. WHEN a duração é 2h, 4h, 6h ou 10h THEN o fator SHALL ser 0.5, 1.0, 1.5 e 2.5 respectivamente. *(CALC-02)*
4. WHEN a duração é menor que 2h (inclusive 0) THEN o fator SHALL ser exatamente 0.5 — o piso `max(0.5, horas/4)`. *(CALC-02)*
5. WHEN um valor monetário é formatado THEN o sistema SHALL devolver `R$ ` + o valor **arredondado a inteiro**, em pt-BR: 210.6 → `R$ 211`, 30.14 → `R$ 30`, 1234.0 → `R$ 1.234`, 0 → `R$ 0`. *(CALC-03)*
6. WHEN um valor monetário é formatado THEN o sistema SHALL **nunca** exibir centavos nem separador decimal. *(CALC-03)*
7. WHEN a duração é rotulada THEN o sistema SHALL devolver `2 horas`, `4 horas`, `6 horas` e, para 10, `Dia todo`. *(CALC-04)*

**Independent Test**: chamar contagem, fator e formatador com os valores acima e conferir saída — sem nenhuma outra parte da camada existir.

---

### P1-2: Entidades de domínio compartilhadas

**User Story**: Como desenvolvedor de qualquer feature, quero as entidades do arquivo 01 §6 em PT-BR e Dart puro, para que código e spec falem a mesma língua e nenhuma feature invente o seu próprio `Party`.

**Why P1**: As regras operam sobre elas; as dez specs seguintes as consomem. Se nascerem depois das fórmulas, cada fórmula inventa um formato de entrada.

**Acceptance Criteria**:

1. WHEN o domínio é inspecionado THEN SHALL existir, em PT-BR e com o vocabulário do arquivo 01 §6: `Festa`, `Pessoa`, `ContagemDePessoas`, `ComposicaoDaFesta`, `ItemDeLista`, `Despesa`, `SaldoDePessoa`, `LinhaDeAcerto`, `PrecoDeMercado` e os enums `Dieta`, `PapelNaFesta`, `StatusDePresenca`, `StatusDaFesta`, `ChaveItem`, `UnidadeDeItem`, `Corredor`, `SituacaoDeSaldo`. *(CALC-05)*
2. WHEN duas entidades com os mesmos campos são comparadas THEN SHALL ser iguais (`==`) e ter o mesmo `hashCode` — são valores, não identidades. *(CALC-05)*
3. WHEN uma entidade é copiada com um campo alterado THEN a original SHALL permanecer inalterada — todas são imutáveis. *(CALC-05)*
4. WHEN a dieta ou a bebida de uma pessoa é desconhecida THEN o campo SHALL ser `null`, e `null` SHALL ser distinto de "não bebe" / "come de tudo". *(CALC-05, A-08)*
5. WHEN qualquer arquivo de `lib/core/calculo/` é compilado THEN SHALL ser Dart puro — sem `package:flutter`, `dart:ui`, `package:firebase…`, `cloud_firestore` ou `package:flutter_bloc` — e o teste de isolamento existente SHALL continuar verde. *(CALC-27)*

**Independent Test**: construir cada entidade, comparar duas iguais, copiar com alteração e rodar `test/architecture/calculo_isolation_test.dart`.

---

### P1-3: Quantidades automáticas da calculadora

**User Story**: Como anfitrião, quero que o app decida sozinho quanta carne, bebida e pão comprar a partir de quem vai e de quanto tempo dura, para não ter que estimar nada.

**Why P1**: É o "calcula" da tagline e a metade do caso literal R$ 211.

**Acceptance Criteria**:

1. WHEN há carnes selecionadas THEN as gramas totais SHALL ser `(homens×400 + mulheres×300 + crianças×200) × f`, divididas igualmente entre as carnes; e cada carne SHALL ter `kg = max(0,5; arredondado para 0,1 kg)`. Para 3H+3M+1C, f=1, 2 carnes: 2300 g ÷ 2 = 1150 g → **1,2 kg** cada. *(CALC-07)*
2. WHEN as carnes selecionadas são Bovina e Frango a 1,2 kg THEN os valores SHALL ser R$ 54,00 (1,2 × 45) e R$ 21,60 (1,2 × 18), exibidos como `R$ 54` e `R$ 22`. *(CALC-07)*
3. WHEN nenhuma carne está selecionada THEN nenhum item de carne SHALL entrar na lista e o valor de carne SHALL ser 0 — sem divisão por zero. *(CALC-07)*
4. WHEN pão de alho está selecionado THEN `un = max(1, ceil(pessoas × 0,5 × f))` a R$ 6/un; 7 pessoas, f=1 → **4 un, R$ 24**. *(CALC-08)*
5. WHEN cerveja está selecionada THEN `latas = max(1, ceil(adultosQueBebem × 1000 × f / 350))` a R$ 4/lata; 6 adultos, f=1 → **18 latas, R$ 72**. *(CALC-09)*
6. WHEN refrigerante está selecionado THEN `garrafas 2L = max(1, ceil((adultos×400 + crianças×500) × f / 2000))` a R$ 9/gf; 6 adultos + 1 criança, f=1 → **2 gf, R$ 18**. *(CALC-10)*
7. WHEN suco está selecionado THEN `litros = max(1, ceil((adultos×250 + crianças×400) × f / 1000))` a R$ 8/L. *(CALC-11)*
8. WHEN água está selecionada THEN `garrafas 1,5L = max(1, ceil(pessoas × 400 × f / 1500))` a R$ 3/gf; 7 pessoas, f=1 → **2 gf, R$ 6**. *(CALC-12)*
9. WHEN destilados estão selecionados THEN `ml por destilado = adultos × 120 × f / nº selecionados` e `garrafas = max(1, ceil(ml/1000))`; preços Vodka R$ 40, Cachaça R$ 15, Whisky R$ 90; 6 adultos, f=1, só cachaça → 720 ml → **1 gf, R$ 15**. *(CALC-13)*
10. WHEN o consumível é restrito a adultos (cerveja, destilados) e `adultos == 0` THEN a quantidade SHALL ser 0 e o item SHALL ficar fora da lista. *(CALC-09, CALC-13, A-12)*
11. WHEN a lista é montada THEN os quatro essenciais de RN-10 (🔥 Carvão 1 saco R$ 22 · 🧊 Gelo 3 sacos R$ 10/saco · 🧂 Sal grosso 1 kg R$ 8 · 🍽️ Copos & pratos 1 kit R$ 15) SHALL entrar **sozinhos**, marcados como essenciais e com a fonte da proporção declarada (`kg de carne`, `volume de bebida gelada`, `kg de carne`, `nº de pessoas`). *(CALC-14)*
12. WHEN o total dos essenciais é somado THEN SHALL somar **apenas** os essenciais com `entraNoTotal` verdadeiro — Carvão + Gelo + Sal = **R$ 60** —, enquanto Copos & pratos continua **visível na lista** e fora do total. *(CALC-14, A-01/A-02)*

**Independent Test**: chamar cada função com o estado padrão e comparar com os números acima, um a um.

---

### P1-4: Lista calculada, preferências e custo ao vivo ⭐ MVP

**User Story**: Como anfitrião, quero ver o total e o "por cabeça" mudarem a cada toque, já ajustados às preferências da galera, para saber o custo antes de convidar ninguém.

**Why P1**: É o aceite de UC-03/UC-04 e o caso literal do arquivo 03 — o critério de M0 no ROADMAP.

**Acceptance Criteria**:

1. WHEN a composição é o estado padrão (3H+3M+1C, 4h, bovina + frango + pão de alho + refrigerante + água + cerveja + cachaça, sem pessoas nomeadas) THEN o total dos itens SHALL ser **R$ 211** e o por cabeça **≈ R$ 30**. *(CALC-16)*
2. WHEN a esse mesmo estado somam-se os essenciais que entram no total THEN o total SHALL ser **R$ 271** e o por adulto **≈ R$ 45** — **os dois números**, não só o total. *(CALC-16, A-01)*
3. WHEN a lista é montada THEN a ordem dos itens SHALL ser a ordem canônica do catálogo, estável entre execuções. *(CALC-15)*
4. WHEN há ≥1 pessoa nomeada com dieta veggie THEN o item "Legumes p/ grelha (kit veggie)" SHALL entrar na lista (1 kit, R$ 28). *(CALC-15)*
5. WHEN há ≥1 pessoa nomeada com dieta "sem porco" THEN a carne suína SHALL sair da lista, mesmo que esteja selecionada, e as gramas SHALL ser redivididas entre as carnes restantes. *(CALC-15)*
6. WHEN há pessoas nomeadas THEN a cerveja SHALL dimensionar por `adultosQueBebem = max(0, adultos − nomeados com bebe == false)`; sem pessoas nomeadas SHALL usar `adultos`. *(CALC-15, A-06)*
7. WHEN uma pessoa nomeada tem `bebe == null` ou `dieta == null` THEN ela SHALL **não** contar como abstêmia nem como veggie. *(CALC-15, A-08)*
8. WHEN `pessoas == 0` THEN a lista SHALL ser vazia e todos os totais SHALL ser 0 — nunca negativo, nunca com os pisos `max(1, …)`. *(CALC-16, UC-03 E1)*
9. WHEN a mesma composição é calculada duas vezes THEN os dois resultados SHALL ser iguais. *(CALC-27)*
10. WHEN a quantidade de um item é ajustada THEN o passo SHALL ser 0,5 kg para carnes, 2 latas para cerveja e 1 para os demais, com **mínimo igual a um passo**. *(CALC-17)*
11. WHEN o preço de um item é ajustado THEN o passo SHALL ser R$ 1 e o mínimo R$ 1. *(CALC-17)*
12. WHEN um item tem qualquer override THEN ele SHALL se declarar **editado**; WHEN é restaurado THEN SHALL voltar exatamente ao valor automático e deixar de se declarar editado. *(CALC-17)*
13. WHEN existe ao menos um item editado THEN a lista SHALL informar que há overrides a restaurar; WHEN todos são restaurados THEN SHALL informar que não há. *(CALC-17)*

**Independent Test**: montar a composição padrão, conferir R$ 211/≈R$ 30 e R$ 271/≈R$ 45; nomear um veggie e um "sem porco" e conferir a lista mudar; editar e restaurar um item.

---

### P1-5: Racha e acerto ⭐ MVP

**User Story**: Como participante, quero saber exatamente quanto devo, para quem, e quanto já foi quitado — descontando o que eu levei —, para o rolê acabar sem treta.

**Why P1**: É a terceira promessa do produto e o aceite de UC-19..UC-23.

**Acceptance Criteria**:

1. WHEN uma pessoa assume itens ("eu levo") e/ou adianta despesas THEN a contribuição dela SHALL ser a soma dos valores dos itens atribuídos mais o valor das despesas que adiantou. *(CALC-18)*
2. WHEN nenhum item é atribuído a uma pessoa THEN a contribuição dela SHALL ser 0 — não negativa, não nula. *(CALC-18)*
3. WHEN a cota é calculada THEN SHALL ser `total ÷ nº de adultos participantes`, com **criança sempre de fora**; total 320 e 4 adultos → cota **R$ 80**. *(CALC-19)*
4. WHEN `adultos == 0` THEN a cota SHALL ser 0 — sem divisão por zero e sem `NaN`/`Infinity`. *(CALC-19)*
5. WHEN o saldo é calculado THEN SHALL ser `contribuição − cota`, e a situação SHALL ser **recebe** (>0), **paga** (<0) ou **no zero** (=0, dentro da tolerância de 1 centavo). *(CALC-20)*
6. WHEN os saldos do **Teste A** entram (VOCÊ 200, ANA 120, LÉO 0, BIA 0 → total 320, cota 80) THEN `calcularRacha` SHALL devolver exatamente, nesta ordem: **LÉO→VOCÊ R$ 80 · BIA→VOCÊ R$ 40 · BIA→ANA R$ 40**. *(CALC-21)*
7. WHEN os saldos do **Teste B** entram (Rafa 200, Ana 120, Léo 60, Bia 0 → total 380, cota 95) THEN `calcularRacha` SHALL devolver exatamente, nesta ordem: **LÉO→RAFA R$ 35 · BIA→RAFA R$ 70 · BIA→ANA R$ 25**. *(CALC-21)*
8. WHEN o racha é calculado THEN devedores e credores SHALL ser percorridos **na ordem de entrada**, nunca reordenados por valor. *(CALC-21, A-14)*
9. WHEN o racha é calculado THEN a soma paga SHALL igualar a soma recebida (UC-20), e nenhuma linha SHALL ter valor menor ou igual a 1 centavo. *(CALC-21, A-13)*
10. WHEN não há credores, ou não há devedores, ou a lista de saldos é vazia THEN `calcularRacha` SHALL devolver lista vazia sem lançar. *(CALC-21)*
11. WHEN uma despesa é dividida THEN o sistema SHALL expor o valor por adulto e o número de adultos ("split R$ X × N"), com N = adultos participantes. *(CALC-22)*
12. WHEN as linhas de acerto são resumidas THEN o progresso SHALL expor `pagas`, `total`, `valorPago`, `valorDevido` e `fracao = valorPago ÷ valorDevido`; todas pagas → fração 1.0. *(CALC-23)*
13. WHEN não há nenhuma linha THEN a fração SHALL ser 1.0, com `pagas = 0` e `total = 0`. *(CALC-23, A-16)*
14. WHEN uma linha alterna entre pendente e paga THEN a transição SHALL ser reversível e o progresso SHALL refletir a mudança. *(CALC-23)*

**Independent Test**: rodar os Testes A e B literalmente e conferir linha a linha; marcar uma linha como paga e ver o progresso mover.

---

### P2-1: Preço médio real e total do pedido

**User Story**: Como quem vai comprar, quero ver a média real de mercados com a faixa mín/máx e o total do pedido com frete, para confiar no número e decidir onde comprar.

**Why P2**: Não bloqueia M0 nem o caso literal; é insumo da spec 06 `lista` (M1). Mas a aritmética não pode nascer lá.

**Acceptance Criteria**:

1. WHEN a tabela de preços de mercado é lida THEN SHALL reproduzir literalmente as 8 linhas de RN-11 (item, corredor, qtd, média, mín, máx, fontes). *(CALC-24)*
2. WHEN o total da tabela é somado THEN SHALL ser média **R$ 286**, faixa **R$ 234 – R$ 356**. *(CALC-24)*
3. WHEN a posição do marcador é pedida THEN SHALL ser `(média − mín) ÷ (máx − mín)`, sempre dentro de `[0,1]`. Para a Picanha (65, 54, 83): `11/29 ≈ 0.379`. *(CALC-25)*
4. WHEN `máx == mín` THEN a posição SHALL ser `0.0` — sem divisão por zero. *(CALC-25, A-15)*
5. WHEN um pedido é totalizado THEN `total = subtotal + frete`, e frete 0 SHALL dar total igual ao subtotal (Zé Delivery). *(CALC-26)*

**Independent Test**: comparar a tabela linha a linha com RN-11, somar os totais e conferir 286/234–356; calcular a posição da Picanha.

---

### P1-6: Superfície pública e fixture tipada

**User Story**: Como desenvolvedor de tela, quero importar um único barrel e receber tudo pronto — inclusive a fixture RN-30 já tipada — para nunca precisar recalcular nem reconstruir dado de teste.

**Why P1**: É o contrato que impede a fórmula de vazar. E a tipagem da fixture é compromisso herdado da fundação (`spec.md` §Nota de dependência).

**Acceptance Criteria**:

1. WHEN uma feature importa apenas `package:bora/core/calculo/calculo.dart` THEN SHALL ter acesso a todas as entidades, regras e formatadores necessários para reproduzir o caso literal R$ 211 — sem importar nenhum arquivo interno da pasta. *(CALC-27)*
2. WHEN a fixture RN-30 é lida em versão tipada THEN SHALL devolver `Festa`, `List<Pessoa>` e a lista de `ChaveItem`, **derivadas dos mapas brutos existentes**, batendo campo a campo com RN-30. *(CALC-06)*
3. WHEN a fixture tipada é construída THEN `dieta` e `bebe` da Duda SHALL ser `null`. *(CALC-06, A-08)*
4. WHEN a suíte roda THEN todas as asserções de `test/fixtures/rn30_estado_inicial_test.dart` SHALL continuar valendo **sem enfraquecimento** — inclusive a ausência de `dieta`/`bebe` na Duda e a de que todo valor bruto é primitivo. *(CALC-06)*

**Independent Test**: um teste que importa só o barrel e reproduz R$ 211; outro que compara a fixture tipada com RN-30 e roda a suíte antiga inalterada.

---

## Edge Cases

- WHEN `horas = 2` THEN `f` SHALL ser exatamente 0.5 (fronteira do piso), e WHEN `horas = 0` THEN SHALL ser 0.5 também.
- WHEN `pessoas = 0` THEN lista vazia, todos os totais 0, nenhum piso `max(1, …)` aplicado, nada negativo.
- WHEN `adultos = 0` e `crianças > 0` THEN cerveja e destilados ficam fora; refrigerante e água ainda entram (`max(1, …)` vale, pois há plateia).
- WHEN nenhuma carne está selecionada THEN nenhuma divisão por número de carnes acontece e a lista não tem item de carne.
- WHEN "sem porco" remove a **única** carne selecionada THEN o resultado SHALL ser idêntico a "nenhuma carne selecionada".
- WHEN as gramas por carne dão exatamente 1150 g THEN o arredondamento a 0,1 kg SHALL dar **1,2 kg** (meio para cima) — e não 1,1 kg por erro de ponto flutuante.
- WHEN as gramas por carne dão menos de 500 g THEN a quantidade SHALL ser 0,5 kg (piso de RN-03), desde que haja ≥1 pessoa.
- WHEN a quantidade de uma carne é decrementada abaixo de 0,5 kg THEN SHALL parar em 0,5 kg (um passo); a cerveja SHALL parar em 2 latas; os demais em 1.
- WHEN o preço de um item é decrementado abaixo de R$ 1 THEN SHALL parar em R$ 1.
- WHEN a lista de saldos de `calcularRacha` é vazia, ou só tem credores, ou só tem devedores THEN o resultado SHALL ser lista vazia.
- WHEN um saldo residual é menor ou igual a R$ 0,01 THEN SHALL ser tratado como zero e **não** gerar linha.
- WHEN todos os saldos são zero THEN não SHALL haver nenhuma linha e todo mundo SHALL estar "NO ZERO".
- WHEN `máx == mín` numa faixa de preço THEN a posição do marcador SHALL ser 0.0.
- WHEN não há linhas de acerto THEN o progresso SHALL ser `0 de 0` com fração 1.0.
- WHEN um valor monetário é exatamente `.5` (ex.: 30.5) THEN o arredondamento SHALL ser **para cima** (31), meio afastado do zero.
- WHEN o valor formatado passa de mil THEN SHALL usar `.` como separador de milhar (`R$ 1.234`), nunca `,`.

---

## Requirement Traceability

| Requirement ID | Regra-fonte | Story | Fase | Status |
|---|---|---|---|---|
| CALC-01 | RN-01 | P1-1 | Tasks | In Tasks |
| CALC-02 | RN-02 | P1-1 | Tasks | In Tasks |
| CALC-03 | RN-13 (dinheiro) | P1-1 | Tasks | In Tasks |
| CALC-04 | RN-13 (horas) | P1-1 | Tasks | In Tasks |
| CALC-05 | arquivo 01 §6 | P1-2 | Tasks | In Tasks |
| CALC-06 | RN-30 (tipagem) | P1-6 | Tasks | In Tasks |
| CALC-07 | RN-03 | P1-3 | Tasks | In Tasks |
| CALC-08 | RN-04 | P1-3 | Tasks | In Tasks |
| CALC-09 | RN-05 | P1-3 | Tasks | In Tasks |
| CALC-10 | RN-06 | P1-3 | Tasks | In Tasks |
| CALC-11 | RN-07 | P1-3 | Tasks | In Tasks |
| CALC-12 | RN-08 | P1-3 | Tasks | In Tasks |
| CALC-13 | RN-09 | P1-3 | Tasks | In Tasks |
| CALC-14 | RN-10 | P1-3 | Tasks | In Tasks |
| CALC-15 | RN-21 | P1-4 | Tasks | In Tasks |
| CALC-16 | RN-10 (exemplo), RN-13, RN-14 | P1-4 | Tasks | In Tasks |
| CALC-17 | RN-12 | P1-4 | Tasks | In Tasks |
| CALC-18 | RN-20 | P1-5 | Tasks | In Tasks |
| CALC-19 | RN-14 | P1-5 | Tasks | In Tasks |
| CALC-20 | RN-15 | P1-5 | Tasks | In Tasks |
| CALC-21 | RN-16 | P1-5 | Tasks | In Tasks |
| CALC-22 | RN-17 | P1-5 | Tasks | In Tasks |
| CALC-23 | RN-18 | P1-5 | Tasks | In Tasks |
| CALC-24 | RN-11 (tabela) | P2-1 | Tasks | In Tasks |
| CALC-25 | RN-11 (marcador) | P2-1 | Tasks | In Tasks |
| CALC-26 | RN-27 (só totais) | P2-1 | Tasks | In Tasks |
| CALC-27 | CLAUDE.md (Dart puro, ninguém recalcula) | P1-2, P1-6 | Tasks | In Tasks |

**ID format:** `CALC-NN` · **Status:** Pending → In Design → In Tasks → Implementing → Verified
**Coverage:** 27 requisitos, 27 mapeados a componente no `design.md`, 27 mapeados a task no `tasks.md` (T1–T27), 0 órfãos.

### Matriz RN-xx → CALC-xx (a rastreabilidade do arquivo 05 tem que continuar verdadeira)

| RN | CALC | RN | CALC |
|---|---|---|---|
| RN-01 | CALC-01 | RN-13 | CALC-03, CALC-04 |
| RN-02 | CALC-02 | RN-14 | CALC-16, CALC-19 |
| RN-03 | CALC-07 | RN-15 | CALC-20 |
| RN-04 | CALC-08 | RN-16 | CALC-21 |
| RN-05 | CALC-09, CALC-15 | RN-17 | CALC-22 |
| RN-06 | CALC-10 | RN-18 | CALC-23 |
| RN-07 | CALC-11 | RN-20 | CALC-18 |
| RN-08 | CALC-12 | RN-21 | CALC-15 |
| RN-09 | CALC-13 | RN-27 (só totais) | CALC-26 |
| RN-10 | CALC-14, CALC-16 | RN-30 (só tipagem) | CALC-06 |
| RN-11 | CALC-24, CALC-25 | arquivo 01 §6 | CALC-05 |
| RN-12 | CALC-17 | CLAUDE.md (pureza) | CALC-27 |

**RNs fora do escopo, com dono declarado:** RN-19 → `custos` · RN-22, RN-23 → `galera` · RN-24 → `convidado` · RN-25, RN-26, RN-26b → `convite` · RN-27 (corredores e parceiros) → `lista` · RN-28 → `convidado`/`home` · RN-29 → `design-system`.

---

## Contratos de fronteira com a spec 01 `design-system` (em execução paralela)

A spec 01 **não calcula nada** — ela consome. Dois contratos precisam existir antes que a UI encoste no assunto:

1. **Barra de faixa de preço (RN-11 / DS §5):** esta camada expõe a posição do marcador como um `double` já resolvido em `[0,1]`. O componente só pinta — **não** conhece média, mín nem máx para fazer a divisão. *(CALC-25)*
2. **Dinheiro (RN-13):** esta camada expõe o formatador. A UI **nunca** formata dinheiro por conta própria; recebe string pronta ou chama o formatador desta camada. *(CALC-03)*

---

## Success Criteria

- [ ] `flutter test` verde com os quatro casos literais do arquivo 03 passando: R$ 211/≈R$ 30, R$ 271/≈R$ 45, Teste A e Teste B.
- [ ] `flutter analyze` com zero issues e `test/architecture/calculo_isolation_test.dart` continuando verde — nenhum import de Flutter ou Firebase entrou em `core/calculo/`.
- [ ] Toda RN-01..RN-21 (menos as fora de escopo) tem pelo menos um teste que a nomeia.
- [ ] Todo edge case listado acima tem teste dedicado.
- [ ] A suíte antiga da fixture RN-30 continua passando **sem uma única asserção enfraquecida**.
- [ ] Nenhum arquivo criado fora de `lib/core/calculo/`, `test/core/calculo/` e `test/fixtures/rn30_estado_inicial*`.
