import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';
import '../bloc/entrar_bloc.dart';
import '../entrar_textos.dart';
import 'formulario_de_entrada.dart';

/// T-01 — coluna centralizada, padding lateral 30px.
class EntrarCompacto extends StatelessWidget {
  const EntrarCompacto({
    required this.estado,
    required this.email,
    required this.senha,
    required this.aoSubmeter,
    required this.aoEntrarComGoogle,
    required this.aoAlternarModo,
    super.key,
  });

  /// Padding lateral de T-01.
  static const double paddingLateral = 30;

  /// Largura máxima do parágrafo de apresentação (T-01: "máx 260px").
  static const double larguraDaApresentacao = 260;

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
        // Rola para que o teclado do celular não estoure o layout — edge case
        // da spec.
        padding: const EdgeInsets.symmetric(
          horizontal: paddingLateral,
          vertical: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: BoraMarca.compacta()),
            const SizedBox(height: 14),
            const Center(
              child: BoraRotatedTag(texto: EntrarTextos.tagline),
            ),
            const SizedBox(height: 20),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: larguraDaApresentacao,
                ),
                child: Text(
                  EntrarTextos.apresentacao,
                  textAlign: TextAlign.center,
                  style: BoraTextStyles.corpo,
                ),
              ),
            ),
            const SizedBox(height: 32),
            FormularioDeEntrada(
              estado: estado,
              email: email,
              senha: senha,
              // A-05: a copy do Google difere entre plataformas, e as duas
              // ficam literais.
              rotuloDoGoogle: EntrarTextos.googleCompacto,
              aoSubmeter: aoSubmeter,
              aoEntrarComGoogle: aoEntrarComGoogle,
              aoAlternarModo: aoAlternarModo,
            ),
          ],
        ),
      ),
    );
  }
}
