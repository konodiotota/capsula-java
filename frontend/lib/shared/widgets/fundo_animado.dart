import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../theme/capsula_theme.dart';

/// Fundo da tela de login: janelas de chamado, balões de mensagem, vistos e
/// blocos de pixel sobem devagar, e uma faixa de varredura desce como numa
/// tela de tubo. Tudo em baixa opacidade e nas cores do tema. Com animações
/// desativadas no sistema, fica parado.
class FundoAnimado extends StatefulWidget {
  const FundoAnimado({super.key, required this.child});

  final Widget child;

  @override
  State<FundoAnimado> createState() => _FundoAnimadoState();
}

class _FundoAnimadoState extends State<FundoAnimado>
    with SingleTickerProviderStateMixin {
  // Um ciclo longo; a velocidade de cada peça é um múltiplo inteiro, então o
  // laço fecha sem salto.
  late final AnimationController _relogio =
      AnimationController(vsync: this, duration: const Duration(seconds: 120));
  late final List<_Peca> _pecas = _gerar();

  static List<_Peca> _gerar() {
    final r = math.Random(42);
    return List.generate(26, (i) {
      return _Peca(
        forma: _Forma.values[r.nextInt(_Forma.values.length)],
        x: r.nextDouble(),
        fase: r.nextDouble(),
        ciclos: 1 + r.nextInt(3),
        unidade: [3.0, 4.0, 5.0][r.nextInt(3)],
        cor: r.nextInt(3),
        balanco: 6 + r.nextDouble() * 18,
        tamanho: 2 + r.nextInt(3),
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _relogio
        ..stop()
        ..value = .31;
    } else if (!_relogio.isAnimating) {
      _relogio.repeat();
    }
  }

  @override
  void dispose() {
    _relogio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ExcludeSemantics(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(painter: _FundoPainter(_relogio, _pecas)),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

enum _Forma { bloco, janela, balao, visto }

class _Peca {
  const _Peca({
    required this.forma,
    required this.x,
    required this.fase,
    required this.ciclos,
    required this.unidade,
    required this.cor,
    required this.balanco,
    required this.tamanho,
  });

  final _Forma forma;
  final double x, fase, unidade, balanco;
  final int ciclos, cor, tamanho;
}

class _FundoPainter extends CustomPainter {
  _FundoPainter(this.relogio, this.pecas) : super(repaint: relogio);

  final Animation<double> relogio;
  final List<_Peca> pecas;

  @override
  void paint(Canvas canvas, Size size) {
    final cores = [
      Cores.brasa,
      Cores.visto,
      Cores.escura ? Cores.creme : Cores.bordaForte,
    ];
    final base = Cores.escura ? .2 : .24;

    for (final p in pecas) {
      final t = (relogio.value * p.ciclos + p.fase) % 1;
      final u = p.unidade;
      final y = size.height + 60 - t * (size.height + 140);
      final x =
          p.x * size.width + math.sin(t * 2 * math.pi * p.ciclos) * p.balanco;
      // Posição encaixada na grade de pixels, para o movimento andar em degraus.
      final px = (x / u).roundToDouble() * u;
      final py = (y / u).roundToDouble() * u;
      final alfa = base * math.min(1, math.min(t * 7, (1 - t) * 7));
      final tinta = Paint()..color = cores[p.cor].withValues(alpha: alfa);

      canvas.save();
      canvas.translate(px, py);
      void cel(double cx, double cy, [double w = 1, double h = 1]) =>
          canvas.drawRect(Rect.fromLTWH(cx * u, cy * u, w * u, h * u), tinta);

      switch (p.forma) {
        case _Forma.bloco:
          cel(0, 0, p.tamanho.toDouble(), p.tamanho.toDouble());
        case _Forma.janela:
          cel(0, 0, 9, 2); // barra de título
          cel(0, 2, 9, .5);
          cel(0, 2, .5, 5);
          cel(8.5, 2, .5, 5);
          cel(0, 6.5, 9, .5);
          cel(1.5, 3.5, 5, .5);
          cel(1.5, 5, 3, .5);
        case _Forma.balao:
          cel(0, 0, 8, 5);
          cel(1, 5, 2, 1);
          canvas.drawRect(
            Rect.fromLTWH(1.5 * u, 2 * u, u, u),
            Paint()..color = Cores.fundo.withValues(alpha: alfa * 3),
          );
          canvas.drawRect(
            Rect.fromLTWH(3.5 * u, 2 * u, u, u),
            Paint()..color = Cores.fundo.withValues(alpha: alfa * 3),
          );
          canvas.drawRect(
            Rect.fromLTWH(5.5 * u, 2 * u, u, u),
            Paint()..color = Cores.fundo.withValues(alpha: alfa * 3),
          );
        case _Forma.visto:
          for (final (c, l) in const [(0, 2), (1, 3), (2, 2), (3, 1), (4, 0)]) {
            cel(c.toDouble(), l.toDouble());
          }
      }
      canvas.restore();
    }

    // Faixa de varredura.
    final faixa = (relogio.value * 12) % 1;
    final fy = faixa * (size.height + 160) - 160;
    canvas.drawRect(
      Rect.fromLTWH(0, fy, size.width, 160),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Cores.brasa.withValues(alpha: 0),
            Cores.brasa.withValues(alpha: Cores.escura ? .06 : .07),
          ],
        ).createShader(Rect.fromLTWH(0, fy, size.width, 160)),
    );
    canvas.drawRect(
      Rect.fromLTWH(0, fy + 158, size.width, 2),
      Paint()..color = Cores.brasa.withValues(alpha: Cores.escura ? .12 : .14),
    );
  }

  @override
  bool shouldRepaint(_FundoPainter o) => true;
}
