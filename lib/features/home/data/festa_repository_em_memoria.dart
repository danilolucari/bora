import 'dart:async';

import '../../../core/festas/festas.dart';
import '../domain/festa_repository.dart';
import '../domain/resumo_de_festa.dart';

/// A implementação que o M1 **roda de verdade** (AD-016) — não é duplo de
/// teste.
///
/// A semente entra **por injeção**: quem monta a lista é o `main` ou o teste,
/// nunca este arquivo. É o que impede `lib/` de importar `test/fixtures/`, e
/// há uma varredura de import afirmando isso.
///
/// Em produção a semente é vazia — a fixture RN-30 é dado de teste (G7). O app
/// abre no estado vazio de HOME-15 até a spec 05 criar festa.
///
/// **Uma instância, duas portas, o mesmo store** (AD-029): a Home lê a lista
/// por [FestaRepository]; `montar` cria e grava por [FestaEmEdicaoRepository].
/// Guardar a composição num mapa paralelo criaria duas fontes para a mesma
/// festa — o registro é um só, e é o [ResumoDeFesta].
class FestaRepositoryEmMemoria
    implements FestaRepository, FestaEmEdicaoRepository {
  FestaRepositoryEmMemoria({List<ResumoDeFesta> inicial = const []})
      : _ultimo = List.of(inicial);

  final StreamController<List<ResumoDeFesta>> _mudancas =
      StreamController<List<ResumoDeFesta>>.broadcast();

  List<ResumoDeFesta> _ultimo;

  /// Quantas festas [criarFesta] já criou — a fonte do id novo.
  int _criadas = 0;

  /// Entrega o estado corrente **antes** de acompanhar as mudanças.
  ///
  /// Sem a primeira entrega, quem assina depois da semente ficaria numa tela
  /// em branco até a próxima emissão — e o bloc, que assina na construção,
  /// dependeria da ordem em que o teste chama as coisas.
  ///
  /// `Stream.multi`, e não `async*`, porque o gerador abria uma janela: entre
  /// entregar `_ultimo` e assinar `_mudancas`, um `emitir` era **perdido** —
  /// controller broadcast descarta evento sem ouvinte. Em produção isso é uma
  /// confirmação chegando enquanto a Home monta: o contador ficava em 4/2 e o
  /// atalho do acerto não aparecia. Aqui a entrega e a assinatura acontecem no
  /// mesmo turno, e não há janela.
  @override
  Stream<List<ResumoDeFesta>> observarFestas() =>
      Stream<List<ResumoDeFesta>>.multi((assinante) {
        assinante.add(_ultimo);

        final inscricao = _mudancas.stream.listen(
          assinante.add,
          onError: assinante.addError,
          onDone: assinante.close,
        );
        assinante.onCancel = inscricao.cancel;
      });

  /// A festa de [id] como `montar` a edita — MONT-16, MONT-18.
  ///
  /// Deriva de [observarFestas], e é de propósito: herda a entrega do estado
  /// corrente **antes** de acompanhar as mudanças, e reemite a cada
  /// [salvarFesta]. Uma segunda fonte de emissão poderia atrasar em relação à
  /// lista — e a festa que `montar` grava não chegaria na Home.
  ///
  /// `null` quando a festa não existe: quem abre `/roles/{id}/montar` com um
  /// id inventado recebe a resposta, não silêncio nem exceção.
  @override
  Stream<FestaEmEdicao?> observarFesta(String id) =>
      observarFestas().map((festas) {
        final resumo = _acharPorId(festas, id);
        if (resumo == null) return null;

        return FestaEmEdicao(
          festa: resumo.festa,
          composicao: resumo.composicao,
        );
      });

  /// Cria a festa e devolve o `festaId` — MONT-17.
  ///
  /// A festa nasce na **mesma lista** que a Home observa: é isso que faz o
  /// rolê de `/roles/novo` aparecer na Home sem refresh. Contadores nascem
  /// zerados — não há convidado nem RSVP numa festa recém-criada (AD-022).
  @override
  Future<String> criarFesta(FestaEmEdicao rascunho) async {
    final id = _idNovo();

    emitir([
      ..._ultimo,
      ResumoDeFesta(
        id: id,
        festa: rascunho.festa,
        composicao: rascunho.composicao,
      ),
    ]);

    return id;
  }

  /// Grava identidade e composição de uma festa existente — MONT-18.
  ///
  /// **Preserva `confirmados`, `pendentes`, `iniciais`, `pessoas` e `total`**:
  /// montar grava o que o anfitrião mexe, nunca contador de RSVP, que é dado
  /// de outra origem (AD-022). Sobrescrevê-los aqui apagaria a confirmação que
  /// chegou enquanto a tela estava aberta.
  ///
  /// **Id inexistente é no-op observável**: nada é emitido e nenhuma festa
  /// fantasma nasce. Criar por engano aqui poria na Home um rolê que o
  /// anfitrião nunca criou.
  @override
  Future<void> salvarFesta(String id, FestaEmEdicao festa) async {
    final indice = _ultimo.indexWhere((resumo) => resumo.id == id);
    if (indice < 0) return;

    final atual = _ultimo[indice];
    final atualizada = List.of(_ultimo);
    atualizada[indice] = ResumoDeFesta(
      id: atual.id,
      festa: festa.festa,
      confirmados: atual.confirmados,
      pendentes: atual.pendentes,
      iniciais: atual.iniciais,
      pessoas: atual.pessoas,
      total: atual.total,
      composicao: festa.composicao,
    );

    emitir(atualizada);
  }

  /// Empurra um estado novo para quem já está ouvindo.
  ///
  /// É por aqui que o teste faz a confirmação de RN-28 chegar com a tela
  /// montada, enquanto a spec 09 `convidado` não existe (A-02).
  void emitir(List<ResumoDeFesta> festas) {
    // Cópia nas duas pontas: guardar a lista de quem chamou deixaria o estado
    // do repositório mudar por fora, sem emissão nenhuma — e a Home não teria
    // como perceber.
    _ultimo = List.of(festas);
    _mudancas.add(_ultimo);
  }

  @override
  Future<void> dispose() => _mudancas.close();

  /// O resumo de [id] na lista, ou `null` se não houver.
  ///
  /// `firstWhere` com `orElse` exigiria inventar um resumo vazio para
  /// devolver; o laço diz "não existe" sem fabricar festa nenhuma.
  static ResumoDeFesta? _acharPorId(List<ResumoDeFesta> festas, String id) {
    for (final festa in festas) {
      if (festa.id == id) return festa;
    }
    return null;
  }

  /// Um id que nenhuma festa do store já usa.
  ///
  /// O contador sozinho bastaria enquanto a semente vem vazia; a checagem
  /// existe porque a semente é injetada e pode trazer ids quaisquer — e um id
  /// repetido faria [salvarFesta] gravar na festa errada.
  String _idNovo() {
    var id = 'festa-${++_criadas}';
    while (_acharPorId(_ultimo, id) != null) {
      id = 'festa-${++_criadas}';
    }
    return id;
  }
}
