# A galera — Validation

**Date**: 2026-09-02 (iteração 1) · **2026-09-03** (iteração 2 — re-verificação, ao fim deste arquivo)
**Spec**: `.specs/features/galera/spec.md` (GAL-01..GAL-28)
**Diff range**: `main...HEAD` na branch `feature/galera` — 30 commits, 68 arquivos, `+10910 / −329` linhas
**Verifier**: sub-agente independente (autor ≠ verificador). Cobertura re-derivada do zero a partir da `spec.md`, regra **evidence-or-zero**. Nenhuma alegação dos batch workers foi aceita — inclusive os autoexames de discriminação que eles relataram.

**Veredito**: ❌ **FAIL** — fechado na **iteração 2** (ver §Re-verificação). Gate verde (2449/0, `analyze` limpo), **58/61 critérios ✅**, **0 ❌**, **3 ⚠️** declarados, e **1 mutante sobrevivente novo** (V2) — falha **de teste, não de produto**: nenhuma linha de `lib/` está errada hoje. A regra de `validate.md` ("surviving mutants are fix tasks — do not mark the feature done") é o que decide o veredito. **1 Fix Major + 2 Minor** em §Fix Plans; resta **1** iteração das 3.

---

## Task Completion

| Task | Status | Notas |
|---|---|---|
| T1..T27 | ✅ Done | `tasks.md` tem **239** critérios `- [x]` marcados nas 27 tasks. Os **10** `- [ ]` restantes são a seção "Success Criteria da feature (da `spec.md`, conferidos ao fim)" — o checklist **deste** relatório, não trabalho pendente. Um commit por task, na ordem, `01610c2`..`9874ae5`. |
| fix fora do plano | ✅ Done | `3f521c2` — round-trip de `ResumoDeFesta` (ver §Round-trip). |

---

## Gate Check

- **Comando**: `flutter test` · `flutter analyze` (Gate Check Commands de `tasks.md` §Gate)
- **Resultado**: **2439 passaram, 0 falharam, 0 pulados** (`exit 0`, conferido por mim, não pelo relato)
- **`flutter analyze`**: `No issues found! (ran in 1.8s)` (`exit 0`)
- **Baseline antes da feature** (`main`): 1935 · **depois**: 2439 · **delta**: **+504**
- **Árvore**: `git status --porcelain` **vazio** antes de começar (conferido).

**Test Integrity Check** — `git diff main...HEAD -- test/` toca apenas dois arquivos de teste pré-existentes:

| Arquivo | Mudança | Veredito |
|---|---|---|
| `test/core/festas/dominio/festa_em_edicao_repository_test.dart` | 1 linha | (auditado abaixo) |
| `test/core/routing/app_router_shell_test.dart` | +2 linhas | (auditado abaixo) |
| `test/support/app_de_teste.dart` | +13/−? | suporte, não asserção |

Nenhum `skip:` novo em `test/features/galera/**`. Nenhum teste apagado.

---

## Spec-Anchored Acceptance Criteria

Legenda: ✅ o valor afirmado bate com o desfecho que a `spec.md` define · ⚠️ spec-precision gap ou cláusula sem asserção · ❌ sem evidência.

### P1-1 — O card do link e o nível de acesso (GAL-01, GAL-02, GAL-03)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 card na ordem de T-05: sombra roxa, label amarela, URL sublinhada, "COPIAR 🔗", "QUEM ABRIR O LINK PODE…", segmented de 3 | os seis blocos, nesta ordem vertical | `card_do_link_test.dart:95-113` — os cinco `find.text` + `expect(topos, orderedEquals(List.of(topos)..sort()))` (roda nos dois viewports); fundo/sombra `:143-145` — `superficie.fundo == BoraColors.ink`, `.acento == BoraAccent.purple`; URL sublinhada `:182-190`; segmented `:124` — `expect(controle.opcoes, ['SÓ VER','EDITAR LISTA','CO-ANFITRIÃO'])` + `hasLength(3)` | ✅ |
| AC2 fixture RN-30 ⇒ URL `bora.app/c/rafa18` | o literal | `card_do_link_test.dart:133` — `expect(find.text('bora.app/c/rafa18'), findsOneWidget)`; camada: `galera_textos_test.dart:49` — `expect(GaleraTextos.urlDoConvite('rafa18'), 'bora.app/c/rafa18')` | ✅ |
| AC3 SÓ VER ⇒ "convidados só veem a festa e confirmam presença" | o literal de RN-23 | `galera_textos_test.dart:81-85` — a constante comparada com o literal escrito no teste; na tela: `card_do_link_test.dart:203` — `find.text(GaleraTextos.notaDoNivel(nivel)) findsOneWidget` + `:207` as outras duas `findsNothing` | ✅ |
| AC4 EDITAR LISTA ⇒ "convidados marcam o que levam e ajustam a lista" | idem | `galera_textos_test.dart:88-92` + `card_do_link_test.dart:203` (laço pelos três níveis) | ✅ |
| AC5 CO-ANFITRIÃO ⇒ "acesso total: editam tudo e cobram a galera" | idem | `galera_textos_test.dart:95-99` + `card_do_link_test.dart:203` | ✅ |
| AC6 "COPIAR 🔗" ⇒ URL completa na área de transferência **e** toast "LINK COPIADO 🔗" de 2200 ms | a URL exata + a copy de RN-29 + a duração | `galera_page_test.dart:217` — `expect(palco.area.copiados, [_urlDaFixture])`; `:227-228` — `find.byKey(BoraToastContent.toastKey) findsOneWidget` + `find.text(GaleraTextos.linkCopiado.toUpperCase()) findsOneWidget`; duração `:238-243` — o toast some depois do `pump` da duração de `BoraToast`; RN-29 literal: `galera_textos_test.dart:344` — `expect(GaleraTextos.linkCopiado, BoraToastTexts.linkCopiado)` | ✅ |
| AC7 "+ CONVIDAR MAIS GENTE 🔗" ⇒ **exatamente o mesmo efeito** | mesma URL, mesmo toast | `galera_page_test.dart:253` — a mesma `[_urlDaFixture]` pelo CTA; `:263-264` — o mesmo toast; `galera_compacta_test.dart:348` — `expect(cenario.area.copiados, [_urlDaFixture, _urlDaFixture])` (os dois botões, mesma URL); `galera_bloc_copia_test.dart:99` — existe **um** evento de cópia só | ✅ |
| AC8 trocar o nível persiste no repositório, a nota troca, **sem** toast | gravação + nota nova + zero toast | Persistência: `galera_repositorio_papel_e_nivel_test.dart:156` — `expect((await lerConvite()).nivel, NivelDoLink.coAnfitriao)`; round-trip real: `festa_repository_em_memoria_round_trip_test.dart:119` — `expect(lida!.convite.nivel, NivelDoLink.editarLista)`; nota nova: `card_do_link_test.dart:203/207`; sem toast: `card_do_link_test.dart:270-271` — `find.byKey(BoraToastContent.toastKey) findsNothing` | ✅ |

### P1-2 — O papel de quem já entrou não muda (GAL-04)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 nível de X para Y ⇒ `papel` de **toda** pessoa inalterado | a lista de pessoas idêntica | `galera_repositorio_papel_e_nivel_test.dart:159-166` — `for (i…) expect(pessoas[i], pessoasRn30Tipadas[i])` — item a item, e a **pessoa inteira**, não só o papel | ✅ |
| AC2 as **tags exibidas** na seção PESSOAS continuam idênticas, item a item | as cinco tags | Nenhum teste troca o nível **na tela** e reafirma as tags. A garantia é composta de dois elos separados: `papel` inalterado (`galera_repositorio_papel_e_nivel_test.dart:159`) + tag = f(papel) (`linha_de_pessoa_test.dart:179-207`, os quatro papéis contra o token). Nenhum teste atravessa segmented → porta → stream → tag. | ⚠️ cláusula sem asserção direta (cadeia, não ponta-a-ponta) |
| AC3 trocar o nível ⇒ **nenhuma** copy nova; nenhum aviso sobre quem já entrou | ausência de texto novo | Parcial: `card_do_link_test.dart:207` (as outras duas notas `findsNothing`) e `:270-271` (nenhum toast). Não existe asserção sobre "nenhum aviso sobre convidados já dentro" — é negativa aberta, não enumerável. | ⚠️ cláusula sem asserção |
| AC4 tela **sem pessoa nomeada** + nível alterado ⇒ mesmo comportamento | só o nível muda | Nenhum teste troca o nível numa festa vazia. `galera_bloc_escritas_test.dart:120` chama-se "sem pessoa nenhuma" mas `carregado()` usa a galera de teste **com** pessoas — "sem pessoa" ali quer dizer *o evento não carrega pessoa*, não *a festa está vazia*. | ❌ **GAP** |

### P1-3 — Ver a galera (GAL-06, GAL-07, GAL-08, GAL-09)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 header "A GALERA" + sub derivado | título + `{n} pessoas · {n} confirmadas` | `galera_compacta_test.dart:151-152` (nos dois viewports); derivação: `:156-164` — o sub é `GaleraTextos.subtitulo(...)`, não literal; `galera_textos_test.dart:143-163` — singular/plural independentes nas duas metades | ✅ |
| AC2 fixture RN-30 ⇒ "5 pessoas · 4 confirmadas" | o literal de T-05 | `galera_compacta_test.dart:152` — `expect(find.text('5 pessoas · 4 confirmadas'), findsOneWidget)`; `galera_page_test.dart:137` idem pela página; camada: `galera_textos_test.dart:134` | ✅ |
| AC3 uma linha por pessoa nomeada, ordem do repositório, avatar/nome/tag/caret | a ordem da fixture | `galera_compacta_test.dart:203` — `expect(_nomesNaTela(tester), ['Rafa','Ana','Léo','Bia','Duda'])`; peças: `linha_de_pessoa_test.dart:101-104` — `BoraAvatar`, `find.text('Léo')`, `BoraStatusTag`, `caretFechado` | ✅ |
| AC4 badge "VOCÊ" só no `voce` | presente/ausente | `linha_de_pessoa_test.dart:119` — `findsOneWidget` no Rafa; `:125` — `findsNothing` na Ana (o par que discrimina) | ✅ |
| AC5 sublinha `{dieta} · bebe 🍺` / `… · não bebe 🚫`, dieta pelo rótulo de RN-21 | os literais | `galera_textos_test.dart:214-232` — Rafa `'🍖 Come de tudo · bebe 🍺'`, Léo `'🥗 Veggie · bebe 🍺'`, Bia `'🚫 Sem porco · não bebe 🚫'`, escritos por extenso; na tela: `linha_de_pessoa_test.dart:143,149` | ✅ |
| AC6 termo não declarado omitido; os dois ausentes ⇒ sublinha não renderiza | Duda sem sublinha | `galera_textos_test.dart:235,242` (cada omissão isolada), `:249` — `expect(GaleraTextos.sublinhaDe(_daFixture('Duda')), isNull)`; na tela: `linha_de_pessoa_test.dart:157-165` | ✅ |
| AC7 cores de §5: ANFITRIÃO amarelo, CO-ANFITRIÃO roxo/branco, CONVIDADO branco, SÓ VÊ `wa-bubble`/`text-2` | os quatro pares contra o token | `linha_de_pessoa_test.dart:182-206` — `status.fundo == BoraColors.yellow` / `.purple` + `.texto == .white` / `.white` / `.waBubble` + `.texto == .text2` | ✅ |
| AC8 `confirmados` da Home == contagem de confirmados aqui — 4 com RN-30 | 4 nos dois lados | `galera_repositorio_papel_e_nivel_test.dart:251-253` — `expect(resumo.confirmados, 4)` **e** `expect(galera.confirmados, resumo.confirmados)`, reafirmado depois de cada uma das quatro escritas (`:256,261,266,271`) | ✅ |
| AC9 nenhuma contagem de pendentes, nenhuma representação do sem-nome, nenhum contador escrito | ausência | `galera_compacta_test.dart:215-218` — `findsNWidgets(5)` + `textContaining('pendente'/'Pendente'/'PENDENTE') findsNothing`; contador intocado: `fonte_unica_test.dart:107-108` — `resumo.confirmados == 4`, `resumo.pendentes == 2` depois da escrita | ✅ |

### P1-4 — Preferências que realimentam a lista (GAL-10..GAL-15)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 tocar expande; outro fecha o anterior — 1 por vez | um campo, não conjunto | `galera_compacta_test.dart:230-241` (abre Ana; abrir Léo deixa `_painelDe('Ana') findsNothing`), `:251` (tocar a aberta fecha); bloc: `galera_bloc_painel_test.dart:66,75,87` | ✅ |
| AC2 painel do não-anfitrião: NÍVEL DE ACESSO / RESTRIÇÃO ALIMENTAR / BEBIDA, nesta ordem | a ordem vertical | `painel_da_pessoa_test.dart:102-112` — as três seções + `expect(topos, orderedEquals(List.of(topos)..sort()))`, nos dois viewports | ✅ |
| AC3 escolher restrição ⇒ `dieta` passa ao valor e a sublinha reflete na hora | `tudo`/`veggie`/`semPorco` + sublinha nova | Escrita: `galera_repositorio_sobre_festas_test.dart:138` — `expect((await lerComposicao()).pessoas[3].dieta, Dieta.tudo)`; gesto: `painel_da_pessoa_test.dart:257` — `expect(gestos.dietas, [(_chave, Dieta.veggie)])`; ponta-a-ponta com sublinha: `galera_expandida_test.dart:269,299` — `'🚫 Sem porco · não bebe 🚫'` vira `'🥗 Veggie · não bebe 🚫'` | ✅ |
| AC4 toggle de bebida alterna `bebe` e a sublinha reflete | `false`/`true` + sublinha | `galera_repositorio_sobre_festas_test.dart:171` — `pessoas[2].bebe isFalse`; `painel_da_pessoa_test.dart:236` — `expect(gestos.bebidas, [(_chave, false)])`; página: `galera_page_test.dart:401-403` | ✅ |
| AC5 faixa = "💡 " + **exatamente** `resumoDasPreferencias` | a string da camada, sem recomposição | `faixa_de_preferencias_test.dart:92` — `find.text('💡 ${_resumoDe(daFixture)}')`, onde `_resumoDe` chama `resumoDasPreferencias(efeitosDasPreferencias(...))`; `galera_textos_test.dart:189` — `expect(GaleraTextos.faixa('qualquer coisa'), '💡 qualquer coisa')`; guard: `faixa_de_preferencias_test.dart:197-200` — o arquivo não contém a frase nem os termos | ✅ |
| AC6 fixture RN-30 ⇒ "💡 A lista já se ajusta às preferências: 1 veggie 🥗 · 1 sem porco 🚫 · 3 bebem 🍺" | o literal inteiro | `faixa_de_preferencias_test.dart:78-83` — o literal por extenso, nos dois viewports; `galera_compacta_test.dart:191` e `galera_expandida_test.dart:313` idem nas duas telas | ✅ |
| AC7 nenhum termo > 0 ⇒ faixa **não** renderiza | ausência | `faixa_de_preferencias_test.dart:142-144` — `_resumoDe(composicao) isEmpty` + `_superficie() findsNothing` + `textContaining('💡') findsNothing`; o par que discrimina `:154-161`; tela: `galera_compacta_test.dart:288` | ✅ |
| AC8 veggie ⇒ "Legumes p/ grelha (kit veggie)" na lista; sem veggie ⇒ ausente | presença/ausência, pelo nome literal | `galera_repositorio_sobre_festas_test.dart:261-267` — `isFalse` → escreve veggie → `isTrue` → desfaz → `isFalse`; nome literal `:270-277`; pela fonte única: `fonte_unica_test.dart:123-127` | ✅ |
| AC9 "sem porco" ⇒ suína sai mesmo selecionada; sem ninguém ⇒ permanece | ida e volta | `galera_repositorio_sobre_festas_test.dart:283-289`; `fonte_unica_test.dart:115-119` | ✅ |
| AC10 cerveja dimensionada por `adultosQueBebem`, não por `adultos` | a quantidade cai ao desmarcar alguém | `galera_repositorio_sobre_festas_test.dart:297` — `expect(await _cerveja(lerComposicao), lessThan(antes))` (com `adultos` de RN-05 a quantidade não se moveria) + `:311` — bate com um registro montado com o mesmo dado | ✅ |
| AC11 nenhuma fórmula de RN-21/RN-03/RN-05 em `lib/features/galera/` | varredura sobre o diretório | `galera_guards_test.dart:274` — `expect(violacoesEm(Directory(_raiz)), isEmpty)` com as **quatro** regras de §13; `:283` a varredura não roda vazia; `:312` não há allowlist; sete auto-testes provam que morde (`:332,347,363,378,416,427,462,496`) | ✅ |
| AC12 override de RN-12 sobrevive e continua prevalecendo | `overrides` idênticos após a escrita | `galera_repositorio_sobre_festas_test.dart:233-234` — `expect(composicao.overrides, _overrides)` + `noCarrinho`; `:242-244` contagem/duração/itens; `:251-252` festa e convite | ✅ |

### P1-5 — Nível de acesso por pessoa (GAL-16, GAL-17, GAL-18)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 três botões — CONVIDADO, CO-ANFITRIÃO, SÓ VÊ — ativo preto | exatamente três, nessa ordem | `painel_da_pessoa_test.dart:139-140` — `expect(controle.opcoes, ['CONVIDADO','CO-ANFITRIÃO','SÓ VÊ'])` + `hasLength(3)`; ativo preto: `:170` (`sobreCardEscuro isFalse`), `:185-186` (`BoxDecoration.color == BoraColors.ink`, texto `cream`) | ✅ |
| AC2 escolher ⇒ `papel` passa ao valor e a tag troca de cor | papel novo + cor do papel | Papel: `galera_repositorio_papel_e_nivel_test.dart:56` — `expect(duda.papel, PapelNaFesta.coAnfitriao)`; gesto: `painel_da_pessoa_test.dart:279`; tag = f(papel): `linha_de_pessoa_test.dart:186-191` | ✅ |
| AC3 papel de uma muda ⇒ o de **nenhuma outra** muda | os outros quatro idênticos | `galera_repositorio_papel_e_nivel_test.dart:64-67` — os quatro papéis escritos à mão, um `expect` cada; `:70-77` nada além do papel muda na endereçada | ✅ |
| AC4 painel do **anfitrião**: só a nota 👑; os três controles **ausentes da árvore** | `findsNothing`, não desabilitado | `painel_da_pessoa_test.dart:298` (a nota literal presente), `:308-312` — as três seções `findsNothing` + `BoraSegmentedControl findsNothing` + `BotaoDeDieta findsNothing`; o outro lado do par `:319` | ✅ |
| AC5 nenhum caminho atribui ANFITRIÃO; a festa continua com exatamente 1 | 1 anfitrião | Recusa de **atribuir**: `galera_repositorio_papel_e_nivel_test.dart:108-109` (`salvas isEmpty`, papel intacto), `:112-125` (recusa registrada, mensagem "não é atribuível"), `:129` (`_anfitrioes(...) == 1`), `:132-148` (nem numa festa sem anfitrião). Recusa de **remover**: `:85-86`, `:89-94` (mensagem "o alvo é o anfitrião"), `:97-100`. A opção nem é oferecida: `galera_textos_test.dart:317-331`; `painel_da_pessoa_test.dart:143-151` | ✅ |
| AC6 papel novo ⇒ capacidades da linha de RN-22 daquele papel, sem etapa intermediária | a tabela | `permissoes_test.dart:35-235` — as 32 células; consumo pela tela: `galera_compacta_test.dart:422-447` — `CapacidadesDaGalera` sai de RN-22, papel a papel | ✅ |

### P1-6 — A tabela de permissões como domínio consultável (GAL-19, GAL-20, GAL-21)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 ANFITRIÃO ⇒ **as oito** | 8 `isTrue` | `permissoes_test.dart:35,41,47,53,59,65,71,77` — uma por célula, valor escrito à mão; + `:241` `hasLength(8)` e `== Capacidade.values.toSet()` | ✅ |
| AC2 CO-ANFITRIÃO ⇒ 6 sim, 2 não (papéis e nível) | 6 `isTrue` + 2 `isFalse` | `permissoes_test.dart:86,92,98,104,110,116` (`isTrue`) e `:122,128` (`isFalse`); `:249` `hasLength(6)`; `:262-268` a diferença é exatamente `{gerenciarPapeis, configurarNivelDoLink}` | ✅ |
| AC3 CONVIDADO ⇒ 4 sim, 4 não | 4+4 | `permissoes_test.dart:137,143,149,155` / `:161,167,173,179`; `:253` `hasLength(4)` | ✅ |
| AC4 SÓ VÊ ⇒ 2 sim, 6 não | 2+6 | `permissoes_test.dart:188,194` / `:200,206,212,218,224,230`; `:257` `hasLength(2)` | ✅ |
| AC5 SÓ VER→SÓ VÊ · EDITAR LISTA→CONVIDADO · CO-ANFITRIÃO→CO-ANFITRIÃO | os três pares | `permissoes_test.dart:285,289,293` — um `expect` por par; `:296-304` nenhum nível entrega anfitrião | ✅ |
| AC6 nível ausente/desconhecido ⇒ SÓ VER; festa nova ⇒ EDITAR LISTA | menor privilégio vs. default de produto | `nivel_do_link_test.dart:64` (`resolver(null) == soVer`), `:72` (chave desconhecida), `:89` (`padraoDeFestaNova == editarLista`), `:93` (os dois diferem); e o default de fato usado: `convite_da_festa_test.dart:15` — `ConviteDaFesta.vazio.nivel == padraoDeFestaNova`; `festa_em_edicao_test.dart:347` — `emEdicao.convite == ConviteDaFesta.vazio` | ✅ |
| AC7 a tabela vive em `domain/` como valor puro, sem import de Flutter | zero import proibido | `permissoes_test.dart:337-345` — `expect(importsProibidosEm(conteudo), isEmpty)` sobre o arquivo real; guard de diretório: `galera_guards_test.dart:495-544` (regra 4), com infrator sintético provando que morde e o caminho `\` do Windows coberto | ✅ |

### P2-1 — A galera no web (GAL-22, GAL-23)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 duas colunas: card do link fixo à esquerda com **370px**, pessoas à direita | 370 | `galera_expandida_test.dart:128-132` — a largura medida + `expect(GaleraExpandida.larguraDaColuna, 370)`; card dentro `:139`; lista fora `:153` | ✅ |
| AC2 CTA na coluna esquerda, abaixo do card; **sem** rodapé fixo | posição + ausência | `galera_expandida_test.dart:168-179` (CTA dentro da coluna, abaixo do card), `:184-186` — `RodapeDaGalera findsNothing` + `BoraFooterBar findsNothing` + `ctaKey findsNothing`; o par a 390: `:193-196` | ✅ |
| AC3 abaixo de ~900px colapsa para T-05 com rodapé, **preservando** accordion e nível | estado preservado | `galera_expandida_test.dart:216-221` (accordion sobrevive 1180→890), `:224-251` (nível selecionado sobrevive), `:253-260` (900 expandido / 890 compacto); pela página: `galera_page_test.dart:150-198` + `:206` (a travessia não reassina a porta) | ✅ |
| AC4 nunca scroll horizontal | zero `Scrollable` horizontal | `galera_expandida_test.dart:334-335` — `expect(horizontais, isEmpty)` + `takeException() isNull`, em quatro larguras; compacto: `galera_compacta_test.dart:463` | ✅ |
| AC5 mudança numa plataforma vale na outra — mesma fonte, mesmo bloc | o mesmo estado | `galera_expandida_test.dart:269-300` — troca a dieta a 390, atravessa para 1180 **sem** `pumpWidget`, e a sublinha nova aparece; `galera_page_test.dart:199-206` — a porta é observada uma vez só | ✅ |
| AC6 todo clicável tem hover no expandido | fundo muda sob o ponteiro | `galera_expandida_test.dart:345-363` — `fundoEmRepouso` → `fundoNoHover` → `fundoEmRepouso`; cursor `:375`; CTA e COPIAR `:382-395`. **Ressalva:** o `BoraSegmentedControl` (nível do link, papel, bebida) não tem hover — dívida 4 do `STATE.md`, território da spec 01, fora da fronteira de arquivos desta spec. | ⚠️ cobertura parcial, declarada |

### P2-2 — Estado vazio e resiliência (GAL-05, GAL-24, GAL-25, GAL-26, GAL-28)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 só o anfitrião ⇒ 1 linha, sub "1 pessoa · 1 confirmada", faixa com o que sobrar | os literais no singular | `galera_compacta_test.dart:264-270` — `LinhaDePessoa findsOneWidget`, `find.text('1 pessoa · 1 confirmada')`, e `:267` a faixa `'💡 A lista já se ajusta às preferências: 1 bebem 🍺'` | ✅ |
| AC2 sem pessoa nomeada ⇒ "nenhuma pessoa ainda", seção sem linhas e sem copy inventada, faixa ausente, card + CTA presentes e funcionais | os quatro | `galera_compacta_test.dart:278-281` (sub, seção, zero linhas, zero painéis), `:288-291` (faixa ausente, `CardDoLink` presente, URL presente, `ctaKey` presente), `:294-300` (o CTA copia de verdade: `expect(cenario.area.copiados, [_urlDaFixture])`) | ✅ |
| AC3 repositório emite erro ⇒ estado de falha visível + log | mensagem na tela + `logError` | `galera_page_test.dart:323-325` — `find.text(GaleraTextos.falha) findsOneWidget` + `CardDoLink findsOneWidget` + `logger.erros hasLength(1)`; bloc: `galera_bloc_test.dart:123,134`; o par que discrimina: `galera_compacta_test.dart:322-323` | ✅ (a copy é SPEC_PRECISION_GAP declarado) |
| AC4 área de transferência falha ⇒ **sem** toast, falha registrada, URL continua na tela | ausência + log + URL | `galera_page_test.dart:292-294` (`toastKey findsNothing`, texto `findsNothing`, `copiasConcluidas == 0`), `:303-304` (`erros hasLength(1)`, `name == 'galera'`), `:312` (`find.text(_urlDaFixture) findsOneWidget`); bloc: `galera_bloc_copia_test.dart:153,163-165,176` | ✅ |
| AC5 confirmação nova pelo stream ⇒ accordion aberto continua, edição preservada, lista incorpora sem remontar | a mesma pessoa aberta | `galera_bloc_painel_test.dart:112-138` — alguém entrando **antes** da aberta mantém a mesma pessoa aberta (é o caso que um índice quebraria), `:140` a lista nova entra sem derrubar, `:166` outra pessoa sumindo não fecha, `:185` a **aberta** sumindo fecha (guarda distinta, sensor próprio), `:237` homônimas | ✅ |
| AC6 opção já ativa ⇒ **nada** muda: sem escrita, sem toast, sem reordenação | zero gravações | Por **contagem de gravações**: `galera_repositorio_sobre_festas_test.dart:326,333` (`fake.salvas isEmpty`) + `:341` controle positivo `hasLength(2)`; `galera_repositorio_papel_e_nivel_test.dart:185,191` + `:199` `hasLength(2)`; bloc: `galera_bloc_escritas_test.dart:167,176,185,194` (`repositorio.escritas`); widget: `card_do_link_test.dart:259` (`gestos.niveis isEmpty`), `painel_da_pessoa_test.dart:246,268,290`; toast único: `galera_page_test.dart:279` | ✅ |

### P3-1 — A Galera de quem não é o anfitrião (GAL-27)

| Critério | Desfecho da spec | `file:line` + asserção | Resultado |
|---|---|---|---|
| AC1 sem `configurarNivelDoLink` ⇒ segmented ausente; URL, nota e "COPIAR 🔗" ficam | ausência + três presenças | `card_do_link_test.dart:290-296` — `_segmented() findsNothing` + URL + `copiar` + `notaDoNivel(convite.nivel)` presentes; pela página: `galera_page_test.dart:346-356` | ✅ |
| AC2 sem `gerenciarPapeis` ⇒ "NÍVEL DE ACESSO" ausente de **todos** os painéis; restrição e bebida ficam | ausência + duas presenças | `painel_da_pessoa_test.dart:328-331`; na tela inteira: `galera_compacta_test.dart:400-402`; pela página: `galera_page_test.dart:356-358` | ✅ |
| AC3 usuário anfitrião ⇒ os dois controles presentes — o par que discrimina | presença | `galera_page_test.dart:334-339` (com Rafa) contra `:346-358` (com Ana), **o mesmo repositório, trocando só quem é `voce`**; `card_do_link_test.dart:303-308`; `painel_da_pessoa_test.dart:338-340` | ✅ |

**Status**: **54/57 ✅** · **1 ❌ GAP** (P1-2 AC4) · **3 ⚠️** (P1-2 AC2 e AC3 sem asserção direta; P2-1 AC6 parcial e declarado).

---

## Edge Cases da `spec.md`

| Edge case | Evidência | Resultado |
|---|---|---|
| Mais pessoas do que cabem ⇒ rola no documento, sem scroll horizontal, sem altura fixa | `galera_compacta_test.dart:463-476` — zero `Scrollable` horizontal e a última linha alcançável por rolagem a 390px | ✅ |
| Nome longo quebra ou trunca sem overflow | `linha_de_pessoa_test.dart:258-268` — `expect(tester.takeException(), isNull)` | ✅ |
| Duas homônimas ⇒ duas linhas distintas | `linha_de_pessoa_test.dart:271-281` — `findsNWidgets(2)` + sublinhas diferentes; bloc: `galera_bloc_painel_test.dart:208,221,237`; escrita: `galera_repositorio_sobre_festas_test.dart:151,184` (só a endereçada muda) | ✅ |
| `recusou` aparece na lista e **não** conta no `{n} confirmadas` | `galera_da_festa_test.dart:48-58` — com uma confirmada, uma que recusou e uma pendente, conta só a confirmada; `:60-70` — "quem recusou aparece em `pessoas` e não entra em `confirmados`", o par que discrimina | ✅ |
| Código com caractere que exige escape ⇒ exibida == copiada | `galera_textos_test.dart:64-77` — laço por códigos com caractere especial, `expect(GaleraTextos.urlDoConvite(codigo), 'bora.app/c/$codigo')`, e a mesma função alimenta card e cópia | ✅ |
| Toast já na tela + outra cópia ⇒ o segundo substitui, 1 por vez | `galera_page_test.dart:278-280` — duas cópias, `copiados` com dois itens, **um** `toastKey` na árvore, `copiasConcluidas == 2` | ✅ |
| Alvo anfitrião por outro caminho ⇒ o domínio recusa, independentemente de quem pede | `galera_repositorio_papel_e_nivel_test.dart:82-100` — a recusa mora no adaptador, não na UI, e o teste chama a porta direto | ✅ |

---

## Discrimination Sensor

**Profundidade**: **P0-full** (RN-22 é herdada por três specs; o nível do link é o contrato de entrada da spec 09). **30 mutações**, todas em estado descartável.

**Protocolo, sem exceção**: `git status --porcelain` conferido antes de cada mutação → edição pela ferramenta Edit → `flutter test` (**suíte inteira**, nunca só o arquivo alvo, para que "sobreviveu" signifique *ninguém no repositório inteiro* pegou) → **restauração imediata pela mesma ferramenta Edit** → `git status` + `git diff --stat` conferidos. **`git checkout --` não foi usado em momento algum.** Os dois infratores sintéticos (M15, M16) foram arquivos novos, criados e removidos por `rm`.

| # | Arquivo:símbolo | Mutação | Morta? | Quem matou |
|---|---|---|---|---|
| M1 | `permissoes.dart` `_tabelaRn22` | CO-ANFITRIÃO ganha `gerenciarPapeis` | ✅ Morta | `permissoes_test.dart` (2: a célula AC2 e a diferença A-19) + `galera_page_test.dart` + `galera_compacta_test.dart` |
| M2 | `permissoes.dart` `_tabelaRn22` | SÓ VÊ perde `confirmarPresenca` | ✅ Morta | `permissoes_test.dart` (3: a célula AC4, `hasLength(2)` e a imutabilidade) |
| M3 | `galera_repositorio_sobre_festas.dart:99` | removida a guarda **de atribuir** anfitrião (`if (papel == anfitriao)`) | ✅ Morta | `galera_repositorio_papel_e_nivel_test.dart` — os **4** testes do grupo "não é atribuível a ninguém" |
| M4 | `galera_repositorio_sobre_festas.dart:105` | removida a guarda **de remover** o anfitrião (`if (pessoa.papel == anfitriao)`) | ✅ Morta | `galera_repositorio_papel_e_nivel_test.dart` — os **3** testes do grupo "o anfitrião não perde o papel" |
| M5 | `galera_repositorio_sobre_festas.dart:69` | `alterarDieta` grava mesmo com a dieta já vigente | ✅ Morta | `galera_repositorio_sobre_festas_test.dart` — GAL-28, por **contagem de gravações** |
| M6 | `galera_repositorio_sobre_festas.dart:124` | removida `if (festa.convite.nivel == nivel) return;` | ✅ Morta | `galera_repositorio_papel_e_nivel_test.dart` — GAL-28, por contagem |
| M7 | `galera_repositorio_sobre_festas.dart:128` | trocar o nível **rebaixa todo mundo a SÓ VÊ** (a retroação que AD-026 proíbe) | ✅ Morta | `galera_repositorio_papel_e_nivel_test.dart` — GAL-04, "toda a lista de pessoas continua idêntica — item a item" |
| M8 | `galera_bloc.dart:85` | o `null` do stream deixa de virar `falhou` | ✅ Morta | `galera_bloc_test.dart` (2) — GAL-25, festa inexistente |
| M9 | `galera_bloc.dart:86` | o `null` passa a **registrar** no logger | ✅ Morta | `galera_bloc_test.dart` — "o null do stream não registra erro nenhum no logger" |
| M10 | `galera_bloc.dart:230` | falha da área de transferência deixa de abortar: o contador incrementa | ✅ Morta | `galera_bloc_copia_test.dart` (3) + `galera_page_test.dart` (3) — GAL-05 |
| M11 | `painel_da_pessoa.dart:98` | o painel do anfitrião passa a exibir também os três controles | ✅ Morta | `painel_da_pessoa_test.dart` — GAL-16, "as três seções estão ausentes da árvore, não desabilitadas" |
| M12 | `painel_da_pessoa.dart:109` | `if (podeGerenciarPapeis)` → `if (true)` | ✅ Morta | `painel_da_pessoa_test.dart` + `galera_compacta_test.dart` + `galera_page_test.dart` — GAL-27 AC2/AC3 |
| M13 | `festa_repository_em_memoria.dart:139` | `salvarFesta` volta a **não** gravar `convite` (o defeito de `3f521c2`) | ✅ Morta | `festa_repository_em_memoria_round_trip_test.dart` (2) |
| M14 | `festa_repository_em_memoria.dart:78` | `observarFesta` volta a **não** devolver `convite` | ✅ Morta | `festa_repository_em_memoria_round_trip_test.dart` (3) + `galera_route_test.dart` (1) |
| M15 | **arquivo infrator real** plantado em `lib/features/galera/presentation/widgets/` | constante `400` de RN-03 + `Color(0xFFFF4D2E)` + a frase de RN-21 recomposta | ✅ Morta | `galera_guards_test.dart` (2) — e o relatório nomeou **as três regras**: `reescreve quantidade de RN-03/RN-05 (400)`, `reescreve a frase de RN-21`, `literal de cor, fonte ou sombra (Color(0x)` e `(0xFF)` |
| M16 | **arquivo infrator real** plantado em `lib/features/galera/domain/` | `import 'package:flutter/material.dart'` | ✅ Morta | `galera_guards_test.dart` — `importa Flutter no domínio (package:flutter/material.dart)`, nomeando o arquivo |
| M17 | `permissoes.dart:107` | `papelDoUsuario` sem ninguém marcado devolve `soVe` | ✅ Morta | `permissoes_test.dart` (2) — premissa P-1 |
| M18 | `nivel_do_link.dart:46` | `resolver` deixa de aplicar menor privilégio (devolve `editarLista`) | ✅ Morta | `nivel_do_link_test.dart` (3) — GAL-21 AC6 |
| **M19** | `galera_repositorio_sobre_festas.dart:124` | `if (festa.composicao.pessoas.isEmpty) return;` — **festa sem pessoa nomeada deixa de gravar o nível** | ❌ **Sobreviveu** | ninguém — **2439 verdes** |
| M20 | `galera_repositorio_sobre_festas.dart:82` | `alterarBebida` grava mesmo com o valor já vigente | ✅ Morta | `galera_repositorio_sobre_festas_test.dart` — GAL-28, por contagem |
| M21 | `galera_da_festa.dart:52` | `confirmados` passa a contar tudo que não recusou | ✅ Morta | **13** testes — `galera_repositorio_papel_e_nivel_test.dart` (GAL-09, as quatro escritas), `galera_da_festa_test.dart`, `galera_compacta_test.dart`, `galera_route_test.dart` |
| M22 | `galera_bloc.dart:98` | `aberta: continua ? aberta : null` → `aberta` (o painel **nunca** fecha) | ✅ Morta | `galera_bloc_painel_test.dart` (2) — a pessoa aberta sumindo, e o caso das homônimas |
| M23 | `galera_bloc.dart:98` | → `null` (toda emissão **fecha** o painel) | ✅ Morta | `galera_bloc_painel_test.dart` (4) — GAL-26 |
| M24 | `galera_compacta.dart:186` | `CapacidadesDaGalera.de` devolve `true, true` sem consultar RN-22 | ✅ Morta | `galera_page_test.dart` (GAL-27 AC3, com Ana) + `galera_compacta_test.dart` |
| **M25** | `galera_expandida.dart:169` | `podeGerenciarPapeis: capacidades.podeGerenciarPapeis` → `true` | ❌ **Sobreviveu** | ninguém — 2439 verdes |
| **M26** | `galera_expandida.dart:116` | `podeConfigurarNivel: capacidades.podeConfigurarNivel` → `true` | ❌ **Sobreviveu** | ninguém — 2439 verdes |
| **M27** | `galera_expandida.dart:171` | `aoEscolherDieta` → `(_, __) {}` (a dieta escolhida no web não chega ao bloc) | ❌ **Sobreviveu** | ninguém — 2439 verdes |
| **M28** | `galera_expandida.dart:115,170,172` | `onEscolherNivel`, `aoEscolherPapel` e `aoAlternarBebida` → no-op | ❌ **Sobreviveu** | ninguém — 2439 verdes |
| M29 | `galera_textos.dart:114` | `faixa` devolve o resumo sem o âncora `'💡 '` | ✅ Morta | **12** testes — `galera_textos_test.dart`, `faixa_de_preferencias_test.dart`, `galera_compacta_test.dart`, `galera_expandida_test.dart` |
| M30 | `chave_de_pessoa.dart:46` | `indiceEm` ignora a ocorrência (a primeira homônima sempre vence) | ✅ Morta | **6** testes — `chave_de_pessoa_test.dart`, `galera_repositorio_sobre_festas_test.dart`, `galera_bloc_painel_test.dart` |

**Resultado**: **25/30 mortas · 5 sobreviventes** → ❌ **FAIL**.

### Leitura dos cinco sobreviventes

**M25, M26, M27, M28 são um defeito só, com quatro faces: `GaleraExpandida` não tem nenhum teste que exercite gesto no layout de 1180px.** Todo teste de `galera_expandida_test.dart` ou (a) monta e mede geometria, (b) faz o gesto **a 390px** e depois atravessa a fronteira, ou (c) empurra o estado novo pela porta (`palco.porta.emitir(...)`) em vez de tocar o controle. O único gesto de verdade a 1180 é `_tocar(tester, _linhaDe('Ana'))` (abrir o accordion, `:213`) e o `aoCopiar` do rail (`:199`) — e são exatamente os dois fios que **não** sobreviveram à mutação. Os outros seis fios que a `GaleraExpandida` liga entre a árvore e o bloc — `onEscolherNivel`, `aoEscolherPapel`, `aoEscolherDieta`, `aoAlternarBebida`, `podeConfigurarNivel`, `podeGerenciarPapeis` — podem ser cortados um a um, ou todos de uma vez, sem que nenhum dos 2439 testes note.

Duas consequências, e a segunda é a grave:

1. **Funcional (Major):** no web, trocar a dieta, a bebida, o papel ou o nível do link poderia não fazer nada, e a suíte continuaria verde. GAL-11, GAL-12, GAL-17 e GAL-04 são verificados só no compacto; P2-1 AC5 ("a mudança feita numa plataforma vale na outra") é afirmada **numa direção só** — 390 → 1180 —, e a direção que falta é justamente a que exercita o código novo da `GaleraExpandida`.
2. **De autorização (Blocker):** M25 e M26 são a **regra de RN-22 sendo contornada pelo layout**. Com eles plantados, um co-anfitrião abrindo a Galera no computador vê o segmented "QUEM ABRIR O LINK PODE…" e a seção "NÍVEL DE ACESSO" — as duas capacidades que a A-19 declara **exclusivas do anfitrião** — e pode usá-las. GAL-27 AC1 e AC2 escrevem "de **todos** os painéis"; o teste que os cobre (`galera_compacta_test.dart:388`, `painel_da_pessoa_test.dart:323`, `galera_page_test.dart:342`) só monta o compacto. É a mesma classe do botão invisível (**L-034**): a regra existe, é correta, é testada — e o fio que a liga à tela não é.

**M19 (Minor, mas é um AC):** `definirNivelDoLink` pode passar a recusar silenciosamente a gravação numa festa **sem pessoa nomeada nenhuma** e nada percebe. É a única mutação que ataca diretamente **P1-2 AC4** ("WHEN a tela não tem nenhuma pessoa nomeada e o nível é alterado THEN o comportamento SHALL ser o mesmo — só o nível muda"), que a §Spec-Anchored já marcara ❌ por falta de evidência. O sensor confirma: não é um AC coberto sem citação, é um AC **sem defesa**. Cenário real: festa recém-criada em `/roles/novo`, o anfitrião ajusta o nível **antes** de convidar alguém — o gesto mais natural do fluxo —, e a gravação some. Hoje o código está certo; nada impede que amanhã deixe de estar.

---
## Re-verificação — iteração 2

**Data**: 2026-09-03 · **Verifier**: sub-agente **novo**, que não implementou nada e não
aceitou como prova nenhuma afirmação do `STATE.md`, do corpo da commit `457de00` ou do
autoexame de `scratchpad/sensor.py`. Script de sensor **escrito do zero**
(`scratchpad/verifier_sensor.py`), não reaproveitado.

**Objeto da iteração**: a alegação de `457de00` — *"os cinco sobreviventes eram buraco de
cobertura, fechados com 10 testes novos e **nenhuma linha de produção mudada**"*.

### Superfície do diff, conferida por mim

- `git log --oneline main..HEAD | wc -l` → **37** commits (o relatório da iteração 1 dizia 30;
  eram 30 **naquele** HEAD).
- `git diff --stat main..HEAD` → **73 arquivos**, `+11569 / −355`.
- Fora de `**/galera/**`, o diff toca 9 arquivos de `lib/` e 16 de `test/` — auditados em
  §Code Quality (fronteira de arquivos).

### Gate, rodado por mim e lido por exit code

| Comando | Saída | Exit |
|---|---|---|
| `flutter test` | `00:28 +2449: All tests passed!` | **0** |
| `flutter analyze` | `No issues found! (ran in 3.1s)` | **0** |

Baseline `main` 1935 → **2449**, delta **+514**. Bate com o handoff — mas foi **medido**, não
lido dele.

**Test Integrity** — `git diff main..HEAD --numstat -- test/` fora de `features/galera/`:
16 arquivos, **1370 linhas somadas e 2 removidas**. As duas removidas são:

| Arquivo | Mudança | Veredito |
|---|---|---|
| `festa_em_edicao_repository_test.dart:119` | `hasLength(2)` → `hasLength(4)` | **Não é afrouxamento** — é a contagem de arquivos de `core/festas/dominio/`, que passou de 2 a 4 (`convite_da_festa.dart`, `nivel_do_link.dart`, AD-031). A asserção seguinte continua exigindo `exportados == arquivosDeDominio`, ou seja, o barrel continua obrigado a exportar **todos**. |
| `app_de_teste.dart:86` | `logger: RecordingAppLogger()` inline → variável `logger` reusada | Refactor mecânico; o logger é o mesmo objeto, agora também passado à porta da Galera. Aditivo. |

Nenhum `skip:` novo em `test/**`. Nenhum teste apagado. Nenhuma asserção enfraquecida.

---

### Sensor — as 7 mutações do autor, re-plantadas por mim

**Protocolo executado, sem exceção**, por mutação: `git status --porcelain` **vazio** conferido
antes → escrita direta no arquivo pelo meu script (leitura e escrita com `newline` preservado,
para não converter fim de linha) → **`flutter test` da suíte inteira** → restauração imediata
escrevendo de volta o conteúdo original → `git status --porcelain` conferido depois.
**`git checkout --` não foi usado em nenhum momento sobre a árvore de trabalho.**

> **Incidente registrado, e a correção.** A **primeira** tentativa (M25) abortou por dois bugs
> do meu próprio script: `subprocess` decodificando a saída do `flutter` em cp1252, e a escrita
> sem preservação de fim de linha convertendo os LF do arquivo em CRLF. O `flutter test` nem
> chegou a rodar. O restauro deixou o arquivo **byte-diferente** do original (7007 vs. 6830
> bytes) e `git status` acusou ` M lib/.../galera_expandida.dart` — embora `git diff` viesse
> vazio, por causa de `core.autocrlf=true`. Consertado na hora restaurando o arquivo a partir do
> **blob de HEAD** (`git cat-file -p HEAD:... > arquivo`, md5 conferido idêntico) e corrigindo o
> script. Registro isto porque a regra "nenhuma mutação pode ficar no disco" foi testada de
> verdade, e porque o modo de falha — restauro que parece certo e não é — é reutilizável.

| # | Arquivo:símbolo | Mutação | Morta? | **Quem matou** (medido, não relatado) |
|---|---|---|---|---|
| M25 | `galera_expandida.dart:169` | `podeGerenciarPapeis: capacidades.podeGerenciarPapeis` → `true` | ✅ Morta (2448 +1) | `galera_expandida_test.dart:455` — *"o co-anfitrião não vê 'NÍVEL DE ACESSO' no painel"*. `Expected: no matching candidates / Actual: Found 1 widget with text "NÍVEL DE ACESSO"` |
| M26 | `galera_expandida.dart:116` | `podeConfigurarNivel: capacidades.podeConfigurarNivel` → `true` | ✅ Morta (2448 +1) | `galera_expandida_test.dart:428` — *"o co-anfitrião não vê o segmented do nível no card"*. `Actual: Found 1 widget with type "BoraSegmentedControl" descending from CardDoLink` |
| M27 | `galera_expandida.dart:171` | `aoEscolherDieta` → no-op | ✅ Morta (2448 +1) | `galera_expandida_test.dart:343` — `Expected: [(festa-1, Ana#0, Dieta.veggie)] / Actual: []` |
| M28a | `galera_expandida.dart:115` | `onEscolherNivel` → no-op | ✅ Morta (2448 +1) | `galera_expandida_test.dart:397` — `Expected: [(festa-1, NivelDoLink.coAnfitriao)] / Actual: []` |
| M28b | `galera_expandida.dart:170` | `aoEscolherPapel` → no-op | ✅ Morta (2448 +1) | `galera_expandida_test.dart:379` — `Expected: [(festa-1, Ana#0, PapelNaFesta.soVe)] / Actual: []` |
| M28c | `galera_expandida.dart:172` | `aoAlternarBebida` → no-op | ✅ Morta (2448 +1) | `galera_expandida_test.dart:361` — `Expected: [(festa-1, Ana#0, false)] / Actual: []` |
| M19 | `galera_repositorio_sobre_festas.dart:124` | `if (festa.composicao.pessoas.isEmpty) return;` inserido | ✅ Morta (2448 +1) | `galera_repositorio_papel_e_nivel_test.dart:174` — *"festa sem nenhuma pessoa nomeada grava o nível do mesmo jeito"*. `Expected: an object with length of <1> / Actual: []` |

**7/7 mortas.** A alegação de `457de00` **procede**, e por asserção de **valor**, não de chamada:
os quatro gestos afirmam a tripla `(festaId, chave, valor)` gravada na porta, não que "houve
escrita".

**Observação que o autor não fez, e que importa:** cada uma das sete mutações mata **exatamente
um** teste (2448 passando, 1 falhando, sempre). Não há redundância nenhuma nesses sete fios — é
cobertura mínima suficiente. Apagar qualquer um dos 10 testes novos reabre exatamente um
sobrevivente. É um fato para quem for mexer nesse arquivo, não um defeito.

---

### A tautologia dos 10 testes novos — as quatro perguntas do contrato

**1. As duas guardas de RN-22 têm mesmo o par que discrimina?** **Sim, e o par é real.**
`galera_expandida_test.dart:428` (co-anfitriã, `findsNothing`) contra `:443` (anfitrião,
`findsOneWidget`) para o segmented; `:455` (co-anfitriã: "NÍVEL DE ACESSO" `findsNothing`, mas
"RESTRIÇÃO ALIMENTAR" e "BEBIDA" `findsOneWidget`) contra `:467` (anfitrião: as três presentes).
Não passariam com o controle sempre ausente — os testes `:443` e `:467` são exatamente essa
defesa, e M25/M26 provam que a metade `findsNothing` morde. O troca-quem-é-`voce` é feito por
`_galeraComVoce('Ana')` (`:48`), **a mesma fixture**, mudando só o campo `voce` — o par isola a
variável certa.

**2. Os quatro gestos falham com o fio cortado, *e* montam mesmo a `GaleraExpandida`?**
**Sim para os dois.** O corte foi testado (M27, M28a-c, cada um matando o gesto correspondente).
A montagem foi testada com uma **sonda própria (V1)**: forcei `GaleraPage` a escolher sempre
`GaleraCompacta` (`galera_page.dart:92`, `modo == LayoutMode.compact` → `true`) e rodei
`galera_expandida_test.dart`. **14 testes caem**, entre eles os quatro gestos (`:343`, `:361`,
`:379`, `:397`) — logo eles não são satisfazíveis pelo compacto.
Não há atalho por `porta.emitir(...)`: os quatro chamam `_tocar(...)` sobre um `Finder` escopado
ao painel (`find.descendant(of: _painelDe('Ana'), ...)`) ou ao `CardDoLink`, e afirmam o efeito
**na porta**. E o valor pedido é sempre **distinto** do vigente (a Ana da fixture é
`dieta: tudo`, `bebe: true`, co-anfitriã; os testes pedem `veggie`, `false`, `soVe`), o que
impede que GAL-28 ("já ativo não escreve") faça o teste passar por acidente.

**3. O teste da festa vazia afirma que *só* o nível mudou?** **Quase — e a folga virou o Fix 1.**
`galera_repositorio_papel_e_nivel_test.dart:174-190` afirma `fake.salvas hasLength(1)`,
`convite.nivel == coAnfitriao`, `convite.codigo == 'rafa18'`, `composicao.pessoas isEmpty` e
`logger.erros isEmpty`. Isso cobre "gravou" e "não mexeu em pessoas nem no código". **Não** cobre
o resto da composição — ver a sonda V2 abaixo, que sobrevive.

**4. Os testes novos passariam com o widget errado montado?** **Três sim, e é o único ponto
frouxo dos dez.** A sonda V1 mostra que, com a página renderizando sempre o compacto, três dos
quatro testes de guarda de RN-22 continuam **verdes**:

| Teste | Tem `expect(find.byType(GaleraExpandida), findsOneWidget)`? | Cai sob V1? |
|---|---|---|
| `:428` co-anfitriã não vê o segmented | ✅ sim, em `:432` | ✅ cai |
| `:443` anfitrião vê — o par | ❌ **não tem** | ❌ **passa** |
| `:455` co-anfitriã não vê "NÍVEL DE ACESSO" | ❌ **não tem** | ❌ **passa** |
| `:467` anfitrião vê as três seções | ❌ **não tem** | ❌ **passa** |
| `:343`, `:361`, `:379`, `:397` (os 4 gestos) | ✅ sim, em `:356`, `:374`, `:392`, `:413` | ✅ caem |

Hoje isso é inofensivo — `_abrir` monta a `1180x800` por default e M25/M26 morrem —, mas os três
testes **não estão ancorados ao layout que dizem verificar**: se a fronteira de AD-007 regredir,
eles passam a testar o compacto em silêncio, com o nome dizendo "no expandido". É o **Fix 3**
(Minor), uma linha por teste.

---

### As mutações **próprias** desta iteração

| # | Arquivo:símbolo | Mutação | Morta? | Leitura |
|---|---|---|---|---|
| V1 | `galera_page.dart:92` | `modo == LayoutMode.compact` → `true` (a página nunca escolhe o expandido) | ✅ Morta — **14** testes em `galera_expandida_test.dart` | Sonda de ancoragem, tabela acima. |
| **V2** | `galera_repositorio_sobre_festas.dart:127` | `definirNivelDoLink` grava também `composicao.copyWith(itensSelecionados: const {})` — trocar o nível do link **apaga a lista inteira da festa** | ❌ **SOBREVIVEU** — **2449 verdes** | **Fix 1.** Ver abaixo. |
| V3 | `linha_de_pessoa.dart:92` | o fundo ignora `_sobHover` (hover morto) | ✅ Morta | `galera_expandida_test.dart:500` — *"a linha de pessoa acende sob o ponteiro e apaga ao sair"*. P2-1 AC6 tem sensor de verdade na parte que a spec 07 controla. |
| V4 | `galera_expandida.dart:170` | `aoAlternarLinha` → no-op (o accordion do web não abre) | ✅ Morta | O 5º fio da `GaleraExpandida`, que a iteração 1 dava por coberto — confirmado. |
| V5 | `galera_expandida.dart:114` | `onCopiar` do card do rail → no-op | ✅ Morta | O 6º fio — confirmado. |
| V6 | `linha_de_pessoa.dart:130` | a tag sempre lê `PapelNaFesta.convidado` em vez de `pessoa.papel` | ✅ Morta — 4 testes | `linha_de_pessoa_test.dart`, grupo *"GAL-08 — o papel vira tag, e a cor vem do enum"*. É o **segundo elo** de P1-2 AC2, e ele morde. |

**Sensor da iteração 2: 13 mutações · 12 mortas · 1 sobrevivente (V2).**
Somando à iteração 1: **43 mutações · 42 mortas · 1 sobrevivente vivo**.

#### V2 — o sobrevivente, lido por inteiro

`GaleraRepositorioSobreFestas.definirNivelDoLink` documenta, no próprio código (`:114-119`), que
*"escreve **só** `convite.nivel`"*, e o grupo de testes que o cobre se chama, literalmente,
**"GAL-04 — definirNivelDoLink escreve só o nível"**. Mas o que o grupo afirma é: o nível novo
(`:154`), `pessoas` idêntica item a item (`:159`), o `codigo` intacto (`:171`), `pessoas` vazia
na festa vazia (`:189`), e a contagem de gravações (`:185-199`). **Ninguém afirma o resto de
`ComposicaoDaFesta`** — `itensSelecionados`, `overrides`, `noCarrinho`, `contagem`,
`duracaoHoras` — nem os campos de `festa`.

Com V2 plantada, tocar o segmented "QUEM ABRIR O LINK PODE…" **zera a lista de compras da
festa**, e as 2449 asserções continuam verdes.

É exatamente a classe do defeito que o commit `3f521c2` acabou de consertar (o `ResumoDeFesta`
que perdia `despesas` e `convite` no round-trip, e sumia com o carrinho da `lista`). O produto
**não está errado hoje** — a linha de produção está correta. O que falta é a asserção que impede
o amanhã, e que a própria spec pede em P1-2 AC4 ("**só** o nível muda").

---

### Os três ⚠️ da iteração 1, reabertos com evidência própria

| ⚠️ | Situação na iteração 2 | Veredito |
|---|---|---|
| **P1-2 AC2** — as tags exibidas continuam idênticas item a item | Continua sem teste que atravesse `segmented → porta → stream → tag`. Mas os **dois elos** têm agora sensor próprio: o elo "o nível não retroage sobre `papel`" morre com M7 (iteração 1) e o elo "tag = f(papel)" morre com **V6** (esta iteração, 4 testes). A cadeia é defendida em cada junta, e não só afirmada. | **⚠️ mantido**, severidade **Minor** (era "cadeia não verificada"; agora é "cadeia verificada junta a junta, sem teste ponta-a-ponta"). **Fix 2.** |
| **P1-2 AC3** — "nenhuma copy nova" ao trocar o nível | Re-derivado: `card_do_link_test.dart:203/207` (só a nota do nível vigente renderiza; as outras duas `findsNothing`) e `:270-271` (nenhum toast). A cláusula "nenhum aviso sobre convidados já dentro" continua sendo uma **negativa aberta**: não é enumerável, e a A-09 escolheu de propósito não criar copy para ela. | **⚠️ mantido** como **spec-precision gap intrínseco**, não como buraco de teste. Sem fix — inventar a asserção exigiria inventar a copy que a A-09 recusa. |
| **P2-1 AC6** — todo clicável tem hover no expandido | Re-derivado e **agora com sensor**: V3 mata o hover da `LinhaDePessoa`; `galera_expandida_test.dart:537` cobre o CTA e o "COPIAR 🔗" via `BoraPressSink` (e cai sob V1, logo é do expandido). A lacuna que resta é o `BoraSegmentedControl`, que **não tem hover** — e ele é de `core/design_system/`, **fora da fronteira de arquivos** desta spec (dívida 4 do `STATE.md`). | **⚠️ mantido**, sem fix nesta spec. É dívida da spec 01. |

**Nenhum dos três é ❌.** Nenhum vira Blocker.

---

### Cobertura re-derivada — GAL-01..GAL-28 e a aritmética da iteração 1

Re-contei os critérios direto da `spec.md`: P1-1 **8** · P1-2 **4** · P1-3 **9** · P1-4 **12** ·
P1-5 **6** · P1-6 **7** · P2-1 **6** · P2-2 **6** · P3-1 **3** = **61**. As tabelas da
§Spec-Anchored acima têm, contadas, **61 linhas** de critério — batem com a spec.

> **A iteração 1 errou a conta.** Ela fechou com *"**54/57 ✅** · 1 ❌ · 3 ⚠️"*, e 54+1+3 = 58 ≠ 57.
> O denominador correto é **61**, e o numerador daquele momento era **57 ✅**. O corpo do
> relatório (as 61 linhas, uma a uma) estava certo; só o resumo estava errado, nas duas metades.
> **Corrigido aqui**: a §Status da §Spec-Anchored deve ser lida com estes números.

| Momento | Total | ✅ | ❌ | ⚠️ |
|---|---|---|---|---|
| Iteração 1 (números corrigidos) | 61 | 57 | 1 (P1-2 AC4) | 3 |
| **Iteração 2** | **61** | **58** | **0** | **3** |

**P1-2 AC4 fecha.** Evidência própria, não relatada:
`galera_repositorio_papel_e_nivel_test.dart:174-190` (o adaptador, festa com `pessoas: []`) e
`galera_bloc_escritas_test.dart:131-144` (o bloc, `carregado(galeraDeTeste(pessoas: const []))`,
afirmando `repositorio.niveis == [(festa, coAnfitriao)]` **e** `escritas == 1`). O par sobrevive
à mutação: M19 mata o primeiro. O segundo é o que separa a leitura antiga ("o *evento* não
carrega pessoa") da nova ("a *festa* está vazia") — as duas leituras agora têm teste, e o nome de
cada um diz qual é qual.

Os 28 requisitos `GAL-xx` mapeiam nos 61 critérios sem órfão e sem critério não mapeado — a
matriz de §Requirement Traceability da `spec.md` foi conferida linha a linha contra as histórias.

**Não é omissão** (pergunta explícita do handoff): `efeitosDasPreferencias` e
`resumoDasPreferencias` **são consumidos** — `faixa_de_preferencias.dart:35-36` chama os dois, e
`faixa_de_preferencias_test.dart:88` afirma que o texto da faixa é o que `resumoDasPreferencias`
devolve, com o "💡 " na frente. Fechado.
---

## Auditoria dos desvios declarados

O handoff do `STATE.md` lista **dois** desvios pendentes de decisão do usuário. A varredura
(`grep -rn "SPEC_DEVIATION" lib/features/galera/ lib/core/`) encontra **seis** marcadores. Os
quatro que o handoff não menciona são desvios **de desenho**, já racionalizados no código e sem
custo para o usuário; os dois que ele menciona são os que tocam regra publicada do `CLAUDE.md` /
`design.md`. Registro os seis; **não decido nenhum**.

| # | Desvio declarado | Onde | Veredito | Evidência |
|---|---|---|---|---|
| 1 | **Três acentos na tela**, contra o máximo de 2 do arquivo 02 §8 — roxo (card do link, CTA), amarelo (label, faixa de RN-21) e vermelho (ativo de "RESTRIÇÃO ALIMENTAR") | `galera_compacta.dart:31-37` | **Procede, consciente, e continua violando a leitura estrita** | Os três usos são literais de T-05, e a `spec.md` já os registrou em D-2 / A-16 antes de o código existir. A racionalização ("vermelho é estado de controle, não cor de superfície") é uma leitura defensável de §8, não uma isenção que §8 conceda. **Decisão do usuário — pendente.** Precedente idêntico já aceito em `lista` (item 13 do `validation.md` daquela spec). |
| 2 | **Rodapé não usa `BoraFooterBar`** | `galera_compacta.dart:343-350` | **Procede** | `BoraFooterBar` tem o bloco "SAI POR"/valor/sublinha à esquerda, e T-05 **não dá número nenhum** a esta tela — a Galera não fala de dinheiro. A composição reusa os tokens do próprio componente (`bordaSuperior`, `BoraSpacing.rodape`); `core/design_system/` **não foi tocado** (conferido: `git diff --name-only main..HEAD -- lib/core/design_system/` é vazio). Mesmo caminho do rodapé de T-04. **Decisão do usuário — pendente.** |
| 3 | `GaleraRepositorioSobreFestas` é **vista** sobre `FestaEmEdicaoRepository`, não a "impl em memória" que a A-01 literalmente pediu | `galera_repositorio_sobre_festas.dart:28-37` | **Procede, e é o desvio que salva dois requisitos** | Com store paralelo, GAL-14 (a dieta muda a lista) e GAL-09 (Home e Galera contam o mesmo) viram disciplina em vez de estrutura. `fonte_unica_test.dart` existe justamente para provar a fonte única, e `festa_repository_em_memoria_round_trip_test.dart` (256 linhas novas) fecha o round-trip real. Fora do escopo de decisão do usuário: honra a intenção da A-01. |
| 4 | `BotaoDeDieta` composto em vez de `BoraSegmentedControl` | `botao_de_dieta.dart:21-25` | **Procede** | T-05 pede o ativo em **vermelho**, e `BoraSegmentedControl` fixa o ativo em preto. A alternativa — emendar o design system a partir de uma tela — é o caminho para o componente virar o caso de uso de quem o emendou. Fica como candidato a variante `acentoAtivo:` numa spec futura. O guard de literais (`galera_guards_test.dart:462`) prova que o arquivo não introduz cor nova. |
| 5 | `LinhaDePessoa` composta em vez de `BoraExpandableRow` | `linha_de_pessoa.dart:20-24` | **Procede** | `BoraExpandableRow` tem slots fixos (título + caret) e não recebe avatar, badge, sublinha e tag. A linha reusa os **glifos de caret** do componente, o que é a parte que divergiria primeiro. |
| 6 | `ComposicaoDaFesta.copyWith` — emenda em `lib/core/calculo/**`, que a `spec.md` põe **fora** da fronteira desta feature | `composicao_da_festa.dart:62-74` (E-3) | **Procede, e é a emenda certa** | Sem `copyWith`, a escrita da Galera remontaria a composição campo a campo — e a próxima spec que acrescentasse um campo o perderia em toda escrita antiga, sem erro de compilação. É literalmente o defeito que `3f521c2` consertou noutro registro. A emenda é **estrutural**: nenhum campo novo, nenhuma aritmética, nenhuma `RN-xx`. `test/core/calculo/dominio/composicao_da_festa_test.dart` ganhou 153 linhas cobrindo-a. |

**Nota sobre o handoff:** ele diz "dois SPEC_DEVIATION declarados". São **seis**. Os quatro
extras não mudam o veredito e não exigem decisão do usuário, mas quem for aprovar a feature
precisa saber que a contagem do handoff estava incompleta.

---

## O que ninguém tinha verificado

| Verificação | Resultado |
|---|---|
| **Fronteira de arquivos da `spec.md`** — a tabela "Pode tocar / Não pode tocar" | ⚠️ **Atravessada em 4 lugares, os 4 justificáveis, 1 sem marcador.** `lib/core/calculo/**` (declarado, item 6 acima). `lib/core/routing/app_router.dart` (**sem** marcador `SPEC_DEVIATION`): o diff é o `import` da porta, o parâmetro `required GaleraRepository galera` em `buildAppRouter` e a troca de `const GaleraPage()` pela página real com `festaId`/`galera`/`logger` — mínimo indispensável para a rota deixar de ser placeholder, e precedente idêntico aceito em `lista`. `lib/features/home/**` (`festa_repository_em_memoria.dart`, `resumo_de_festa.dart`): é o fix `3f521c2`, feito **por decisão explícita do usuário** e registrado no `STATE.md`. `lib/core/festas/**` não estava em nenhuma das duas colunas e é **sancionado pela AD-031** (o dado do acesso mora em `core/festas/`). |
| **`lib/core/design_system/**` intocado** (guarda de pureza da spec 01) | ✅ `git diff --name-only main..HEAD -- lib/core/design_system/` é **vazio**. |
| **`lib/features/{montar,lista,convite,convidado,custos}/**` intocados** | ✅ nenhum aparece em `git diff --name-only main..HEAD -- lib/`. |
| **`lib/core/di/injector.dart` — "só registro dos próprios"** | ✅ o diff é dois `import`, um `registerLazySingleton<GaleraRepository>` e a linha `galera: getIt<GaleraRepository>()` na construção do roteador. Nada além. |
| **`lib/features/galera/domain/` é Dart puro** (GAL-19 AC7 — a spec 09 precisa traduzir RN-22 em security rules) | ✅ `grep -rn "package:flutter\|dart:ui" lib/features/galera/domain/` é **vazio**. E o guard `galera_guards_test.dart:495-544` prova que a regra **morde**: infrator sintético em `domain/` é acusado nomeando o arquivo, o mesmo import **fora** de `domain/` não é, e o caminho com separador do Windows continua contando como domínio. |
| **Nenhuma fórmula de RN-03 / RN-05 / RN-21 em `lib/features/galera/`** | ✅ `galera_guards_test.dart:273-460` — varredura de diretório real (não de string), com prova de que ela **não roda vazia** (`:283`) e de que **alcança o domínio** (`:291`). Seis testes de infrator sintético cobrem a constante em gramas, em quilos, a RN-21 reescrita, a conta escondida em interpolação, e os **dois falsos positivos** que a regra não pode acusar (`:390`, `:402`). |
| **Nenhum literal de cor / fonte / sombra na feature** | ✅ `galera_guards_test.dart:461-494` — cada forma de literal acusada, e o token + `copyWith` de cor continuam legítimos. |
| **Regra payload/conjunção** — a asserção incide sobre o **valor**, não sobre a chamada | ✅ nos quatro gestos do expandido (`galera_expandida_test.dart:357/375/393/415` afirmam a tripla `(festaId, chave, valor)` inteira, não `escritas > 0`), no adaptador (`galera_repositorio_papel_e_nivel_test.dart:159` compara a **pessoa inteira**, não só `papel`), e no bloc (`galera_bloc_escritas_test.dart` afirma `repositorio.niveis` **e** `escritas`). Não encontrei nenhum caso de "houve `emit`, logo há campo". |
| **AD-022 — a Galera não escreve contador** | ✅ nenhuma escrita de `confirmados`/`pendentes` em `lib/features/galera/**`; GAL-09 é afirmado por **igualdade** contra o `ResumoDeFesta` da mesma festa, e M21 (iteração 1) mata a contagem errada com 13 testes. |
| **AD-026 — o link é perpétuo; nada expira nem revoga** | ✅ nenhum caminho de código apaga ou regenera `convite.codigo`; `galera_repositorio_papel_e_nivel_test.dart:171` e `:188` afirmam `codigo == 'rafa18'` depois da escrita do nível. |
| **AD-007 — a fronteira de layout é 900px** | ✅ `galera_expandida_test.dart` afirma 900 = expandido e 890 = compacto, e V1 prova que a escolha é do `ResponsiveBuilder` da página, não de cada widget. |
| **Nenhum teste pré-existente enfraquecido, pulado ou apagado** | ✅ ver §Test Integrity da iteração 2 — 2 linhas removidas em `test/`, ambas auditadas e nenhuma delas asserção. |

---

## Code Quality

| Princípio | Status |
|---|---|
| Código mínimo, sem funcionalidade além do pedido | ✅ — nada de "+ pessoa", nada de revogar link, nada de remover pessoa: os três estão no Out of Scope e nenhum existe no código. |
| Mudanças cirúrgicas; fronteira de arquivos respeitada | ⚠️ — 4 travessias, as 4 justificadas, **1 sem marcador** (`app_router.dart`). Ver §O que ninguém tinha verificado. |
| Sem abstração para código de uso único | ✅ — `CapacidadesDaGalera`, `ChaveDePessoa` e `GaleraTextos` têm ≥2 consumidores cada (compacto e expandido, no mínimo). |
| Segue os padrões existentes | ✅ — bloc com eventos/estados explícitos, `*_textos.dart`, guards de arquitetura, porta em `domain/`, impl em `data/` — a mesma forma de `montar` e `lista`. |
| Testes mapeiam a AC e não são rasos | ✅ — 43 mutações plantadas nas duas iterações, 42 mortas. |
| Spec-anchored outcome check | ⚠️ — **58/61 ✅**, 0 ❌, 3 ⚠️ (2 intrínsecos à spec-fonte, 1 dívida da spec 01). |
| Cobertura por camada | ✅ — domínio 1:1 com as ACs (as 32 células de RN-22 são 32 asserções explícitas em `permissoes_test.dart:37-…`, não um laço comparando o domínio consigo mesmo, como a `spec.md` exige); adaptador com happy + vazio + inexistente + idempotente; página com happy + erro + falha de cópia; os **dois** layouts com gesto real. |
| Todo teste mapeia a uma AC / edge case / Done-when | ✅ — nenhum teste órfão encontrado; todo grupo de `test/features/galera/**` nomeia um `GAL-xx` ou uma dimensão declarada. |
| Diretrizes documentadas seguidas | ✅ — `CLAUDE.md` (copy literal, zero fórmula na UI, domínio em PT-BR e infra em inglês, Conventional Commits em português com `RN-xx`/`UC-xx` no corpo — conferido em `457de00` e `3f521c2`), `design.md` §13. |
| **Sensor** | ❌ — **1 sobrevivente** (V2). É o item que decide o veredito. |

**RN-13 / RN-14**: fora do alcance desta tela — a Galera não exibe dinheiro. Conferido que
nenhum arquivo de `lib/features/galera/**` formata moeda nem divide por `adultos`/`pessoas`
(a regra 1 do guard proíbe as constantes, e a varredura está verde).

**RN-29**: `galera_textos_test.dart:344` afirma `GaleraTextos.linkCopiado == BoraToastTexts.linkCopiado`
— a copy não é redigitada aqui, é a mesma constante do design system. "1 por vez" é afirmado por
`galera_page_test.dart:279`.

---

## Fix Plans

### Fix 1 — `definirNivelDoLink` não tem quem prove que escreve **só** o nível (Major)

- **Root cause**: o grupo "GAL-04 — definirNivelDoLink escreve só o nível"
  (`test/features/galera/data/galera_repositorio_papel_e_nivel_test.dart:151-199`) afirma o nível
  novo, `pessoas` item a item e o `codigo`, mas **nada** sobre o resto de `ComposicaoDaFesta`
  (`itensSelecionados`, `overrides`, `noCarrinho`, `contagem`, `duracaoHoras`) nem sobre os campos
  de `festa`. A sonda **V2** planta uma escrita destrutiva em
  `lib/features/galera/data/galera_repositorio_sobre_festas.dart:127` e a suíte de **2449** testes
  fica verde.
- **Fix task**: acrescentar ao grupo um teste que capture o `FestaEmEdicao` **inteiro** antes de
  `definirNivelDoLink` e afirme, depois, que o registro gravado é **igual ao capturado a menos de
  `convite.nivel`** — `expect(depois, antes.copyWith(convite: antes.convite.copyWith(nivel: novo)))`,
  usando a igualdade por valor que `FestaEmEdicao` já tem
  (`test/core/festas/dominio/festa_em_edicao_test.dart`). Um teste, uma asserção; nenhuma linha de
  produção muda. Fazer o mesmo no caso da festa vazia (`:174`).
- **Verify**: replantar V2 — o novo teste tem de ficar **vermelho**.
- **Done when**: V2 morre, a suíte fica verde sem ela, `flutter analyze` continua limpo.
- **Priority**: **Major** — é a classe exata do defeito que `3f521c2` consertou (perda silenciosa
  de estado de outra spec no round-trip), e o alvo aqui é o carrinho da `lista`.

### Fix 2 — P1-2 AC2 não tem teste ponta-a-ponta (Minor)

- **Root cause**: a garantia "as tags exibidas continuam idênticas item a item depois de trocar o
  nível" é composta de dois elos, cada um com sensor próprio (M7 e V6), mas nenhum teste atravessa
  `segmented → porta → stream → tag`.
- **Fix task**: um widget test em `galera_compacta_test.dart` (ou `galera_page_test.dart`) que
  capture os cinco `GaleraTextos.statusDoPapel(pessoa.papel)` renderizados, percorra os três níveis
  tocando o segmented, e reafirme a **mesma lista, na mesma ordem**.
- **Verify**: replantar M7 (o adaptador rebaixando todo mundo a SÓ VÊ) — o teste novo tem de cair
  **também** por ele, além do teste de adaptador que já cai.
- **Done when**: AC2 sai de ⚠️ para ✅ com `file:line` próprio.
- **Priority**: **Minor** — defesa em profundidade; as duas juntas já mordem.

### Fix 3 — Três testes do expandido não estão ancorados ao expandido (Minor)

- **Root cause**: `galera_expandida_test.dart:443`, `:455` e `:467` não têm
  `expect(find.byType(GaleraExpandida), findsOneWidget)`. A sonda V1 (página sempre compacta)
  deixa os três **verdes**, com o nome dizendo "no expandido".
- **Fix task**: acrescentar a linha de âncora aos três, como já fazem `:432`, `:356`, `:374`,
  `:392` e `:413`.
- **Verify**: replantar V1 — os três têm de cair.
- **Done when**: V1 derruba **17** testes no arquivo, não 14.
- **Priority**: **Minor** — hoje inofensivo; vira silencioso se AD-007 regredir.

### Não-fixes, registrados de propósito

- **P1-2 AC3** ("nenhum aviso sobre convidados já dentro") — negativa aberta. A A-09 decidiu não
  criar copy; inventar a asserção exigiria inventar a copy. Fica **⚠️ spec-precision gap**.
- **P2-1 AC6 / `BoraSegmentedControl` sem hover** — `core/design_system/` está fora da fronteira
  desta spec. Dívida 4 do `STATE.md`, território da spec 01.
- **Os dois SPEC_DEVIATION pendentes** (três acentos; rodapé sem `BoraFooterBar`) — **decisão do
  usuário**, não do Verifier. Não são gap de teste e não entram no veredito.

---

## Requirement Traceability Update

| Requisito | Status anterior | Novo status |
|---|---|---|
| GAL-01, GAL-02, GAL-03 | Implementing | ✅ Verified |
| **GAL-04** | ❌ Needs Fix (P1-2 AC4 sem evidência) | ✅ **Verified** — AC4 fechado por `galera_repositorio_papel_e_nivel_test.dart:174` + `galera_bloc_escritas_test.dart:131`, com M19 morta. AC2 permanece ⚠️ (Fix 2). |
| GAL-05, GAL-06, GAL-07, GAL-08, GAL-09 | Implementing | ✅ Verified |
| GAL-10, GAL-11, GAL-12, GAL-13, GAL-14, GAL-15 | Implementing | ✅ Verified — GAL-11 e GAL-12 agora também **no expandido** (M27, M28c mortas). |
| GAL-16, GAL-17, GAL-18 | Implementing | ✅ Verified — GAL-17 também no expandido (M28b morta). |
| GAL-19, GAL-20, GAL-21 | Implementing | ✅ Verified — 32 células explícitas, domínio Dart puro conferido. |
| GAL-22, GAL-23 | Implementing | ✅ Verified — AC6 com ⚠️ declarado (dívida da spec 01). |
| GAL-24, GAL-25, GAL-26, GAL-28 | Implementing | ✅ Verified |
| **GAL-27** | Implementing | ✅ **Verified** — RN-22 agora tem par discriminante nos **dois** layouts (M25, M26 mortas). Ancoragem dos três testes é o Fix 3. |

**28/28 requisitos verificados.** O veredito ❌ **não** vem de requisito descoberto — vem do
sobrevivente V2, que é fragilidade de teste sobre GAL-04.

---

## Integridade da árvore

| Momento | `git status --porcelain` |
|---|---|
| Antes da primeira mutação | **vazio** (conferido) |
| Entre cada uma das 13 mutações | **vazio** (conferido pelo script, impresso a cada rodada) |
| Depois do incidente de fim de linha (M25, 1ª tentativa) | ` M lib/.../galera_expandida.dart` → **restaurado a partir do blob de HEAD**, md5 idêntico, status vazio de novo |
| Ao final de todas as mutações | **vazio** (conferido) |
| Antes de escrever este relatório | **vazio** |

`git checkout --` **não foi usado** sobre a árvore de trabalho em nenhum momento. Nenhuma
mutação ficou no disco. `dart format` **não foi executado**. A única alteração que este Verifier
deixa na árvore é este arquivo, `.specs/features/galera/validation.md`.

---

## Summary

**Overall**: ❌ **Not Ready** — por **um** item, e ele é de teste, não de produto.

**Spec-anchored check**: **58/61 ✅** · **0 ❌** · **3 ⚠️** (2 intrínsecos à spec-fonte, 1 dívida
da spec 01).
**Sensor (iteração 2)**: 13 mutações · **12 mortas · 1 sobrevivente**.
**Sensor (acumulado)**: 43 mutações · 42 mortas · 1 sobrevivente vivo.
**Gate**: `flutter test` **2449 passaram, 0 falharam** (exit 0) · `flutter analyze` **zero
issues** (exit 0).

**O que funciona** — verificado por mim, não relatado:

- A alegação central de `457de00` **procede**: as 7 mutações que ela diz ter fechado morrem, cada
  uma pelo teste que o commit criou, e por asserção de **valor** na porta, não de chamada.
- O único ❌ da iteração 1 (**P1-2 AC4**) está fechado, com o par de testes que separa as duas
  leituras de "sem pessoa nenhuma".
- Os 10 testes novos **não são tautológicos**: as duas guardas de RN-22 têm par discriminante
  real, e os quatro gestos são insatisfazíveis pelo layout compacto (provado pela sonda V1).
- A tabela de RN-22 é domínio Dart puro, com 32 asserções célula a célula, pronta para a spec 09
  traduzir em security rules.
- A fronteira de arquivos foi atravessada 4 vezes, todas justificáveis; `core/design_system/`
  está intocado.

**Issues found**:

1. **Fix 1 (Major)** — `definirNivelDoLink` pode apagar `itensSelecionados` da festa (a lista de
   compras inteira) e os 2449 testes ficam verdes. Uma asserção de igualdade-a-menos-do-nível
   fecha.
2. **Fix 2 (Minor)** — P1-2 AC2 sem teste ponta-a-ponta.
3. **Fix 3 (Minor)** — 3 testes do expandido sem âncora `findsOneWidget` na `GaleraExpandida`.

**Pendente do usuário, não do Verifier**: os dois SPEC_DEVIATION do handoff (três acentos por
tela; rodapé sem `BoraFooterBar`) — e a informação nova de que os marcadores são **seis**, não
dois.

**Next steps**: executar os 3 fixes (todos test-only, nenhuma linha de `lib/` muda) e despachar a
**iteração 3** — a última das 3 antes de escalar. O critério de PASS da iteração 3 é objetivo:
V2 morre, V1 derruba 17 testes em `galera_expandida_test.dart` em vez de 14, e o gate segue verde.
