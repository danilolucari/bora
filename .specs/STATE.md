# STATE

## Decisions

### AD-001
- **Decision**: A especificação `init-spec` foi decomposta em 11 specs de feature (00 `fundacao`, 01 `design-system`, 02 `calculo`, 03 `entrar`, 04 `home`, 05 `montar`, 06 `lista`, 07 `galera`, 08 `convite`, 09 `convidado`, 10 `custos`), organizadas em 4 marcos (M0 fundação → M1 monta e vê o custo → M2 chama a galera → M3 racha a conta), conforme `.specs/ROADMAP.md`.
- **Reason**: Recorte 1:1 com a estrutura feature-first do CLAUDE.md e com a matriz de rastreabilidade do arquivo 05; `design-system` e `calculo` viram specs próprias porque todas as telas dependem delas e as RN-xx precisam nascer testáveis em Dart puro antes de qualquer UI.
- **Trade-off**: `entrar` e `home` viram features fora da lista original do CLAUDE.md (que não previa onde T-01/T-02 morariam); `convite` fica Complexo por absorver T-06 + T-07 em vez de dividir em duas specs menores.
- **Scope**: todo o projeto — ordem de trabalho, dependências entre specs e cobertura de RN/UC/telas.
- **Date**: 2026-08-12
- **Status**: active

### AD-002
- **Decision**: Navegação com **`go_router`** e injeção de dependência com **`get_it` manual — zero codegen** no projeto (sem `injectable`, sem `auto_route`, sem `build_runner`). Container único em `lib/core/di/injector.dart`: `configureDependencies()` idempotente por flag privada + `resetDependencies()` sobre `GetIt.reset()`.
- **Reason**: `go_router` é do time do Flutter e entrega `errorBuilder`, path params e URL limpa no web sem código nosso; `get_it.reset()` satisfaz FUND-12 direto. Zero codegen mantém o ciclo de teste das dez specs seguintes sem `dart run build_runner` obrigatório.
- **Trade-off**: mais boilerplate de registro manual por feature e navegação por string (não tipada) — aceito em troca de diff limpo e teste sem etapa de geração.
- **Scope**: todas as features; nenhuma cria seu próprio container.
- **Date**: 2026-08-13
- **Status**: active

### AD-003
- **Decision**: Esqueleto de navegação em três zonas — `/entrar`, `/c/:codigo` e `/erro` **fora de qualquer shell**; `ShellRoute` (chrome do app) em volta de `/roles`, `/roles/novo` e `/roles/:festaId/montar`; e, aninhado, `StatefulShellRoute.indexedStack` para as quatro abas permanentes da festa (`/roles/:festaId/{lista,galera,whatsapp,custos}`). Mapa de rotas canônico em `.specs/features/fundacao/design.md`.
- **Reason**: `/c/:codigo` sem auth e sem chrome é estrutural (RN-24: o convidado não tem conta) e caro de retrofitar; o `indexedStack` preserva o estado de cada aba, que é o que as specs 06–10 exigem. Base `/roles` vem de W-R5.
- **Trade-off**: mais estrutura do que a fundação precisa hoje (todas as telas são placeholder); em troca as specs 03–10 só trocam o corpo de `features/<x>/presentation/pages/<x>_page.dart` sem tocar em `app_router.dart`.
- **Scope**: todas as specs de tela.
- **Date**: 2026-08-13
- **Status**: active

### AD-004
- **Decision**: Firebase **emulator-first com opções sintéticas**: `FirebaseOptions` de projeto `demo-bora` escritas à mão (sem `flutterfire configure`), emuladores declarados em `firebase.json` e cruzados por teste com as constantes de `EmulatorConfig` (host `10.0.2.2` no emulador Android, `localhost` no resto). Em **release sem** `--dart-define=BORA_FIREBASE_PROJECT_ID` real, `FirebaseEnvironment.resolve` lança `StateError` explícito. Falha do Firebase ou do emulador é **degradação**: o app abre e o erro vai para o logger global.
- **Reason**: mantém toda a fundação verificável offline, sem credencial e sem custo (context.md), e evita que um build de release alcance silenciosamente um projeto inexistente.
- **Trade-off**: projeto `demo-` com FlutterFire é área de atrito conhecido no nativo (flutterfire#9507, #12965) e não pôde ser verificado sem SDK — a task de Firebase verifica empiricamente em mobile e web antes de seguir; se o SDK nativo rejeitar, o fallback (opções reais por `--dart-define`) contraria o emulator-first e volta como decisão do usuário.
- **Scope**: todo acesso a Auth/Firestore até a feature que primeiro precisar publicar.
- **Date**: 2026-08-13
- **Status**: active

### AD-005
- **Decision**: Observabilidade atrás de uma interface própria — `AppLogger` (`logEvent` / `logError`) com `DebugAppLogger` em produção e duplo de gravação em teste; `AppBlocObserver` e `installGlobalErrorHandlers` (`FlutterError.onError` + `platformDispatcher.onError`, sem `runZonedGuarded`) escrevem **só** nela. A instalação acontece logo após o binding, antes do Firebase.
- **Reason**: sem a interface, "o observador registrou" não é afirmável em teste — e FUND-13/14/17 dependem exatamente dessa afirmação. Armar os handlers antes do Firebase é o que torna a queda do emulador observável.
- **Trade-off**: uma indireção a mais em vez de `print`/`debugPrint` direto.
- **Scope**: todo log de bloc e todo erro não capturado do app.
- **Date**: 2026-08-13
- **Status**: active

### AD-006
- **Decision**: `entrar` e `home` existem como **features próprias** em `lib/features/`, ao lado das seis do CLAUDE.md (`montar`, `lista`, `galera`, `convite`, `convidado`, `custos`) — oito pastas, cada uma com `domain/`, `data/`, `presentation/`.
- **Reason**: materializa em código o recorte do AD-001, que já as tratava como specs 03 e 04.
- **Trade-off**: diverge da lista literal de features do CLAUDE.md (que não dizia onde T-01/T-02 morariam); a alternativa (fundir `home` numa feature `festa`) foi descartada por afastar código e spec.
- **Scope**: árvore de `lib/features/` e o espelho em `test/`.
- **Date**: 2026-08-13
- **Status**: active

### AD-007
- **Decision**: O breakpoint de W-R3 mora em `lib/core/responsive/` (`kCompactBreakpoint = 900.0`, `enum LayoutMode { compact, expanded }`, `layoutModeForWidth`), **não** em `core/design_system/`. Fronteira: `< 900.0` compacto, `>= 900.0` expandido.
- **Reason**: `core/design_system/` é território da spec 01, e o modo de layout precisa ser consumível (e testável) sem depender de tema. O `~900px` do arquivo 06 era prosa; um AC precisa de fronteira única.
- **Trade-off**: mais uma pasta em `core/`; a spec 01 reexporta se quiser tratar o breakpoint como token.
- **Scope**: toda decisão de layout responsivo do produto.
- **Date**: 2026-08-13
- **Status**: active

### AD-008
- **Decision**: As entidades de domínio compartilhadas (`Festa`, `Pessoa`, `ContagemDePessoas`, `ItemDeLista`, `Despesa`, `SaldoDePessoa`, `LinhaDeAcerto`, `PrecoDeMercado` e os enums) vivem em `lib/core/calculo/dominio/`, reexportadas pelo barrel `lib/core/calculo/calculo.dart`, que é a única porta de entrada da camada.
- **Reason**: é a única pasta cujo isolamento Dart puro é policiado por teste (FUND-06); uma `core/dominio/` separada criaria uma segunda pasta "pura" que ninguém varre, e entidade com import de Firestore passaria despercebida.
- **Trade-off**: entidades ficam sob uma pasta chamada "calculo", o que soa mais estreito do que o papel delas.
- **Scope**: todas as features; nenhuma define entidade própria de festa, pessoa ou item.
- **Date**: 2026-08-20
- **Status**: active

### AD-009
- **Decision**: Política única de precisão: aritmética interna em `double` e em reais, sem arredondamento intermediário; dinheiro arredondado **uma única vez**, na formatação (RN-13); totais são `round` da soma exata, nunca soma de valores já arredondados; a quantidade de carne arredonda a 0,1 kg **em gramas** (`(gramas/100).round()/10`); a tolerância de 1 centavo de RN-16 vive só na aritmética. Tudo isolado em `lib/core/calculo/regras/precisao.dart`.
- **Reason**: `(1.15*10).round()` devolve 11 em ponto flutuante binário — daria 1,1 kg e quebraria o R$ 211; e arredondar por item acumula erro em listas grandes, num caso que os testes literais não pegam.
- **Trade-off**: `int` em centavos seria exato, mas RN-03 e RN-09 produzem frações e a tolerância de RN-16 perderia sentido — revisitar se o produto passar a cobrar de verdade via Pix.
- **Scope**: toda aritmética monetária e de quantidade do produto.
- **Date**: 2026-08-20
- **Status**: active

### AD-010
- **Decision**: A contradição de RN-10 resolve pela leitura (a): o total **R$ 271** manda e o parêntese "(22+30+8+15)" do arquivo 03 está errado. Entram no total Carvão 22 + Gelo 30 + Sal 8 = 60; Copos & pratos (15) aparece na lista e fica fora do total. A escolha é um dado declarado — `bool entraNoTotal` em `DefinicaoDeItem` —, não um número embutido.
- **Reason**: (a) é a única consistente em dois números independentes (210,6+60 = 270,6 → R$ 271 e 270,6/6 = 45,1 → ≈R$ 45); (b) daria R$ 286 e ≈R$ 48, contradizendo o "≈R$ 45" da mesma frase. Decidida pelo usuário em 2026-08-20.
- **Trade-off**: um essencial visível na lista e ausente do total é assimétrico; trocar para (b) é virar um booleano, com efeito documentado no doc comment.
- **Scope**: RN-10 e todo total que inclua essenciais.
- **Date**: 2026-08-20
- **Status**: active

### AD-011
- **Decision**: Os tokens do arquivo 02 são **constantes Dart puras** em `lib/core/design_system/tokens/` (`BoraColors`, `BoraTextStyles`, `BoraShadows`, `BoraBorders`, `BoraSpacing`, `BoraMotion`, `BoraAccent`) como fonte da verdade, e `boraTheme()` é um `ThemeData` **derivado** delas — nenhum valor nasce dentro do tema. Sem `ThemeExtension`. `bora_colors.dart` é o único arquivo do projeto autorizado a conter literal de cor e `bora_text_styles.dart` o único com literal de `fontFamily`, ambos policiados por teste de varredura.
- **Reason**: `ThemeData` não tem slot para sombra dura, borda de 2px, `letter-spacing` negativo por papel ou rotação de tag — metade do arquivo 02 ficaria fora dele de qualquer jeito. Constante pura torna o token afirmável em teste unitário sem montar `MaterialApp`, e concentrar os literais em um arquivo por categoria é o que faz a regra "nenhuma cor fora dos tokens" virar varredura simples em vez de revisão humana.
- **Trade-off**: dois lugares para olhar (constante e tema) em vez de um; `ThemeExtension` seria mais idiomático, mas exigiria `copyWith`/`lerp` para um sistema de tema único que não interpola nada.
- **Scope**: toda cor, tipo, forma, sombra e duração de todas as telas.
- **Date**: 2026-08-20
- **Status**: active

### AD-012
- **Decision**: O peso da tipografia é declarado por **`TextStyle.fontWeight`**; `FontVariation` fica **proibida** em todo `lib/`, com a proibição policiada por teste de varredura. Archivo é bundlada como fonte variável única por família, sem descritor `weight:` no `pubspec.yaml`; Archivo Black é família estática separada e sempre usa `FontWeight.w400`.
- **Reason**: a partir do Flutter 3.41 stable (landed 3.39.0-0.0.pre) `FontWeight` ajusta o eixo `wght` internamente, e a doc oficial recomenda **evitar** `FontVariation` para `wght`. Verificado contra o SDK instalado (3.47.0, `engine/src/flutter/lib/ui/text.dart:60`) e medido empiricamente: `FontWeight.w800` e `FontVariation('wght', 800)` produzem largura idêntica (401.4395751953125), enquanto `w400` e `w800` diferem. A premissa inicial do projeto (de que a variável não responderia a `fontWeight`) era verdadeira até o 3.40 e está superada.
- **Trade-off**: o projeto fica preso a Flutter ≥3.41; se o SDK recuar, o teste de equivalência de DS-03 é o que avisa, e a saída seria reintroduzir `FontVariation` revogando este AD.
- **Scope**: toda tipografia do produto.
- **Date**: 2026-08-20
- **Status**: active

### AD-013
- **Decision**: O design system entrega `boraTheme()` pronto e testado, mas **não o aplica no app**: `lib/app.dart` não pertence à spec 01. O catálogo aplica o tema em si mesmo (`Theme(data: boraTheme(), …)`), e quem pluga o tema no `BoraApp` é a **spec 03 `entrar`**. Pelo mesmo motivo, revestir `PlaceholderPage`, `RouteErrorPage`, `AppShell` e `FestaTabsShell` — que a fundação deixou "para a spec 01" — volta para as specs 03/04.
- **Reason**: a spec 01 rodou em worktree paralelo à spec 02 e a fronteira de arquivos era condição de merge limpo. Além disso, revestir o chrome é decidir layout de tela, e o arquivo 02 não especifica o header do app — falta âncora (T-01/T-02) para fazer isso sem inventar.
- **Trade-off**: entre o merge da spec 01 e a spec 03 o app roda sem tema; qualquer tela criada nesse intervalo veria o default do Material.
- **Scope**: `lib/app.dart` e o revestimento do chrome de navegação.
- **Date**: 2026-08-20
- **Status**: active

### AD-014
- **Decision**: O catálogo de componentes é uma **rota interna `/catalogo`** em `lib/core/design_system/catalog/`, registrada em `app_router.dart` fora de qualquer shell, com teste que abre a rota e **afirma o destino** (página presente, `AppShell.chromeKey` ausente). Sem dependência nova (widgetbook/storybook) e sem golden images: a verificação automatizada é asserção de propriedade sobre a árvore renderizada.
- **Reason**: coerente com AD-002 (zero codegen, nada de pacote extra) e roda no app real, em mobile e web, pelo mesmo binário. Golden exigiria carregar fonte em todo teste e rasterização dependente de plataforma, e discrimina pior — um golden diz "mudou um pixel", `expect(borda.width, 2.0)` diz qual valor da spec foi violado.
- **Trade-off**: a página vai no bundle de produção (`bora.app/catalogo`), é página sem dado e sem escrita; esconder atrás de `kDebugMode` é uma linha, registrada e não implementada.
- **Scope**: conferência visual do design system e toda rota nova do projeto (o teste que afirma o destino vira o padrão).
- **Date**: 2026-08-20
- **Status**: active
## Handoff

> **SESSÃO EM ANDAMENTO — retomada em 2026-08-25.**
> Este bloco substitui o handoff de 2026-08-21, que estava **desatualizado**: as branches
> avançaram depois dele. Tudo abaixo foi re-apurado do git e da suíte, não herdado.
>
> Houve uma pausa por volta das 09:05 BRT, registrada aqui numa versão anterior deste
> arquivo, que foi **um alarme falso** — ver "Monitoria de cota" abaixo. O trabalho seguiu.

### Mudança de ambiente

A sessão anterior rodava em **Linux** (`/home/lucari/repo/...`). Esta roda em **Windows**,
`c:\repos\lucari\bora`, Flutter 3.47.1 / Dart 3.13.1 (SDK em `C:\SDKs\flutter`). As
worktrees foram **recriadas a partir do `origin`**:

| Caminho | Branch | Último commit |
|---|---|---|
| `C:/repos/lucari/bora` | `main` | `a659aec` |
| `C:/repos/lucari/bora-calculo` | `feature/calculo` | `62c5537` |
| `C:/repos/lucari/bora-ds` | `feature/design-system` | `bcd156d` |

Os dois arquivos não-commitados que o handoff antigo mandava preservar **não existem aqui**
— ficaram na outra máquina. Nada se perdeu: o trabalho deles já tinha sido commitado e
chegou pelo remote (`3b4d040` o bottom sheet da T30, `62c5537` o `validation.md`).

### Panorama re-apurado

| Spec | Tasks | Testes | Analyze | Estado |
|---|---|---|---|---|
| 02 `calculo` | **28 / 28** | **425** verdes | limpo | Implementação completa. Falta a validação independente. |
| 01 `design-system` | **32 / 32** | **395** verdes | limpo | Implementação completa. Falta a validação independente. |

**As duas specs estão implementadas.** O que resta antes do merge é validação, não código.

### O que esta sessão fez

1. **`fix(design-system)` `179bab0`** — a suíte do DS chegou **vermelha** no Windows:
   `token_purity_guard_test.dart` comparava o path devolvido por `listSync`
   (`lib\core\design_system`) contra a constante escrita com `/`. O teste anti-vácuo — que
   existe justamente para provar que a varredura não passa à toa — falhava, e a guarda se
   declarava vazia numa plataforma e cheia na outra. Normalizado o separador, com sensor
   cobrindo as duas formas de path. **Era bug de teste, não de produto**: as varreduras em si
   usam `endsWith` de nome de arquivo e sempre funcionaram nos dois sistemas.
2. **`feat(design-system)` `bcd156d` — T31, o frame do celular.** 390×820, radius 38, borda
   1px, conteúdo cortado nos cantos; header e rodapé fixos com a área central rolando; sombra
   suave **fora** do recorte. Seção no catálogo e export no barrel. +7 testes (379 → 386). As
   duas allowlists da guarda já nomeavam `bora_phone_frame.dart` desde a fase 2 e seguem verdes.
3. **`feat(design-system)` `4b21801` — T32, o catálogo fechado por completude.** O catálogo e
   o responsivo já vinham da T10; o que faltava era a prova de que **todo** componente tem
   lugar lá dentro. Duas listas de naturezas diferentes de propósito: a de tipos é escrita à
   mão (uma lista derivada da árvore renderizada concordaria com qualquer catálogo, inclusive
   um vazio), e a de arquivos é varrida do disco (componente novo entra sozinho na cobrança do
   barrel). O barrel é cobrado nos dois sentidos. **Verificado por mutação**: removida a seção
   do frame, o teste falha nomeando `BoraPhoneFrame (bora_phone_frame.dart)`; árvore
   restaurada em seguida. +9 testes (386 → **395**).
4. **`docs(design-system)` `18fd815`** — marca T30–T32 no plano. A conferência visual de DS-33
   fica **desmarcada de propósito**: sem device nem navegador aqui, é reportada como **não
   verificada**, não assumida como passada.

### O `validation.md` de `calculo` é um esqueleto vazio

`62c5537` commitou `.specs/features/calculo/validation.md` com **todas as nove seções em
`_(pendente)_`** — e com mensagem de commit em inglês, fora da convenção do projeto. **Não é
uma validação.** O Verifier de `calculo` continua integralmente por fazer.

### O que falta, em ordem

1. **Verifiers das duas specs** — despachados em 2026-08-25 como **agentes novos**, um por
   worktree, rodando em paralelo. Contrato abaixo. O do `design-system` recebeu instrução
   extra: os commits `179bab0` (fix da guarda), `bcd156d` (T31) e `4b21801` (T32) saíram da
   sessão principal, não dos batch workers, e por isso pedem escrutínio redobrado — inclusive
   refazer por conta própria a mutação que a T32 alega ter feito.
2. **Corrigir gaps** dos Verifiers (loop fix→re-verify, máx. 3 iterações antes de escalar).
3. **Merge** de `feature/calculo` e depois `feature/design-system` em `main`. Fronteiras de
   arquivo foram disjuntas — só `design-system` tocou `pubspec.yaml` e `lib/core/routing/`.
4. **Rodar** `.claude/skills/tlc-spec-driven/scripts/lessons.py` com as lições dos Verifiers.
   Candidata desta sessão: *guarda que compara path de filesystem contra constante escrita com
   `/` é verde só no POSIX*.
5. **Atualizar o `ROADMAP.md`**: specs 01 e 02 concluídas, marco **M0** fechado.

**Feito nesta sessão:** os 7 ADs pendentes foram escritos na seção Decisions acima, já
renumerados (`calculo` 008–010, `design-system` 011–014), e `.specs/features/ads-pendentes.md`
foi apagado.

### Decisão pendente do usuário: push

`feature/design-system` está **4 commits à frente** de `origin` (`179bab0`, `bcd156d`,
`4b21801`, `18fd815`) e nada foi enviado — push não foi pedido nesta sessão. Se o trabalho for
retomado em outra máquina, é preciso `git push origin feature/design-system` antes.

### Contrato do Verifier (vale para as duas specs)

Agente **novo**, que não implementou nada. Instruções essenciais:
- **Não aceitar nenhuma alegação dos batch workers**, inclusive os "self-checks de
  discriminação" que eles relataram — self-check de autor não substitui o sensor.
- Re-derivar a cobertura a partir do `spec.md` com **evidence-or-zero**: critério sem
  `file:line` + expressão da asserção conta como **não coberto**.
- **Sensor P0**: ≥10 mutações comportamentais em estado descartável. Protocolo: árvore limpa
  antes de cada uma → editar → rodar → `git checkout -- <arquivo>` **imediato** → `git status`
  conferido entre todas e ao final. Nenhum commit de código, nenhuma mutação deixada para trás.
- **O Verifier não conserta.** Gap vira task ranqueada para outro agente.
- Escrever `.specs/features/<spec>/validation.md` **incrementalmente em disco** (risco de
  limite) e commitá-lo.
- Espelhar o formato de `.specs/features/fundacao/validation.md`.

**Pontos que o Verifier de `calculo` precisa atacar:** os quatro números canônicos
(R$ 211 · ≈R$ 30/cabeça · R$ 271 · ≈R$ 45/adulto), os Testes A e B de RN-16 com **ordem** (e se
a guarda anti-ordenação em `casos_literais_do_arquivo_03_test.dart` discrimina mesmo), a
política de precisão de AD-009 (a armadilha `(1.15*10).round() == 11`), RN-14 (criança fora do
racha; os dois divisores coexistindo), `entraNoTotal` como dado declarado, a cerveja por
`adultos − abstêmios`, a pureza Dart puro, a fixture RN-30 e o barrel como porta única.

**Pontos para o de `design-system`:** os valores literais de §1 e §4 afirmados um a um, o
press-sink (translate 2,2 + sombra 4→2), o toast (1 por vez, 2200 ms, substitui sem empilhar),
as três guardas de varredura (se ainda mordem), a fronteira com `calculo` (DS-27 recebe a
fração pronta e não calcula), e as exceções de radius/blur.

### Pendências manuais (M) — não automatizáveis neste ambiente

- **DS-33** — a conferência visual "parece o protótipo?". Roteiro: `flutter run` e
  `flutter run -d chrome`, abrir `/catalogo`, conferir cada seção contra
  `.specs/init-spec/02-design-system.md`. **Testes verdes provam que cada token tem o valor
  literal da spec; não provam que o conjunto parece certo.**
- **FUND-17 AC4** (herdada da fundação) — a spec nomeia "handler global" mas a implementação
  registra pelo `try/catch` do boot. Diagnóstico em
  `.specs/features/fundacao/validation.md`. **Decisão do usuário, ainda pendente.**

### Decisões do usuário (2026-08-20 / 21)

1. Fontes **bundladas** em `assets/fonts/` (Archivo variável + Archivo Black + OFL), não o
   pacote `google_fonts`.
2. Catálogo de componentes como **rota interna `/catalogo`**, sem dependência nova.
3. **RN-10 leitura (a)**: R$ 271 manda; entram Carvão 22 + Gelo 30 + Sal 8 = 60; Copos & pratos
   aparece na lista e fica **fora** do total. O parêntese "(22+30+8+15)" do arquivo 03 está
   errado.
4. Execução **ponta a ponta**, sem checkpoint de aprovação entre fases.
5. Ao bater no limite de cota, retomar **5 minutos depois** do horário de reset,
   automaticamente.

### Monitoria de cota (montada em 2026-08-25, a pedido do usuário)

**A fonte certa é `~/.claude.json` → `cachedUsageUtilization`** — o mesmo dado que o `/usage`
do Claude Code mostra. Campos que interessam:
`utilization.five_hour.utilization` (% da sessão), `utilization.seven_day.utilization`
(% da semana), `five_hour.resets_at` e `fetchedAtMs`. O próprio Claude Code reescreve esse
cache enquanto a sessão está ativa.

- `scratchpad/monitor-cota.sh` lê esse cache a cada **5 min**.
- Silencioso por padrão; avisa ao cruzar **50/70/80%** e dispara `ALERTA-COTA-85` quando a
  sessão **ou** a semana passam de 85%.
- Dois guardas contra falso-verde: grita se não conseguir ler o cache 3× seguidas, e grita se
  o `fetchedAtMs` ficar parado por mais de 30 min — número velho repetido para sempre parece
  "tudo bem" e não é.
- Log em `scratchpad/cota.log`, último status em `cota-status.json`.
- **A monitoria é da sessão, não do repositório**: quem retomar precisa rearmá-la.

#### O alarme falso de 09:05 — não repetir

A primeira versão do monitor estimava a cota com **`ccusage`**, somando os tokens do bloco de
5h e dividindo pelo **maior bloco já visto no histórico local**. As duas pontas estavam
erradas:

1. `ccusage` soma `cacheReadInputTokens`, que cresce a cada turno porque o contexto inteiro é
   relido — o número infla rápido e não é o que a cota mede.
2. O denominador "maior bloco já observado" **satura em 100% por construção** assim que o
   bloco atual vira o maior. Foi o que aconteceu: o monitor gritou "100%" quando o `/usage`
   real marcava **18%**.

O trabalho chegou a ser pausado por causa disso. **`ccusage` não enxerga o limite da conta e
não serve para esta medida** — use `cachedUsageUtilization`.

### Estado da cota

Medido em 2026-08-25 11:10 BRT, pela fonte certa: **sessão em 18%**, **semana em 3%**.
Reset da janela de 5h: **2026-08-25 13:50 BRT** (16:50 UTC); reset semanal: 30/08 06:00 BRT.
Há folga larga — não há motivo para pausar.

### Pergunta aberta, sem bloquear

Premissa **A-16** de `calculo`: `progressoDeQuitacao` **sem nenhuma linha** devolve `1.0`
(barra cheia). Está implementado e testado assim, com doc comment registrando que `0.0` seria
defensável. A spec `custos` pode trocar em uma linha.

### Como retomar

```bash
export PATH="$PATH:/c/SDKs/flutter/bin"
git worktree list
cd /c/repos/lucari/bora-calculo && flutter test   # 425
cd /c/repos/lucari/bora-ds     && flutter test   # 386
# o que já fechou está em .specs/features/<spec>/tasks.md
# os 7 ADs esperando merge: .specs/features/ads-pendentes.md
```

### Histórico de interrupções — o que funcionou

A cota estourou **quatro vezes** em 2026-08-20/21. Em 2026-08-25 houve uma quinta pausa, mas
por **alarme falso** do monitor — ver "Monitoria de cota".
**Perda acumulada de trabalho: praticamente zero.** O que fez isso funcionar:

1. **Commit atômico ao fim de cada task**, antes de a próxima começar — limita a perda a uma
   task, sem depender de prever o limite.
2. **Conferir o portão antes de retomar.** O estado do trabalho meio-escrito varia: 3× estava
   íntegro e verde, 1× não compilava. E o handoff pode estar velho: desta vez as branches
   tinham avançado além do que ele dizia.
3. **Retomar por mensagem, nunca por agente novo** — o transcript preserva o contexto e custa
   muito menos que recomeçar frio.
4. **Não abrir task que não cabe no que resta de cota.** Melhor parar com o plano preciso do
   que deixar meia task no disco.
