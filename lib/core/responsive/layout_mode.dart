/// Fronteira entre os dois modos de layout, em px lógicos.
///
/// W-R3 fala em "abaixo de ~900px"; o `~` não é testável, então a fronteira é
/// exatamente 900.0 e é **inclusiva à direita**: 900.0 já é expandido.
const double kCompactBreakpoint = 900.0;

/// Modo de layout da janela — mecanismo de W-R3.
///
/// É só o mecanismo: a aparência de cada modo é território da spec 01
/// `design-system`, que consome este enum sem redefinir o breakpoint.
enum LayoutMode { compact, expanded }

/// Modo correspondente a [width] px lógicos de largura.
LayoutMode layoutModeForWidth(double width) =>
    width < kCompactBreakpoint ? LayoutMode.compact : LayoutMode.expanded;
