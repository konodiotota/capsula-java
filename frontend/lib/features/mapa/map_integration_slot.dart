import 'package:material_ui/material_ui.dart';

import '../../theme/capsula_theme.dart';

/// Espaço do mapa de um chamado.
///
/// Passe [mapBuilder] quando um provedor de mapas for escolhido e
/// configurado. Sem ele, o espaço mostra uma planta estilizada com o pino do
/// chamado, o endereço e as coordenadas guardados nele, e informa que o mapa
/// não está conectado.
class MapaChamado extends StatelessWidget {
  const MapaChamado({
    super.key,
    required this.endereco,
    this.numero,
    this.latitude,
    this.longitude,
    this.mapBuilder,
  });

  final String endereco;

  /// Número do chamado, escrito na etiqueta do pino.
  final int? numero;
  final double? latitude;
  final double? longitude;
  final WidgetBuilder? mapBuilder;

  @override
  Widget build(BuildContext context) {
    if (mapBuilder != null) return mapBuilder!(context);

    final tema = Theme.of(context).textTheme;
    final coordenadas = (latitude != null && longitude != null)
        ? '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}'
        : null;

    return Container(
      width: double.infinity,
      height: 196,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Cores.mapaFundo,
        borderRadius: BorderRadius.circular(raioFolha),
        border: Border.all(color: Cores.borda),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _Planta())),
          Align(
            alignment: const Alignment(.35, -.45),
            child: _Pino(numero: numero),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              decoration: BoxDecoration(
                color: Cores.fundo.withValues(alpha: .88),
                border: Border(top: BorderSide(color: Cores.borda)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    endereco,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tema.titleMedium?.copyWith(fontSize: 14),
                  ),
                  if (coordenadas != null)
                    Text(coordenadas,
                        style: Estilos.mono(tamanho: 12, cor: Cores.creme)),
                  Text(
                    'O mapa ainda não está conectado.',
                    style: tema.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pino extends StatelessWidget {
  const _Pino({this.numero});

  final int? numero;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: Cores.fundo,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Cores.brasa, width: 2),
          ),
          child: Text(
            numero == null ? 'Chamado' : '$numero',
            style: Estilos.corpo(
                tamanho: 13, peso: FontWeight.w800, cor: Cores.texto),
          ),
        ),
        Container(width: 3, height: 10, color: Cores.brasa),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: Cores.brasa,
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                  color: Cores.brasa.withValues(alpha: .35), spreadRadius: 5)
            ],
          ),
        ),
      ],
    );
  }
}

/// Planta estilizada: quadras, uma avenida e a rota até o pino.
class _Planta extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final rua = Paint()
      ..color = Cores.mapaRua
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.butt;
    final fina = Paint()
      ..color = Cores.mapaRuaFina
      ..strokeWidth = 3;

    for (var i = 1; i < 6; i++) {
      canvas.drawLine(Offset(w * i / 6, 0), Offset(w * i / 6 + 14, h),
          i.isEven ? rua : fina);
    }
    for (var j = 1; j < 4; j++) {
      canvas.drawLine(
          Offset(0, h * j / 4), Offset(w, h * j / 4 - 10), j == 2 ? rua : fina);
    }
    // Avenida diagonal.
    canvas.drawLine(
      Offset(w * .05, h * .95),
      Offset(w * .95, h * .1),
      Paint()
        ..color = Cores.mapaAvenida
        ..strokeWidth = 10,
    );

    // Raio de atendimento.
    final centro = Offset(w * .675, h * .27);
    canvas.drawCircle(
      centro,
      h * .42,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Cores.visto.withValues(alpha: .35),
    );
    canvas.drawCircle(
        centro, h * .42, Paint()..color = Cores.visto.withValues(alpha: .05));

    // Rota até o pino.
    final rota = Path()
      ..moveTo(w * .12, h * .88)
      ..lineTo(w * .36, h * .88)
      ..lineTo(w * .36, h * .56)
      ..lineTo(w * .675, h * .5)
      ..lineTo(w * .675, h * .3);
    canvas.drawPath(
      rota,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeJoin = StrokeJoin.miter
        ..color = Cores.brasa.withValues(alpha: .9),
    );
  }

  @override
  bool shouldRepaint(_Planta o) => true;
}
