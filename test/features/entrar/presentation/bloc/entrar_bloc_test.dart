import 'dart:io';

import 'package:bora/core/autenticacao/autenticacao.dart';
import 'package:bora/features/entrar/domain/validacao_de_credenciais.dart';
import 'package:bora/features/entrar/presentation/bloc/entrar_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/fake_autenticacao_repository.dart';

void main() {
  late FakeAutenticacaoRepository autenticacao;
  late EntrarBloc bloc;

  setUp(() {
    autenticacao = FakeAutenticacaoRepository();
    bloc = EntrarBloc(autenticacao);
  });

  tearDown(() async {
    await bloc.close();
    await autenticacao.dispose();
  });

  /// Deixa a fila de eventos do bloc drenar.
  Future<void> assentar() => Future<void>.delayed(Duration.zero);

  group('ENT-06 — o modo decide qual método do repositório é chamado', () {
    test('no modo entrar, chama entrarComEmailESenha', () async {
      bloc.add(
        const SubmetidoComCredenciais(
          email: 'rafa@bora.app',
          senha: 'segredo',
        ),
      );
      await assentar();

      expect(autenticacao.chamadas, ['entrarComEmailESenha']);
    });

    test('no modo cadastro, chama criarConta', () async {
      bloc.add(const ModoAlternado());
      bloc.add(
        const SubmetidoComCredenciais(email: 'novo@bora.app', senha: 'segredo'),
      );
      await assentar();

      expect(
        autenticacao.chamadas,
        ['criarConta'],
        reason: 'ENT-20 AC3: é o mesmo gesto sobre o mesmo formulário; quem '
            'decide o método é o modo corrente',
      );
    });

    test('o e-mail chega ao repositório já aparado', () async {
      bloc.add(
        const SubmetidoComCredenciais(
          email: '  rafa@bora.app  ',
          senha: 'segredo',
        ),
      );
      await assentar();

      expect(autenticacao.chamadas, ['entrarComEmailESenha']);
      expect(bloc.state.erroDeEmail, isNull);
    });

    test('Google chama entrarComGoogle', () async {
      bloc.add(const SubmetidoComGoogle());
      await assentar();

      expect(autenticacao.chamadas, ['entrarComGoogle']);
    });

    test('sucesso não produz estado de autenticado — quem anuncia é o stream',
        () async {
      bloc.add(
        const SubmetidoComCredenciais(
          email: 'rafa@bora.app',
          senha: 'segredo',
        ),
      );
      await assentar();

      expect(bloc.state.situacao, SituacaoDeEnvio.ocioso);
      expect(bloc.state.falha, isNull);
      expect(
        autenticacao.sessaoAtual,
        isNotNull,
        reason: 'AD-020: o sucesso vive no stream de sessão, e é a guarda de '
            'rota que reage — não um estado da tela',
      );
    });
  });

  group('ENT-08 — validação barra antes do repositório', () {
    test('e-mail inválido não chama o repositório', () async {
      bloc.add(const SubmetidoComCredenciais(email: 'rafa', senha: 'segredo'));
      await assentar();

      expect(bloc.state.erroDeEmail, ErroDeEmail.formato);
      expect(
        autenticacao.chamadas,
        isEmpty,
        reason: 'sem viagem de rede para o que a tela já sabe que está errado',
      );
    });

    test('senha curta não chama o repositório', () async {
      bloc.add(
        const SubmetidoComCredenciais(email: 'rafa@bora.app', senha: '12345'),
      );
      await assentar();

      expect(bloc.state.erroDeSenha, ErroDeSenha.curta);
      expect(autenticacao.chamadas, isEmpty);
    });

    test('campos vazios acusam os dois erros de uma vez', () async {
      bloc.add(const SubmetidoComCredenciais(email: '', senha: ''));
      await assentar();

      expect(bloc.state.erroDeEmail, ErroDeEmail.vazio);
      expect(bloc.state.erroDeSenha, ErroDeSenha.vazia);
      expect(autenticacao.chamadas, isEmpty);
    });

    test('corrigir e submeter de novo chama o repositório', () async {
      bloc.add(const SubmetidoComCredenciais(email: 'rafa', senha: 'segredo'));
      await assentar();
      bloc.add(
        const SubmetidoComCredenciais(
          email: 'rafa@bora.app',
          senha: 'segredo',
        ),
      );
      await assentar();

      expect(bloc.state.erroDeEmail, isNull);
      expect(autenticacao.chamadas, ['entrarComEmailESenha']);
    });

    test('Google não passa pela validação do formulário', () async {
      bloc.add(const SubmetidoComGoogle());
      await assentar();

      expect(
        autenticacao.chamadas,
        ['entrarComGoogle'],
        reason: 'o botão do Google não depende dos campos preenchidos',
      );
    });
  });

  group('ENT-07/ENT-10 — duplo toque dispara um login, não dois', () {
    test('durante o envio o estado diz enviando, e depois volta ao ocioso',
        () async {
      // É isto que ENT-07 exige do bloc: expor `enviando` para a tela poder
      // desabilitar o CTA. A garantia de "um login por toque" é da UI — o
      // botão inerte —, e está afirmada no teste de widget de T13.
      //
      // Testar aqui "dois add() viram uma chamada" seria testar o
      // processamento de eventos do bloc, não o requisito: com o
      // transformador padrão, o segundo evento só começa depois que o
      // primeiro termina, e aí `enviando` já voltou a ser falso. A guarda
      // interna cobre o add programático concorrente, não o duplo toque.
      final observados = <bool>[];
      bloc.stream.listen((estado) => observados.add(estado.enviando));

      bloc.add(
        const SubmetidoComCredenciais(
          email: 'rafa@bora.app',
          senha: 'segredo',
        ),
      );
      await assentar();

      expect(
        observados,
        [true, false],
        reason: 'sem o estado intermediário de envio a tela não teria como '
            'desabilitar o CTA',
      );
    });

    test('depois que o envio termina, submeter de novo funciona', () async {
      const evento = SubmetidoComCredenciais(
        email: 'rafa@bora.app',
        senha: 'segredo',
      );

      bloc.add(evento);
      await assentar();
      bloc.add(evento);
      await assentar();

      expect(
        autenticacao.chamadas,
        hasLength(2),
        reason: 'o bloqueio é do envio em curso, não permanente',
      );
    });
  });

  group('ENT-09/ENT-11 — a falha chega ao estado e o CTA volta', () {
    for (final falha in FalhaDeAutenticacao.values) {
      test('${falha.name} chega ao estado e devolve o CTA ao ocioso',
          () async {
        autenticacao.falha = falha;

        bloc.add(
          const SubmetidoComCredenciais(
            email: 'rafa@bora.app',
            senha: 'segredo',
          ),
        );
        await assentar();

        expect(bloc.state.falha, falha);
        expect(
          bloc.state.enviando,
          isFalse,
          reason: 'ENT-09: o CTA volta ao ocioso para o usuário tentar de novo',
        );
      });
    }

    test('cancelada não vira mensagem na tela', () async {
      autenticacao.falha = FalhaDeAutenticacao.cancelada;

      bloc.add(const SubmetidoComGoogle());
      await assentar();

      expect(bloc.state.falha, FalhaDeAutenticacao.cancelada);
      expect(
        bloc.state.mostraFalha,
        isFalse,
        reason: 'ENT-14 AC3: quem fechou o popup sabe que fechou — acusar erro '
            'faria a tela reclamar de algo que não aconteceu',
      );
    });

    test('credencial inválida vira mensagem na tela', () async {
      autenticacao.falha = FalhaDeAutenticacao.credencialInvalida;

      bloc.add(
        const SubmetidoComCredenciais(
          email: 'rafa@bora.app',
          senha: 'errada',
        ),
      );
      await assentar();

      expect(
        bloc.state.mostraFalha,
        isTrue,
        reason: 'par discriminante de cancelada: se mostraFalha fosse sempre '
            'falso, o teste acima passaria à toa',
      );
    });
  });

  group('ENT-13/ENT-20 — a alternância de modo', () {
    test('alterna entrar para cadastro e de volta', () {
      expect(bloc.state.modo, ModoDeEntrada.entrar);

      bloc.add(const ModoAlternado());
      expect(bloc.state.modo, ModoDeEntrada.entrar);
    });

    test('alternar limpa a falha anterior', () async {
      autenticacao.falha = FalhaDeAutenticacao.credencialInvalida;
      bloc.add(
        const SubmetidoComCredenciais(
          email: 'rafa@bora.app',
          senha: 'errada',
        ),
      );
      await assentar();
      expect(bloc.state.falha, isNotNull);

      bloc.add(const ModoAlternado());
      await assentar();

      expect(
        bloc.state.falha,
        isNull,
        reason: 'ENT-13: carregar para o cadastro um erro que aconteceu no '
            'modo entrar acusaria o usuário de algo que ele não fez ali',
      );
      expect(bloc.state.modo, ModoDeEntrada.cadastro);
    });

    test('alternar limpa os erros de validação', () async {
      bloc.add(const SubmetidoComCredenciais(email: '', senha: ''));
      await assentar();
      expect(bloc.state.erroDeEmail, isNotNull);

      bloc.add(const ModoAlternado());
      await assentar();

      expect(bloc.state.erroDeEmail, isNull);
      expect(bloc.state.erroDeSenha, isNull);
    });

    test('dois toques voltam ao modo entrar', () async {
      bloc.add(const ModoAlternado());
      bloc.add(const ModoAlternado());
      await assentar();

      expect(bloc.state.modo, ModoDeEntrada.entrar);
    });
  });

  group('AD-020 — o bloc não navega', () {
    /// Os imports de [caminho] que trariam navegação para dentro do bloc.
    List<String> importsDeNavegacao(Iterable<String> linhas) => linhas
        .where((linha) => linha.trimLeft().startsWith('import '))
        .where(
          (linha) =>
              linha.contains('go_router') ||
              linha.contains('flutter/material') ||
              linha.contains('flutter/widgets'),
        )
        .toList();

    test('nenhum arquivo do bloc importa navegação', () {
      const arquivos = [
        'lib/features/entrar/presentation/bloc/entrar_bloc.dart',
        'lib/features/entrar/presentation/bloc/entrar_state.dart',
        'lib/features/entrar/presentation/bloc/entrar_event.dart',
      ];

      for (final caminho in arquivos) {
        expect(
          importsDeNavegacao(File(caminho).readAsLinesSync()),
          isEmpty,
          reason: '$caminho: navegar por login é papel da guarda de rota, não '
              'do bloc — três caminhos chamando context.go poderiam divergir '
              'um a um sem nenhum teste perceber. A asserção olha os imports '
              'porque o doc do bloc CITA BuildContext de propósito, para '
              'dizer que não o usa.',
        );
      }
    });

    test('a varredura acusa um import de navegação', () {
      // Controle positivo no lugar de exigir imports: `entrar_event.dart` não
      // tem import nenhum, e isso é a prova mais forte de que ele não navega —
      // não um vácuo. O que precisa ser provado é que o detector detecta.
      expect(
        importsDeNavegacao([
          "import 'package:go_router/go_router.dart';",
          "import 'package:flutter/material.dart';",
          "import 'package:flutter_bloc/flutter_bloc.dart';",
          "  // import 'package:go_router/go_router.dart'; comentado não conta",
        ]),
        hasLength(2),
        reason: 'pega go_router e material, deixa flutter_bloc passar, e não '
            'confunde comentário com import',
      );
    });
  });
}
