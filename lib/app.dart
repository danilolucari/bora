import 'package:flutter/material.dart';

/// Raiz do app BORA.
///
/// Mínima de propósito: o roteador (`MaterialApp.router`) e o título literal de
/// W-R5 entram quando a tabela de rotas existir. Nenhum token da spec 01 aqui.
class BoraApp extends StatelessWidget {
  const BoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: Text('BORA.')),
      ),
    );
  }
}
