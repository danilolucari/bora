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

  /// Os métodos chamados, em ordem. Deixa o teste afirmar **quantas** vezes o
  /// repositório foi acionado — é o que prova que a validação barrou antes
  /// (ENT-08) e que o duplo toque não disparou dois logins (ENT-07).
  final List<String> chamadas = [];

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
      _autenticar('entrarComEmailESenha');

  @override
  Future<void> entrarComGoogle() => _autenticar('entrarComGoogle');

  @override
  Future<void> criarConta({required String email, required String senha}) =>
      _autenticar('criarConta');

  @override
  Future<void> sair() async {
    chamadas.add('sair');
    _emitir(null);
  }

  @override
  Future<void> dispose() => _controlador.close();

  /// Muda a sessão sem passar por método de autenticação.
  ///
  /// É como o teste da guarda simula a sessão expirando com uma rota de festa
  /// montada (ENT-18), que nenhum método do app provoca.
  void mudarSessao(UsuarioLogado? usuario) => _emitir(usuario);

  Future<void> _autenticar(String metodo) async {
    chamadas.add(metodo);

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
