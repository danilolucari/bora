import 'dart:io';

// A porta de entrada da camada — e o **único** import de `core/calculo` deste
// arquivo, de propósito (CALC-27). Nenhum arquivo interno da pasta é
// importado: se algo essencial não estiver exportado pelo barrel, este teste
// não compila. `dart:io` entra só para a varredura de exaustividade do fim.
import 'package:bora/core/calculo/calculo.dart';
import 'package:flutter_test/flutter_test.dart';

const String _barrel = 'lib/core/calculo/calculo.dart';
const List<String> _pastasDaCamada = ['dominio', 'regras', 'formatacao'];

/// O estado padrão de RN-10, montado **só** com o que o barrel expõe.
ComposicaoDaFesta _estadoPadrao() => ComposicaoDaFesta(
      contagem: ContagemDePessoas(homens: 3, mulheres: 3, criancas: 1),
      duracaoHoras: 4,
      itensSelecionados: const {
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
  group('CALC-27 — a camada inteira sai por uma porta só', () {
    test('o caso literal R\$ 211 se reproduz importando apenas o barrel', () {
      final resultado = CalculadoraDaFesta.calcular(_estadoPadrao());

      expect(resultado.totalDosItens, closeTo(210.6, 0.001));
      expect(MoneyFormatter.reais(resultado.totalDosItens), 'R\$ 211');
      expect(MoneyFormatter.reais(resultado.porCabeca), 'R\$ 30');
      expect(resultado.totalComEssenciais, closeTo(270.6, 0.001));
      expect(MoneyFormatter.reais(resultado.totalComEssenciais), 'R\$ 271');
      expect(MoneyFormatter.reais(resultado.porAdulto), 'R\$ 45');
    });

    test('os dois contratos de fronteira com a spec 01 chegam prontos', () {
      expect(
        MoneyFormatter.reais(210.6),
        'R\$ 211',
        reason: 'a UI nunca formata dinheiro por conta própria (RN-13)',
      );
      expect(
        posicaoDoMarcador(tabelaDePrecosDeMercado.first),
        closeTo(11 / 29, 1e-9),
        reason: 'a UI recebe a posição resolvida em [0,1] e só pinta (RN-11)',
      );
      expect(rotuloDeDuracao(10), 'Dia todo');
    });
  });

  group('CALC-27 — recalcular a mesma composição dá o mesmo resultado', () {
    test('duas passadas produzem itens, essenciais e totais idênticos', () {
      final composicao = _estadoPadrao();

      final primeira = CalculadoraDaFesta.calcular(composicao);
      final segunda = CalculadoraDaFesta.calcular(composicao);

      expect(segunda.itens, primeira.itens);
      expect(segunda.essenciais, primeira.essenciais);
      expect(segunda.contagem, primeira.contagem);
      expect(segunda.fator, primeira.fator);
      expect(segunda.totalDosItens, primeira.totalDosItens);
      expect(segunda.totalDosEssenciais, primeira.totalDosEssenciais);
      expect(segunda.porCabeca, primeira.porCabeca);
      expect(segunda.porAdulto, primeira.porAdulto);
    });

    test('composições iguais construídas em separado dão o mesmo total', () {
      final primeira = CalculadoraDaFesta.calcular(_estadoPadrao());
      final segunda = CalculadoraDaFesta.calcular(_estadoPadrao());

      expect(segunda.totalDosItens, primeira.totalDosItens);
      expect(segunda.todosOsItens, primeira.todosOsItens);
    });
  });

  group('CALC-27 — o barrel não deixa nenhum arquivo da camada de fora', () {
    test('todo .dart de dominio/, regras/ e formatacao/ é exportado', () {
      final conteudo = File(_barrel).readAsStringSync();

      final naoExportados = <String>[];
      for (final pasta in _pastasDaCamada) {
        final arquivos = Directory('lib/core/calculo/$pasta')
            .listSync()
            .whereType<File>()
            .where((arquivo) => arquivo.path.endsWith('.dart'))
            .map((arquivo) => arquivo.uri.pathSegments.last);

        for (final arquivo in arquivos) {
          if (!conteudo.contains("export '$pasta/$arquivo';")) {
            naoExportados.add('$pasta/$arquivo');
          }
        }
      }

      expect(
        naoExportados,
        isEmpty,
        reason: 'arquivo da camada fora do barrel — a feature seria obrigada a '
            'importar o arquivo interno, contornando a porta única (AD-008)',
      );
    });

    test('a varredura não roda vazia', () {
      for (final pasta in _pastasDaCamada) {
        expect(
          Directory('lib/core/calculo/$pasta').listSync(),
          isNotEmpty,
          reason: pasta,
        );
      }
    });
  });
}
