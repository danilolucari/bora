import 'dart:io';

import 'package:bora/core/calculo/calculo.dart';
// A porta de entrada da camada é o barrel — importar `dominio/` direto
// contornaria o contrato que o próprio `festas.dart` declara. Este import é,
// ele mesmo, a asserção de que o barrel exporta `FestaEmEdicao`.
import 'package:bora/core/festas/festas.dart';
import 'package:flutter_test/flutter_test.dart';

const String _diretorioDaPorta = 'lib/core/festas';
const String _barrel = 'lib/core/festas/festas.dart';

/// O **único** alvo de fora da camada que `core/festas/dominio/` pode
/// importar (AD-029): o barrel de `core/calculo`.
const String _unicoImportDeFora = '../../calculo/calculo.dart';

/// Um irmão dentro da própria `dominio/` — `festa_em_edicao.dart`. Não sai da
/// camada, então não é import "de fora": a regra da AD-029 é sobre o que a
/// porta **conhece** (nada de `features/`, Flutter ou Firebase), não sobre a
/// porta se referenciar. `dart:ui` não escapa por aqui — tem `:`, e o padrão
/// exige nome de arquivo puro.
final RegExp _irmaoDaCamada = RegExp(r'^[a-z_]+\.dart$');

bool _saiDaCamada(String alvo) =>
    alvo != _unicoImportDeFora && !_irmaoDaCamada.hasMatch(alvo);

final RegExp _diretivaDeImport = RegExp(
  r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''',
  multiLine: true,
);

List<String> _alvosDe(String conteudoDart) => _diretivaDeImport
    .allMatches(conteudoDart)
    .map((m) => m.group(1)!)
    .toList();

List<File> _arquivosDartEm(String caminho) => Directory(caminho)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

/// Uma linha por violação, no formato `<arquivo>: <import>` — é o que nomeia o
/// arquivo infrator quando a suíte quebra.
List<String> _importsForaDeCalculo(String diretorio) => [
      for (final arquivo in _arquivosDartEm('$diretorio/dominio'))
        for (final alvo in _alvosDe(arquivo.readAsStringSync()))
          if (_saiDaCamada(alvo)) '${arquivo.path}: $alvo',
    ];

Festa _festa({String nome = 'CHURRAS DO RAFA 🔥', int duracaoHoras = 4}) =>
    Festa(
      nome: nome,
      data: 'SÁB · 18 JUL',
      hora: '14H',
      local: 'Laje do Rafa — Vila Madalena',
      duracaoHoras: duracaoHoras,
    );

/// O estado padrão de RN-30, montado do zero a cada chamada: coleções novas
/// toda vez, que é o que faz a igualdade **profunda** ser testada de verdade.
ComposicaoDaFesta _composicaoPadrao({int duracaoHoras = 4}) =>
    ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: duracaoHoras,
      itensSelecionados: {
        ChaveItem.bovina,
        ChaveItem.frango,
        ChaveItem.paoDeAlho,
        ChaveItem.refrigerante,
        ChaveItem.agua,
        ChaveItem.cerveja,
        ChaveItem.cachaca,
      },
    );

void main() {
  group('AD-029 — FestaEmEdicao é a festa como montar precisa dela', () {
    test('carrega a identidade e a composição, sem inventar id', () {
      final emEdicao =
          FestaEmEdicao(festa: _festa(), composicao: _composicaoPadrao());

      expect(emEdicao.festa, _festa());
      expect(emEdicao.composicao, _composicaoPadrao());
    });
  });

  group('AD-029 — igualdade por valor profundo', () {
    test('duas instâncias com a mesma festa e a mesma composição são iguais',
        () {
      final a = FestaEmEdicao(festa: _festa(), composicao: _composicaoPadrao());
      final b = FestaEmEdicao(festa: _festa(), composicao: _composicaoPadrao());

      expect(a, b);
    });

    test('instâncias iguais têm o mesmo hashCode', () {
      final a = FestaEmEdicao(festa: _festa(), composicao: _composicaoPadrao());
      final b = FestaEmEdicao(festa: _festa(), composicao: _composicaoPadrao());

      expect(a.hashCode, b.hashCode);
    });

    test('trocar a festa separa as duas', () {
      final composicao = _composicaoPadrao();
      final a = FestaEmEdicao(festa: _festa(), composicao: composicao);
      final b = FestaEmEdicao(
        festa: _festa(nome: 'CHURRAS NOVO'),
        composicao: composicao,
      );

      expect(a, isNot(b));
    });

    test('trocar a composição separa as duas', () {
      final festa = _festa();
      final a = FestaEmEdicao(festa: festa, composicao: _composicaoPadrao());
      final b = FestaEmEdicao(
        festa: festa,
        composicao: _composicaoPadrao(duracaoHoras: 6),
      );

      expect(a, isNot(b));
    });

    test('a composição é comparada por conteúdo, não por identidade de coleção',
        () {
      final a = FestaEmEdicao(
        festa: _festa(),
        composicao: ComposicaoDaFesta(
          contagem: ContagemDePessoas(homens: 1),
          duracaoHoras: 4,
          itensSelecionados: {ChaveItem.bovina, ChaveItem.cerveja},
        ),
      );
      final b = FestaEmEdicao(
        festa: _festa(),
        composicao: ComposicaoDaFesta(
          contagem: ContagemDePessoas(homens: 1),
          duracaoHoras: 4,
          itensSelecionados: {ChaveItem.bovina, ChaveItem.cerveja},
        ),
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('AD-029 — copyWith preserva o campo não informado', () {
    test('sem argumento nenhum, devolve um valor igual ao original', () {
      final original =
          FestaEmEdicao(festa: _festa(), composicao: _composicaoPadrao());

      expect(original.copyWith(), original);
    });

    test('trocando a festa, a composição é preservada', () {
      final original =
          FestaEmEdicao(festa: _festa(), composicao: _composicaoPadrao());

      final copia = original.copyWith(festa: _festa(nome: 'CHURRAS NOVO'));

      expect(copia.festa.nome, 'CHURRAS NOVO');
      expect(copia.composicao, _composicaoPadrao());
    });

    test('trocando a composição, a festa é preservada', () {
      final original =
          FestaEmEdicao(festa: _festa(), composicao: _composicaoPadrao());

      final copia =
          original.copyWith(composicao: _composicaoPadrao(duracaoHoras: 2));

      expect(copia.festa, _festa());
      expect(copia.composicao.duracaoHoras, 2);
    });
  });

  group('AD-029 — a porta fala só em tipos de core/calculo', () {
    test('nenhum arquivo de core/festas/dominio importa fora de core/calculo',
        () {
      expect(
        _importsForaDeCalculo(_diretorioDaPorta),
        isEmpty,
        reason: 'a porta em core/ não pode conhecer features/, Flutter nem '
            'Firebase — é o que a AD-029 compra',
      );
    });

    test('a varredura não roda vazia: o diretório existe e tem arquivo .dart',
        () {
      expect(_arquivosDartEm('$_diretorioDaPorta/dominio'), isNotEmpty);
    });

    test('a varredura acusa o import proibido nomeando o arquivo infrator', () {
      final infrator = File('$_diretorioDaPorta/dominio/infrator_de_teste.dart');
      addTearDown(() {
        if (infrator.existsSync()) infrator.deleteSync();
      });
      infrator.writeAsStringSync(
        "import 'package:flutter/material.dart';\n"
        "import 'dart:ui';\n"
        "import '../../../features/home/domain/resumo_de_festa.dart';\n"
        // O irmão da própria camada não é violação — se fosse, a porta não
        // poderia declarar o próprio tipo de retorno.
        "import 'festa_em_edicao.dart';\n",
      );

      final violacoes = _importsForaDeCalculo(_diretorioDaPorta);

      expect(violacoes, hasLength(3));
      expect(violacoes.every((v) => v.contains('infrator_de_teste.dart')), isTrue);
      expect(violacoes[0], contains('package:flutter/material.dart'));
      expect(violacoes[1], contains('dart:ui'));
      expect(violacoes[2], contains('resumo_de_festa.dart'));
    });

    test('import de irmão da própria camada não é acusado', () {
      expect(_saiDaCamada('festa_em_edicao.dart'), isFalse);
      expect(_saiDaCamada('../../calculo/calculo.dart'), isFalse);
      expect(_saiDaCamada('package:firebase_core/firebase_core.dart'), isTrue);
      expect(_saiDaCamada('package:flutter_bloc/flutter_bloc.dart'), isTrue);
    });

    test('o barrel é a única porta: só exporta arquivos de dominio/', () {
      final alvos = _alvosDe(File(_barrel).readAsStringSync());

      expect(alvos, isNotEmpty);
      expect(
        alvos.where((a) => !a.startsWith('dominio/')),
        isEmpty,
        reason: 'o barrel exporta a camada, e nada além dela',
      );
    });
  });
}
