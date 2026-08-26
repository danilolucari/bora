import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../bloc/entrar_bloc.dart';
import '../entrar_textos.dart';
import 'formulario_de_entrada.dart';
import 'marca_bora.dart';

/// W-01 — duas colunas centralizadas: marca à esquerda, card à direita.
class EntrarExpandido extends StatelessWidget {
  const EntrarExpandido({
    required this.estado,
    required this.email,
    required this.senha,
    required this.aoSubmeter,
    required this.aoEntrarComGoogle,
    required this.aoAlternarModo,
    super.key,
  });

  /// W-01: `gap: 74px` entre as colunas.
  static const double espacoEntreColunas = 74;

  /// W-01: coluna da marca, máx 410px.
  static const double larguraDaMarca = 410;

  /// W-01: coluna do formulário, 340px.
  static const double larguraDoCard = 340;

  /// W-01: parágrafo com máx 300px (um degrau acima dos 260 de T-01).
  static const double larguraDaApresentacao = 300;

  /// W-01: "sombra 10px 10px 0 `ink`" — mais funda que a do CTA.
  static const double sombraDoCard = 10;

  /// W-01: padding 30px dentro do card.
  static const EdgeInsets paddingDoCard = EdgeInsets.all(30);

  final EntrarState estado;
  final TextEditingController email;
  final TextEditingController senha;
  final VoidCallback aoSubmeter;
  final VoidCallback aoEntrarComGoogle;
  final VoidCallback aoAlternarModo;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 50),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: larguraDaMarca),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const MarcaBora.expandida(),
                    const SizedBox(height: 16),
                    const BoraRotatedTag(texto: EntrarTextos.tagline),
                    const SizedBox(height: 22),
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: larguraDaApresentacao,
                      ),
                      child: Text(
                        EntrarTextos.apresentacao,
                        style: BoraTextStyles.corpo,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: espacoEntreColunas),
              SizedBox(
                width: larguraDoCard,
                child: BoraSurface(
                  acento: BoraAccent.ink,
                  deslocamentoDaSombra: sombraDoCard,
                  padding: paddingDoCard,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        EntrarTextos.label(estado.modo),
                        style: BoraTextStyles.labelSecao,
                      ),
                      const SizedBox(height: 18),
                      FormularioDeEntrada(
                        estado: estado,
                        email: email,
                        senha: senha,
                        // A-05: no web a copy é outra, e as duas são literais.
                        rotuloDoGoogle: EntrarTextos.googleExpandido,
                        aoSubmeter: aoSubmeter,
                        aoEntrarComGoogle: aoEntrarComGoogle,
                        aoAlternarModo: aoAlternarModo,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
