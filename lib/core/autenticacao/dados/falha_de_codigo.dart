import '../dominio/falha_de_autenticacao.dart';

/// Traduz o `code` de um `FirebaseAuthException` para o vocabulário de
/// domínio — ENT-09, ENT-11.
///
/// Recebe `String`, e não a exceção, para ser **Dart puro**: o mapeamento é a
/// única parte do adaptador com ramificação, e mantê-lo separado torna a
/// tabela inteira afirmável sem SDK, sem rede e sem emulador.
///
/// ## Por que quatro códigos para uma falha só
///
/// O doc do próprio pacote (`firebase_auth-6.5.7/lib/src/firebase_auth.dart`,
/// linhas 578-584) explica: desde setembro de 2023 a proteção contra
/// enumeração de e-mail é o default, e `invalid-credential` **substitui**
/// `user-not-found` e `wrong-password` para não revelar se a conta existe. Os
/// dois antigos continuam mapeados porque projeto com a proteção desligada
/// ainda os devolve.
///
/// E a linha que mais importa aqui: *"On the Firebase emulator, the code may
/// appear as INVALID_LOGIN_CREDENTIALS"*. A AD-016 manda desenvolver contra o
/// emulador — mapear só a forma canônica faria "E-MAIL OU SENHA INCORRETOS"
/// nunca aparecer justamente no ambiente de desenvolvimento, e parecer bug de
/// UI.
///
/// Código fora da tabela cai em [FalhaDeAutenticacao.indisponivel], que é a
/// degradação de AD-004: a tela abre, o CTA falha com mensagem, nada trava.
/// É onde caem `invalid-email` (inalcançável — a validação de ENT-08 barra
/// antes) e `too-many-requests`, que nenhuma tela da spec desenha.
/// Os códigos que significam "o usuário desistiu", e não "deu erro".
///
/// ATENÇÃO — **não verificados empiricamente.** Vêm da lista pública de erros
/// do Firebase Auth (SDK JS/nativo) e **não aparecem em nenhum pacote Dart
/// instalado**: a varredura de `firebase_auth-6.5.7`, `firebase_auth_web-6.2.6`
/// e `firebase_auth_platform_interface-9.0.6` não encontrou nenhuma
/// ocorrência. O que está testado aqui é o **mecanismo** (código do conjunto
/// vira `cancelada`), não a exatidão desta lista.
///
/// A captura do código real depende de fechar o popup do Google num navegador
/// com o emulador ligado — e o botão que abre esse popup só nasce em T13/T14.
/// Confirmar lá, com a skill `run`, e corrigir este conjunto.
const Set<String> codigosDeCancelamento = {
  'popup-closed-by-user',
  'cancelled-popup-request',
  'user-cancelled',
  'web-context-canceled',
};

FalhaDeAutenticacao falhaDeCodigo(String codigo) => switch (codigo) {
      _ when codigosDeCancelamento.contains(codigo) =>
        FalhaDeAutenticacao.cancelada,
      'invalid-credential' ||
      'INVALID_LOGIN_CREDENTIALS' ||
      'wrong-password' ||
      'user-not-found' =>
        FalhaDeAutenticacao.credencialInvalida,
      'email-already-in-use' => FalhaDeAutenticacao.emailEmUso,
      'weak-password' => FalhaDeAutenticacao.senhaFraca,
      'network-request-failed' => FalhaDeAutenticacao.semRede,
      _ => FalhaDeAutenticacao.indisponivel,
    };
