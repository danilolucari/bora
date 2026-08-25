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
- **Reason**: arredondar por item acumula erro em listas grandes — um caso que os testes literais do arquivo 03 **não** pegam, porque o estado padrão tem poucos itens. Arredondar uma única vez, na formatação, é o que mantém o total igual ao `round` da soma exata.
- **Correção de 2026-08-25**: a justificativa original desta decisão citava `(1.15*10).round() == 11` como armadilha de ponto flutuante. **É factualmente falsa.** Em Dart `1.15 * 10` dá exatamente `11.5` (`== 11.5` é `true`) e `.round()` devolve **12**. E uma varredura de 2.000.001 pontos (0–20 kg, passo de 0,01 g) não achou **nenhuma** divergência entre arredondar em gramas e arredondar em kg. Apurado pelo Verifier independente de `calculo` e reconfirmado empiricamente. A decisão continua válida pelo motivo acima; o arredondamento da carne em gramas é **defensivo**, não corretivo — e o teste que o cobre não pode prometer proteção contra um erro de float que não existe.
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
| 02 `calculo` | **28 / 28** | **436** verdes | limpo | Implementada **e validada**. Gaps do Verifier corrigidos. |
| 01 `design-system` | **32 / 32** | **398** verdes | limpo | Implementada **e validada**. Gaps do Verifier corrigidos. |

**As duas specs estão prontas para o merge.** Não há código pendente.

### Rodada de verificação independente (2026-08-25)

Dois Verifiers novos, um por worktree, autor ≠ verificador em ambos. Os dois deram **PASS com
ressalvas**, e nenhuma ressalva bloqueava o merge.

| | `calculo` | `design-system` |
|---|---|---|
| Critérios sem evidência | **1 de 60** | **0 de 35** |
| Mutações mortas | **15 de 17** | **21 de 23** |
| Relatório | `.specs/features/calculo/validation.md` (`53a84f4`) | `.specs/features/design-system/validation.md` (`ccf6c03`) |

**Todos os gaps acionáveis foram corrigidos**, cada um com mutação confirmando que o teste novo
morde:

- **`a5932d9`** (ds) — as duas mutações sobreviventes apontavam o mesmo defeito de desenho: as
  allowlists liberavam **arquivo**, e §3 autoriza **forma**. Uma segunda sombra com blur entrava
  em `bora_shadows.dart` com a suíte verde, e `BorderRadius.circular(8)` passava dentro do
  avatar. Agora a unicidade da sombra é afirmada por **contagem**, e a exceção de forma remove o
  literal exato antes de varrer — o que sobra é sempre violação.
- **`0fc8dfb`** (ds) — `BoraHeroCard` copiava a distância da sombra em vez de ler o token; o
  teste batia num literal, e literal no teste concorda com literal no componente.
- **`40a3ab8`** (calculo) — `ComposicaoDaFesta` e `PrecoDeMercado` ganharam `==`/`hashCode`
  (P1-2 AC2, o único critério sem evidência). A composição é a primeira entidade com coleção, e
  `==` de `List`/`Set`/`Map` em Dart é identidade: comparadores profundos escritos à mão, porque
  `package:collection` é dependência nova (A-19) e `flutter/foundation` está fora (CALC-27).
- **`da61385`** (calculo) — o credor **sub-centavo na frente da fila** não tinha teste: trocar a
  tolerância por `> 0` deixava a suíte inteira verde emitindo uma linha fantasma de R$ 0,005. E
  o doc do barrel reivindicava RN-01..RN-29 quando dez delas têm dono fora da camada.

**Achado que mais valeu a rodada:** o Verifier de `calculo` mostrou que a **justificativa** do
AD-009 era factualmente falsa — corrigida em `b9e83d5`, ver o próprio AD. O AD tinha acabado de
ser gravado no `STATE.md` e teria virado folclore permanente.

**Único gap não corrigível:** o commit `62c5537` está fora da convenção (assunto em inglês,
`feat` para doc, sem `RN-xx` no corpo) — é histórico, e reescrevê-lo custa mais do que vale.

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

## 🎉 M0 FECHADO — não há trabalho pendente de código

`main` está em **742 testes verdes** com `flutter analyze` limpo, e as duas branches foram
mergeadas sem conflito (`--no-ff`, um merge commit cada). A aritmética fecha e é a prova de que
o merge não perdeu nem duplicou nada: **92** da `fundacao` + **344** de `calculo` + **306** de
`design-system` = **742**.

Tudo o que a lista de pendências desta sessão pedia foi feito:

- ✅ Verifiers independentes das duas specs, gaps corrigidos com mutação confirmando cada fix
- ✅ 7 ADs pendentes escritos em Decisions e `ads-pendentes.md` apagado
- ✅ Merge de `feature/calculo` e `feature/design-system` em `main`, com a suíte inteira verde
- ✅ 6 lições registradas no `lessons.py` (L-006..L-011)
- ✅ `ROADMAP.md` atualizado: specs 01 e 02 concluídas, **M0 fechado**

### O que fica em aberto — e não é código

1. **DS-33, a conferência visual — metade feita.** O **web foi validado pelo usuário em
   2026-08-25** (Chrome 151, via `flutter run -d web-server` em `/catalogo`); falta o **mobile**.
   Golden images seguem fora de escopo por decisão, então **nenhum teste da suíte afirma
   aparência** — a evidência deste critério é a conferência humana, e é por isso que ela não
   podia ser dada por boa sem acontecer.

   ⚠️ **Premissa corrigida:** este arquivo e o `spec.md` afirmavam "não há device nem navegador
   neste ambiente (risco R-11)". Isso valia na máquina **Linux** original e foi herdado sem
   reteste. **Nesta máquina há os dois**: emulador `Pixel_10` disponível e `android/` no repo.
   A metade mobile é executável e continua cobrada.

   Nota de ambiente: `flutter run -d chrome` **falha** aqui — o Chrome sobe e aceita
   `--remote-debugging-port` (testado com os flags exatos), mas o handshake do debug service do
   `flutter_tools` 3.47.1 não fecha com o Chrome 151. O contorno é `-d web-server`, que para
   conferência visual é mais fiel: renderiza no navegador real do usuário.
2. **FUND-17 AC4**, herdado da fundação — a spec nomeia "handler global" mas a implementação
   registra pelo `try/catch` do boot. Diagnóstico em `.specs/features/fundacao/validation.md`.
   **Decisão do usuário.**
3. **Premissa A-16 de `calculo`** — `progressoDeQuitacao` sem nenhuma linha devolve `1.0`. A
   spec `custos` pode trocar em uma linha.
4. **`62c5537`** está fora da convenção de commit (assunto em inglês, `feat` para doc, sem
   `RN-xx` no corpo). É histórico; reescrever custa mais do que vale.

### Próximo marco: M1 — monta e vê o custo

As specs de M1 são **03 `entrar`**, **04 `home`** e **05 `montar`**, nesta ordem de dependência.
Duas coisas que M0 deliberadamente deixou para elas, registradas em **AD-013**: plugar
`boraTheme()` no `BoraApp` (`lib/app.dart` ficou fora da spec 01) e revestir `PlaceholderPage`,
`RouteErrorPage`, `AppShell` e `FestaTabsShell`. Até isso acontecer, o app roda sem tema.

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

**Sessão pausada em 85%** (semana em 10%), pelo gatilho combinado com o usuário. Desta vez o
alerta veio da fonte certa e é confiável — diferente do alarme falso das 09:05.

- **Reset da janela de 5h: 2026-08-25 13:50 BRT** (16:49:59 UTC).
- **Retomar às 13:55 BRT.**
- Reset semanal: 30/08, 06:00 BRT.

Nada ficou pela metade: o último commit (`0fc8dfb`) fechou com 398 testes verdes e árvore
limpa nas três worktrees.

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
