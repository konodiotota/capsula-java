import 'package:material_ui/material_ui.dart';

import '../../app/sessao.dart';
import '../../domain/models.dart';
import '../../domain/regras.dart';
import '../../shared/formatadores.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/painel.dart';
import '../../shared/widgets/rota_chamado.dart';
import '../../theme/capsula_theme.dart';
import '../mapa/map_integration_slot.dart';

/// Detalhe de um chamado: situação, local, trajeto e ações permitidas.
///
/// Mostra o chamado recebido e o atualiza depois de cada ação, avisando a
/// lista compartilhada em [Dados].
class ChamadoDetalhe extends StatefulWidget {
  const ChamadoDetalhe({
    super.key,
    required this.chamado,
    required this.aoAbrirConversa,
    this.aoFechar,
    this.mostrarCabecalho = true,
  });

  final Chamado chamado;
  final void Function(Chat chat) aoAbrirConversa;

  /// Quando informado, o cabeçalho ganha um botão para fechar o painel.
  final VoidCallback? aoFechar;

  /// Telas empilhadas já exibem "Chamado #id" na barra de título.
  final bool mostrarCabecalho;

  @override
  State<ChamadoDetalhe> createState() => _ChamadoDetalheState();
}

class _ChamadoDetalheState extends State<ChamadoDetalhe> {
  late Chamado _chamado = widget.chamado;
  List<HistoricoChamado>? _historico;
  Object? _erroHistorico;
  Object? _ocupado; // AcaoChamado ou 'conversa'
  bool _iniciado = false;
  bool _avancou = false; // o chamado mudou de etapa com este painel aberto

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_iniciado) {
      _iniciado = true;
      _carregarHistorico();
    }
  }

  @override
  void didUpdateWidget(covariant ChamadoDetalhe antigo) {
    super.didUpdateWidget(antigo);
    if (widget.chamado.id != antigo.chamado.id) {
      _chamado = widget.chamado;
      _avancou = false;
      _historico = null;
      _carregarHistorico();
    }
  }

  Future<void> _carregarHistorico() async {
    setState(() => _erroHistorico = null);
    try {
      final h = await SessaoScope.of(context).gateway.historico(_chamado.id);
      if (mounted) setState(() => _historico = h);
    } catch (e) {
      if (mounted) setState(() => _erroHistorico = e);
    }
  }

  Future<void> _executar(AcaoChamado acao) async {
    if (acao == AcaoChamado.cancelar && !await _confirmarCancelamento()) return;
    if (!mounted) return;
    final sessao = SessaoScope.of(context);
    final gateway = sessao.gateway;
    setState(() => _ocupado = acao);
    try {
      final id = _chamado.id;
      final novo = await switch (acao) {
        AcaoChamado.aceitar => gateway.aceitarChamado(id),
        AcaoChamado.iniciarDeslocamento => gateway.iniciarDeslocamento(id),
        AcaoChamado.iniciarAtendimento => gateway.iniciarAtendimento(id),
        AcaoChamado.finalizar => gateway.finalizarAtendimento(id),
        AcaoChamado.cancelar => gateway.cancelarChamado(id),
      };
      if (!mounted) return;
      setState(() {
        _chamado = novo;
        _avancou = true;
      });
      sessao.dados.atualizar(novo);
      mostrarAviso(context, acao.concluida);
      _carregarHistorico();
    } catch (e) {
      if (mounted) mostrarAviso(context, mensagemDeErro(e));
    } finally {
      if (mounted) setState(() => _ocupado = null);
    }
  }

  Future<bool> _confirmarCancelamento() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancelar o chamado ${_chamado.id}?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Nenhum técnico será acionado. Não é possível reabrir um chamado cancelado.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Manter chamado'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Cores.alerta,
              foregroundColor: Cores.sobreBrasa,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cancelar chamado'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _abrirConversa() async {
    final gateway = SessaoScope.of(context).gateway;
    setState(() => _ocupado = 'conversa');
    try {
      final chat = await gateway.abrirChat(_chamado.id);
      if (mounted) widget.aoAbrirConversa(chat);
    } catch (e) {
      if (mounted) mostrarAviso(context, mensagemDeErro(e));
    } finally {
      if (mounted) setState(() => _ocupado = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = SessaoScope.of(context).usuario!;
    final tema = Theme.of(context).textTheme;
    final c = _chamado;

    final avancar = Permissoes.avancar(c, usuario);
    final podeCancelar = Permissoes.cancelar(c, usuario);
    final podeConversar = Permissoes.conversar(c, usuario);
    final temAcoes = avancar != null || podeConversar || podeCancelar;

    final informacoes = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 18,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            // Encerrado, o carimbo é a situação; antes disso, é o texto.
            if (c.status.encerrado)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Selo(
                  c.status.label,
                  cor: corDoStatus(c.status),
                  tamanho: 20,
                  animar: _avancou,
                ),
              )
            else
              StatusTexto(c.status, tamanho: 22),
            PrioridadeTexto(c.prioridade),
          ],
        ),
        const SizedBox(height: 16),
        Text(c.descricao, style: tema.bodyLarge),
        const SizedBox(height: 22),
        MapaChamado(
          endereco: c.endereco,
          numero: c.id,
          latitude: c.latitude,
          longitude: c.longitude,
        ),
        const SizedBox(height: 18),
        _Pessoas(chamado: c),
      ],
    );

    final trajeto = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Trajeto', style: tema.titleLarge),
        const SizedBox(height: 16),
        RotaChamado(chamado: c, historico: _historico, animar: _avancou),
        if (_erroHistorico != null) ...[
          const SizedBox(height: 12),
          Text(
            'Não foi possível carregar quem registrou cada etapa.',
            style: tema.bodyMedium,
          ),
          TextButton(
            onPressed: _carregarHistorico,
            child: const Text('Tentar de novo'),
          ),
        ],
      ],
    );

    final acoes = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: Cores.lateral,
        border: Border(top: BorderSide(color: Cores.bordaForte)),
      ),
      child: SafeArea(
        top: false,
        child: Wrap(
          spacing: 12,
          runSpacing: 10,
          children: [
            if (avancar != null)
              FilledButton(
                onPressed: _ocupado == null ? () => _executar(avancar) : null,
                child: _Rotulo(avancar.rotulo, ocupado: _ocupado == avancar),
              ),
            if (podeConversar)
              OutlinedButton.icon(
                onPressed: _ocupado == null ? _abrirConversa : null,
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(
                    _ocupado == 'conversa' ? 'Abrindo…' : 'Abrir conversa'),
              ),
            if (podeCancelar)
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Cores.alerta),
                onPressed: _ocupado == null
                    ? () => _executar(AcaoChamado.cancelar)
                    : null,
                child: _Rotulo(
                  AcaoChamado.cancelar.rotulo,
                  ocupado: _ocupado == AcaoChamado.cancelar,
                ),
              ),
          ],
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, caixa) {
        final duasColunas = caixa.maxWidth >= 760;
        final horizontal = duasColunas ? 36.0 : 20.0;
        return ColoredBox(
          color: Cores.painel,
          child: Column(
            children: [
              if (widget.mostrarCabecalho)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 8, 14),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Cores.bordaForte)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child:
                            Text('Chamado ${c.id}', style: tema.headlineSmall),
                      ),
                      if (widget.aoFechar != null)
                        IconButton(
                          tooltip: 'Fechar detalhes',
                          onPressed: widget.aoFechar,
                          icon: const Icon(Icons.close),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(horizontal, 22, horizontal, 28),
                  children: [
                    if (duasColunas)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: informacoes),
                          const SizedBox(width: 48),
                          Expanded(flex: 5, child: trajeto),
                        ],
                      )
                    else ...[
                      informacoes,
                      const SizedBox(height: 28),
                      trajeto,
                    ],
                  ],
                ),
              ),
              if (temAcoes) acoes,
            ],
          ),
        );
      },
    );
  }
}

/// Campos da ordem de serviço: rótulo pequeno, valor datilografado e a linha
/// onde ele estaria escrito.
class _Pessoas extends StatelessWidget {
  const _Pessoas({required this.chamado});

  final Chamado chamado;

  @override
  Widget build(BuildContext context) {
    final c = chamado;
    return Column(
      children: [
        _Campo('Solicitante', c.solicitante.nome),
        _Campo('Técnico', c.tecnico?.nome ?? 'Aguardando um técnico aceitar',
            vazio: c.tecnico == null),
        if (c.criadoEm != null) _Campo('Aberto em', dataHora(c.criadoEm!)),
        if (c.concluidoEm != null)
          _Campo(
            c.status == StatusChamado.cancelado
                ? 'Cancelado em'
                : 'Concluído em',
            dataHora(c.concluidoEm!),
          ),
      ],
    );
  }
}

class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto, {required this.ocupado});

  final String texto;
  final bool ocupado;

  @override
  Widget build(BuildContext context) => ocupado
      ? const SizedBox.square(
          dimension: 20,
          child: CircularProgressIndicator(strokeWidth: 3),
        )
      : Text(texto);
}

class _Campo extends StatelessWidget {
  const _Campo(this.rotulo, this.valor, {this.vazio = false});

  final String rotulo;
  final String valor;
  final bool vazio;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Cores.borda)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: tema.labelMedium),
          const SizedBox(height: 2),
          Text(
            valor,
            style: vazio
                ? Estilos.corpo(tamanho: 16, cor: Cores.apagado)
                : Estilos.mono(tamanho: 16),
          ),
        ],
      ),
    );
  }
}
