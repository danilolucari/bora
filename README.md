# BORA.

> A conta do rolê, resolvida.

App de organização de churrasco: calcula quantidades e custo ao vivo, chama a
galera por link/WhatsApp e racha a conta descontando o que cada um levou. Um
único codebase Flutter serve mobile e web.

Este README é o roteiro para sair de um clone limpo até o app rodando. Se algo
aqui não bastar, é bug do README — a spec (`.specs/`) não deveria ser leitura
obrigatória para subir o projeto.

---

## Versão do SDK

O SDK Flutter **não é versionado neste repositório** — nem por FVM, nem por
submódulo, nem por binário commitado. É uma decisão explícita do projeto: o SDK
é instalado globalmente, à mão, por quem for desenvolver. A consequência é que
**este README é a única memória da versão exigida**; sem ele, a versão vira
folclore e cada máquina resolve dependências de um jeito.

Versão usada para gerar o scaffold e para a qual o `pubspec.lock` foi resolvido:

```
Flutter 3.47.0 · channel stable
Dart 3.13.0 · DevTools 2.60.0
```

O `pubspec.yaml` declara `environment: sdk: ^3.13.0` — qualquer Dart 3.13.x
serve, mas as versões exatas dos pacotes estão travadas no `pubspec.lock`
(versionado de propósito). Confira a sua com:

```bash
flutter --version
```

---

## Setup

```bash
git clone <url-do-repo>
cd bora
flutter pub get
```

Nada além disso é necessário para `flutter analyze`, `flutter test` e
`flutter run`: não há projeto Firebase na nuvem, credencial, arquivo `.env` nem
chave de API para pedir a ninguém (ver [Firebase](#firebase-emulator-first)).

---

## Rodando o app

O mesmo `lib/main.dart` sobe nas duas plataformas.

**Mobile** (device físico ou emulador Android/iOS conectado):

```bash
flutter devices          # confirma que há um alvo disponível
flutter run
```

**Web** (Chrome):

```bash
flutter run -d chrome
```

O app abre em `/roles` (a home). As rotas registradas são:

| Rota | Tela |
|---|---|
| `/entrar` | T-01 entrar — fora do shell |
| `/roles` | T-02 home |
| `/roles/novo` | T-03 montar (rolê novo) |
| `/roles/:festaId/montar` | T-03 montar |
| `/roles/:festaId/lista` | T-04 lista |
| `/roles/:festaId/galera` | T-05 galera |
| `/roles/:festaId/whatsapp` | T-06/T-07 convite |
| `/roles/:festaId/custos` | T-09 custos |
| `/c/:codigo` | T-08 convidado — **sem shell e sem login** |
| qualquer outra | destino de erro legível |

Todas respondem com **placeholder**: as telas de verdade nascem nas specs
seguintes. No web a URL usa caminho de verdade, sem `#`.

---

## Portão de qualidade

```bash
flutter analyze     # precisa terminar com zero issues
flutter test        # precisa terminar com todos passando
```

Os dois rodam **sem emulador ativo** — nenhum teste da fundação depende de
processo externo. `flutter analyze` com zero issues é requisito, não meta:
`flutter_lints` está declarado no `pubspec.yaml` e ativo no
`analysis_options.yaml`.

---

## Firebase (emulator-first)

Não existe projeto Firebase na nuvem. O app aponta para o **Emulator Suite**
local, com o projeto sintético `demo-bora` (`.firebaserc`) — é o que mantém o
desenvolvimento offline, sem credencial e sem custo.

Para subir os emuladores é preciso o CLI do Firebase, que **não vem com o
Flutter**:

```bash
npm install -g firebase-tools    # uma vez por máquina
firebase --version
```

Depois, na raiz do repositório (é onde estão `firebase.json` e `.firebaserc`):

```bash
firebase emulators:start
```

Portas declaradas em `firebase.json` — a fonte da verdade; as constantes Dart em
`lib/core/firebase/emulator_config.dart` são conferidas contra esse arquivo por
teste:

| Emulador | Porta |
|---|---|
| Auth | 9099 |
| Firestore | 8080 |
| UI do Emulator Suite | habilitada — o endereço aparece na saída do comando |

Detalhe de plataforma: no **emulador de Android** o app procura os emuladores em
`10.0.2.2` (o endereço pelo qual o aparelho virtual enxerga a máquina
hospedeira); em web, iOS e device físico na mesma máquina, `localhost`.

Os emuladores só são conectados fora de release — o app nunca aponta um emulador
contra infraestrutura real.

### Build de release

Uma build de release **falha de propósito** enquanto não houver projeto real,
com `StateError` e mensagem explícita, em vez de tentar em silêncio alcançar um
projeto que não existe. Quando existir, passe o id:

```bash
flutter build web --dart-define=BORA_FIREBASE_PROJECT_ID=<id-do-projeto>
```

O id não pode começar com `demo-`: esse prefixo é reservado a projeto que só
existe no emulador.

---

## Checklist de verificação manual

Estes itens **não são cobertos pela suíte automatizada** — dependem de device,
navegador ou dos emuladores no ar. Estão aqui porque, sem lista, viram verificação
esquecida.

### 1. Mobile e web a partir do mesmo `main.dart` (FUND-01)

> **Faça este primeiro** assim que houver um device ou navegador disponível: é
> o que valida empiricamente a premissa que sustenta o resto.

- [ ] `flutter run` sobe o app em mobile, sem erro de compilação
- [ ] `flutter run -d chrome` sobe o **mesmo** app em web, sem erro de compilação
- [ ] Nos **dois** casos o app abre de fato — ou seja,
      `Firebase.initializeApp` aceita as opções sintéticas de `demo-bora`
      (`lib/core/firebase/demo_firebase_options.dart`) tanto no SDK nativo
      quanto no web

Se o SDK nativo recusar as opções sintéticas (erro do tipo
`invalid GOOGLE_APP_ID`), **pare e escale**: o fallback seria passar opções
reais por `--dart-define`, o que contraria a decisão emulator-first e é escolha
do dono do projeto, não do executor.

### 2. URL limpa e título da aba, no navegador (FUND-10)

- [ ] Navegando pelas rotas no Chrome, a URL reflete a rota atual **sem `#`**
      (ex.: `localhost:PORTA/roles`, não `localhost:PORTA/#/roles`)
- [ ] O título da aba é exatamente `bora — a conta do rolê`
- [ ] Abrir `/rota-que-nao-existe` cai no destino de erro legível, nunca em tela
      branca
- [ ] Abrir `/c/rafa18` mostra o placeholder do convidado sem pedir login

### 3. Emulador no ar e emulador derrubado (FUND-17)

O par importa: os dois casos precisam terminar com o app aberto.

- [ ] Com `firebase emulators:start` rodando, abrir o app — sobe normalmente
- [ ] Derrubar os emuladores (Ctrl+C) e abrir o app de novo — **o app abre
      mesmo assim**, e o erro de conexão aparece no log pelo handler global

Emulador indisponível é degradação, não crash. Se o app não abrir no segundo
caso, é regressão.

---

## Estrutura

```
lib/
  core/
    design_system/     # tokens e componentes (spec 01)
    calculo/           # camada de cálculo — todas as RN-xx (spec 02)
    di/ routing/ observability/ firebase/ responsive/
  features/<feature>/  # entrar, home, montar, lista, galera, convite,
                       # convidado, custos
    domain/ data/ presentation/
test/                  # espelha lib/
```

`lib/core/calculo/` é Dart puro: sem import de Flutter e sem import de Firebase.
Isso não é convenção escrita — é policiado por teste
(`test/architecture/calculo_isolation_test.dart`), assim como a existência da
árvore (`test/architecture/project_structure_test.dart`).

Convenções de código, commits e testes estão no `CLAUDE.md`. A especificação do
produto está em `.specs/init-spec/`.
