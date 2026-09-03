# A galera — Validation

**Date**: 2026-09-02
**Spec**: `.specs/features/galera/spec.md` (GAL-01..GAL-28)
**Diff range**: `main...HEAD` na branch `feature/galera` — 30 commits, 68 arquivos, `+10910 / −329` linhas
**Verifier**: sub-agente independente (autor ≠ verificador). Cobertura re-derivada do zero a partir da `spec.md`, regra **evidence-or-zero**. Nenhuma alegação dos batch workers foi aceita — inclusive os autoexames de discriminação que eles relataram.

**Veredito**: (preenchido ao fim)

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
