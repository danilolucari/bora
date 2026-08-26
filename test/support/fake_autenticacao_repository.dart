import 'dart:async';

import 'package:bora/core/autenticacao/autenticacao.dart';

/// Duplo de teste da [AutenticacaoRepository] — o substrato de toda a suíte
/// da spec 03.
///
/// É escrito à mão, e não gerado por `mocktail`, de propósito: uma porta de
/// domínio tem comportamento que os testes dependem de estar **correto**
/// (autenticar emite no stream *e* atualiza o snapshot, na mesma transição).
/// Um mock devolveria o que cada teste mandasse e essa relação sumiria.
/// `mocktail` fica para o que não dá para escrever à mão — classe concreta de
/// SDK (AD-021).
class FakeAutenticacaoRepository implements AutenticacaoRepository {
  FakeAutenticacaoRepository({UsuarioLogado? sessaoInicial})
      : _sessao = sessaoInicial;

  /// O usuário que um login bem-sucedido produz.
  static const usuarioPadrao = UsuarioLogado(
    id: 'u1',
    email: 'rafa@bora.app',
    nome: 'Rafa',
  );

  /// Quando != `null`, **todo** método de autenticação lança esta falha em vez
  /// de autenticar.
  FalhaDeAutenticacao? falha;

  /// O usuário que a próxima autenticação bem-sucedida coloca na sessão.
  UsuarioLogado usuarioAoEntrar = usuarioPadrao;

  /// Cada chamada com os **argumentos** que ela recebeu.
  ///
  /// Guardar só o nome do método não bastava: a regra payload/conjunção diz
  /// que afirmar "a chamada aconteceu" não prova o **valor** que ela levou —
  /// e o edge case do `trim` é exatamente sobre o valor (o Verifier pegou
  /// isso como gap nº 5).
  final List<ChamadaDeAutenticacao> registros = [];

  /// Os métodos chamados, em ordem.
  List<String> get chamadas => [for (final r in registros) r.metodo];

  /// Quando != `null`, a autenticação **fica pendurada** até o teste
  /// completá-lo. É o que permite observar a tela no estado "enviando" —
  /// sem isso o envio termina no mesmo frame e o estado intermediário some.
  Completer<void>? travaDeEnvio;

  final _controlador = StreamController<UsuarioLogado?>.broadcast();
  UsuarioLogado? _sessao;

  @override
  UsuarioLogado? get sessaoAtual => _sessao;

  @override
  Stream<UsuarioLogado?> get mudancasDeSessao => _controlador.stream;

  @override
  Future<void> entrarComEmailESenha({
    required String email,
    required String senha,
  }) =>
      _autenticar('entrarComEmailESenha', email: email, senha: senha);

  @override
  Future<void> entrarComGoogle() => _autenticar('entrarComGoogle');

  @override
  Future<void> criarConta({required String email, required String senha}) =>
      _autenticar('criarConta', email: email, senha: senha);

  @override
  Future<void> sair() async {
    registros.add(const ChamadaDeAutenticacao('sair'));
    _emitir(null);
  }

  @override
  Future<void> dispose() => _controlador.close();

  /// Muda a sessão sem passar por método de autenticação.
  ///
  /// É como o teste da guarda simula a sessão expirando com uma rota de festa
  /// montada (ENT-18), que nenhum método do app provoca.
  void mudarSessao(UsuarioLogado? usuario) => _emitir(usuario);

  Future<void> _autenticar(String metodo, {String? email, String? senha}) async {
    registros.add(ChamadaDeAutenticacao(metodo, email: email, senha: senha));

    await travaDeEnvio?.future;

    final programada = falha;
    if (programada != null) throw programada;

    _emitir(usuarioAoEntrar);
  }

  /// O snapshot e o stream mudam **juntos**: quem acorda pelo stream e lê
  /// `sessaoAtual` — que é exatamente o que o roteador faz — tem de ver o
  /// valor novo, nunca o anterior.
  void _emitir(UsuarioLogado? usuario) {
    _sessao = usuario;
    _controlador.add(usuario);
  }
}

/// Uma chamada ao repositório, com os argumentos que ela levou.
class ChamadaDeAutenticacao {
  const ChamadaDeAutenticacao(this.metodo, {this.email, this.senha});

  final String metodo;
  final String? email;
  final String? senha;

  @override
  String toString() => 'ChamadaDeAutenticacao($metodo, $email)';
}
