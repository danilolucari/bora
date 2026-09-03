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

### L-026 — Give a test stub the same structure as the real child it stands for, because a simpler stub can make the assertion unable to exhibit the defect it names
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `widget-tests` · harmful: 0
- features: home
- evidence: validation.md iter3 P1 — app_shell_test.dart:180-193; probe mediu faixa de 44px com filho realista, asserção ficou verde sob P1 e sob N5 (widget-tests)
- last seen: 2026-08-26T20:13:39Z

### L-027 — Guard de varredura que procura um literal de string tem de procurá-lo como a linguagem obriga a escrevê-lo na fonte (em Dart, o cifrão só existe escapado ou em raw string) — e o teste da regra tem de passar a fonte crua, não a string já desescapada.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `test/**/architecture` · harmful: 0
- features: montar
- evidence: M5 — formula_nao_vaza_test.dart:140 (test/**/architecture)
- last seen: 2026-08-31T19:30:00Z

### L-028 — Quando um copyWith é escrito à mão porque a entidade não tem um, cada campo apenas repassado precisa de um teste que dispare um evento e reafirme o campo depois — senão a preservação sobrevive por acidente.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `presentation/bloc` · harmful: 0
- features: montar
- evidence: M7/M18 — montar_bloc.dart:373-386 (presentation/bloc)
- last seen: 2026-08-31T19:30:00Z

### L-029 — Teste de tela montado só com os valores default não discrimina o campo do literal: use dado diferente do default e afirme também a ausência do default.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `test/**/widgets` · harmful: 0
- features: montar
- evidence: M8 — montar_expandido.dart:150 (test/**/widgets)
- last seen: 2026-08-31T19:30:00Z

### L-030 — Teste de widget que monta o próprio gatilho (um GestureDetector local com bloc do próprio teste) não exercita a fiação da página: o valor que a página passa de verdade fica livre para ser fixado sem matar teste — abra pela rota real, e cuidado com helper cujo nome promete rota e não abre nenhuma.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `test/widget` · harmful: 0
- features: lista
- evidence: GAP-1 lista_page.dart:145 (test/widget)
- last seen: 2026-09-02T12:42:42Z

### L-031 — Valor afirmado que coincide com um default, uma fixture ou o literal da spec não discrimina: o mutante que fixa esse mesmo literal sobrevive. Escolha um valor distinto de todo default — e desconfie inclusive da receita prescrita por um Verifier.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `test/widget` · harmful: 0
- features: lista
- evidence: GAP-2 lista_page.dart:144 (test/widget)
- last seen: 2026-09-02T12:42:42Z

### L-032 — Duas guardas no mesmo handler precisam de sensor separado: uma morre de carona na outra e o furo passa por duas iterações. Mute cada guarda isoladamente.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `lib/bloc` · harmful: 0
- features: lista
- evidence: GAP-4 lista_bloc.dart _aoReceberFesta (lib/bloc)
- last seen: 2026-09-02T12:42:42Z

### L-033 — Equivalência de mutante não se prova pela suíte continuar verde — isso é a hipótese, não a prova. Prove procurando o caminho que discrimina; aqui a guarda parecia inerte e na verdade descartava escrita externa legítima.
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `verificação` · harmful: 0
- features: lista
- evidence: iteração 2, alegação de equivalência do GAP-4 (verificação)
- last seen: 2026-09-02T12:42:42Z

### L-034 — find.text acha texto ilegível: teste de árvore não prova que o pixel dá para ler. Botão secundário renderizou como bloco preto por ~1900 testes e dois Verifiers — rode o app antes de dar uma tela por pronta.
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `test/widget` · harmful: 0
- features: design-system
- evidence: BoraSecondaryButton, achado com a skill run em 2026-09-01 (test/widget)
- last seen: 2026-09-02T12:42:56Z

### L-035 — BoxShadow do Flutter não é recortado para fora da borda como o box-shadow do CSS: sombra sem blur atrás de fundo transparente aparece através do widget e tapa o conteúdo. Ao portar sombra dura de protótipo HTML, o fundo tem de ser opaco.
- signal: `spec_deviation` · recurrence: 1 feature(s) · scope: `lib/design_system` · harmful: 0
- features: design-system
- evidence: bora_surface.dart decoracaoDe + fundo transparente (lib/design_system)
- last seen: 2026-09-02T12:42:56Z

### L-036 — Quando o codigo ou o nome do teste promete escrever SO um campo, afirme o registro inteiro igual ao anterior a menos daquele campo, nunca so o campo escrito
- signal: `surviving_mutant` · recurrence: 1 feature(s) · scope: `repo-layer` · harmful: 0
- features: galera
- evidence: validation.md §Re-verificação — mutação V2, galera_repositorio_sobre_festas.dart:127 (repo-layer)
- last seen: 2026-09-03T10:38:36Z

### L-037 — Todo teste de um layout responsivo afirma qual widget de layout esta montado, senao ele passa testando o outro layout em silencio
- signal: `ac_gap` · recurrence: 1 feature(s) · scope: `presentation` · harmful: 0
- features: galera
- evidence: validation.md §Fix 3 — sonda V1, galera_expandida_test.dart:443,455,467 (presentation)
- last seen: 2026-09-03T10:38:45Z

### L-038 — Criterio garantido por dois elos separados precisa de um teste ponta-a-ponta alem do sensor em cada elo
- signal: `spec_precision_gap` · recurrence: 1 feature(s) · scope: `presentation` · harmful: 0
- features: galera
- evidence: validation.md §Os tres ⚠️ — P1-2 AC2 (presentation)
- last seen: 2026-09-03T10:38:45Z

### L-039 — Conte os marcadores SPEC_DEVIATION por varredura do codigo, nunca pelo que o handoff lista
- signal: `spec_deviation` · recurrence: 1 feature(s) · scope: `process` · harmful: 0
- features: galera
- evidence: validation.md §Auditoria dos desvios declarados — 6 marcadores SPEC_DEVIATION, handoff contava 2 (process)
- last seen: 2026-09-03T10:38:45Z

### L-040 — Neste repo o checkout é CRLF (core.autocrlf=true): ferramenta que edita arquivo por bytes deve casar a âncora com o fim de linha real e regravar os mesmos bytes que leu, ou o restauro deixa a árvore suja com git diff vazio.
- signal: `gate_fail` · recurrence: 1 feature(s) · scope: `test/verification` · harmful: 0
- features: galera
- evidence: .specs/features/galera/validation.md — incidente de fim de linha, iterações 2 e 3 (harness de mutação) (test/verification)
- last seen: 2026-09-03T12:22:14Z

## Quarantined (failed when applied — ignore)

A confirmed lesson that recurred alongside failure. Kept for the maintainer to review.

_none_
