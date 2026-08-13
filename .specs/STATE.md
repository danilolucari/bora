# STATE

## Decisions

### AD-001
- **Decision**: A especificação `init-spec` foi decomposta em 11 specs de feature (00 `fundacao`, 01 `design-system`, 02 `calculo`, 03 `entrar`, 04 `home`, 05 `montar`, 06 `lista`, 07 `galera`, 08 `convite`, 09 `convidado`, 10 `custos`), organizadas em 4 marcos (M0 fundação → M1 monta e vê o custo → M2 chama a galera → M3 racha a conta), conforme `.specs/ROADMAP.md`.
- **Reason**: Recorte 1:1 com a estrutura feature-first do CLAUDE.md e com a matriz de rastreabilidade do arquivo 05; `design-system` e `calculo` viram specs próprias porque todas as telas dependem delas e as RN-xx precisam nascer testáveis em Dart puro antes de qualquer UI.
- **Trade-off**: `entrar` e `home` viram features fora da lista original do CLAUDE.md (que não previa onde T-01/T-02 morariam); `convite` fica Complexo por absorver T-06 + T-07 em vez de dividir em duas specs menores.
- **Scope**: todo o projeto — ordem de trabalho, dependências entre specs e cobertura de RN/UC/telas.
- **Date**: 2026-08-12
- **Status**: active

## Handoff

- **Feature**: `fundacao` (`.specs/features/fundacao/`)
- **Phase / Task**: Specify **concluído** (spec.md com FUND-01..20 + context.md com as decisões do Discuss). Design ainda não iniciado.
- **Completed**: ROADMAP.md, STATE.md (AD-001), fundacao/context.md, fundacao/spec.md
- **In-progress** (file:line): none
- **Next step**: rodar o **Design** da `fundacao` — escolher pacote de rotas, container de DI, forma do BlocObserver e wiring do emulador, promovendo as decisões do context.md a AD-002+ no log de Decisions (são herdadas pelas dez specs seguintes).
- **Blockers**: ⚠️ **SDK Flutter/Dart não instalado nesta máquina** (verificado 2026-08-12: `flutter`, `dart`, `firebase` ausentes do PATH; presentes Node, Python 3.14, Git, JDK 17). Design pode prosseguir; **Execute não pode começar** antes de `flutter --version` responder. Por decisão do Discuss, instalar o SDK é responsabilidade externa, fora do escopo da spec.
- **Uncommitted files**: `.specs/ROADMAP.md`, `.specs/STATE.md`, `.specs/features/fundacao/spec.md`, `.specs/features/fundacao/context.md`
- **Branch**: main
