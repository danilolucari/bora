import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
import 'package:bora/core/festas/festas.dart';
import 'package:bora/features/montar/domain/rascunho_inicial.dart';
import 'package:bora/features/montar/presentation/bloc/montar_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/festa_em_edicao_repository_fake.dart';
import '../../../../support/recording_app_logger.dart';

const String _arquivoDoBloc =
    'lib/features/montar/presentation/bloc/montar_bloc.dart';

/// Uma quarta-feira qualquer: o rascunho não depende de quando o teste roda.
final DateTime _hoje = DateTime(2026, 7, 15);

/// Espera o bloc processar os eventos pendentes da fila.
Future<void> _assentar() => Future<void>.delayed(Duration.zero);

Pessoa _pessoa(String nome, {Dieta? dieta, bool? bebe}) => Pessoa(
      nome: nome,
      papel: PapelNaFesta.convidado,
      status: StatusDePresenca.confirmado,
      dieta: dieta,
      bebe: bebe,
    );

/// O item de [chave] na lista calculada, ou `null` se ele não entrou.
ItemDeLista? _itemDe(ResultadoDoCalculo resultado, ChaveItem chave) {
  for (final item in resultado.itens) {
    if (item.chave == chave) return item;
  }
  return null;
}

void main() {
  MontarBloc blocCom(FestaEmEdicao inicial) {
    final festas = FestaEmEdicaoRepositoryFake();
    addTearDown(festas.dispose);

    final bloc = MontarBloc(festas, RecordingAppLogger(), inicial: inicial);
    addTearDown(bloc.close);
    return bloc;
  }

  /// O rascunho de `/roles/novo`: 0/0/0, 4h e os sete itens padrão de RN-30.
  FestaEmEdicao rascunho() => rascunhoInicial(hoje: _hoje);

  /// O rascunho com a composição trocada — a única forma de pôr pessoas
  /// nomeadas na tela no M1, já que `galera` ainda não existe (A-10).
  FestaEmEdicao rascunhoCom({
    List<Pessoa> pessoas = const [],
    Set<ChaveItem>? itens,
    ContagemDePessoas? contagem,
    Map<ChaveItem, OverrideDeItem> overrides = const {},
  }) {
    final base = rascunho();

    return base.copyWith(
      composicao: ComposicaoDaFesta(
        contagem: contagem ?? ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
        duracaoHoras: base.composicao.duracaoHoras,
        pessoas: pessoas,
        itensSelecionados: itens ?? base.composicao.itensSelecionados,
        overrides: overrides,
      ),
    );
  }

  /// O estado padrão de RN-30 alcançado **pelos eventos da tela**: sete toques
  /// nos steppers, como o anfitrião faria.
  Future<MontarBloc> naContagemDeRn30() async {
    final bloc = blocCom(rascunho());

    for (var i = 0; i < 3; i++) {
      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, 1));
      bloc.add(const ContagemAlterada(TipoDeCabeca.mulheres, 1));
    }
    bloc.add(const ContagemAlterada(TipoDeCabeca.criancas, 1));
    await _assentar();

    return bloc;
  }

  group('MONT-04 — o custo muda embaixo do dedo, sem botão calcular', () {
    test('o estado inicial já vem calculado', () {
      final bloc = blocCom(rascunho());

      expect(
        bloc.state.resultado.itens,
        CalculadoraDaFesta.calcular(bloc.state.composicao).itens,
      );
      expect(bloc.state.festaId, isNull);
      expect(bloc.state.falhouAoSalvar, isFalse);
    });

    test('todo evento deixa resultado e composicao de acordo', () async {
      final bloc = await naContagemDeRn30();

      final eventos = <MontarEvent>[
        const ContagemAlterada(TipoDeCabeca.homens, 1),
        const ContagemAlterada(TipoDeCabeca.mulheres, -1),
        const ContagemAlterada(TipoDeCabeca.criancas, 1),
        const ItemAlternado(ChaveItem.suina),
        const ItemAlternado(ChaveItem.cerveja),
        const DuracaoAlterada(6),
      ];

      for (final evento in eventos) {
        bloc.add(evento);
        await _assentar();

        final recalculado = CalculadoraDaFesta.calcular(bloc.state.composicao);

        expect(
          bloc.state.resultado.totalDosItens,
          recalculado.totalDosItens,
          reason: '$evento emitiu sem passar pelo cálculo',
        );
        expect(bloc.state.resultado.fator, recalculado.fator, reason: '$evento');
        expect(
          bloc.state.resultado.itens.length,
          recalculado.itens.length,
          reason: '$evento',
        );
      }
    });

    test('um toque no stepper muda o total na mesma interação', () async {
      final bloc = await naContagemDeRn30();
      final antes = bloc.state.resultado.totalDosItens;

      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, 1));
      await _assentar();

      expect(bloc.state.resultado.totalDosItens, greaterThan(antes));
    });

    test('um toque no chip muda o total na mesma interação', () async {
      final bloc = await naContagemDeRn30();
      final antes = bloc.state.resultado.totalDosItens;

      bloc.add(const ItemAlternado(ChaveItem.whisky));
      await _assentar();

      expect(bloc.state.resultado.totalDosItens, greaterThan(antes));
    });

    test('um toque na duração muda o total na mesma interação', () async {
      final bloc = await naContagemDeRn30();
      final antes = bloc.state.resultado.totalDosItens;

      bloc.add(const DuracaoAlterada(6));
      await _assentar();

      expect(bloc.state.resultado.totalDosItens, greaterThan(antes));
    });
  });

  group('MONT-05 — o aceite de UC-03, alcançado pelos eventos da tela', () {
    test('o estado padrão de RN-30 sai por R\$ 211', () async {
      final bloc = await naContagemDeRn30();

      expect(bloc.state.resultado.totalDosItens, closeTo(210.6, 0.001));
      expect(
        MoneyFormatter.reais(bloc.state.resultado.totalDosItens),
        'R\$ 211',
      );
    });

    test('e dá ≈ R\$ 30 por cabeça, dividindo pelas 7 pessoas', () async {
      final bloc = await naContagemDeRn30();

      expect(bloc.state.resultado.contagem.pessoas, 7);
      expect(bloc.state.resultado.porCabeca, closeTo(30.0857, 0.001));
      expect(MoneyFormatter.reais(bloc.state.resultado.porCabeca), 'R\$ 30');
    });

    test('a contagem chegou a 3 homens, 3 mulheres e 1 criança', () async {
      final bloc = await naContagemDeRn30();

      expect(bloc.state.composicao.contagem.homens, 3);
      expect(bloc.state.composicao.contagem.mulheres, 3);
      expect(bloc.state.composicao.contagem.criancas, 1);
    });
  });

  group('MONT-14 / UC-03 E1 — o stepper não desce de 0', () {
    test('decremento em 0 mantém 0 e não lança, nos três steppers', () async {
      final bloc = blocCom(rascunho());

      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, -1));
      bloc.add(const ContagemAlterada(TipoDeCabeca.mulheres, -1));
      bloc.add(const ContagemAlterada(TipoDeCabeca.criancas, -1));
      await _assentar();

      expect(bloc.state.composicao.contagem.homens, 0);
      expect(bloc.state.composicao.contagem.mulheres, 0);
      expect(bloc.state.composicao.contagem.criancas, 0);
    });

    test('descer de 1 chega a 0, e o toque seguinte fica em 0', () async {
      final bloc = blocCom(rascunho());

      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, 1));
      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, -1));
      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, -1));
      await _assentar();

      expect(bloc.state.composicao.contagem.homens, 0);
    });

    test('festa sem ninguém tem lista vazia e total 0, com chips marcados',
        () async {
      final bloc = await naContagemDeRn30();

      for (var i = 0; i < 3; i++) {
        bloc.add(const ContagemAlterada(TipoDeCabeca.homens, -1));
        bloc.add(const ContagemAlterada(TipoDeCabeca.mulheres, -1));
      }
      bloc.add(const ContagemAlterada(TipoDeCabeca.criancas, -1));
      await _assentar();

      expect(bloc.state.composicao.itensSelecionados, hasLength(7));
      expect(bloc.state.resultado.itens, isEmpty);
      expect(bloc.state.resultado.totalDosItens, 0);
      expect(bloc.state.resultado.porCabeca, 0);
    });

    test('quando a contagem volta a subir, a lista volta', () async {
      final bloc = blocCom(rascunho());

      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, 1));
      await _assentar();

      expect(bloc.state.resultado.itens, isNotEmpty);
      expect(bloc.state.resultado.totalDosItens, greaterThan(0));
    });
  });

  group('MONT-20 — alternar o mesmo chip é determinístico', () {
    test('dois toques no mesmo chip voltam ao estado inicial', () async {
      final bloc = await naContagemDeRn30();
      final antes = bloc.state;

      bloc.add(const ItemAlternado(ChaveItem.suina));
      await _assentar();
      expect(bloc.state, isNot(antes));

      bloc.add(const ItemAlternado(ChaveItem.suina));
      await _assentar();

      expect(bloc.state, antes);
    });

    test('o chip não marcado entra e o marcado sai', () async {
      final bloc = blocCom(rascunho());

      bloc.add(const ItemAlternado(ChaveItem.suina));
      await _assentar();
      expect(bloc.state.composicao.itensSelecionados,
          contains(ChaveItem.suina));

      bloc.add(const ItemAlternado(ChaveItem.bovina));
      await _assentar();
      expect(
        bloc.state.composicao.itensSelecionados,
        isNot(contains(ChaveItem.bovina)),
      );
    });

    test('alternar um chip não mexe nos outros', () async {
      final bloc = blocCom(rascunho());
      final antes = {...bloc.state.composicao.itensSelecionados};

      bloc.add(const ItemAlternado(ChaveItem.whisky));
      await _assentar();

      expect(
        bloc.state.composicao.itensSelecionados.difference(antes),
        {ChaveItem.whisky},
      );
      expect(antes.difference(bloc.state.composicao.itensSelecionados), isEmpty);
    });
  });

  group('MONT-07 / RN-02 — a duração vira fator, vindo da camada', () {
    Future<double> fatorCom(int horas) async {
      final bloc = await naContagemDeRn30();

      bloc.add(DuracaoAlterada(horas));
      await _assentar();

      return bloc.state.resultado.fator;
    }

    test('2h vale o piso de meia duração', () async {
      expect(await fatorCom(2), 0.5);
    });

    test('4h vale 1', () async {
      expect(await fatorCom(4), 1.0);
    });

    test('6h vale 1,5', () async {
      expect(await fatorCom(6), 1.5);
    });

    test('o dia todo, 10h, vale 2,5', () async {
      expect(await fatorCom(10), 2.5);
    });

    test('a duração é espelhada em Festa e em ComposicaoDaFesta', () async {
      final bloc = blocCom(rascunho());

      bloc.add(const DuracaoAlterada(6));
      await _assentar();

      expect(bloc.state.composicao.duracaoHoras, 6);
      expect(
        bloc.state.festa.duracaoHoras,
        bloc.state.composicao.duracaoHoras,
        reason: 'divergirem faria o card-herói mostrar uma duração enquanto a '
            'conta usa outra',
      );
    });
  });

  group('MONT-24 — as preferências da galera realimentam a lista (RN-21)', () {
    test('uma pessoa veggie acrescenta o kit de legumes, sem chip', () async {
      final bloc = blocCom(
        rascunhoCom(pessoas: [_pessoa('Bia', dieta: Dieta.veggie)]),
      );

      expect(_itemDe(bloc.state.resultado, ChaveItem.legumesParaGrelha),
          isNotNull);
      expect(
        bloc.state.composicao.itensSelecionados,
        isNot(contains(ChaveItem.legumesParaGrelha)),
      );
    });

    test('sem porco tira a suína da lista e deixa o chip como estava',
        () async {
      final bloc = blocCom(
        rascunhoCom(
          pessoas: [_pessoa('Léo', dieta: Dieta.semPorco)],
          itens: {...rascunho().composicao.itensSelecionados, ChaveItem.suina},
        ),
      );

      expect(_itemDe(bloc.state.resultado, ChaveItem.suina), isNull);
      expect(
        bloc.state.composicao.itensSelecionados,
        contains(ChaveItem.suina),
        reason: 'o chip permanece no estado em que o usuário o deixou',
      );
    });

    test('a cerveja dimensiona por quem bebe, não por adultos', () async {
      final semNomeados = blocCom(rascunhoCom());
      final comAbstemios = blocCom(
        rascunhoCom(
          pessoas: [
            _pessoa('Duda', bebe: false),
            _pessoa('Nina', bebe: false),
          ],
        ),
      );

      final cervejaCheia =
          _itemDe(semNomeados.state.resultado, ChaveItem.cerveja)!;
      final cervejaReduzida =
          _itemDe(comAbstemios.state.resultado, ChaveItem.cerveja)!;

      expect(cervejaCheia.quantidade, 18);
      expect(cervejaReduzida.quantidade, 12);
    });

    test('sem pessoas nomeadas, nenhum efeito de RN-21 se aplica', () async {
      final bloc = blocCom(
        rascunhoCom(
          itens: {...rascunho().composicao.itensSelecionados, ChaveItem.suina},
        ),
      );

      expect(bloc.state.composicao.pessoas, isEmpty);
      expect(_itemDe(bloc.state.resultado, ChaveItem.suina), isNotNull);
      expect(
        _itemDe(bloc.state.resultado, ChaveItem.legumesParaGrelha),
        isNull,
      );
    });

    // P2-2 fala de "a lista", não de "a lista na abertura": os três efeitos
    // são propriedade da tela viva, e a tela viva é a que já recebeu toque.
    // As pessoas nomeadas não vêm de evento nenhum desta tela (A-10, no M1
    // quem as produz é `galera`), então o primeiro toque de stepper, chip ou
    // duração é justamente onde elas se perderiam sem ninguém notar.
    test('AC1: o kit veggie continua na lista depois do primeiro toque no '
        'stepper', () async {
      final bloc = blocCom(
        rascunhoCom(pessoas: [_pessoa('Bia', dieta: Dieta.veggie)]),
      );

      bloc.add(const ContagemAlterada(TipoDeCabeca.homens, 1));
      await _assentar();

      expect(bloc.state.composicao.pessoas, hasLength(1));
      expect(
        _itemDe(bloc.state.resultado, ChaveItem.legumesParaGrelha),
        isNotNull,
        reason: 'RN-21 dimensiona pela galera nomeada: se o toque a apagar, o '
            'kit some da lista e o anfitrião não vê por quê',
      );
    });

    test('AC2: o "sem porco" continua valendo depois de alternar outro chip',
        () async {
      final bloc = blocCom(
        rascunhoCom(
          pessoas: [_pessoa('Léo', dieta: Dieta.semPorco)],
          itens: {...rascunho().composicao.itensSelecionados, ChaveItem.suina},
        ),
      );

      bloc.add(const ItemAlternado(ChaveItem.agua));
      await _assentar();

      expect(bloc.state.composicao.pessoas, hasLength(1));
      expect(_itemDe(bloc.state.resultado, ChaveItem.suina), isNull);
      expect(
        bloc.state.composicao.itensSelecionados,
        contains(ChaveItem.suina),
        reason: 'o chip permanece no estado em que o usuário o deixou',
      );
    });

    test('AC3: a cerveja continua dimensionando por quem bebe depois de '
        'mudar a duração', () async {
      final semNomeados = blocCom(rascunhoCom());
      final comAbstemios = blocCom(
        rascunhoCom(
          pessoas: [
            _pessoa('Duda', bebe: false),
            _pessoa('Nina', bebe: false),
          ],
        ),
      );

      semNomeados.add(const DuracaoAlterada(6));
      comAbstemios.add(const DuracaoAlterada(6));
      await _assentar();

      expect(comAbstemios.state.composicao.pessoas, hasLength(2));
      expect(
        _itemDe(comAbstemios.state.resultado, ChaveItem.cerveja)!.quantidade,
        lessThan(
          _itemDe(semNomeados.state.resultado, ChaveItem.cerveja)!.quantidade,
        ),
        reason: 'RN-21 sobre RN-05: com dois abstêmios a cerveja tem de ficar '
            'abaixo da que a contagem sozinha pediria, em qualquer duração',
      );
    });

    // Non-Goals: nenhuma UI de `montar` **produz** override (isso é RN-12, da
    // spec 06 `lista`) — mas a camada de cálculo já os aceita, e apagá-los no
    // primeiro toque faria a tela Montar desfazer, em silêncio, o ajuste
    // manual que o anfitrião fez na Lista.
    test('o override de RN-12 sobrevive ao primeiro toque, mesmo sem esta '
        'tela produzir nenhum', () async {
      final bloc = blocCom(
        rascunhoCom(
          overrides: const {
            ChaveItem.cerveja: OverrideDeItem(quantidade: 42, preco: 7),
          },
        ),
      );

      bloc.add(const ContagemAlterada(TipoDeCabeca.mulheres, 1));
      await _assentar();

      final cerveja = _itemDe(bloc.state.resultado, ChaveItem.cerveja)!;

      expect(bloc.state.composicao.overrides, hasLength(1));
      expect(cerveja.quantidade, 42);
      expect(cerveja.preco, 7);
      expect(cerveja.editado, isTrue);
    });
  });

  group('MONT-08 — a conta mora num lugar só', () {
    test('o bloc chama CalculadoraDaFesta.calcular em um ponto só', () {
      final fonte = File(_arquivoDoBloc)
          .readAsStringSync()
          .replaceAll(RegExp(r'//.*'), '');

      expect(
        RegExp(r'CalculadoraDaFesta\.calcular\(').allMatches(fonte).length,
        1,
        reason: 'um segundo ponto de cálculo é o caminho de emissão que não '
            'passa por _emitirComCalculo',
      );
    });
  });

  group('MontarState — igualdade por valor', () {
    test('dois estados com os mesmos campos são iguais', () async {
      final a = blocCom(rascunho()).state;
      final b = blocCom(rascunho()).state;

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('trocar qualquer campo separa os estados', () async {
      final base = blocCom(rascunho()).state;

      expect(base.copyWith(festaId: 'festa-1'), isNot(base));
      expect(base.copyWith(festa: base.festa.copyWith(nome: 'OUTRO')),
          isNot(base));
      expect(base.copyWith(falhouAoSalvar: true), isNot(base));
    });

    test('copyWith preserva o campo não informado', () {
      final base = blocCom(rascunho()).state;

      final copia = base.copyWith(falhouAoSalvar: true);

      expect(copia.festa, base.festa);
      expect(copia.composicao, base.composicao);
      expect(copia.festaId, base.festaId);
      expect(copia.falhouAoSalvar, isTrue);
    });
  });
}
