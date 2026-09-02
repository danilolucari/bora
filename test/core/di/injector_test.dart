import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/di/injector.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/core/observability/app_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:bora/features/home/data/festa_repository_em_memoria.dart';
import 'package:bora/features/home/domain/festa_repository.dart';
import 'package:bora/features/lista/data/pedido_falso.dart';
import 'package:bora/features/lista/domain/pedido_repository.dart';

import '../../support/fake_autenticacao_repository.dart';
import '../../support/recording_app_logger.dart';

/// O store de produção, contando quantas vezes foi descartado.
///
/// Duas portas sobre o mesmo objeto com dois `dispose` registrados fechariam
/// o controller **duas vezes**; este contador é o que torna isso afirmável.
class _StoreQueContaDispose extends FestaRepositoryEmMemoria {
  int descartes = 0;

  @override
  Future<void> dispose() {
    descartes++;

    return super.dispose();
  }
}

/// Um rascunho qualquer, só para exercitar a porta de escrita.
FestaEmEdicao _rascunho() => FestaEmEdicao(
      festa: Festa(
        nome: 'CHURRAS NOVO',
        data: 'SÁB · 18 JUL',
        hora: '',
        local: '',
        duracaoHoras: 4,
      ),
      composicao: ComposicaoDaFesta(
        contagem: ContagemDePessoas(homens: 2),
        duracaoHoras: 4,
        itensSelecionados: const {ChaveItem.bovina},
      ),
    );

/// Um duplo qualquer da porta de pedido — só para provar que a costura de
/// [configureDependencies] a substitui.
class _PedidoQueNaoEnvia implements PedidoRepository {
  @override
  Future<Never> enviar(Object pedido) async => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(resetDependencies);
  tearDown(resetDependencies);

  group('FUND-12 — o container registra o que a fundação precisa', () {
    test('registra logger, roteador e os serviços do Firebase', () async {
      await configureDependencies(logger: RecordingAppLogger());

      expect(getIt.isRegistered<AppLogger>(), isTrue);
      expect(getIt.isRegistered<GoRouter>(), isTrue);
      expect(getIt.isRegistered<FirebaseAuth>(), isTrue);
      expect(getIt.isRegistered<FirebaseFirestore>(), isTrue);
    });

    test('registrar não toca no SDK do Firebase', () async {
      // Se Auth ou Firestore fossem registrados com resolução adiantada, esta
      // chamada lançaria: nenhum app Firebase foi inicializado nesta suíte.
      await expectLater(
        configureDependencies(logger: RecordingAppLogger()),
        completes,
      );
    });

    test('o roteador é singleton preguiçoso: sempre a mesma instância',
        () async {
      // Desde a AD-017 o roteador exige a porta de sessão, e resolvê-lo
      // construiria o adaptador Firebase de verdade — que toca o SDK. O duplo
      // entra pela costura que `configureDependencies` já expõe.
      await configureDependencies(
        logger: RecordingAppLogger(),
        autenticacaoFactory: FakeAutenticacaoRepository.new,
      );

      expect(getIt<GoRouter>(), same(getIt<GoRouter>()));
    });
  });

  group('AD-024 — a porta de pedido resolve para o adaptador falso do M1', () {
    test('PedidoRepository é o PedidoFalso, e é sempre a mesma instância',
        () async {
      await configureDependencies(
        logger: RecordingAppLogger(),
        autenticacaoFactory: FakeAutenticacaoRepository.new,
      );

      expect(getIt<PedidoRepository>(), isA<PedidoFalso>());
      expect(getIt<PedidoRepository>(), same(getIt<PedidoRepository>()));
    });

    test('a porta pode ser trocada por um duplo sem tocar a tela', () async {
      final duplo = _PedidoQueNaoEnvia();

      await configureDependencies(
        logger: RecordingAppLogger(),
        autenticacaoFactory: FakeAutenticacaoRepository.new,
        pedidosFactory: () => duplo,
      );

      expect(getIt<PedidoRepository>(), same(duplo));
    });
  });

  group('AD-029 — as duas portas de festa, um store só', () {
    test('FestaRepository e FestaEmEdicaoRepository resolvem para a mesma '
        'instância', () async {
      await configureDependencies(
        logger: RecordingAppLogger(),
        autenticacaoFactory: FakeAutenticacaoRepository.new,
      );

      expect(
        getIt<FestaEmEdicaoRepository>(),
        same(getIt<FestaRepository>()),
        reason: 'duas instâncias seriam duas fontes para a mesma festa: o '
            'rolê criado em montar não apareceria na Home',
      );
    });

    test('a festa criada pela porta de edição aparece em observarFestas()',
        () async {
      await configureDependencies(
        logger: RecordingAppLogger(),
        autenticacaoFactory: FakeAutenticacaoRepository.new,
      );

      final id = await getIt<FestaEmEdicaoRepository>().criarFesta(
        _rascunho(),
      );
      final festas = await getIt<FestaRepository>().observarFestas().first;

      expect(festas.map((resumo) => resumo.id), contains(id));
    });

    test('o store é descartado uma vez só — a segunda porta não registra '
        'dispose próprio', () async {
      final store = _StoreQueContaDispose();
      await configureDependencies(
        logger: RecordingAppLogger(),
        autenticacaoFactory: FakeAutenticacaoRepository.new,
        festasFactory: () => store,
      );

      // Materializa as duas portas: só o que foi resolvido é descartado.
      getIt<FestaRepository>();
      getIt<FestaEmEdicaoRepository>();

      await resetDependencies();

      expect(
        store.descartes,
        1,
        reason: 'com `dispose` também na porta de edição, o mesmo controller '
            'seria fechado duas vezes',
      );
    });
  });

  group('FUND-12 — configurar duas vezes é inofensivo', () {
    test('a segunda chamada não lança', () async {
      await configureDependencies(logger: RecordingAppLogger());

      await expectLater(
        configureDependencies(logger: RecordingAppLogger()),
        completes,
      );
    });

    test('a segunda chamada não duplica nem troca o que já estava registrado',
        () async {
      final primeiro = RecordingAppLogger();
      await configureDependencies(logger: primeiro);

      await configureDependencies(logger: RecordingAppLogger());

      expect(getIt<AppLogger>(), same(primeiro));
    });
  });

  group('FUND-12 — o reset devolve o container ao estado vazio', () {
    test('depois do reset nada está registrado', () async {
      await configureDependencies(logger: RecordingAppLogger());

      await resetDependencies();

      expect(getIt.isRegistered<AppLogger>(), isFalse);
      expect(getIt.isRegistered<GoRouter>(), isFalse);
      expect(getIt.isRegistered<FirebaseAuth>(), isFalse);
      expect(getIt.isRegistered<FirebaseFirestore>(), isFalse);
    });

    test('depois do reset dá para configurar de novo, com outro duplo',
        () async {
      await configureDependencies(logger: RecordingAppLogger());
      await resetDependencies();

      final novo = RecordingAppLogger();
      await configureDependencies(logger: novo);

      expect(getIt<AppLogger>(), same(novo));
    });
  });
}
