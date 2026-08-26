# LESSONS — auto-maintained by scripts/lessons.py

> Machine-owned. Do NOT hand-edit. Changes are overwritten on the next `lessons.py` write.
> Canonical state lives in `.specs/lessons.json`. Edit lessons only via the script.
> promote_threshold=2 distinct features · window_days=45 · quarantine_threshold=2

## Confirmed (load these at Specify/Design)

Corroborated across multiple features. Safe to apply as guidance.

_none_

## Candidates (under observation — do NOT load as guidance yet)

Seen once or not yet corroborated. Tracked, not trusted.

### L-001 — Toda rota alcançável que existe só como redirect precisa de um teste que a abra e afirme o destino final
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `routing` · harmful: 0
- features: fundacao
- evidence: validation.md Sensor mutação 12 — lib/core/routing/app_router.dart:77 (routing)
- last seen: 2026-08-20T14:20:00Z

### L-002 — Não afirme como literal de spec um valor que a spec não define; registre o default como assumption antes de congelá-lo em teste
- signal: `spec_precision_gap` · recurrence: 1 feature(s) · scope: `fixtures` · harmful: 0
- features: fundacao
- evidence: validation.md gap #1 — test/fixtures/rn30_estado_inicial_test.dart:59 (fixtures)
- last seen: 2026-08-20T14:20:13Z

### L-003 — Adaptador declarado sem teste unitário deixa o efeito do AC sem prova; declare qual AC fica dependente de verificação manual
- signal: `spec_precision_gap` · recurrence: 1 feature(s) · scope: `firebase` · harmful: 0
- features: fundacao
- evidence: validation.md gap #2 — FUND-16 AC2, lib/core/firebase/firebase_bootstrap.dart:45 (firebase)
- last seen: 2026-08-20T14:20:13Z

### L-004 — Quando a implementação alcança o resultado do AC por outro mecanismo que não o nomeado, alinhe o texto do AC em vez de deixar a divergência só no design
- signal: `spec_precision_gap` · recurrence: 1 feature(s) · scope: `observability` · harmful: 0
- features: fundacao
- evidence: validation.md gap #3 — FUND-17 AC4, lib/bootstrap/app_bootstrap.dart:46 (observability)
- last seen: 2026-08-20T14:20:13Z

### L-005 — Desvio que acrescenta um nó de rota deve vir acompanhado do teste que cobre o nó acrescentado, não só da prova de que as URLs antigas não mudaram
- signal: `spec_deviation` · recurrence: 1 feature(s) · scope: `routing` · harmful: 0
- features: fundacao
- evidence: validation.md SPEC_DEVIATION 2 — lib/core/routing/app_router.dart:17-26 (routing)
- last seen: 2026-08-20T14:20:20Z

### L-006 — Guarda que compara path de filesystem contra constante escrita com barra normal e verde no POSIX e vermelha no Windows: normalize o separador antes de comparar.
- signal: `gate_fail` · recurrence: 1 feature(s) · scope: `test/architecture` · harmful: 0
- features: design-system
- evidence: test/core/design_system/architecture/token_purity_guard_test.dart:261 (test/architecture)
- last seen: 2026-08-25T17:19:10Z

### L-007 — Allowlist de guarda deve liberar a forma exata, nao o arquivo: liberar o arquivo abre um buraco do tamanho do arquivo inteiro.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `test/architecture` · harmful: 0
- features: design-system
- evidence: GAP-1 e GAP-2 do validation.md (test/architecture)
- last seen: 2026-08-25T17:19:10Z

### L-008 — Assercao contra literal concorda com o literal do componente: para amarrar componente a token, compare com o token.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `test/components` · harmful: 0
- features: design-system
- evidence: GAP-3 do validation.md (test/components)
- last seen: 2026-08-25T17:19:11Z

### L-009 — Justificativa de AD com exemplo numerico tem de ser rodada antes de virar registro: a de AD-009 era falsa e passou por planner, implementador e revisao.
- signal: `spec_precision_gap` · recurrence: 1 feature(s) · scope: `.specs` · harmful: 0
- features: calculo
- evidence: AD-009 (.specs)
- last seen: 2026-08-25T17:19:11Z

### L-010 — Tolerancia usada como filtro de entrada precisa de teste com o caso na frente da fila: no fim da fila os outros testes ja cobrem.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `lib/core/calculo/regras` · harmful: 0
- features: calculo
- evidence: M12 do validation.md (lib/core/calculo/regras)
- last seen: 2026-08-25T17:19:11Z

### L-011 — Entidade de dominio com colecao precisa de igualdade profunda: == de List, Set e Map em Dart e identidade.
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `lib/core/calculo/dominio` · harmful: 0
- features: calculo
- evidence: P1-2 AC2 (lib/core/calculo/dominio)
- last seen: 2026-08-25T17:19:11Z

### L-012 — Premissa sobre o ambiente (nao ha device, nao ha navegador) tem de ser retestada a cada maquina: a de R-11 valia so na maquina antiga e foi herdada por tres documentos, dando um criterio como impossivel por duas sessoes ate alguem rodar flutter devices.
- signal: `spec_precision_gap` · recurrence: 1 feature(s) · scope: `.specs` · harmful: 0
- features: design-system
- evidence: R-11 / DS-33 (.specs)
- last seen: 2026-08-25T19:46:26Z

### L-013 — No Git Bash do Windows, argumento que comeca com barra e convertido em caminho Windows: use MSYS_NO_PATHCONV=1 em adb, git show ref:path e flags como --route.
- signal: `gate_fail` · recurrence: 1 feature(s) · scope: `windows` · harmful: 0
- features: design-system
- evidence: --route=C:\Program Files\Git\catalogo virou C;C:\Program Files\Git\Program Files\Git\catalogo (windows)
- last seen: 2026-08-25T19:46:27Z

### L-014 — Assert the resulting router location string for every navigation acceptance criterion, not the destination widget key, because distinct routes can render the same page widget
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `routes` · harmful: 0
- features: home
- evidence: validation.md M8/M9/M10 — home_page_test.dart:139,149,160,169; app_shell_acao_test.dart:56 (routes)
- last seen: 2026-08-26T15:32:21Z

### L-015 — Pass skipOffstage false when asserting that a navigation did not stack a second page, because the default finder hides the covered route and the assertion cannot fail
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `widget-tests` · harmful: 0
- features: home
- evidence: validation.md M3 — home_page_test.dart:199 (widget-tests)
- last seen: 2026-08-26T15:32:31Z

### L-016 — Assert the vertical order of sections that share a layout column, not only their horizontal side, because a column-order swap survives a side-only assertion
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `layout-tests` · harmful: 0
- features: home
- evidence: validation.md M15 — home_expandida_test.dart:107-120 (layout-tests)
- last seen: 2026-08-26T15:32:32Z

### L-017 — Give every element named in a layout acceptance criterion its own positional assertion, because an element only asserted as present leaves its placement unverified
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `layout-tests` · harmful: 0
- features: home
- evidence: validation.md HOME-05 AC3 / HOME-12 AC4 — grep -rn ArquivoDeFestas test/ (layout-tests)
- last seen: 2026-08-26T15:32:32Z

### L-018 — When a field is added outside the design to satisfy a requirement, add the test that proves the field reaches the behaviour the requirement names
- signal: `spec_deviation` · recurrence: 1 feature(s) · scope: `domain` · harmful: 0
- features: home
- evidence: validation.md — resumo_de_festa.dart:28-39 (ResumoDeFesta.id) (domain)
- last seen: 2026-08-26T15:32:40Z

### L-019 — Flag as a spec-precision gap any acceptance criterion whose word describes runtime behaviour the test only approximates by static geometry
- signal: `spec_precision_gap` · recurrence: 1 feature(s) · scope: `chrome` · harmful: 0
- features: home
- evidence: validation.md P1-1 AC1 — app_shell_test.dart:184 (chrome)
- last seen: 2026-08-26T15:32:40Z

### L-020 — Exercise a capping or truncating expression with input above the cap, because every fixture sized at or below the cap makes the expression a no-op
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `widget-tests` · harmful: 0
- features: home
- evidence: validation.md iter2 N1 — card_da_festa.dart:108; nenhum teste de widget com >3 iniciais (widget-tests)
- last seen: 2026-08-26T20:02:02Z

### L-021 — Assert the style on the same node that carries the text, because a widget level style assertion misses a colour applied on the span
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `widget-tests` · harmful: 0
- features: home
- evidence: validation.md iter2 N7 — card_da_festa_test.dart:136-139 (widget-tests)
- last seen: 2026-08-26T20:02:03Z

### L-022 — Set the MediaQuery inset a test needs to observe, because inset aware widgets are invisible in a default test surface with zero padding
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `widget-tests` · harmful: 0
- features: home
- evidence: validation.md iter2 N5 — app_shell.dart:84-85; grep MediaQuery em test/ vazio (widget-tests)
- last seen: 2026-08-26T20:02:03Z

### L-023 — Test the defensive copy on every entry point that stores caller data, not only on the constructor
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `repo-layer` · harmful: 0
- features: home
- evidence: validation.md iter2 N6 — festa_repository_em_memoria.dart:57; teste só cobre a semente (repo-layer)
- last seen: 2026-08-26T20:02:13Z

### L-024 — Prove a claimed regression test by removing the fix and watching it fail, because a fix commit can ship with a test that never exercised the defect
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `process` · harmful: 0
- features: home
- evidence: validation.md iter2 N5 — tasks.md declara regressão para bf55f82 e 4e4a069 (process)
- last seen: 2026-08-26T20:02:13Z

### L-025 — File a value the spec states precisely but the code does not implement as a deferred requirement, never as a spec precision gap
- signal: `spec_precision_gap` · recurrence: 1 feature(s) · scope: `process` · harmful: 0
- features: home
- evidence: validation.md iter2 SP-8 — card_da_festa.dart:51-55 (avatar 40px de W-02) (process)
- last seen: 2026-08-26T20:02:13Z

## Quarantined (failed when applied — ignore)

A confirmed lesson that recurred alongside failure. Kept for the maintainer to review.

_none_
