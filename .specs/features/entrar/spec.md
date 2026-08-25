# Entrar — Specification

**ID prefix:** `ENT` · **Porte:** **Grande** (revisto — ver §Porte)
**Design:** `.specs/features/entrar/design.md` (a produzir)
**Tasks:** `.specs/features/entrar/tasks.md` (a produzir)
**Context:** `.specs/features/entrar/context.md`
**Spec-fonte:** T-01 (`04-telas-ux.md`) · W-01 + §Regras transversais web (`06-telas-web.md`) · UC-01 (`05-casos-de-uso.md`)
**Roadmap:** `.specs/ROADMAP.md` — spec 03, marco M1
**Decisões ativas herdadas:** AD-001..AD-014 (`.specs/STATE.md`) · **AD-013 é a razão da primeira task desta spec**
**Decisões que esta spec origina:** AD-015 (auth), AD-016 (dados do M1), AD-017 (guarda de rota)

## Problem Statement

O M0 entregou um app que compila, navega, calcula e tem design system — e que **abre num placeholder sem cor**. `boraTheme()` existe, está testado com o valor literal de cada token do arquivo 02, e **não é aplicado em lugar nenhum**: a AD-013 deixou `lib/app.dart` deliberadamente fora da spec 01 porque aplicar tema é decisão de app, não de biblioteca. Enquanto ninguém pluga o tema no `BoraApp`, cada uma das oito specs de tela vai nascer contra um `MaterialApp` sem `theme:` — e a primeira que resolver plugar vai repintar as sete anteriores.

Esta spec é a que abre a porta: pluga o tema, e só então constrói a primeira tela de produto do BORA. T-01 é a porta de entrada literal do app — sem ela não há sessão, e sem sessão a Home (spec 04) e o Montar (spec 05) não têm de quem falar.

Havia ainda um conflito aberto no projeto desde antes do código: o `CLAUDE.md` decidiu "Auth (Google + telefone)", mas T-01, W-01 e o aceite de UC-01 mostram **e-mail/senha + Google** e não mencionam telefone em nenhum lugar. A zona cinzenta **G1** do roadmap era exatamente isso, e ela se resolve aqui (A-01 / AD-015).

## Goals

- [ ] `boraTheme()` aplicado no `BoraApp` — toda tela do app, presente e futura, herda os tokens do arquivo 02 sem `Theme()` local.
- [ ] T-01 e W-01 renderizados com a copy literal das specs 04 e 06, cada literal afirmado por teste.
- [ ] Login por e-mail/senha e por Google funcionando **de verdade** contra o emulador do Firebase Auth, com o aceite de UC-01 verificável: os dois métodos presentes, foco de input vermelho, pós-login sempre na Home.
- [ ] Sessão persiste entre aberturas do app e governa a navegação: quem não tem sessão não alcança `/roles/**`; quem tem não fica preso em `/entrar`; `/c/:codigo` continua livre.
- [ ] "CRIAR CONTA" cria conta de verdade, sem tela nova e sem rota nova.
- [ ] Falha de rede, credencial errada e Firebase caído produzem mensagem visível — nunca tela travada nem exceção não tratada.

## Out of Scope

| Item | Razão |
|---|---|
| Login por **telefone/SMS** | **AD-015**: T-01, W-01 e UC-01 não o mencionam e não há UI desenhada para ele. O `CLAUDE.md` é corrigido, não obedecido. |
| Recuperação de senha ("esqueci minha senha") | Não existe em T-01 nem em W-01 nem em UC-01. Nenhuma tela da spec-fonte tem esse link. |
| Perfil, logout, troca de conta | Nenhuma tela do M1 os expõe. O avatar do header de app (W-02) é da spec 04 e é decorativo. |
| Verificação de e-mail, termos de uso, política de privacidade | Fora da spec-fonte. |
| Qualquer leitura de festa, contador ou lista | Spec 04 `home` e 05 `montar`. Esta spec entrega sessão, não dado de festa. |
| `FestaRepository` e persistência de dados de domínio | **AD-016**: dado de festa é em memória no M1 e nasce na spec 04. |
| Revestir `AppShell` e `PlaceholderPage` | Passam para a spec 04 `home` — o header de app só é especificado em `06-telas-web.md` §Header de app, cujo conteúdo (`+ NOVO ROLÊ`, avatar) é da Home. Ver §Herança da AD-013. |
| Revestir `FestaTabsShell` | Nenhuma tela do M1 monta as abas da festa. Passa para a spec 06 `lista`, a primeira aba a existir. |
| Security rules do Firestore | Dependem de RN-22 (papéis), que nasce na spec 07 `galera`. |
| Projeto Firebase real na nuvem | **AD-016** mantém o emulator-first da AD-004. `flutterfire configure` continua adiado. |
| CI | `CLAUDE.md` proíbe criar sem pedido explícito. |

---

## Herança da AD-013 — quem reveste o quê

A AD-013 devolveu quatro artefatos da fundação "para as specs 03/04" sem dividir. A divisão é esta:

| Artefato | Dono | Por quê |
|---|---|---|
| `lib/app.dart` — aplicar `boraTheme()` | **`entrar`** (ENT-01) | É a primeira spec de tela; sem isso T-01 nasce sem tokens |
| `RouteErrorPage` | **`entrar`** (ENT-19) | Página global, alcançável de qualquer rota inclusive antes do login; não tem tela-dona melhor |
| `AppShell` (header de app) | `home` (spec 04) | Especificado em `06` §Header de app, e seu conteúdo — `+ NOVO ROLÊ`, avatar — é da Home |
| `PlaceholderPage` | `home` (spec 04) | Todos os placeholders restantes vivem sob o shell, alcançados a partir da Home |
| `FestaTabsShell` | `lista` (spec 06) | Nenhuma tela do M1 o monta |

---

## Fronteira de arquivos

| Pode tocar | Não pode tocar |
|---|---|
| `lib/features/entrar/**` | `lib/core/calculo/**` (camada fechada) |
| `lib/app.dart` — **só** para aplicar o tema (ENT-01) | `lib/core/design_system/**` (spec 01 fechada; componente que faltar vira desvio registrado) |
| `lib/core/routing/app_router.dart` — **só** o redirect de sessão (ENT-15..18) | `lib/features/{home,montar,lista,galera,convite,convidado,custos}/**` |
| `lib/core/routing/route_error_page.dart` | `lib/core/routing/{app_shell,festa_tabs_shell,placeholder_page}.dart` |
| `lib/core/di/injector.dart` — **só** registro dos próprios | `.specs/{STATE,ROADMAP,LESSONS}.md`, `.specs/lessons.json` |
| `test/features/entrar/**`, `test/app_test.dart`, `test/core/routing/**` | qualquer teste existente — os **742** de baseline não podem ser enfraquecidos nem apagados |

**Baseline a preservar:** `flutter test` = 742 passando · `flutter analyze` = zero issues (`main`, 2026-08-25).

---

## Assumptions & Open Questions

| # | Assumption / decisão | Default escolhido | Rationale | Confirmado? |
|---|---|---|---|---|
| A-01 | **G1** — `CLAUDE.md` diz "Google + telefone"; T-01/W-01/UC-01 mostram e-mail/senha + Google | **E-mail/senha + Google.** Telefone sai do produto; o `CLAUDE.md` é corrigido | A tela desenhada é a que existe; obedecer o `CLAUDE.md` exigiria redesenhar T-01 e W-01 e quebrar o aceite de UC-01 | **y** (2026-08-25) |
| A-02 | **G8** — origem dos dados no M1 | **Auth real contra o emulador; dado de festa em memória.** `FestaRepository` nasce como porta na spec 04, com impl em memória semeada pela fixture RN-30; Firestore entra no M2 com RN-28 | O realtime de RN-28 só tem quem o produza no M2 (`convidado`); a porta abstrata torna a troca barata e mantém a suíte do M1 rodando sem emulador ligado | **y** (2026-08-25) |
| A-03 | Guarda de rota | **Redirect por sessão no `app_router`**: sem sessão em `/roles/**` → `/entrar`; com sessão em `/entrar` → `/roles`; `/c/:codigo`, `/erro` e `/catalogo` sempre livres | Sem guarda, no web basta digitar `/roles` na barra; e o aceite de UC-01 "pós-login sempre cai na Home" é exatamente um redirect | **y** (2026-08-25) |
| A-04 | "CRIAR CONTA" não tem tela na spec-fonte | **Modo alternado na mesma tela** — o card vira modo cadastro; nenhuma rota nova, nenhum layout inventado | A alternativa (rota `/criar-conta`) acrescentaria nó ao mapa canônico da AD-003 sem que 04 ou 06 o desenhem | **y** (2026-08-25) |
| A-05 | A copy do botão Google **difere entre plataformas**: "CONTINUAR COM GOOGLE" (T-01) × "🌐 ENTRAR COM GOOGLE" (W-01) | **Manter as duas literais**, uma por plataforma | `CLAUDE.md`: "a copy nas specs é literal, não paráfrase". Unificar seria escolher qual das duas specs desobedecer | n |
| A-06 | Nenhuma spec dá o texto do erro de credencial | **"E-MAIL OU SENHA INCORRETOS"**, no padrão de caixa alta de labels, exibido inline abaixo dos inputs — **não** como toast | RN-29 fecha a lista de toasts canônicos e nenhum deles é de erro; inventar toast furaria a regra. Erro de formulário é do formulário | n |
| A-07 | Nenhuma spec dá o texto do modo cadastro | Label do card **"CRIAR CONTA"**, CTA **"CRIAR CONTA →"**, rodapé **"Já tem conta? ENTRAR"** | Espelha a estrutura literal de W-01 (label "ENTRAR" 800 13px, CTA "COMEÇAR →", rodapé "Novo por aqui? CRIAR CONTA") trocando só o verbo | n |
| A-08 | Nenhuma spec define validação de e-mail/senha | E-mail: formato com `@` e domínio. Senha: **mínimo 6 caracteres** | 6 é o mínimo que o próprio Firebase Auth impõe; inventar outro número faria o app rejeitar antes ou aceitar o que o backend recusa | n |
| A-09 | O `RouteErrorPage` não tem especificação visual em 04 nem 06 | Revestido com tokens do arquivo 02 (fundo `paper`, título Archivo Black caixa alta, CTA secundário "VOLTAR PRO INÍCIO"), **sem** inventar ilustração | O arquivo 02 governa forma; a ausência de tela específica não autoriza sair dos tokens | n |
| A-10 | Login com Google no **emulador**: o provider Google não tem fluxo nativo no emulador Android | O emulador do Auth aceita o fluxo genérico de OAuth no **web**; no mobile o botão exercita o mesmo caminho de repositório, e a verificação ponta-a-ponta do Google fica **declarada como dependente de conferência manual** no web | L-003 do playbook: adaptador sem prova automatizada deve declarar qual AC depende de verificação manual, em vez de fingir cobertura | n |
| A-11 | O `CLAUDE.md` afirma "Não há código ainda" e "Auth (Google + telefone)" — ambos falsos após o M0 e a A-01 | Corrigir as duas passagens no `CLAUDE.md` como parte desta spec | Documento que orienta toda sessão futura contradizendo uma AD ativa faz a próxima sessão implementar telefone | n |

**Open questions:** nenhuma — tudo resolvido ou registrado acima.

---

## Varredura de dimensões implícitas (porte Grande — todas cobertas)

| Dimensão | Cobertura |
|---|---|
| Input validation & bounds | ENT-08 (formato de e-mail, mínimo de senha, campos vazios) |
| Failure / partial-failure | ENT-09 (credencial inválida), ENT-11 (rede/Firebase indisponível) |
| Idempotency / retry / duplicate | ENT-10 (CTA bloqueado durante a chamada — duplo toque não dispara dois logins) |
| Auth boundaries & rate limits | ENT-15..18 (guarda de rota). **Rate limit: N/A** — o do Firebase Auth já responde por isso e nenhuma tela do M1 o expõe |
| Concurrency / ordering | ENT-18 (mudança de sessão durante navegação reavalia o redirect) |
| Data lifecycle / expiry | ENT-17 (sessão persiste entre aberturas). **Expiração explícita: N/A** — o SDK renova o token e nenhuma spec define TTL de sessão |
| Observability | ENT-12 (falha de auth vai para o `AppLogger` da AD-005) |
| External-dependency failure | ENT-11 (Firebase caído degrada: a tela abre, o erro aparece, o app não trava — coerente com a AD-004) |
| State-transition integrity | ENT-13 (alternância entrar ⇄ criar conta preserva o e-mail digitado e limpa o erro anterior) |

---

## User Stories

### P1: O app veste os tokens ⭐ MVP

**User Story**: Como time, quero que o `BoraApp` aplique `boraTheme()`, para que toda tela nasça com os tokens do arquivo 02 sem repintar nada depois.

**Why P1**: É a AD-013 sendo cumprida. Sem isso, T-01 e todas as telas seguintes nascem contra um `MaterialApp` sem `theme:`, e a primeira spec que plugar o tema repinta as anteriores. **Esta é a primeira task da spec.**

**Acceptance Criteria**:
1. WHEN o `BoraApp` é construído THEN `MaterialApp.router` SHALL receber `theme: boraTheme()` — o mesmo `ThemeData` que a spec 01 testou, sem nenhum valor redeclarado em `lib/app.dart`.
2. WHEN uma tela qualquer sob o roteador lê `Theme.of(context)` THEN SHALL obter o `scaffoldBackgroundColor`, a `fontFamily` e o `ColorScheme` de `boraTheme()`, sem `Theme()` local.
3. WHEN o `BoraApp` é construído THEN o título da aba SHALL continuar `'bora — a conta do rolê'` (W-R5/FUND-10) — o tema não pode custar a regressão do título.
4. WHEN `lib/app.dart` é varrido por teste THEN SHALL conter **zero** literal de cor, de `fontFamily` e de sombra — o tema chega pronto de `core/design_system/`.

**Independent Test**: monta `BoraApp` na suíte e afirma `Theme.of(context)` idêntico a `boraTheme()` numa rota qualquer; o guard de pureza da spec 01 estendido a `lib/app.dart` prova o AC4.

---

### P1: Entrar com e-mail e senha ⭐ MVP

**User Story**: Como anfitrião, quero entrar com meu e-mail e senha, para chegar nos meus rolês.

**Why P1**: É o fluxo principal de UC-01 e a única porta de entrada do app.

**Acceptance Criteria**:
1. WHEN a tela `/entrar` abre em viewport compacta (`< 900`, AD-007) THEN SHALL renderizar, na ordem de T-01: logo "BORA." com ponto vermelho, tag rotacionada −2° "A CONTA DO ROLÊ, RESOLVIDA", o parágrafo "Monta o churras, chama a galera e racha a conta. Sem planilha, sem treta.", input "seu e-mail", input "senha", CTA "COMEÇAR →", divisor "OU", botão "CONTINUAR COM GOOGLE" e o rodapé "Novo por aqui? CRIAR CONTA" — cada string literal.
2. WHEN a tela abre em viewport expandida (`>= 900`) THEN SHALL renderizar o layout de duas colunas de W-01: marca à esquerda (logo, tag −2°, parágrafo) e card branco à direita com o label "ENTRAR", os inputs, o CTA "COMEÇAR →", o botão "🌐 ENTRAR COM GOOGLE" e o rodapé "Novo por aqui? CRIAR CONTA".
3. WHEN um input recebe foco THEN a borda SHALL passar para o vermelho do token de acento — o aceite literal de UC-01.
4. WHEN o usuário informa credenciais válidas e aciona "COMEÇAR →" THEN o sistema SHALL autenticar e navegar para `/roles`.
5. WHEN a autenticação está em curso THEN o CTA SHALL exibir estado de carregando e não aceitar novo acionamento.

**Independent Test**: com um duplo de `AuthRepository` que aceita um par conhecido, preencher os inputs, tocar "COMEÇAR →" e afirmar que a rota corrente virou `/roles`; afirmar cada literal de T-01 e W-01 nos dois viewports.

---

### P1: Entrar com Google ⭐ MVP

**User Story**: Como anfitrião, quero entrar com minha conta Google, para não criar mais uma senha.

**Why P1**: UC-01 exige os dois métodos presentes; o aceite os nomeia explicitamente.

**Acceptance Criteria**:
1. WHEN a tela abre THEN o botão secundário Google SHALL estar presente com a copy da plataforma (A-05): "CONTINUAR COM GOOGLE" em compacto, "🌐 ENTRAR COM GOOGLE" em expandido.
2. WHEN o usuário aciona o botão Google e a autenticação conclui THEN o sistema SHALL navegar para `/roles` — o mesmo destino do e-mail/senha (UC-01: "pós-login sempre cai na Home").
3. WHEN o usuário cancela o fluxo do Google THEN a tela SHALL voltar ao estado ocioso, sem erro e sem navegar.

**Independent Test**: duplo de `AuthRepository` cujo `entrarComGoogle()` resolve — afirmar destino `/roles`; segundo duplo que devolve cancelamento — afirmar que a rota não mudou e nenhuma mensagem de erro apareceu. *(A verificação ponta-a-ponta contra o emulador é manual, no web — A-10.)*

---

### P1: A sessão manda na navegação ⭐ MVP

**User Story**: Como anfitrião, quero que o app me leve direto aos meus rolês quando já estou logado, e me barre nas telas de festa quando não estou.

**Why P1**: Sem guarda, no web basta digitar `/roles` na barra de endereços. E "pós-login sempre cai na Home" (UC-01) é literalmente um redirect.

**Acceptance Criteria**:
1. WHEN uma rota sob `/roles` é alcançada sem sessão THEN o roteador SHALL redirecionar para `/entrar`.
2. WHEN `/entrar` é alcançada **com** sessão THEN o roteador SHALL redirecionar para `/roles`.
3. WHEN `/c/:codigo`, `/erro` ou `/catalogo` são alcançadas THEN SHALL abrir **com ou sem sessão** — o convidado de RN-24 não tem conta e não pode ser barrado.
4. WHEN o app é reaberto após ter sido fechado com sessão ativa THEN SHALL abrir direto em `/roles`, sem passar por `/entrar`.
5. WHEN a sessão termina enquanto uma rota de festa está montada THEN o roteador SHALL reavaliar o redirect e levar para `/entrar`.

**Independent Test**: tabela de casos (rota alvo × com/sem sessão) afirmando a rota **final** depois do redirect — inclusive as três livres. *(L-001: rota que existe só como redirect precisa de teste que a abra e afirme o destino.)*

---

### P1: Erro não trava a tela ⭐ MVP

**User Story**: Como anfitrião, quero saber por que meu login falhou, para poder corrigir.

**Why P1**: A AD-004 já decidiu que falha de Firebase é **degradação, não crash**. Uma tela de login que trava em silêncio bloqueia o app inteiro.

**Acceptance Criteria**:
1. WHEN "COMEÇAR →" é acionado com e-mail em formato inválido ou senha com menos de 6 caracteres (A-08) THEN o sistema SHALL exibir a validação inline e **não** chamar o repositório.
2. WHEN "COMEÇAR →" é acionado com algum campo vazio THEN o sistema SHALL exibir a validação inline e não chamar o repositório.
3. WHEN o repositório recusa a credencial THEN a tela SHALL exibir "E-MAIL OU SENHA INCORRETOS" (A-06) inline, manter o e-mail digitado e voltar o CTA ao estado ocioso.
4. WHEN o repositório falha por rede ou Firebase indisponível THEN a tela SHALL exibir mensagem de falha, permanecer utilizável e **não** lançar exceção não tratada.
5. WHEN qualquer falha de autenticação ocorre THEN SHALL ser registrada no `AppLogger` (AD-005) — nenhuma falha silenciosa.

**Independent Test**: duplos de `AuthRepository` que lançam cada tipo de falha; afirmar mensagem exibida, CTA reabilitado, e-mail preservado e uma entrada no `RecordingAppLogger`.

---

### P2: Criar conta sem sair da tela

**User Story**: Como usuário novo, quero criar minha conta ali mesmo, para começar a usar sem procurar outra tela.

**Why P2**: A alternativa A1 de UC-01 cita o link, e o aceite de UC-01 só exige que ele **esteja presente** — o cadastro funcionando é o passo seguinte, não o mínimo de UC-01.

**Acceptance Criteria**:
1. WHEN "CRIAR CONTA" é acionado THEN a mesma tela SHALL alternar para modo cadastro: label "CRIAR CONTA", CTA "CRIAR CONTA →", rodapé "Já tem conta? ENTRAR" (A-07) — **sem** mudar de rota.
2. WHEN a alternância ocorre THEN o e-mail já digitado SHALL ser preservado e qualquer mensagem de erro anterior SHALL ser limpa.
3. WHEN o cadastro conclui com sucesso THEN o sistema SHALL autenticar o usuário novo e navegar para `/roles` — mesmo destino dos demais caminhos.
4. WHEN o e-mail já está em uso THEN a tela SHALL exibir mensagem inline e permanecer no modo cadastro.
5. WHEN "ENTRAR" do rodapé é acionado no modo cadastro THEN SHALL voltar ao modo entrar, preservando o e-mail.

**Independent Test**: alternar os modos afirmando as três strings de cada um e a preservação do e-mail; duplo que cria com sucesso → `/roles`; duplo que recusa por e-mail em uso → mensagem e modo mantido.

---

### P2: A tela de erro veste os tokens

**User Story**: Como usuário, quero que a tela de erro pareça o BORA, para não achar que quebrei o app.

**Why P2**: `RouteErrorPage` existe desde a fundação (FUND-09) e é alcançável de qualquer rota. Não bloqueia UC-01.

**Acceptance Criteria**:
1. WHEN uma rota inexistente é alcançada THEN a página de erro SHALL renderizar com os tokens do arquivo 02 (fundo `paper`, título Archivo Black caixa alta) e **nenhum** literal de cor ou fonte próprio (A-09).
2. WHEN a página de erro está montada THEN SHALL oferecer um CTA secundário "VOLTAR PRO INÍCIO" que leva à raiz.
3. WHEN a página de erro é alcançada sem sessão THEN SHALL abrir normalmente — a guarda não a intercepta (P1-4 AC3).

**Independent Test**: navegar para uma rota inexistente e afirmar os tokens na árvore renderizada e o destino do CTA.

---

## Edge Cases

- WHEN o usuário aciona "COMEÇAR →" duas vezes em sequência rápida THEN o sistema SHALL executar **uma** autenticação (ENT-10).
- WHEN o e-mail tem espaços nas pontas THEN SHALL ser aparado antes da validação e do envio.
- WHEN a viewport cruza 900px com a tela montada THEN SHALL trocar de layout preservando o texto já digitado e o modo (entrar/cadastro) — sem remontar o formulário do zero.
- WHEN o teclado do celular cobre o CTA THEN o conteúdo SHALL rolar, sem overflow de layout.
- WHEN o Firebase não inicializou (AD-004, degradação) THEN a tela SHALL abrir e os CTAs SHALL exibir falha ao serem acionados — nunca tela branca.
- WHEN a senha tem exatamente 6 caracteres THEN SHALL ser aceita (fronteira de A-08, inclusiva).

---

## Requirement Traceability

| ID | História | Origem na spec-fonte | Fase | Status |
|---|---|---|---|---|
| ENT-01 | P1-1 AC1,AC2 | AD-013 | Design | Pending |
| ENT-02 | P1-1 AC3,AC4 | W-R5 / FUND-10 | Design | Pending |
| ENT-03 | P1-2 AC1 | T-01 | Design | Pending |
| ENT-04 | P1-2 AC2 | W-01 | Design | Pending |
| ENT-05 | P1-2 AC3 | UC-01 (aceite) | Design | Pending |
| ENT-06 | P1-2 AC4 | UC-01 passo 2 | Design | Pending |
| ENT-07 | P1-2 AC5 | dimensão: idempotência | Design | Pending |
| ENT-08 | P1-5 AC1,AC2 | dimensão: input validation | Design | Pending |
| ENT-09 | P1-5 AC3 | dimensão: failure | Design | Pending |
| ENT-10 | P1-2 AC5 / edge | dimensão: duplicate | Design | Pending |
| ENT-11 | P1-5 AC4 | AD-004 (degradação) | Design | Pending |
| ENT-12 | P1-5 AC5 | AD-005 (observabilidade) | Design | Pending |
| ENT-13 | P2-1 AC2,AC5 | dimensão: state transition | Design | Pending |
| ENT-14 | P1-3 AC1,AC2,AC3 | T-01 / W-01 / UC-01 | Design | Pending |
| ENT-15 | P1-4 AC1 | A-03 / AD-017 | Design | Pending |
| ENT-16 | P1-4 AC2 | UC-01 (aceite) | Design | Pending |
| ENT-17 | P1-4 AC3,AC4 | RN-24 / A-03 | Design | Pending |
| ENT-18 | P1-4 AC5 | dimensão: concurrency | Design | Pending |
| ENT-19 | P2-2 AC1,AC2,AC3 | AD-013 / FUND-09 | Design | Pending |
| ENT-20 | P2-1 AC1,AC3,AC4 | UC-01 A1 / A-04 | Design | Pending |

**Cobertura:** 20 requisitos · 0 mapeados a tasks (Design pendente) · 0 órfãos.

---

## Porte — revisão pós-Discuss

O roadmap classificou `entrar` como **Médio** (Design inline, Tasks inline). O Discuss elevou para **Grande**, por duas razões, e não por volume de tela:

1. **A guarda de sessão é herdada por sete specs.** O redirect da AD-017 vive em `app_router.dart` e passa a governar toda navegação de `home`, `montar`, `lista`, `galera`, `convite`, `convidado` e `custos`. Escolha herdada por sete specs é decisão de arquitetura — o mesmo argumento que subiu a `fundacao` de Médio para Grande.
2. **A porta de autenticação é herdada igual.** `AuthRepository` e o formato da identidade logada são consumidos por toda tela que precise saber "quem sou eu" — e a AD-016 exige que a porta sobreviva à troca de impl no M2.

Somados ao plug do tema (ENT-01, que toca `lib/app.dart` — arquivo transversal), à tela nas duas plataformas e ao modo cadastro, o corte estimado é de **~11 tasks**, acima do limite de 8 do auto-sizing. **Design e Tasks passam a ser formais.**

---

## Success Criteria

- [ ] `flutter analyze` = zero issues · `flutter test` = 742 de baseline + os novos, todos verdes.
- [ ] Aceite de UC-01 verificável na tela: e-mail e Google presentes, foco vermelho, pós-login sempre na Home.
- [ ] Nenhum literal de cor, fonte ou sombra fora de `core/design_system/` — guard da spec 01 estendido a `lib/app.dart` e `lib/features/entrar/**`.
- [ ] Fechar e reabrir o app com sessão ativa cai direto na Home; `/c/rafa18` abre sem sessão.
- [ ] Emulador do Auth desligado ⇒ a tela abre, o CTA falha com mensagem, o app não trava.
