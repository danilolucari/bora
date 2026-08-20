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

## Quarantined (failed when applied — ignore)

A confirmed lesson that recurred alongside failure. Kept for the maintainer to review.

_none_
