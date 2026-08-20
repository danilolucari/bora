import 'package:firebase_core/firebase_core.dart';

/// Opções do projeto `demo-bora`, que existe **só** no Emulator Suite.
///
/// O prefixo `demo-` é reservado pelo Firebase para projetos que nunca tocam a
/// nuvem: nenhuma credencial real mora aqui e nenhum teste desta spec depende
/// de rede.
///
/// Os valores são sintéticos **mas bem formados** de propósito (risco R-1): os
/// SDKs nativos validam o formato do `appId` (`1:<sender>:<plataforma>:<hash>`)
/// e rejeitam um valor arbitrário. O `appId` usa o token `android` por ser o
/// validador mais estrito — o SDK web trata o campo como string opaca. Se um
/// alvo nativo ainda assim recusar, a spec manda parar e escalar em vez de
/// trocar por opções reais, que contrariam o emulator-first.
const FirebaseOptions demoFirebaseOptions = FirebaseOptions(
  // 39 caracteres, como as chaves reais: `AIzaSy` + 33.
  apiKey: 'AIzaSyDEMOboraDEMOboraDEMOboraDEMObora0',
  appId: '1:000000000000:android:0000000000000000000000',
  messagingSenderId: '000000000000',
  projectId: 'demo-bora',
);
