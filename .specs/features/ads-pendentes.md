# ADs pendentes — specs 01 `design-system` e 02 `calculo`

> **Arquivo temporário de orquestração.** Os sete ADs abaixo foram propostos pelos planners
> das specs 01 e 02, que rodaram em worktrees paralelas e por isso **não podem escrever no
> `STATE.md`** (escrita única, do orquestrador, para não conflitar no merge).
>
> **Ação pendente:** ao fazer o merge das duas branches em `main`, colar estes blocos na
> seção `## Decisions` do `.specs/STATE.md` e **apagar este arquivo**.
>
> **Colisão resolvida aqui:** os dois planners propuseram, cada um por sua conta, os números
> AD-008, AD-009 e AD-010 para decisões diferentes. A renumeração abaixo é a canônica:
> `calculo` fica com 008–010 (planejou primeiro) e `design-system` com 011–014.

| Nº final | Nº proposto | Spec | Assunto |
|---|---|---|---|
| AD-008 | AD-008 | `calculo` | Entidades de domínio em `core/calculo/dominio/` |
| AD-009 | AD-009 | `calculo` | Política de precisão e arredondamento |
| AD-010 | AD-010 | `calculo` | RN-10 pela leitura (a), com `entraNoTotal` declarado |
| AD-011 | AD-008 | `design-system` | Tokens como constantes Dart puras, `boraTheme()` derivado |
| AD-012 | AD-009 | `design-system` | Peso por `FontWeight`; `FontVariation` proibida |
| AD-013 | AD-010 | `design-system` | O design system não aplica o tema; hand-off para a spec 03 |
| AD-014 | AD-011 | `design-system` | Catálogo como rota interna `/catalogo` |

---

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
