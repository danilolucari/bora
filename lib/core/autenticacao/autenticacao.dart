/// Camada de autenticação do BORA — a casa da sessão (**AD-019**).
///
/// Mora em `core/` e não dentro de `features/entrar/` por três razões: o
/// roteador precisa ler a sessão para a guarda de AD-017 (feature dentro de
/// core seria inversão de camada); a spec 04 `home` precisa de
/// [UsuarioLogado.inicial] para o avatar do header, e importar de `entrar`
/// seria acoplamento feature↔feature; e a AD-008 já resolveu este caso uma vez
/// para as entidades de cálculo.
///
/// **Esta é a única porta de entrada da camada.** Uma feature importa
/// `package:bora/core/autenticacao/autenticacao.dart` e recebe a entidade, o
/// vocabulário de falha e a porta. Importar arquivo interno da pasta contorna
/// o contrato e não é permitido.
///
/// `dominio/` é Dart puro. **Só `dados/` importa `firebase_auth`** — e é o
/// único lugar do projeto que o faz fora do bootstrap e do injector.
library;

export 'dominio/autenticacao_repository.dart';
export 'dominio/falha_de_autenticacao.dart';
export 'dominio/usuario_logado.dart';
