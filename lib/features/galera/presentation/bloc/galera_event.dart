import '../../domain/chave_de_pessoa.dart';
import '../../domain/galera_da_festa.dart';

/// Os eventos da tela A GALERA.
///
/// Os dois primeiros vêm **do repositório**, não do usuário: a tela não pede
/// nada, ela assina `observarGalera` e desenha o que chega (RN-28). Os toques
/// em botão de navegação não passam pelo bloc (AD-020).
sealed class GaleraEvent {
  const GaleraEvent();
}

/// O repositório entregou a galera da festa — a semente ou uma mudança
/// (RN-28).
///
/// [galera] `null` = a festa não existe. É dado, não erro: quem decide o que
/// fazer com a ausência é o bloc.
class GaleraRecebida extends GaleraEvent {
  const GaleraRecebida(this.galera);

  final GaleraDaFesta? galera;
}

/// Um card-linha da seção PESSOAS foi tocado — GAL-10 AC1.
///
/// **Alterna**: a linha que já estava aberta fecha, como em
/// `BoraExpandableGroup`. Não existe evento de "fechar" separado — dois
/// eventos para a mesma intenção divergiriam no primeiro ajuste.
class LinhaAlternada extends GaleraEvent {
  const LinhaAlternada(this.chave);

  final ChaveDePessoa chave;
}

/// O stream do repositório falhou — GAL-25.
class ObservacaoFalhou extends GaleraEvent {
  const ObservacaoFalhou(this.erro, this.stackTrace);

  final Object erro;
  final StackTrace stackTrace;
}
