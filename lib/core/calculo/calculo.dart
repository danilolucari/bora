/// Camada de cálculo do BORA — território das regras RN-01..RN-29.
///
/// Dart puro por contrato: nenhum arquivo desta pasta pode importar
/// `package:flutter/…`, `dart:ui`, `package:firebase…`, `cloud_firestore` ou
/// `package:flutter_bloc`. É o que torna as RN-xx testáveis sozinhas e o que
/// impede a fórmula de vazar para a UI —
/// `test/architecture/calculo_isolation_test.dart` policia a regra e quebra a
/// suíte nomeando o arquivo infrator.
///
/// As fórmulas nascem na spec 02 `calculo`; **nenhuma** mora aqui ainda. Este
/// barrel existe para que a varredura de isolamento não rode vazia.
library;
