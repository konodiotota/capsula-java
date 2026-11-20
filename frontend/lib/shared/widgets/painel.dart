import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../theme/capsula_theme.dart';

/// Linha tracejada, para o trecho do trajeto que ainda falta.
class Picote extends StatelessWidget {
  const Picote({
    super.key,
    this.vertical = true,
    this.cor,
    this.espessura = 2,
  });

  final bool vertical;
  final Color? cor;
  final double espessura;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _PicotePainter(
            vertical: vertical,
            cor: cor ?? Cores.bordaForte,
            espessura: espessura),
        child: SizedBox(
          width: vertical ? espessura : null,
          height: vertical ? null : espessura,
        ),
      );
}

class _PicotePainter extends CustomPainter {
  _PicotePainter(
      {required this.vertical, required this.cor, required this.espessura});

  final bool vertical;
  final Color cor;
  final double espessura;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cor
      ..strokeWidth = espessura;
    const traco = 4.0, vao = 4.0;
    final total = vertical ? size.height : size.width;
    for (var p = 0.0; p < total; p += traco + vao) {
      final fim = math.min(p + traco, total);
      if (vertical) {
        canvas.drawLine(
            Offset(size.width / 2, p), Offset(size.width / 2, fim), paint);
      } else {
        canvas.drawLine(
            Offset(p, size.height / 2), Offset(fim, size.height / 2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_PicotePainter o) =>
      o.vertical != vertical || o.cor != cor || o.espessura != espessura;
}

/// Janela de terminal: barra de título com os três pontos e o conteúdo.
class Janela extends StatelessWidget {
  const Janela(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(28)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    Widget ponto(Color cor) => Container(
          width: 12,
          height: 8,
          margin: const EdgeInsets.only(left: 6),
          decoration:
              BoxDecoration(color: cor, borderRadius: BorderRadius.circular(2)),
        );

    return Container(
      decoration: BoxDecoration(
        color: Cores.painel,
        borderRadius: BorderRadius.circular(raioFolha + 1),
        border: Border.all(color: Cores.bordaForte),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Cores.painelAlto,
              border: Border(bottom: BorderSide(color: Cores.borda)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Cores.bordaForte,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                ponto(Cores.visto),
                ponto(Cores.amarelo),
                ponto(Cores.alerta),
              ],
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// Painel clicável com borda; o escolhido ganha a borda creme.
class PainelToque extends StatelessWidget {
  const PainelToque({
    super.key,
    required this.child,
    required this.aoTocar,
    this.selecionado = false,
  });

  final Widget child;
  final VoidCallback aoTocar;
  final bool selecionado;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selecionado,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: aoTocar,
          borderRadius: BorderRadius.circular(raioFolha),
          child: Ink(
            decoration: BoxDecoration(
              color: selecionado ? Cores.painelAlto : Cores.painel,
              borderRadius: BorderRadius.circular(raioFolha),
              border: Border.all(
                color: selecionado ? Cores.creme : Cores.borda,
                width: selecionado ? 1.6 : 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Selo de situação encerrada, com sombra dura de pixel. Com [animar],
/// assenta ao aparecer.
class Selo extends StatelessWidget {
  const Selo(
    this.texto, {
    super.key,
    required this.cor,
    this.tamanho = 18,
    this.animar = false,
  });

  final String texto;
  final Color cor;
  final double tamanho;
  final bool animar;

  @override
  Widget build(BuildContext context) {
    final selo = Container(
      padding: EdgeInsets.symmetric(
          horizontal: tamanho * .6, vertical: tamanho * .22),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: cor, width: 2),
        boxShadow: [
          BoxShadow(
              color: cor.withValues(alpha: .55), offset: const Offset(3, 3))
        ],
      ),
      child: Text(texto, style: Estilos.titulo(tamanho: tamanho, cor: cor)),
    );
    if (!animar) return selo;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      builder: (context, t, filho) => Opacity(
        opacity: t,
        child: Transform.scale(scale: 1.3 - .3 * t, child: filho),
      ),
      child: selo,
    );
  }
}
