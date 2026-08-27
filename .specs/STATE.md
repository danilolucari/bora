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

### AD-015
- **Decision**: A autenticação do BORA é **e-mail/senha + Google**. Login por **telefone/SMS sai do produto** — não é adiado, é descartado. O `CLAUDE.md`, que dizia "Auth (Google + telefone)", passa a ser corrigido em vez de obedecido. "CRIAR CONTA" é um **modo alternado da própria tela** `/entrar` (label "CRIAR CONTA", CTA "CRIAR CONTA →", rodapé "Já tem conta? ENTRAR"), sem rota nova.
- **Reason**: T-01, W-01 e o aceite de UC-01 desenham exatamente e-mail/senha + Google, com os inputs "seu e-mail" e "senha" e o botão Google — e não mencionam telefone em lugar nenhum. Obedecer o `CLAUDE.md` exigiria redesenhar duas telas literais e quebrar o aceite de UC-01. A tela desenhada é a que existe. Rota `/criar-conta` foi rejeitada por acrescentar nó ao mapa canônico da AD-003 que nem `04` nem `06` desenham.
- **Trade-off**: quem depende de telefone fica de fora do produto; reabrir exige desenho de tela novo. O modo alternado carrega estado a mais na mesma tela (dois conjuntos de copy, preservação do e-mail entre modos).
- **Scope**: spec 03 `entrar`; e o `CLAUDE.md`, que é corrigido.
- **Date**: 2026-08-25
- **Status**: active

### AD-016
- **Decision**: No M1, **auth é real e dado de festa é em memória**. `FirebaseAuth` contra o emulador (mantendo a AD-004 emulator-first); `FestaRepository` nasce como **porta abstrata** na spec 04 `home`, com implementação em memória semeada pela fixture RN-30. **Firestore entra no M2**, junto com a spec 09 `convidado` — que é quem produz o realtime de RN-28. A Home consome um **`Stream`**, não um `Future`, desde já.
- **Reason**: resolve a zona cinzenta **G8** do roadmap. No M1 não existe produtor de RN-28: fazer models, serialização, streams e o começo de security rules agora seria construir a camada de dados **antes** de RN-22 (papéis) existir, e sem nada para ela transportar. A porta abstrata torna a troca de impl barata, e o `Stream` é o contrato que sobrevive a ela — ler uma vez e desenhar faria o M2 reescrever a Home.
- **Trade-off**: o M2 paga a implementação Firestore inteira de uma vez, e até lá nenhum dado sobrevive a reiniciar o app. Em compensação a suíte de widget do M1 roda **sem emulador ligado**. `flutterfire configure` e o projeto real na nuvem continuam adiados.
- **Scope**: specs 03, 04 e 05 (M1); herdado por `lista`, `galera`, `convite`, `convidado` e `custos`.
- **Date**: 2026-08-25
- **Status**: active

### AD-017
- **Decision**: A navegação passa a ter **guarda de sessão** em `app_router.dart`, via `redirect` do `go_router` observando o estado de autenticação: sem sessão em `/roles/**` → `/entrar`; com sessão em `/entrar` → `/roles`; `/c/:codigo`, `/erro` e `/catalogo` passam **sempre**, com ou sem sessão. A sessão persiste entre aberturas do app.
- **Reason**: o aceite de UC-01 — "pós-login sempre cai na Home" — é literalmente um redirect. E sem guarda, no web basta digitar `/roles` na barra de endereços para entrar sem sessão. As três rotas livres não são exceção arbitrária: `/c/:codigo` é o link do convidado **sem conta** (RN-24), e barrá-lo mataria o diferencial "responde sem baixar nada".
- **Trade-off**: toda spec de tela seguinte herda a guarda e precisa considerá-la nos próprios testes de rota; e o `app_router.dart` ganha dependência do estado de auth, que antes não tinha.
- **Scope**: `lib/core/routing/app_router.dart`; herdado pelas sete specs de tela seguintes.
- **Date**: 2026-08-25
- **Status**: active

### AD-018
- **Decision**: A seção **"PROS FORTES"** (🍸 VODKA · 🍹 CACHAÇA · 🥃 WHISKY) existe **nas duas plataformas**, contrariando o `04-telas-ux.md`, que a marca como web-only. E o seletor **"QUEM LEVA?"** do rail de W-03 fica **fora do M1** — junto com a dica tracejada 💡 que o instrui —, entrando com `galera`/`lista` já no formato popover/sheet que W-03 pede.
- **Reason**: duas leituras do mesmo princípio, o de que o aceite tem de ser alcançável na tela que ele descreve. (a) O exemplo canônico de RN-30 e o aceite de UC-03 incluem cachaça: sem "PROS FORTES" no mobile o total fecharia **R$ 196**, não os **R$ 211** que UC-03 exige, e o aceite ficaria impossível na própria tela. (b) "QUEM LEVA?" depende da lista de confirmados, que só nasce na spec 07; e o próprio W-03 registra o botão que cicla como lacuna a substituir — construí-lo agora seria construir para jogar fora. Sem o botão, a dica 💡 seria instrução falsa.
- **Trade-off**: o mobile ganha uma quarta seção de chips que o protótipo original não tinha, alongando a rolagem de T-03. E o rail do web nasce como leitura pura, sem interação — mais pobre que o protótipo até a spec 07.
- **Scope**: spec 05 `montar`; a atribuição de itens é herdada por `galera` e `lista`.
- **Date**: 2026-08-25
- **Status**: active


### AD-019
- **Decision**: A autenticação mora em **`lib/core/autenticacao/`**, não dentro de `features/entrar/`: a entidade `UsuarioLogado`, o enum `FalhaDeAutenticacao`, a porta `AutenticacaoRepository` (em `dominio/`) e o adaptador `FirebaseAutenticacaoRepository` (em `dados/`), atrás do barrel `autenticacao.dart` como **única porta de entrada** — a mesma forma da AD-008. Nenhuma feature cria a sua; `core/routing` e as features consomem a porta, **nunca** o SDK. `FirebaseAutenticacaoRepository` é o único arquivo do projeto que importa `firebase_auth` fora do bootstrap e do injector.
- **Reason**: três consumidores fora de `entrar` obrigam a subida. (a) `core/routing/app_router.dart` precisa ler a sessão para a guarda da AD-017 — com a porta na feature, `core` importaria `features`, inversão de camada. (b) A spec 04 `home` precisa de `UsuarioLogado.inicial` para o avatar do header (HOME-01 AC2) — com a entidade em `entrar`, `home` importaria de `entrar`, acoplamento feature↔feature que é exatamente o que a organização feature-first evita. (c) A AD-008 já resolveu este caso uma vez para as entidades de cálculo; repetir a forma custa menos que inventar outra. Nome em PT-BR pela regra de idioma do `CLAUDE.md` — `core/calculo` é o precedente de pasta de core em português.
- **Trade-off**: `lib/features/entrar/data/` fica vazio (a feature não tem fonte de dados própria) e `lib/core/` ganha mais uma pasta, ampliando a fronteira de arquivos que a `spec.md` de `entrar` havia fechado — registrado ali como emenda E-1. Em troca, nenhuma feature importa `firebase_auth` e a guarda de rota é testável com duplo, sem emulador.
- **Scope**: `lib/core/autenticacao/`, `lib/core/routing/`, e toda feature que precise saber quem está logado.
- **Date**: 2026-08-25
- **Status**: active

### AD-020
- **Decision**: Navegação decorrente de autenticação é **consequência da guarda de rota, nunca imperativa**. Nenhuma feature chama `context.go`/`context.push` para efeito de login, cadastro ou logout: o repositório autentica, o `Stream` de sessão emite, o `refreshListenable` do `go_router` dispara e o `redirect` da AD-017 decide o destino. Vale como regra de revisão: um `context.go` para destino de sessão em código de feature é desvio, não estilo.
- **Reason**: `entrar` tem **três** caminhos que terminam no mesmo lugar — e-mail/senha, Google e cadastro (ENT-06, ENT-14, ENT-20). Com navegação imperativa, o aceite de UC-01 "pós-login sempre cai na Home" vira a mesma linha repetida em três lugares, que podem divergir uma a uma sem que nenhum teste perceba. Como consequência da guarda, o aceite passa a ser propriedade da tabela de rotas: prova-se uma vez, e os três caminhos não têm como discordar. O mesmo mecanismo já é obrigatório para barrar `/roles` sem sessão, então não há mecanismo novo — há um mecanismo a menos.
- **Trade-off**: o destino pós-login deixa de ser legível no ponto do clique — quem lê o bloc não vê para onde o usuário vai, e precisa conhecer a guarda. Mitigado por `guarda_de_sessao.dart` ser função pura em arquivo próprio, com a tabela de destinos num lugar só.
- **Scope**: todas as features; o logout da spec que vier a tê-lo segue a mesma regra.
- **Date**: 2026-08-25
- **Status**: active


### AD-021
- **Decision**: O projeto adota **`mocktail`** em `dev_dependencies` como biblioteca única de duplos para **adaptadores sobre SDK externo** (Firebase Auth agora; Firestore no M2). Ela não substitui os duplos escritos à mão: portas de domínio continuam com fake próprio (`FakeAutenticacaoRepository`, `RecordingAppLogger`), porque esses têm comportamento que a suíte inteira depende de estar correto. `mocktail` entra só onde o colaborador é uma **classe concreta de terceiro** que não dá para instanciar nem estender de forma útil.
- **Reason**: sem ela, testar `FirebaseAutenticacaoRepository` exigiria um gateway abstrato espelhando o SDK 1:1 mais um fake à mão — cerca de 60 linhas de infraestrutura por adaptador, repetidas em cada repositório Firestore do M2. `mocktail` é **livre de codegen** (ao contrário do `mockito`), então a AD-002 — que proíbe `build_runner` e geração de código, não pacotes — segue intacta. É `dev_dependencies`: **nada muda no bundle de produção**.
- **Trade-off**: é a primeira dependência nova desde o M0, e o projeto vinha evitando pacote novo por princípio; além disso, mock de classe concreta de SDK é frágil a upgrade de major do `firebase_auth` — a quebra aparece como teste vermelho, não como bug em produção, que é o lado certo de falhar. A alternativa (gateway à mão) foi considerada e recusada pelo custo repetido no M2.
- **Scope**: `test/` inteiro; todo adaptador sobre SDK externo, presente e futuro.
- **Date**: 2026-08-25
- **Status**: active

### AD-022
- **Decision**: Os contadores "confirmados/pendentes" da Home são **dado da festa** — campos de `ResumoDeFesta` —, nunca derivação da lista de pessoas nomeadas. A divergência de RN-30 (5 nomeados e "4 confirmados/2 pendentes" na mesma frase) mora **inteira no `pendentes`**: `confirmados` coincide com a contagem dos nomeados em toda a spec-fonte (T-05 "5 pessoas · 4 confirmadas", RN-25 "apenas confirmados (4)", T-07 "4 membros", T-08 "4 já confirmaram") e **tem de continuar coincidindo**; `pendentes` não é derivável porque conta também quem recebeu o link (RN-24) e ainda não respondeu, e essa pessoa não é uma `Pessoa` nomeada. O aceite dos contadores é a **transição de RN-28** (`4/2 → 5/1`), não a string estática. A fixture e o teste que afirmam a divergência (`test/fixtures/rn30_estado_inicial_test.dart:88-101`) ficam **intocados**.
- **Reason**: derivar `pendentes` tornaria o produto incapaz de representar o próprio exemplo. T-02 diz que, com uma confirmação nova, a Home lê "5 confirmados · 1 pendente" — sob derivação, quando Duda confirmasse o pendente iria a zero e o literal da transição ficaria impossível de renderizar. Só fecha se existir convidado sem nome, que é exatamente o que o link de RN-24 produz. Contador em campo é também o formato que sobrevive à troca de impl do M2 (AD-016): derivar significaria ler a subcoleção de pessoas só para pintar o card da Home. E a transição é o que **discrimina** — a string estática "4 confirmados · 2 pendentes" passa igual numa implementação derivada errada, então ela sozinha não é aceite.
- **Trade-off**: Home e Galera passam a poder divergir sem que nada impeça, e o "+N" tracejado agrava — `excedenteDeAvatares` calcula `confirmados − visíveis`, então contador fora de sincronia com `iniciais` mente também no avatar. No M1 não há mitigação possível: não existe produtor de RSVP. A obrigação recai na spec 09 `convidado` — **quem grava o RSVP atualiza o contador na mesma escrita**, que é o que RN-28 já manda. A alternativa híbrida (`confirmados` derivado, `pendentes` dado) foi considerada e recusada: exigiria a Home carregar a lista inteira de pessoas só para contar, e no M2 viraria leitura de subcoleção por card.
- **Scope**: `home` agora; `galera` e `convidado` herdam — nenhuma pode invocar esta AD para justificar um `confirmados` que discorde de T-05.
- **Date**: 2026-08-26
- **Status**: active

### AD-023
- **Decision**: Os preços de RN-11 ("média de N mercados perto de você") são uma **tabela curada em Dart puro**, não dado vivo. A tabela do arquivo 03 (média, mín, máx e nº de fontes por item) entra como fixture tipada em `core/calculo`, sobre a entidade `PrecoDeMercado` que a AD-008 já colocou lá. **Não há geolocalização nem consulta**: "perto de você" e "média de N mercados" são copy literal da spec, e o `N` do rótulo vem da coluna "Fontes" da própria tabela.
- **Reason**: Resolve a zona cinzenta **G2**. Não existe fornecedor de preços definido, e a tabela do arquivo 03 já é dado literal — com o total (R$ 286) e a faixa (R$ 234–356) que UC-14 cobra na tela. Curar no código mantém o aceite reproduzível por teste e não antecipa o Firestore, que a AD-016 coloca no M2.
- **Trade-off**: os preços envelhecem e só mudam por deploy, e o rótulo "perto de você" é honesto quanto à origem (mercados reais pesquisados) mas não quanto ao "perto". Trocar por fonte viva depois é substituir a implementação atrás da mesma porta, sem tocar em tela.
- **Scope**: spec 06 `lista` (UC-14, RN-11); `montar` consome no rail do web.
- **Date**: 2026-08-27
- **Status**: active

### AD-024
- **Decision**: O pedido por delivery de RN-27/UC-16 é **implementado inteiro** — sheet com endereço trocável, três parceiros com ETA e frete, subtotal + frete = total, overlay "PEDIDO A CAMINHO! 🛵" e a despesa entrando no acerto por RN-20 — **atrás de uma porta abstrata de pedido**, cujo único adaptador do MVP é falso: nenhuma chamada de rede, nenhum pedido real. A copy de T-04 fica **literal**, sem selo de "simulado".
- **Reason**: Resolve **G3**. iFood, Rappi e Zé não expõem API pública de pedido — nenhuma opção disponível entrega o pedido de verdade. Entre as que não entregam, a que preserva o aceite de UC-16 (total = subtotal + frete, Zé com frete grátis) e o de RN-20 (o pedido vira despesa rachada) é o fluxo completo atrás de porta. Quando houver contrato com um parceiro, troca-se o adaptador sem tocar em tela nem em teste de aceite.
- **Trade-off**: a tela afirma "PEDIDO A CAMINHO!" sem pedido a caminho. Decisão consciente do usuário em 2026-08-27 — o selo "simulado" foi oferecido e recusado por alterar copy literal. Enquanto o adaptador for falso, **o produto não vai a público com essa tela ativa** sem revisão desta AD.
- **Scope**: spec 06 `lista` (UC-16, RN-27); spec 10 `custos` recebe a despesa gerada.
- **Date**: 2026-08-27
- **Status**: active

### AD-025
- **Decision**: "Grupo" e "enquete" de RN-25/RN-26 são **estado do BORA**, não objetos do WhatsApp. "CRIAR GRUPO" cria no BORA um grupo com o nome da festa contendo **apenas os confirmados** (RN-25) e vira chip irreversível; as três enquetes de RN-26 vivem no BORA, com um voto por enquete por pessoa, trocável, e `%` calculado lá; "POSTAR ENQUETE NO GRUPO 📲" e "ENVIAR NO WHATSAPP →" saem por **share sheet / `wa.me`**, levando o texto montado. A trava "CRIE O GRUPO PRIMEIRO ☝️" passa a valer sobre o grupo do BORA. Toasts e estados seguem RN-29, literais.
- **Reason**: Resolve **G4**. A API pública do WhatsApp não cria grupo nem posta enquete, e a Cloud API — número comercial, aprovação da Meta, custo por conversa — também não cria nenhum dos dois. Com grupo e enquete como estado próprio, todo o comportamento de UC-17/UC-18 (ação única e persistente, voto trocável, percentuais somando ~100, trava sem grupo) fica verdadeiro e testável, e o WhatsApp recebe o que de fato aceita: texto por link.
- **Trade-off**: o chip "✅ '<nome>' · N membros" descreve um grupo que não existe no WhatsApp do usuário — a copy de RN-25 promete mais do que o produto faz. Mesma ressalva de exposição pública da AD-024.
- **Scope**: spec 08 `convite` (T-06, T-07, UC-07, UC-17, UC-18).
- **Date**: 2026-08-27
- **Status**: active

### AD-026
- **Decision**: O link público `bora.app/c/<codigo>` é **perpétuo** — sem expiração e sem revogação. O papel de RN-23 é lido **no instante da abertura** (aceite literal de UC-13): trocar o nível no segmented não altera o papel de quem já entrou. A identidade do convidado sem conta é o **uid da auth anônima do Firebase, persistido no dispositivo** — o mesmo aparelho volta como a mesma pessoa (é o que faz "MUDEI DE IDEIA ✊" de UC-10 funcionar), outro aparelho é outra pessoa.
- **Reason**: Resolve **G5**. Nem T-05 nem W-04 desenham controle de revogação ou de expiração; inventá-los seria UI fora da spec-fonte num produto de copy literal. Expiração automática quebraria tanto o retorno tardio de UC-10 quanto o acesso do convidado ao acerto pós-festa.
- **Trade-off**: quem repassa o link dá o mesmo papel a um desconhecido, e não há como cortar o acesso sem trocar o código da festa; limpar os dados do navegador faz o convidado voltar como pessoa nova, duplicando o RSVP. As security rules do Firestore assumem "qualquer portador do código, com o papel vigente na abertura" como modelo de ameaça **aceito**, não como falha.
- **Scope**: spec 09 `convidado` (RN-23, RN-24, security rules); spec 07 `galera` configura o nível.
- **Date**: 2026-08-27
- **Status**: active

### AD-027
- **Decision**: No MVP, **despesa não se cria à mão**. Toda `Despesa` nasce de uma das três fontes que já existem: o que o convidado assume em "EU LEVO" (RN-20), o pedido por delivery (RN-27 / AD-024, lançado no nome de quem pediu) e o que o anfitrião assume na lista. **T-09 não ganha "+ DESPESA"** e UC-19 continua sendo só leitura, exatamente como a spec-fonte o escreve.
- **Reason**: Resolve **G6a**. Nenhum arquivo da spec-fonte desenha tela de criação de despesa — inventá-la seria layout e copy nossos num produto onde a copy é literal. As três fontes existentes já produzem o Teste B de RN-16 (total 380 → cota 95), que é o aceite de UC-19 e UC-20.
- **Trade-off**: gasto fora da lista — uber, gás, aluguel de churrasqueira — não tem onde entrar, e o acerto fica incompleto para festas reais. É lacuna declarada do MVP, candidata a spec própria, não descuido.
- **Scope**: spec 10 `custos` (UC-19); specs 06 `lista` e 09 `convidado` como origens.
- **Date**: 2026-08-27
- **Status**: active

### AD-028
- **Decision**: "COBRAR NO PIX 📲", "COBRAR PENDENTES NO PIX 📲" e "LEMBRAR TODO MUNDO 📲" são **aviso mais mudança de estado**, não movimentação financeira: a linha passa a COBRADO ✓, o progresso de RN-18 atualiza e o devedor é notificado. **Nenhuma chave Pix é cadastrada, nenhum BR Code é gerado, nenhum app de banco é aberto.** O segmented PIX / CARTÃO / DINHEIRO de RN-19 é **etiqueta** das linhas de acerto, não meio de execução.
- **Reason**: Resolve **G6b**. É exatamente o que T-09 e RN-19 descrevem, e o aceite de UC-23 é "linhas pagas nunca são cobradas" — não "o dinheiro chegou". Pix copia-e-cola exigiria um campo "chave Pix" por pessoa que a spec não tem, e deep link de banco não tem padrão confiável em Android/iOS.
- **Trade-off**: quem marca PAGO ✓ está declarando, não comprovando — o app confia no combinado da galera. É coerente com a promessa do produto ("é isso que evita a treta"), que organiza o racha e não intermedeia pagamento.
- **Scope**: spec 10 `custos` (RN-19, UC-21, UC-22, UC-23).
- **Date**: 2026-08-27
- **Status**: active


## Handoff

> **SNAPSHOT — 2026-08-26.** Spec 04 `home` com Execute concluído e Verifier **PASS**.
> O que está abaixo de "Histórico — sessão do M0" é história, não estado corrente.

### Onde parou

**Spec 04 `home` — COMPLETA, validada e mergeada na `main`.** Branch `feature/home`, nascida
de `feature/entrar` porque a 04 depende da porta de sessão e da guarda dela. **31
commits.**

| | |
|---|---|
| Testes | **1137 verdes** (baseline da spec 03: 947 · **+190**) |
| `flutter analyze` | zero issues |
| Verifier | **PASS** na 3ª iteração — **19/19** requisitos com evidência que discrimina |
| Sensor | 3 rodadas · **37 mutações, 32 mortas**, 0 sobreviventes não explicados |
| `code-review` | 2 rodadas · 27 achados · 17 defeitos reais fechados com regressão |
| Relatório | `.specs/features/home/validation.md` — 752 linhas, as 3 iterações preservadas |

**16 tasks executadas**: as 13 planejadas mais **T3a** (`BoraAvatar` aceita par de cores),
**T4a** (`MarcaBora` promovida a `BoraMarca` com `.header()`) e **T9a** (`ResumoDeFesta`
ganha `id`). As três nasceram do mesmo padrão: a tela precisava de algo que o design system
ou o domínio não tinham.

### Conferência visual — W-02 feita, T-02 **não**

**W-02 conferida e aprovada** (2026-08-26). Build web com um entrypoint de demo
descartável — semeando sessão e festas pelos pontos de injeção que
`configureDependencies` já expõe, sem Firebase —, servido local e capturado em headless a
1180×800 e a 900×820. Nos dois tamanhos a tela bate com a spec: header com logo, ação e
avatar amarelo; título e subtítulo na mesma linha; grid de duas colunas; ARQUIVO com os
valores em vermelho. O entrypoint foi **apagado**, não commitado.

**Ela pagou por si já na primeira captura**: "+ CONVIDAR" renderizava como um retângulo
preto sólido, com o rótulo invisível. O default transparente do `BoraSecondaryButton`
deixa a sombra dura de §4 aparecer **através** do botão. A suíte inteira passava, porque a
asserção era `find.text('+ CONVIDAR')` e o texto estava lá — faltava contraste, que teste
de widget não vê. Corrigido em `a88fec4`, com teste que mata o defeito.

**T-02 continua sem conferência.** A captura a 390×820 sai com o conteúdo cortado à
direita, e **não foi possível decidir se é defeito ou artefato**: a mesma página a 900
renderiza exata, o Flutter não pinta faixa de overflow nenhuma na imagem (o que aponta
para recorte da captura, provavelmente o piso de largura de janela do Chrome), e a
hipótese do `<meta name="viewport">` ausente foi **testada e refutada** — injetá-lo não
mudou um pixel. Fica aberto, e é a primeira coisa a resolver: ou com emulador Android de
verdade, ou com CDP/device emulation em vez de `--window-size`.

Junto disso seguem sem conferência **T-01 e W-01**, da spec 03.

### Observação para o design system, fora da fronteira desta spec

O default transparente do `BoraSecondaryButton` combinado com a sombra dura de §4 produz o
retângulo preto sobre **qualquer** fundo claro, não só no card da Home. Quem for mexer no
componente decide se o default deve virar branco; aqui foi resolvido escolhendo a variante
que §5 já oferece.

### Estado do M1, spec a spec

| Spec | Specify | Design | Tasks | Execute | Verifier |
|---|---|---|---|---|---|
| 03 `entrar` | ✅ | ✅ | ✅ 16 tasks | ✅ | ✅ **PASS** |
| 04 `home` | ✅ | ✅ | ✅ 16 tasks | ✅ | ✅ **PASS** |
| 05 `montar` | ✅ | ⬜ **próximo passo** | ⬜ | ⬜ | ⬜ |
| 06 `lista` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |

`montar` tem `spec.md` e `context.md` prontos — **falta o `design.md`**. `lista` nunca foi
especificada e segue com as premissas G2/G3 registradas, por decisão do usuário.

### As duas specs estão mergeadas na `main`

Por decisão do usuário em 2026-08-26, as duas entraram por **merge local** em vez de PR — o
`gh` CLI não está instalado nesta máquina. Na ordem da dependência, e com `--no-ff`, como os
merges do M0:

- `582f63e merge(entrar): integra a tela de entrar na main` — 947 testes na `main`
- `34eb1dc merge(home): integra o painel de rolês na main` — **1137 testes na `main`**

As branches `feature/entrar` e `feature/home` continuam existindo e apontam para o que foi
mergeado. **A `main` local está à frente de `origin/main` e não foi empurrada.**

### Pendências declaradas que o M1 carrega adiante

Numeradas como o Verifier as deixou no `validation.md`:

1. **D-1 · avatares de 40px de W-02.** `BoraStackedAvatars` é fixo nos 34px de §5, e os
   outros três degraus do web (sombra 8px, padding 28px, título 38px) já estão aplicados.
   **Não é imprecisão de spec** — W-02 define os 40px com precisão. É requisito deferido de
   HOME-05, e precisa de emenda de fronteira no design system.
2. **D-2 · seis spec-precision gaps abertos** — ls do logo do header, "primário compacto",
   botão voltar "quando aplicável", emoji do ARQUIVO, cor dos avatares da pilha, copy da
   falha da Home. Todos legítimos: é a spec que não define, e cada um está declarado no
   arquivo que o carrega.
3. **D-3 · contrato de igualdade de `HomeState`** — `comConfirmacaoNova` não tem teste
   direto; hoje é inseparável das listas pela lógica do bloc. É o maior risco da lista.
4. **D-5 · o custo declarado da AD-022** — deriva entre o contador da Home e os nomeados da
   Galera, com o "+N" junto. Dono: spec 09 `convidado`, que grava contador e RSVP na mesma
   escrita.
5. **D-6 · `rotaAtual()` usa estado global de módulo** em `app_de_teste.dart`, isolado por
   `addTearDown`. Vira problema só com testes concorrentes no mesmo isolate.
6. **D-7 · semente vazia em produção** (AD-016) — ver o obstáculo da conferência visual.
7. Da spec 03, ainda aberta: **o código de cancelamento do Google nunca foi capturado
   empiricamente**. O `firebase` CLI está instalado (15.28.1) e o project id é `bora-87050`.

### O padrão que o sensor achou três vezes — vale mirar primeiro na spec 05

**Defesa escrita e documentada no código, nunca exercida por teste, porque a fixture já
satisfazia a condição que ela protege.** Aconteceu com o teto da pilha de avatares (a
fixture já cortava em 3), com o `SafeArea` (nenhum teste definia inset) e com a cópia
defensiva de `emitir` (só a da semente tinha teste). Nas três rodadas foi o alvo mais
produtivo do sensor.

Um segundo padrão, das duas rodadas de `code-review`: **asserção que confere o objeto
errado** — `Text.style` em vez dos spans, `getRect` do widget em vez do texto pintado,
`findsOneWidget` sem `skipOffstage` numa tela empilhada. Todas passavam com o defeito
presente.

### Correção de registro

O `tasks.md` de `home` afirmava que os sete achados do primeiro `code-review` foram fechados
"cada um com teste de regressão que falha sem a correção". O Verifier conferiu e mostrou que
**para os dois de `SafeArea`/inset isso era falso**. A frase foi corrigida no lugar onde
estava, dizendo o que era falso e quando a rede passou a existir.

### Combinados que seguem valendo

- **Um PR por spec**, não por fase interna.
- Execução das tasks **inline**; **Verifier como sub-agente**; `code-review` ao fim de cada
  batch; skill `run` nas tasks de tela.
- Bloqueio de acesso: tentar emular/simular local; se não der, **pular e anotar no relatório
  final** — não travar.
- Cota: `python .claude/scripts/cota.py` ao fim de cada task e em fronteira de fase.
- **Confira o exit code do `flutter test` explicitamente.** `flutter test | tail` engole o
  código de saída, e isso já produziu um commit com o gate vermelho nesta sessão.
- **Arquivo markdown longo em português vai pela ferramenta Write, não por heredoc** — o
  heredoc estoura em conteúdo com acento, crase e aspas. Custou duas falhas aqui e uma no
  sub-agente.

### Como retomar

```bash
export PATH="$PATH:/c/SDKs/flutter/bin"
cd /c/repos/lucari/bora
git checkout main && flutter test            # 1137, referência de sanidade
python .claude/scripts/cota.py

# ler, nesta ordem:
#   .specs/features/home/validation.md   (o que o Verifier cobra e o que ficou pendente)
#   .specs/features/montar/spec.md       (o próximo passo é o design.md dele)
#   .specs/ROADMAP.md §2 e §3
```

Ordem obrigatória do que resta no M1: **`montar` (Design → Tasks → Execute → Verifier → PR)**
→ **`lista` (Specify com premissas → Design → Tasks → Execute → Verifier → PR)**.

---
## Histórico — sessão do M0


> **[histórico]** Bloco da sessão do M0, retomada em 2026-08-25.
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

1. ~~**DS-33, a conferência visual.**~~ ✅ **Fechada em 2026-08-25**, nas **duas** plataformas:
   web (Chrome 151, via `-d web-server` em `/catalogo`) e mobile (emulador `Pixel_10`). Validada
   pelo usuário. A evidência deste critério é a conferência humana — golden images ficaram fora
   de escopo e nenhum teste da suíte afirma aparência; o protótipo original nem está no
   repositório, então "parece o protótipo?" só podia ser respondido por quem o viu.

   ⚠️ **Premissa que estava errada, para não se repetir:** este arquivo e o `spec.md` afirmavam
   "não há device nem navegador neste ambiente (risco R-11)". Isso valia na máquina **Linux**
   original e foi herdado por três documentos sem ninguém retestar. **Nesta máquina havia os
   dois.** O critério foi dado como impossível por duas sessões antes de alguém rodar
   `flutter devices`.

   Nota de ambiente: `flutter run -d chrome` **falha** aqui — o Chrome sobe e aceita
   `--remote-debugging-port` (testado com os flags exatos), mas o handshake do debug service do
   `flutter_tools` 3.47.1 não fecha com o Chrome 151. Use `-d web-server`.
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
