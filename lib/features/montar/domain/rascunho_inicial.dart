import '../../../core/calculo/calculo.dart';
import '../../../core/festas/festas.dart';
import 'data_do_role.dart';

/// O nome default do rolê novo — MONT-15 (A-04).
///
/// Declarado aqui, e não repetido em quem precisa dele, porque é o **mesmo**
/// valor em dois lugares: o rascunho que `/roles/novo` abre e a defesa de
/// P1-5 AC6, que devolve o default quando o anfitrião apaga o nome inteiro.
/// Dois literais divergiriam no primeiro ajuste de copy.
const String nomeDefaultDoRole = 'CHURRAS NOVO';

/// A duração default, em horas — o 4h de RN-30 e o ativo do segmented.
const int duracaoDefaultDoRole = 4;

/// Os **itens padrão de RN-30**: bovina, frango, pão de alho, refrigerante,
/// água, cerveja e cachaça.
///
/// "Itens padrão" é o termo da própria RN-30, e é o que faz "🔥 CHURRASCO"
/// abrir como **template** em vez de formulário em branco. A fixture
/// `itensPadraoRn30Tipados` afirma esta lista item a item — `lib/` não importa
/// `test/fixtures/`, e é o teste que amarra as duas pontas.
const Set<ChaveItem> itensPadraoDoRole = {
  ChaveItem.bovina,
  ChaveItem.frango,
  ChaveItem.paoDeAlho,
  ChaveItem.refrigerante,
  ChaveItem.agua,
  ChaveItem.cerveja,
  ChaveItem.cachaca,
};

/// O rolê que `/roles/novo` abre — MONT-15, MONT-17.
///
/// Nada é gravado ao construí-lo: rascunho vira festa na **primeira mudança**
/// (MONT-17), e abrir a tela para olhar não pode criar rolê na Home.
///
/// - **contagem 0/0/0**: UC-03 E1 é o estado honesto de abertura. O app não
///   inventa convidado, e a lista nasce vazia com total R$ 0.
/// - **[hora] e [local] vazios** — *SPEC_PRECISION_GAP*: nenhuma tela do M1
///   coleta nem renderiza os dois (a Home desenha só `festa.data`), e "14H"
///   seria hora inventada numa festa real.
/// - **duração nos dois lados**: `Festa.duracaoHoras` e
///   `ComposicaoDaFesta.duracaoHoras` nascem do mesmo [duracaoDefaultDoRole].
///   A composição é quem manda — é ela que entra na calculadora —, e
///   divergirem em silêncio faria o card-herói mostrar uma duração enquanto a
///   conta usa outra.
FestaEmEdicao rascunhoInicial({required DateTime hoje}) => FestaEmEdicao(
      festa: Festa(
        nome: nomeDefaultDoRole,
        data: rotuloDeSabado(proximoSabado(hoje)),
        hora: '',
        local: '',
        duracaoHoras: duracaoDefaultDoRole,
      ),
      composicao: ComposicaoDaFesta(
        contagem: ContagemDePessoas(),
        duracaoHoras: duracaoDefaultDoRole,
        itensSelecionados: itensPadraoDoRole,
      ),
    );
