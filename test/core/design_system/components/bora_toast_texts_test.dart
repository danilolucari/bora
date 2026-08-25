import 'package:bora/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DS-12 — os textos canônicos de RN-29, caractere por caractere', () {
    test('cada constante é o literal que RN-29 declara', () {
      expect(BoraToastTexts.linkCopiado, 'LINK COPIADO 🔗');
      expect(BoraToastTexts.roleSalvo, 'ROLÊ SALVO ✊');
      expect(BoraToastTexts.conviteCopiado, 'CONVITE COPIADO 📋');
      expect(BoraToastTexts.listaNoGrupo, 'LISTA NO GRUPO 📲');
      expect(
        BoraToastTexts.abrindoWhatsapp,
        'ABRINDO O WHATSAPP… 📲',
        reason: 'as reticências são o caractere unicode …, não três pontos',
      );
      expect(BoraToastTexts.salvoNaAgenda, 'SALVO NA AGENDA 📅');
      expect(BoraToastTexts.lembreteMandado, 'LEMBRETE MANDADO NO GRUPO 📲');
      expect(BoraToastTexts.cobrancaEnviada, 'COBRANÇA ENVIADA NO PIX 📲');
      expect(BoraToastTexts.grupoCriado, 'GRUPO CRIADO NO WHATSAPP ✅');
      expect(BoraToastTexts.enquetePostada, 'ENQUETE POSTADA NO GRUPO 📲');
      expect(BoraToastTexts.crieOGrupoPrimeiro, 'CRIE O GRUPO PRIMEIRO ☝️');
    });

    test('todos traz os onze, sem repetição, na ordem de RN-29', () {
      expect(BoraToastTexts.todos, hasLength(11));
      expect(BoraToastTexts.todos.toSet(), hasLength(11));
      expect(BoraToastTexts.todos.first, BoraToastTexts.linkCopiado);
      expect(BoraToastTexts.todos.last, BoraToastTexts.crieOGrupoPrimeiro);
    });

    test('todo texto está em CAIXA ALTA e termina com emoji', () {
      for (final texto in BoraToastTexts.todos) {
        expect(
          texto,
          texto.toUpperCase(),
          reason: '§7: "títulos, labels, botões e toasts em CAIXA ALTA"',
        );
        expect(
          texto.runes.last,
          greaterThan(0x2000),
          reason: '§5: "Texto em CAIXA ALTA com emoji final" — $texto',
        );
      }
    });
  });
}
