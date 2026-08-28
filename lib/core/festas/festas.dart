/// Camada de **escrita e leitura-de-uma** festa do BORA — a porta de edição
/// (**AD-029**).
///
/// Mora em `core/` e não dentro de `features/montar/` pela mesma razão da
/// AD-019: há dois consumidores. A Home **lê** a lista pela
/// `FestaRepository`, que continua em `features/home/domain/` e não é tocada;
/// `montar` **escreve** por aqui. Uma feature importando a porta da outra
/// seria acoplamento feature↔feature.
///
/// **Esta é a única porta de entrada da camada.** Uma feature importa
/// `package:bora/core/festas/festas.dart` e recebe o valor e a porta.
/// Importar arquivo interno da pasta contorna o contrato e não é permitido.
///
/// `dominio/` é Dart puro e fala **só** em tipos de `core/calculo` (AD-008):
/// nenhum arquivo desta pasta importa Flutter, Firebase ou `features/`.
///
/// **Sem `dados/`**: a implementação do M1 é `FestaRepositoryEmMemoria`
/// (AD-016), que mora em `features/home/data/` e serve as duas portas sobre o
/// mesmo store; no M2 vira Firestore.
library;

export 'dominio/festa_em_edicao.dart';
export 'dominio/festa_em_edicao_repository.dart';
