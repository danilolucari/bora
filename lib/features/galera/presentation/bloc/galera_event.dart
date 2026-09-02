import '../../../../core/calculo/calculo.dart';
import '../../../../core/festas/festas.dart';
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

/// Uma opção de "RESTRIÇÃO ALIMENTAR" foi escolhida — GAL-11, RN-21.
class DietaEscolhida extends GaleraEvent {
  const DietaEscolhida(this.chave, this.dieta);

  final ChaveDePessoa chave;
  final Dieta dieta;
}

/// O toggle de "BEBIDA" foi acionado — GAL-12, RN-21.
///
/// Carrega o valor **desejado**, e não "inverta o que estiver lá": quem
/// desenha já sabe qual metade do toggle foi tocada, e um evento de inversão
/// dependeria de o bloc e a tela concordarem sobre o estado corrente.
class BebidaAlternada extends GaleraEvent {
  const BebidaAlternada(this.chave, this.bebe);

  final ChaveDePessoa chave;
  final bool bebe;
}

/// Um dos três botões de "NÍVEL DE ACESSO" foi escolhido — GAL-17, RN-22.
class PapelEscolhido extends GaleraEvent {
  const PapelEscolhido(this.chave, this.papel);

  final ChaveDePessoa chave;
  final PapelNaFesta papel;
}

/// O segmented "QUEM ABRIR O LINK PODE…" mudou — GAL-04, RN-23.
///
/// **Não** carrega pessoa: o nível vale para quem **vai** abrir o link, e o
/// papel de quem já entrou não retroage (AD-026).
class NivelEscolhido extends GaleraEvent {
  const NivelEscolhido(this.nivel);

  final NivelDoLink nivel;
}

/// O stream do repositório falhou — GAL-25.
class ObservacaoFalhou extends GaleraEvent {
  const ObservacaoFalhou(this.erro, this.stackTrace);

  final Object erro;
  final StackTrace stackTrace;
}
