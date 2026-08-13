# Fundação — Context

**Gathered:** 2026-08-12
**Spec:** `.specs/features/fundacao/spec.md`
**Status:** Ready for design

---

## Feature Boundary

A fundação entrega o **projeto Flutter vazio porém executável**: compila em mobile e web, tem lint e um portão de teste que roda de verdade, a estrutura de pastas da Clean Architecture feature-first, navegação com todas as rotas registradas (inclusive a pública do convidado), injeção de dependência e observabilidade de BLoC prontas, wiring do Firebase apontando para o Emulator Suite, a fixture do estado inicial (RN-30) e um README que faz um clone novo funcionar.

**Não entrega nenhuma tela de produto, nenhum token de design e nenhuma fórmula de cálculo** — essas são as specs 01 `design-system` e 02 `calculo`. Tudo que a fundação renderiza é placeholder deliberado.

---

## Implementation Decisions

### Toolchain / SDK Flutter

- **O SDK é pré-requisito externo, instalado manualmente pelo usuário.** A spec assume `flutter` disponível no PATH e começa no scaffold — não instala, não gerencia versão via FVM.
- Consequência aceita: a versão do SDK não fica versionada no repositório. Mitigação obrigatória — a versão efetivamente usada no scaffold é **registrada no README** no momento em que o projeto nascer, junto com a `sdk:` constraint do `pubspec.yaml`.
- **Estado atual da máquina:** `flutter`, `dart` e `firebase` **não estão instalados** (Node, Python, Git e JDK 17 estão). O primeiro passo do Execute é bloqueado até o SDK existir — isso é pré-condição da spec, não uma task dela.

### Firebase — emulator-first

- Wiring completo do SDK Firebase (Auth, Firestore) apontando para o **Firebase Emulator Suite local**. Desenvolvimento e testes rodam **sem credencial e sem projeto na nuvem**.
- O projeto Firebase real (e portanto `flutterfire configure`, Hosting e Functions) fica adiado para a primeira feature que precise publicar de verdade — na prática, `home` (RN-28 realtime) ou `convidado` (link público).
- A fundação continua verificável offline: nenhum critério de aceite depende de rede externa.

### RN-30 — estado inicial como fixture Dart puro

- RN-30 ("CHURRAS DO RAFA 🔥", 5 pessoas, 4h, itens padrão) é **artefato de teste e demo**, não conteúdo de produto. Nenhum usuário novo ganha festa de exemplo.
- Vive como Dart puro em `test/fixtures/`, sem import de Flutter e sem import de Firebase, consumido por testes unitários e de widget e por um modo demo em memória.
- **Ajuste de recorte necessário:** as entidades de domínio (`Festa`, `Pessoa`, `ItemDeLista`) pertencem à spec 02 `calculo` e ainda não existem. A fundação entrega a fixture como **dados brutos** (constantes Dart sem tipos de domínio); a spec 02 a tipa quando as entidades nascerem. Isso evita que a fundação invente um modelo de domínio que colidiria com 02.

### Escopo do "pronto"

Além do scaffold básico, a fundação só é aceita com os quatro itens escolhidos:

- **Navegação** — rotas de todas as telas com placeholders, rota pública `/c/:codigo` fora do shell autenticado, e o colapso responsivo de W-R3.
- **DI + BlocObserver** — container de dependências e observador global de BLoC prontos, para que cada feature seguinte só registre seus próprios blocs em vez de reinventar o wiring.
- **README de setup** — como rodar mobile e web, versões exigidas, como executar os testes.
- **Smoke test + espelho de `test/`** — estrutura de testes espelhando `lib/` conforme o CLAUDE.md, com teste mínimo provando que o portão de aceite realmente executa.

### Agent's Discretion

Deixados para o Design decidir, por serem escolhas técnicas e não de visão de produto:

- Pacote de navegação e de injeção de dependência (a spec exige as capacidades — URL limpa no web, deep link, container resetável em teste — não os pacotes).
- Forma concreta do BlocObserver e do handler de erro global.
- Organização interna de `core/` além das duas pastas já fixadas pelo CLAUDE.md (`design_system/`, `calculo/`).
- Portas e composição do `firebase.json` (declaradas lá, não fixadas nesta spec).

### Declined / Undiscussed Gray Areas → Assumptions

Nenhuma zona cinzenta foi declinada — as quatro levantadas foram decididas. As ambiguidades **remanescentes**, que não foram discutidas por serem detalhes de precisão e não de visão, estão registradas na tabela Assumptions & Open Questions do `spec.md`: valor exato do breakpoint de W-R3 (o arquivo 06 diz "~900px"), identificador do pacote/applicationId, rota base do app e título da aba.

---

## Specific References

- `.specs/ROADMAP.md` §3 (recorte da spec 00) e §4 (zona cinzenta **G7**, aqui resolvida: RN-30 é fixture, não seed de produto).
- `CLAUDE.md` — "Decisões de engenharia" fixa Flutter, BLoC, Firebase, Clean Architecture feature-first, idioma do código (domínio PT-BR, resto inglês), `flutter_lints` local, sem CI.
- `.specs/init-spec/06-telas-web.md` — W-R3 (colapso ~900px) e W-R5 (título da aba, URL base) são os únicos requisitos de produto que a fundação implementa de fato.
- `.specs/init-spec/03-regras-de-negocio.md` — RN-30 é a única RN tocada pela fundação, e apenas como dado.

---

## Deferred Ideas

- **CI/CD** — o CLAUDE.md proíbe criar pipeline sem pedido. Quando existir, a ausência de versão pinada do SDK (decisão desta spec) será o primeiro ponto a revisitar.
- **`flutterfire configure` e projeto Firebase real** — adiado para a feature que primeiro precisar publicar (`home` ou `convidado`), junto com Hosting e Functions.
- **Tipagem da fixture RN-30** — entra na spec 02 `calculo`, quando as entidades de domínio existirem.
- **Tela de erro/404 com identidade visual** — a fundação entrega a versão mínima sem design system; a spec 01 a reveste.
