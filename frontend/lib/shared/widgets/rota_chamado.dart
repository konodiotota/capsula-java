import 'package:material_ui/material_ui.dart';

import '../../domain/models.dart';
import '../../theme/capsula_theme.dart';
import '../formatadores.dart';
import 'painel.dart';

/// Esferográfica para o que está em andamento, verde para concluído, carimbo
/// para cancelado e cinza para o que ainda espera.
Color corDoStatus(StatusChamado s) => switch (s) {
      StatusChamado.finalizado => Cores.visto,
      StatusChamado.cancelado => Cores.alerta,
      StatusChamado.pendente => Cores.suave,
      _ => Cores.brasa,
    };

/// Nome da situação do chamado, na cor da etapa.
class StatusTexto extends StatelessWidget {
  const StatusTexto(this.status, {super.key, this.tamanho = 17});

  final StatusChamado status;
  final double tamanho;

  @override
  Widget build(BuildContext context) => Text(
        status.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Estilos.titulo(tamanho: tamanho, cor: corDoStatus(status)),
      );
}

enum MarcaQuadro { futura, feita, atual, cancelada }

/// Quadrinho de visto. A etapa feita leva um visto à caneta; a etapa atual
/// vem preenchida; a que falta fica vazia. Com [animar], o visto se desenha.
class Quadro extends StatelessWidget {
  const Quadro._(this.marca, this.cor, this.tamanho, this.animar);

  /// Quadrinho da [estacao] para um chamado que está em [atual].
  factory Quadro.etapa(StatusChamado estacao, StatusChamado atual,
          {double tamanho = 24}) =>
      _quadro(estacao, atual, tamanho);

  final MarcaQuadro marca;
  final Color cor;
  final double tamanho;
  final bool animar;

  @override
  Widget build(BuildContext context) {
    final desenho = TweenAnimationBuilder<double>(
      tween: Tween(begin: animar ? 0 : 1, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.linear,
      builder: (context, t, _) => CustomPaint(
        size: Size.square(tamanho),
        painter: _QuadroPainter(marca, cor, t),
      ),
    );
    return SizedBox.square(dimension: tamanho, child: desenho);
  }
}

class _QuadroPainter extends CustomPainter {
  _QuadroPainter(this.marca, this.cor, this.progresso);

  final MarcaQuadro marca;
  final Color cor;
  final double progresso;

  // Grade de 8x8 blocos: borda no perímetro, visto ou X no miolo.
  static const _visto = [(4, 2), (5, 3), (4, 4), (3, 5), (2, 6)];
  static const _xis = [
    (2, 2),
    (3, 3),
    (4, 4),
    (5, 5),
    (2, 5),
    (3, 4),
    (4, 3),
    (5, 2)
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.width / 8;
    final cheio = marca == MarcaQuadro.atual || marca == MarcaQuadro.cancelada;
    final corBorda = cheio
        ? cor
        : marca == MarcaQuadro.feita
            ? cor.withValues(alpha: .6)
            : Cores.bordaForte;
    final borda = Paint()..color = corBorda;

    if (cheio) {
      canvas.drawRect(Offset.zero & size, borda);
    } else {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, c), borda);
      canvas.drawRect(Rect.fromLTWH(0, size.height - c, size.width, c), borda);
      canvas.drawRect(Rect.fromLTWH(0, 0, c, size.height), borda);
      canvas.drawRect(Rect.fromLTWH(size.width - c, 0, c, size.height), borda);
    }
    if (marca == MarcaQuadro.futura) return;

    final celulas = marca == MarcaQuadro.cancelada ? _xis : _visto;
    final n = (progresso * celulas.length).ceil();
    final tinta = Paint()..color = cheio ? Cores.sobreBrasa : cor;
    for (var i = 0; i < n; i++) {
      final (l, col) = celulas[i];
      canvas.drawRect(Rect.fromLTWH(col * c, l * c, c, c), tinta);
    }
  }

  @override
  bool shouldRepaint(_QuadroPainter o) => true;
}

/// Marca de cada estação do trajeto, na ordem e na cor certas para o status.
MarcaQuadro _marcaDa(StatusChamado estacao, StatusChamado atual) {
  if (atual == StatusChamado.cancelado) {
    return estacao == StatusChamado.cancelado
        ? MarcaQuadro.cancelada
        : MarcaQuadro.feita;
  }
  if (estacao.etapa > atual.etapa) return MarcaQuadro.futura;
  return estacao == atual ? MarcaQuadro.atual : MarcaQuadro.feita;
}

Quadro _quadro(StatusChamado estacao, StatusChamado atual, double tamanho,
    {bool animar = false}) {
  final marca = _marcaDa(estacao, atual);
  final cor = marca == MarcaQuadro.cancelada
      ? Cores.alerta
      : atual == StatusChamado.finalizado
          ? Cores.visto
          : Cores.brasa;
  return Quadro._(marca, cor, tamanho, animar && marca != MarcaQuadro.futura);
}

/// Os quadrinhos do trajeto, usados nos cartões da lista.
class RotaMini extends StatelessWidget {
  const RotaMini(this.status, {super.key});

  final StatusChamado status;

  @override
  Widget build(BuildContext context) {
    final cancelado = status == StatusChamado.cancelado;
    final estacoes = cancelado
        ? const [StatusChamado.pendente, StatusChamado.cancelado]
        : StatusChamado.trajeto;
    return Semantics(
      label: 'Etapa: ${status.label}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < estacoes.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            _quadro(estacoes[i], status, 16),
          ],
        ],
      ),
    );
  }
}

/// Trajeto vertical de um chamado. Cada estação alcançada mostra quem a
/// registrou e quando, a partir do histórico do chamado.
class RotaChamado extends StatelessWidget {
  const RotaChamado({
    super.key,
    required this.chamado,
    this.historico,
    this.animar = false,
  });

  final Chamado chamado;

  /// `null` enquanto o histórico carrega: as estações aparecem sem detalhes.
  final List<HistoricoChamado>? historico;

  /// Desenha o visto da etapa atual, ao avançar o chamado.
  final bool animar;

  HistoricoChamado? _evento(StatusChamado s) {
    final h = historico;
    if (h == null) return null;
    for (final item in h) {
      if (item.statusNovo == s) return item;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final cancelado = chamado.status == StatusChamado.cancelado;
    final estacoes = cancelado
        ? const [StatusChamado.pendente, StatusChamado.cancelado]
        : StatusChamado.trajeto;
    final atual = chamado.status;

    return Column(
      children: [
        for (var i = 0; i < estacoes.length; i++)
          _Estacao(
            status: estacoes[i],
            quadro: _quadro(estacoes[i], atual, 24,
                animar: animar && estacoes[i] == atual),
            ultima: i == estacoes.length - 1,
            atual: estacoes[i] == atual,
            alcancada: _marcaDa(estacoes[i], atual) != MarcaQuadro.futura,
            proximaAlcancada: i + 1 < estacoes.length &&
                _marcaDa(estacoes[i + 1], atual) != MarcaQuadro.futura,
            quando: estacoes[i] == StatusChamado.pendente
                ? chamado.criadoEm
                : _evento(estacoes[i])?.criadoEm,
            quem: estacoes[i] == StatusChamado.pendente
                ? chamado.solicitante.nome
                : _evento(estacoes[i])?.usuarioNome,
            nota: estacoes[i] == StatusChamado.pendente
                ? null
                : _evento(estacoes[i])?.observacoes,
          ),
      ],
    );
  }
}

class _Estacao extends StatelessWidget {
  const _Estacao({
    required this.status,
    required this.quadro,
    required this.ultima,
    required this.atual,
    required this.alcancada,
    required this.proximaAlcancada,
    this.quando,
    this.quem,
    this.nota,
  });

  final StatusChamado status;
  final Quadro quadro;
  final bool ultima;
  final bool atual;
  final bool alcancada;
  final bool proximaAlcancada;
  final DateTime? quando;
  final String? quem;
  final String? nota;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                quadro,
                if (!ultima)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: proximaAlcancada
                          ? Container(width: 2.5, color: Cores.brasa)
                          : const Picote(),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: ultima ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.label,
                    style: Estilos.titulo(
                      tamanho: atual ? 24 : 20,
                      cor: alcancada ? Cores.texto : Cores.apagado,
                    ),
                  ),
                  if (quem != null || quando != null) ...[
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        children: [
                          if (quem != null) TextSpan(text: quem),
                          if (quem != null && quando != null)
                            const TextSpan(text: '  '),
                          if (quando != null)
                            TextSpan(
                              text: dataHora(quando!),
                              style: Estilos.corpo(
                                  tamanho: 14, cor: Cores.apagado),
                            ),
                        ],
                      ),
                      style: tema.bodyMedium,
                    ),
                  ],
                  if (nota != null && nota!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      nota!,
                      style: tema.bodyMedium?.copyWith(color: Cores.texto),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
