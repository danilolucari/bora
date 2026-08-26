import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../bloc/entrar_bloc.dart';
import '../entrar_textos.dart';
import 'divisor_ou.dart';

/// Os campos, o CTA, o divisor e o botão do Google — o miolo comum a T-01 e
/// W-01.
///
/// Existe para que os dois layouts não copiem o formulário: eles diferem no
/// enquadramento (coluna centralizada × card em duas colunas) e na copy do
/// botão do Google (A-05), não no que o formulário faz.
class FormularioDeEntrada extends StatelessWidget {
  const FormularioDeEntrada({
    required this.estado,
    required this.email,
    required this.senha,
    required this.rotuloDoGoogle,
    required this.aoSubmeter,
    required this.aoEntrarComGoogle,
    required this.aoAlternarModo,
    super.key,
  });

  /// Chave da mensagem de falha — é por ela que o teste afirma presença **e
  /// ausência**, que é o par que discrimina.
  static const Key mensagemDeFalhaKey = Key('entrar-falha');

  final EntrarState estado;
  final TextEditingController email;
  final TextEditingController senha;

  /// A copy do Google muda por plataforma (A-05), então quem monta decide.
  final String rotuloDoGoogle;

  final VoidCallback aoSubmeter;
  final VoidCallback aoEntrarComGoogle;
  final VoidCallback aoAlternarModo;

  @override
  Widget build(BuildContext context) {
    final falha = EntrarTextos.mensagemDe(estado.falha);
    final erroDeEmail = EntrarTextos.mensagemDeEmail(estado.erroDeEmail);
    final erroDeSenha = EntrarTextos.mensagemDeSenha(estado.erroDeSenha);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        BoraTextField(
          controller: email,
          placeholder: EntrarTextos.placeholderEmail,
        ),
        if (erroDeEmail != null) _Erro(texto: erroDeEmail),
        const SizedBox(height: 12),
        BoraTextField(
          controller: senha,
          placeholder: EntrarTextos.placeholderSenha,
          // ENT-21: senha legível na tela é defeito.
          obscureText: true,
        ),
        if (erroDeSenha != null) _Erro(texto: erroDeSenha),
        if (falha != null) _Erro(texto: falha, chave: mensagemDeFalhaKey),
        const SizedBox(height: 16),
        BoraPrimaryButton(
          rotulo: EntrarTextos.cta(estado.modo),
          larguraTotal: true,
          // ENT-07/ENT-10: `null` deixa o CTA inerte enquanto envia — é aqui
          // que "um login por toque" é garantido, e não no bloc.
          onPressed: estado.enviando ? null : aoSubmeter,
        ),
        const SizedBox(height: 18),
        const DivisorOu(),
        const SizedBox(height: 18),
        BoraSecondaryButton(
          rotulo: rotuloDoGoogle,
          onPressed: estado.enviando ? null : aoEntrarComGoogle,
        ),
        const SizedBox(height: 20),
        _Rodape(modo: estado.modo, aoAlternar: aoAlternarModo),
      ],
    );
  }
}

class _Erro extends StatelessWidget {
  const _Erro({required this.texto, this.chave});

  final String texto;
  final Key? chave;

  @override
  Widget build(BuildContext context) => Padding(
        key: chave,
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          texto,
          style: BoraTextStyles.labelSecao.copyWith(color: BoraColors.primary),
        ),
      );
}

class _Rodape extends StatelessWidget {
  const _Rodape({required this.modo, required this.aoAlternar});

  final ModoDeEntrada modo;
  final VoidCallback aoAlternar;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          EntrarTextos.rodapePergunta(modo),
          style: BoraTextStyles.dica,
        ),
        GestureDetector(
          onTap: aoAlternar,
          child: Text(
            EntrarTextos.rodapeAcao(modo),
            style: BoraTextStyles.dica.copyWith(
              color: BoraColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
