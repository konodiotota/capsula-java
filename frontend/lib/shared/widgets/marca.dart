import 'package:material_ui/material_ui.dart';

import '../../theme/capsula_theme.dart';

/// Cápsula feita de blocos de pixel, ao lado do nome.
class Marca extends StatelessWidget {
  const Marca({super.key, this.tamanho = 24});

  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Capsula',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: Size(tamanho * 1.75, tamanho * .7),
            painter: _CapsulaPainter(),
          ),
          SizedBox(width: tamanho * .45),
          Text('Capsula', style: Estilos.titulo(tamanho: tamanho * 1.05)),
        ],
      ),
    );
  }
}

class _CapsulaPainter extends CustomPainter {
  // 15 x 5 blocos. 'b' brasa, 'c' creme, '.' vazio.
  static const _grade = [
    '..bbbbbcccccc..',
    '.bbbbbbccccccc.',
    'bbbbbbbcccccccc',
    '.bbbbbbccccccc.',
    '..bbbbbcccccc..',
  ];

  @override
  void paint(Canvas canvas, Size size) {
    const colunas = 15;
    final lado = size.width / colunas;
    for (var y = 0; y < _grade.length; y++) {
      for (var x = 0; x < _grade[y].length; x++) {
        final c = _grade[y][x];
        if (c == '.') continue;
        canvas.drawRect(
          Rect.fromLTWH(x * lado, y * lado, lado + .5, lado + .5),
          Paint()
            ..color = c == 'b'
                ? Cores.brasa
                : (Cores.escura ? Cores.creme : Cores.texto),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CapsulaPainter o) => true;
}
