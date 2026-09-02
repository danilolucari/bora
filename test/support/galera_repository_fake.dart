import 'dart:async';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/galera/domain/chave_de_pessoa.dart';
import 'package:bora/features/galera/domain/galera_da_festa.dart';
import 'package:bora/features/galera/domain/galera_repository.dart';

/// Duplo à mão da porta da Galera (**AD-021**: `mocktail` só para SDK de
/// terceiro; porta de domínio tem fake próprio).
///
/// Guarda **quem chamou o quê, com que argumentos e em que ordem** — é o que
/// torna afirmável que cada gesto da tela vira a escrita correspondente na
/// porta, e que a opção já ativa **não** vira escrita nenhuma (GAL-28).
///
/// A emissão do stream é **explícita** ([emitir]): escrever não ecoa de volta,
/// para que o teste possa afirmar que o bloc não mexe no estado por conta
/// própria — a fonte da verdade continua sendo o stream.
class GaleraRepositoryFake implements GaleraRepository {
  GaleraRepositoryFake({GaleraDaFesta? inicial}) : _galera = inicial;

  GaleraDaFesta? _galera;

  final StreamController<GaleraDaFesta?> _controller =
      StreamController<GaleraDaFesta?>.broadcast();

  /// Os `festaId` passados a [observarGalera], na ordem.
  final List<String> observados = [];

  /// Os argumentos de cada [alterarDieta], na ordem.
  final List<(String, ChaveDePessoa, Dieta)> dietas = [];

  /// Os argumentos de cada [alterarBebida], na ordem.
  final List<(String, ChaveDePessoa, bool)> bebidas = [];

  /// Os argumentos de cada [alterarPapel], na ordem.
  final List<(String, ChaveDePessoa, PapelNaFesta)> papeis = [];

  /// Os argumentos de cada [definirNivelDoLink], na ordem.
  final List<(String, NivelDoLink)> niveis = [];

  /// Quando não-nulo, é lançado por **toda** escrita — o caminho de falha da
  /// porta.
  Object? erroDeEscrita;

  /// Quantos assinantes de [observarGalera] estão ativos agora. Zero depois de
  /// `bloc.close()` é o que prova que a inscrição não vazou.
  int ouvintes = 0;

  /// Quantas escritas chegaram à porta, de qualquer um dos quatro tipos.
  int get escritas =>
      dietas.length + bebidas.length + papeis.length + niveis.length;

  @override
  Stream<GaleraDaFesta?> observarGalera(String festaId) {
    observados.add(festaId);

    return Stream<GaleraDaFesta?>.multi((assinante) {
      ouvintes++;
      assinante.add(_galera);

      final inscricao = _controller.stream.listen(
        assinante.add,
        onError: assinante.addError,
        onDone: assinante.close,
      );

      assinante.onCancel = () {
        ouvintes--;
        return inscricao.cancel();
      };
    });
  }

  @override
  Future<void> alterarDieta(
    String festaId,
    ChaveDePessoa quem,
    Dieta dieta,
  ) async {
    dietas.add((festaId, quem, dieta));
    _falharSePedido();
  }

  @override
  Future<void> alterarBebida(
    String festaId,
    ChaveDePessoa quem,
    bool bebe,
  ) async {
    bebidas.add((festaId, quem, bebe));
    _falharSePedido();
  }

  @override
  Future<void> alterarPapel(
    String festaId,
    ChaveDePessoa quem,
    PapelNaFesta papel,
  ) async {
    papeis.add((festaId, quem, papel));
    _falharSePedido();
  }

  @override
  Future<void> definirNivelDoLink(String festaId, NivelDoLink nivel) async {
    niveis.add((festaId, nivel));
    _falharSePedido();
  }

  /// Empurra uma emissão para quem estiver ouvindo — a mudança que chega de
  /// fora com a tela aberta (RN-28).
  void emitir(GaleraDaFesta? galera) {
    _galera = galera;
    _controller.add(galera);
  }

  /// Faz o stream falhar — o caminho de GAL-25.
  void falhar(Object erro, StackTrace stack) =>
      _controller.addError(erro, stack);

  Future<void> dispose() => _controller.close();

  /// A chamada é **registrada antes** de falhar: a tentativa é o fato
  /// observável, e o sucesso é quem chamou que decide o que fazer com ele.
  void _falharSePedido() {
    final erro = erroDeEscrita;
    if (erro != null) throw erro;
  }
}
