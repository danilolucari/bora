# Fundação — Specification

**ID prefix:** `FUND` · **Porte:** Grande (revisado — o roadmap previa Médio; ver §Porte)
**Contexto de decisões:** `.specs/features/fundacao/context.md`
**Roadmap:** `.specs/ROADMAP.md` — spec 00, marco M0

## Problem Statement

O repositório não tem código: só a especificação em `.specs/init-spec/` e a skill. Nenhuma das dez specs seguintes pode ser implementada, e nenhum critério de aceite pode ser verificado, porque não existe projeto que compile nem portão de teste que rode. A fundação cria esse chão — o esqueleto executável onde `design-system`, `calculo` e as features de tela vão nascer, com as convenções do CLAUDE.md já materializadas em vez de descritas.

## Goals

- [ ] `flutter run` sobe o app em **mobile e web** a partir de um clone limpo, seguindo só o README.
- [ ] `flutter analyze` termina com **zero issues** e `flutter test` executa e passa — o portão de aceite das specs seguintes existe e é observável.
- [ ] A estrutura de pastas do CLAUDE.md existe de fato, e o isolamento de `core/calculo/` (sem Flutter, sem Firebase) é **garantido por teste**, não por convenção.
- [ ] Toda rota do mapa de telas responde, incluindo a pública `/c/:codigo`, sem que nenhuma tela de produto exista ainda.
- [ ] Firebase inicializa contra o Emulator Suite; nenhum critério desta spec depende de rede externa ou credencial.

## Porte — por que Grande e não Médio

O `.specs/ROADMAP.md` classificou a spec 00 como Médio com Design pulado. As respostas do Discuss ampliaram o "pronto" para incluir navegação, DI + BlocObserver, README e espelho de testes — o que leva a ~10 tasks e, mais importante, obriga escolhas (pacote de rotas, container de DI, forma do observador, wiring do emulador) que **toda feature seguinte herda**. Escolha herdada por dez specs é decisão de arquitetura, e é exatamente o que a fase de Design existe para registrar como AD no `STATE.md`. Portanto: **Design não deve ser pulado**, e o roadmap foi atualizado.

## Out of Scope

Explicitamente excluído. Documentado para evitar scope creep.

| Item | Razão |
|---|---|
| Qualquer tela de produto (T-01..T-09, W-01..W-04) | São as specs 03–10. A fundação entrega **placeholders** deliberados. |
| Tokens, tipografia, componentes do arquivo 02 | Spec 01 `design-system`. A fundação não estiliza nada. |
| Qualquer fórmula RN-01..RN-29 | Spec 02 `calculo`. A fundação toca só RN-30, e apenas como dado. |
| Autenticação real (e-mail, Google, telefone, anônima) | Spec 03 `entrar` e spec 09 `convidado`. Aqui só o SDK é inicializado. |
| Projeto Firebase na nuvem, `flutterfire configure`, Hosting, Functions | Adiado para a primeira feature que precise publicar (decisão emulator-first). |
| Instalação/versionamento do SDK Flutter (FVM) | Decisão do usuário: SDK global, instalado à mão, versão registrada no README. |
| Pipeline de CI | CLAUDE.md proíbe criar sem pedido explícito. |
| Modelo de domínio tipado (`Festa`, `Pessoa`, `ItemDeLista`) | Spec 02 `calculo`. A fixture RN-30 nasce como dado bruto para não colidir. |

---

## Pré-condição de ambiente (bloqueante)

**O SDK Flutter/Dart não está instalado nesta máquina** — verificado em 2026-08-12: `flutter`, `dart` e `firebase` ausentes do PATH e sem instalação via FVM, Chocolatey ou Scoop (presentes: Node, Python 3.14, Git, JDK 17). Por decisão do Discuss, instalar o SDK é responsabilidade externa, **não é task desta spec**.

Consequência operacional: o Execute desta spec não pode começar antes de `flutter --version` responder. Como o portão de aceite (`flutter test`) é justamente o que prova as demais specs, esta é a dependência crítica do projeto inteiro.

---

## Assumptions & Open Questions

Toda ambiguidade resolvida ou registrada aqui — nada fica silenciosamente indefinido.

| Assumption / decisão | Default escolhido | Rationale | Confirmado? |
|---|---|---|---|
| SDK Flutter não versionado no repo | Instalado globalmente pelo usuário; versão efetiva anotada no README no scaffold | Decisão explícita do Discuss; README impede que a versão vire folclore | **y** |
| Escopo Firebase da fundação | Emulator-first: SDK + Emulator Suite, sem projeto na nuvem | Mantém a fundação verificável offline e sem credencial | **y** |
| Natureza de RN-30 | Fixture Dart puro em `test/fixtures/`, para teste e demo | RN-30 é estado de protótipo, não conteúdo de produto | **y** |
| Tipos da fixture RN-30 | Dados brutos sem entidades de domínio; spec 02 `calculo` a tipa depois | Evita a fundação inventar `Festa`/`Pessoa` e colidir com a spec 02 | **y** |
| W-R3 diz "abaixo de ~900px" — o `~` não é testável | Breakpoint exato **900.0** px lógicos: `largura < 900` → compacto; `≥ 900` → expandido | Um AC precisa de fronteira única; 900 é o número citado, o `~` era prosa | n |
| Rota base do app | `/roles` para a home (W-R5 cita `bora.app/roles`) | Único valor de URL declarado na spec | n |
| Título da aba no web | `bora — a conta do rolê` (literal de W-R5) | Copy literal da spec, não paráfrase | n |
| Identificador do pacote (applicationId / bundle id) | `app.bora` | Domínio declarado é `bora.app`; convenção de domínio reverso. Trocar antes da primeira publicação é barato, depois não | n |
| Portas do Emulator Suite | Declaradas em `firebase.json`, não fixadas nesta spec | Não fabrico números que não verifiquei; o arquivo é a fonte | n |
| Nome do diretório do projeto Flutter | Raiz do repositório (`c:\repos\lucari\bora`) | CLAUDE.md descreve `lib/` na raiz, sem subpasta de app | n |

**Open questions:** nenhuma — tudo acima está resolvido ou registrado como assumption.

---

## Dimensions Sweep (obrigatório para porte Grande)

Cada dimensão resolve em requisito ou em `N/A porque…`. Sem campo em branco.

| Dimensão | Resolução |
|---|---|
| Input validation & bounds | **FUND-09** — `/c/:codigo` com código malformado e rota desconhecida caem em destino de erro, nunca em tela em branco |
| Failure / partial-failure states | **FUND-17** — Emulator Suite indisponível não impede o app de abrir |
| Idempotency / retry / duplicate handling | **FUND-12** — registrar dependências duas vezes não duplica nem lança; container resetável entre testes |
| Auth boundaries & rate limits | `N/A porque` a fundação não implementa autenticação nem chama API autenticada — só inicializa o SDK. Fronteiras de acesso são das specs 03 `entrar` e 09 `convidado` (security rules) |
| Concurrency / ordering | **FUND-15** — ordem de inicialização determinística (binding → Firebase → emulador → DI → `runApp`); nenhum widget monta antes das dependências existirem |
| Data lifecycle / expiry | `N/A porque` a fundação não persiste dado de produto: a fixture RN-30 é in-memory e o emulador é efêmero por natureza |
| Observability | **FUND-13**, **FUND-14** — BlocObserver global e handler de erro não capturado |
| External-dependency failure | Mesma resolução de **FUND-17**; o Firebase é a única dependência externa e sua queda é degradação, não crash |
| State-transition integrity | `N/A porque` não há máquina de estado de produto na fundação — nenhum BLoC de feature existe ainda. A integridade de transição é de cada spec de feature |

---

## User Stories

### P1-1: Projeto que compila, linta e testa ⭐ MVP

**User Story**: Como desenvolvedor do BORA, quero um projeto Flutter que rode em mobile e web e tenha lint e teste funcionando, para que exista um portão de aceite real onde as specs seguintes possam ser verificadas.

**Why P1**: Sem isto nenhuma outra spec do projeto pode ser executada nem verificada. É a raiz da árvore de dependências.

**Acceptance Criteria**:

1. WHEN `flutter run` é executado num clone limpo com o SDK instalado THEN o sistema SHALL subir o app em **mobile** sem erro de compilação. *(FUND-01)*
2. WHEN `flutter run -d chrome` é executado THEN o sistema SHALL subir o mesmo app em **web** sem erro de compilação, a partir do mesmo `lib/main.dart`. *(FUND-01)*
3. WHEN `flutter analyze` é executado THEN o sistema SHALL reportar **zero issues**, com `flutter_lints` declarado em `pubspec.yaml` e ativo em `analysis_options.yaml`. *(FUND-02)*
4. WHEN `flutter test` é executado THEN o sistema SHALL executar **ao menos um teste** e terminar com todos passando e código de saída 0. *(FUND-03)*

**Independent Test**: clonar, rodar os quatro comandos, observar app na tela e saída verde nos dois últimos.

---

### P1-2: Esqueleto Clean Architecture com isolamento verificado

**User Story**: Como desenvolvedor, quero a estrutura de pastas do CLAUDE.md já criada e o isolamento de `core/calculo/` garantido por teste, para que a fórmula não possa vazar para a UI por descuido.

**Why P1**: O CLAUDE.md diz que `core/calculo/` é Dart puro — é isso que torna as RN-xx testáveis sozinhas. Convenção escrita em documento é violada em silêncio; convenção com teste, não.

**Acceptance Criteria**:

1. WHEN o repositório é inspecionado THEN `lib/` SHALL conter `core/design_system/`, `core/calculo/` e `features/` com as seis features nomeadas no CLAUDE.md (`montar`, `galera`, `lista`, `convite`, `custos`, `convidado`), cada uma com `domain/`, `data/` e `presentation/`. *(FUND-04)*
2. WHEN o repositório é inspecionado THEN `test/` SHALL espelhar a estrutura de `lib/`. *(FUND-05)*
3. WHEN qualquer arquivo sob `lib/core/calculo/` importa `package:flutter/…`, `dart:ui` ou `package:firebase…` THEN a suíte de testes SHALL falhar, apontando o arquivo infrator. *(FUND-06)*
4. WHEN nenhum arquivo sob `lib/core/calculo/` viola a regra acima THEN esse mesmo teste SHALL passar. *(FUND-06)*

**Independent Test**: adicionar `import 'package:flutter/material.dart';` num arquivo de `core/calculo/`, rodar `flutter test`, ver falhar apontando o arquivo; remover, ver passar.

---

### P1-3: Navegação completa com placeholders

**User Story**: Como desenvolvedor, quero todas as rotas do mapa de telas registradas e respondendo com placeholders, para que cada spec de tela só precise trocar o placeholder pela tela real, sem mexer em navegação.

**Why P1**: A rota pública `/c/:codigo` é estrutural — ela vive **fora** do shell autenticado (o convidado não tem conta) e essa separação é difícil de retrofitar depois.

**Acceptance Criteria**:

1. WHEN o app navega para cada rota do mapa de telas (entrar, home, montar, lista, galera, convite/WhatsApp, custos) THEN o sistema SHALL renderizar um placeholder identificável daquela tela, sem erro. *(FUND-07)*
2. WHEN a rota `/c/:codigo` é aberta com um código válido THEN o sistema SHALL renderizar o placeholder do convidado **sem exigir autenticação e sem o shell do app logado**. *(FUND-08)*
3. WHEN uma rota inexistente é aberta THEN o sistema SHALL renderizar um destino de erro legível — nunca tela em branco nem exceção não tratada. *(FUND-09)*
4. WHEN `/c/` é aberta com código vazio ou malformado THEN o sistema SHALL cair no mesmo destino de erro de FUND-09. *(FUND-09)*
5. WHEN o app roda no web THEN a URL do navegador SHALL refletir a rota atual sem `#`, e o título da aba SHALL ser exatamente `bora — a conta do rolê`. *(FUND-10)*
6. WHEN a largura da janela é **menor que 900.0** px lógicos THEN o sistema SHALL expor modo **compacto**; WHEN é **maior ou igual a 900.0** THEN modo **expandido**. *(FUND-11 — mecanismo de W-R3; a aparência é da spec 01)*

**Independent Test**: navegar por cada rota no web observando a URL; redimensionar cruzando 900px e observar a troca de modo; abrir `/rota-que-nao-existe`.

---

### P1-4: Injeção de dependência e observabilidade

**User Story**: Como desenvolvedor, quero DI e um BlocObserver global prontos, para que cada feature seguinte só registre seus próprios blocs e todo erro apareça em vez de sumir.

**Why P1**: Se cada feature inventar seu wiring, o padrão diverge já na segunda. E BLoC sem observador transforma bug de estado em mistério.

**Acceptance Criteria**:

1. WHEN a configuração de dependências é executada duas vezes no mesmo processo THEN o sistema SHALL permanecer consistente — sem exceção e sem registro duplicado. *(FUND-12)*
2. WHEN um teste solicita o reset do container THEN o sistema SHALL devolvê-lo ao estado vazio, permitindo que testes rodem isolados e em qualquer ordem. *(FUND-12)*
3. WHEN qualquer BLoC sofre uma transição de estado THEN o observador global SHALL registrá-la identificando o bloc, o evento e o estado resultante. *(FUND-13)*
4. WHEN qualquer BLoC emite erro THEN o observador global SHALL registrá-lo com a exceção e o stack trace. *(FUND-13)*
5. WHEN uma exceção não capturada ocorre fora de um BLoC THEN o sistema SHALL registrá-la pelo handler global em vez de descartá-la silenciosamente. *(FUND-14)*

**Independent Test**: teste com um bloc de mentira que emite estado e depois lança; verificar que o observador capturou ambos; chamar a configuração de DI duas vezes seguidas.

---

### P1-5: Firebase emulator-first

**User Story**: Como desenvolvedor, quero o Firebase inicializado contra o Emulator Suite, para desenvolver e testar sem credencial, sem projeto na nuvem e sem custo.

**Why P1**: É a decisão que mantém a fundação verificável offline. Também é o wiring que `home` (RN-28 realtime) e `convidado` (link público) vão consumir sem retrabalho.

**Acceptance Criteria**:

1. WHEN o app inicializa THEN o sistema SHALL executar, nesta ordem: binding do Flutter → inicialização do Firebase → apontamento para os emuladores → configuração de DI → `runApp`; e nenhum widget SHALL montar antes de as dependências estarem registradas. *(FUND-15)*
2. WHEN o app roda em modo debug ou sob teste THEN Auth e Firestore SHALL apontar para os emuladores locais declarados em `firebase.json`, nunca para infraestrutura remota. *(FUND-16)*
3. WHEN o app é compilado em release sem configuração de projeto real THEN o sistema SHALL falhar cedo com mensagem explícita, em vez de tentar silenciosamente alcançar um projeto inexistente. *(FUND-16)*
4. WHEN o Emulator Suite está fora do ar na inicialização THEN o app SHALL abrir mesmo assim, registrando o erro de conexão pelo handler global — a indisponibilidade é degradação, não crash. *(FUND-17)*

**Independent Test**: subir os emuladores e abrir o app; derrubá-los e reabrir — o app abre e o erro aparece no log.

---

### P1-6: Fixture do estado inicial (RN-30)

**User Story**: Como desenvolvedor, quero o estado inicial de RN-30 disponível como dado puro, para que testes e demos partam sempre do mesmo churrasco do Rafa.

**Why P1**: Os casos de teste literais do arquivo 03 (R$ 211 / ≈R$ 30 e R$ 271 / ≈R$ 45) partem exatamente deste estado. Uma fixture só é fonte da verdade se nascer antes de quem a consome.

**Acceptance Criteria**:

1. WHEN a fixture é lida THEN ela SHALL reproduzir RN-30 exatamente: festa "CHURRAS DO RAFA 🔥", SÁB 18 JUL, 14H, "Laje do Rafa — Vila Madalena", duração 4h, 5 pessoas nomeadas (4 confirmadas + Duda), 4 confirmados / 2 pendentes na Home, e os itens padrão bovina, frango, pão de alho, refrigerante, água, cerveja e cachaça. *(FUND-18)*
2. WHEN a fixture é compilada THEN ela SHALL ser Dart puro — sem import de Flutter e sem import de Firebase — e SHALL usar dados brutos, sem depender de entidades de domínio (que pertencem à spec 02). *(FUND-19)*

**Independent Test**: teste que lê a fixture e afirma campo a campo contra o texto de RN-30.

---

### P1-7: README de setup

**User Story**: Como pessoa que clona o repositório, quero um README que me faça rodar o projeto sem adivinhação, para não descobrir requisitos de ambiente por tentativa e erro.

**Why P1**: A decisão de não versionar o SDK torna o README a **única** memória da versão exigida. Sem ele, a decisão vira dívida imediata.

**Acceptance Criteria**:

1. WHEN o README é lido THEN ele SHALL documentar: a versão do Flutter usada no scaffold, como rodar em mobile, como rodar em web, como subir o Emulator Suite e como executar `flutter analyze` e `flutter test`. *(FUND-20)*
2. WHEN alguém segue o README num ambiente limpo com o SDK instalado THEN SHALL chegar ao app rodando sem consultar nenhuma outra fonte. *(FUND-20)*

**Independent Test**: seguir o README do zero, sem consultar a spec.

---

## Edge Cases

- WHEN o SDK Flutter não está no PATH THEN o Execute desta spec SHALL parar antes da primeira task, com a pré-condição de ambiente citada explicitamente — não há workaround dentro da spec.
- WHEN `/c/:codigo` recebe código com caracteres inesperados ou tamanho absurdo THEN o destino de erro SHALL responder sem lançar (a validação **semântica** do código — existe? expirou? — é da spec 09 `convidado`; aqui só a robustez de rota).
- WHEN o app abre em janela redimensionada exatamente a 900.0 px THEN o modo SHALL ser **expandido** (fronteira inclusiva à direita), sem oscilação entre modos.
- WHEN `flutter test` roda sem nenhum emulador ativo THEN a suíte SHALL passar — nenhum teste desta spec pode depender de processo externo.
- WHEN uma feature futura registrar dependências THEN SHALL fazê-lo pelo container desta spec; nenhuma feature cria o seu.

---

## Requirement Traceability

| Requirement ID | Story | Fonte | Fase | Status |
|---|---|---|---|---|
| FUND-01 | P1-1 | CLAUDE.md (um codebase, mobile + web) | Design | Pending |
| FUND-02 | P1-1 | CLAUDE.md (`flutter_lints` local) | Design | Pending |
| FUND-03 | P1-1 | CLAUDE.md (pirâmide de testes) | Design | Pending |
| FUND-04 | P1-2 | CLAUDE.md (árvore `lib/`) | Design | Pending |
| FUND-05 | P1-2 | CLAUDE.md (`test/` espelha `lib/`) | Design | Pending |
| FUND-06 | P1-2 | CLAUDE.md (`core/calculo` Dart puro) | Design | Pending |
| FUND-07 | P1-3 | arquivo 01 §4 (mapa de telas) | Design | Pending |
| FUND-08 | P1-3 | arquivo 01 §4, RN-23, RN-24 | Design | Pending |
| FUND-09 | P1-3 | dimensão input validation | Design | Pending |
| FUND-10 | P1-3 | W-R5 | Design | Pending |
| FUND-11 | P1-3 | W-R3 | Design | Pending |
| FUND-12 | P1-4 | dimensão idempotência | Design | Pending |
| FUND-13 | P1-4 | CLAUDE.md (BLoC) + dimensão observabilidade | Design | Pending |
| FUND-14 | P1-4 | dimensão observabilidade | Design | Pending |
| FUND-15 | P1-5 | dimensão ordering | Design | Pending |
| FUND-16 | P1-5 | context.md (emulator-first) | Design | Pending |
| FUND-17 | P1-5 | dimensão falha de dependência externa | Design | Pending |
| FUND-18 | P1-6 | RN-30 | Design | Pending |
| FUND-19 | P1-6 | CLAUDE.md + context.md (fixture bruta) | Design | Pending |
| FUND-20 | P1-7 | context.md (SDK não versionado) | Design | Pending |

**ID format:** `FUND-NN`
**Status:** Pending → In Design → In Tasks → Implementing → Verified
**Coverage:** 20 requisitos, 0 mapeados a tasks (Tasks ainda não rodou), 0 órfãos.

---

## Success Criteria

- [ ] Clone limpo + README → app rodando em mobile e web, sem pergunta ao autor da spec.
- [ ] `flutter analyze` zero issues e `flutter test` verde, ambos sem emulador ativo.
- [ ] Import proibido em `core/calculo/` quebra a suíte (verificado injetando a violação e removendo).
- [ ] Todas as rotas do mapa de telas respondem; `/c/:codigo` abre sem autenticação; rota inexistente cai em erro legível.
- [ ] Fixture RN-30 confere campo a campo com o arquivo 03.
- [ ] Nenhum arquivo de tela, token ou fórmula foi criado — a fundação continua vazia de produto.

---

## Nota de dependência para as specs seguintes

A spec 02 `calculo` herda dois compromissos desta: **tipar a fixture RN-30** (que aqui nasce bruta) e manter o isolamento que FUND-06 passa a policiar por teste. A spec 01 `design-system` herda o destino de erro e os placeholders de rota, que existem aqui em versão mínima e sem estilo, para revestir.
