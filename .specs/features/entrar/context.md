# Entrar — Context

**Gathered:** 2026-08-25
**Spec:** `.specs/features/entrar/spec.md`
**Status:** Ready for design

---

## Feature Boundary

Plugar `boraTheme()` no `BoraApp` (AD-013) e entregar a tela T-01/W-01 com login por e-mail/senha e Google contra o emulador do Firebase Auth, mais a guarda de sessão no roteador e o modo cadastro na mesma tela. **Não** entrega dado de festa, perfil, logout nem recuperação de senha.

---

## Implementation Decisions

### Método de autenticação (zona cinzenta G1 — resolvida)

- **E-mail/senha + Google.** A spec manda: T-01, W-01 e o aceite de UC-01 desenham exatamente esses dois, com os inputs "seu e-mail" e "senha".
- **Telefone/SMS sai do produto.** O `CLAUDE.md` dizia "Google + telefone" e está errado — nenhuma tela foi desenhada para telefone, e implementá-lo exigiria inventar um terceiro botão e uma tela de código SMS fora de 04 e 06.
- Consequência assumida: **o `CLAUDE.md` é corrigido**, não obedecido. Registrado como AD-015.

### Origem dos dados no M1 (zona cinzenta G8 — resolvida)

- **Auth é real** contra o emulador do Firebase Auth — o login funciona de verdade desde o M1, mantendo a AD-004 emulator-first.
- **Dado de festa é em memória.** `FestaRepository` nasce como porta abstrata na spec 04, com implementação em memória semeada pela fixture RN-30.
- **Firestore entra no M2**, junto com `convidado`, que é quem produz o realtime de RN-28. Trocar a impl não toca em bloc nem em tela.
- Efeito colateral desejado: a suíte de widget do M1 roda **sem emulador ligado**.
- `flutterfire configure` e o projeto real na nuvem continuam adiados.

### Guarda de rota

- **Redirect por sessão em `app_router.dart`**, observando o estado de autenticação:
  - sem sessão em `/roles/**` → `/entrar`
  - com sessão em `/entrar` → `/roles`
  - `/c/:codigo`, `/erro` e `/catalogo` passam **sempre**, com ou sem sessão
- A sessão persiste entre aberturas do app (comportamento padrão do `FirebaseAuth`); reabrir logado cai direto na Home.
- Motivo de existir: sem guarda, no web basta digitar `/roles` na barra de endereços. E o aceite "pós-login sempre cai na Home" de UC-01 é literalmente um redirect.

### "CRIAR CONTA"

- **Alterna a mesma tela para modo cadastro** — sem rota nova, sem tela nova.
- Modo entrar: label "ENTRAR", CTA "COMEÇAR →", rodapé "Novo por aqui? CRIAR CONTA".
- Modo cadastro: label "CRIAR CONTA", CTA "CRIAR CONTA →", rodapé "Já tem conta? ENTRAR".
- A alternância preserva o e-mail digitado e limpa erro anterior.
- Rejeitada a rota `/criar-conta`: acrescentaria nó ao mapa canônico da AD-003 que nem 04 nem 06 desenham.

### Divisão da herança da AD-013

A AD-013 devolveu quatro artefatos "para as specs 03/04" sem dividir. Ficou:

- `lib/app.dart` (tema) e `RouteErrorPage` → **esta spec**
- `AppShell` (header de app) e `PlaceholderPage` → spec 04 `home`
- `FestaTabsShell` → spec 06 `lista`, a primeira feature que monta as abas

### Agent's Discretion

- Texto do erro de credencial (A-06), copy do modo cadastro (A-07), regra de validação (A-08) e revestimento do `RouteErrorPage` (A-09): a spec-fonte não os define. Defaults escolhidos e registrados como assumptions.
- Estrutura interna do bloc, nomes de eventos/estados e organização de widgets: livre dentro da Clean Architecture do `CLAUDE.md`.

### Declined / Undiscussed Gray Areas → Assumptions

- **Copy divergente do botão Google entre plataformas** (A-05) — não foi levantada na conversa; default: manter as duas literais, uma por plataforma, porque a copy das specs é literal por regra do `CLAUDE.md`.
- **Google no emulador Android** (A-10) — o provider não tem fluxo nativo lá; default: cobrir o repositório por duplo e declarar a verificação ponta-a-ponta como manual, no web.
- **Correção do `CLAUDE.md`** (A-11) — consequência direta de AD-015 e do fim do M0; default: corrigir as passagens "não há código ainda" e "Google + telefone".

---

## Specific References

- A primeira coisa que a spec faz é **plugar `boraTheme()` no `BoraApp`** — pedido explícito do usuário na abertura da sessão, e exatamente o que a AD-013 previu.
- Copy literal, sem paráfrase, incluindo a diferença deliberada entre "CONTINUAR COM GOOGLE" (T-01) e "🌐 ENTRAR COM GOOGLE" (W-01).

---

## Deferred Ideas

- **Recuperação de senha** — não existe em T-01, W-01 nem UC-01. Se virar produto, é spec própria.
- **Logout e troca de conta** — o avatar do header de app (W-02) é decorativo no M1; a ação nasce quando alguma tela a especificar.
- **Login por telefone** — descartado, não adiado. Reabrir exigiria desenho de tela novo.
