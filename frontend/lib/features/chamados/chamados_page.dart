import 'package:material_ui/material_ui.dart';

import '../../app/dados.dart';
import '../../app/sessao.dart';
import '../../domain/models.dart';
import '../../shared/formatadores.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/painel.dart';
import '../../shared/widgets/rota_chamado.dart';
import '../../theme/capsula_theme.dart';
import 'chamado_detalhe.dart';
import 'novo_chamado_page.dart';

enum OrigemChamados {
  meus('Meus chamados'),
  disponiveis('Chamados disponíveis');

  const OrigemChamados(this.titulo);
  final String titulo;
}

enum _Filtro {
  todos('Todos'),
  pendentes('Pendentes'),
  andamento('Em andamento'),
  finalizados('Finalizados'),
  cancelados('Cancelados');

  const _Filtro(this.rotulo);
  final String rotulo;

  bool aceita(StatusChamado s) => switch (this) {
        todos => true,
        pendentes => s == StatusChamado.pendente,
        andamento => s == StatusChamado.aceito ||
            s == StatusChamado.aCaminho ||
            s == StatusChamado.atendimento,
        finalizados => s == StatusChamado.finalizado,
        cancelados => s == StatusChamado.cancelado,
      };
}

enum _Ordem {
  recentes('Mais recentes'),
  antigos('Mais antigos'),
  prioridade('Maior prioridade');

  const _Ordem(this.rotulo);
  final String rotulo;
}

enum _Visao { grade, lista }

class ChamadosPage extends StatefulWidget {
  const ChamadosPage({
    super.key,
    required this.origem,
    required this.aoAbrirConversa,
  });

  final OrigemChamados origem;
  final void Function(Chat chat) aoAbrirConversa;

  @override
  State<ChamadosPage> createState() => _ChamadosPageState();
}

class _ChamadosPageState extends State<ChamadosPage> {
  final _busca = TextEditingController();
  _Filtro _filtro = _Filtro.todos;
  _Ordem _ordem = _Ordem.recentes;
  _Visao _visao = _Visao.grade;
  int? _selecionadoId;

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  Carga<List<Chamado>> _carga(Dados d) =>
      widget.origem == OrigemChamados.meus ? d.meus : d.disponiveis;

  Future<void> _atualizar(Dados d) => widget.origem == OrigemChamados.meus
      ? d.carregarMeus()
      : d.carregarDisponiveis();

  List<Chamado> _visiveis(List<Chamado> todos) {
    final termo = _busca.text.trim().toLowerCase().replaceAll('#', '');
    final lista = todos.where((c) {
      if (!_filtro.aceita(c.status)) return false;
      if (termo.isEmpty) return true;
      return c.descricao.toLowerCase().contains(termo) ||
          c.endereco.toLowerCase().contains(termo) ||
          c.id.toString() == termo;
    }).toList();
    final zero = DateTime.fromMillisecondsSinceEpoch(0);
    int recente(Chamado a, Chamado b) =>
        (b.criadoEm ?? zero).compareTo(a.criadoEm ?? zero);
    switch (_ordem) {
      case _Ordem.recentes:
        lista.sort(recente);
      case _Ordem.antigos:
        lista.sort((a, b) => -recente(a, b));
      case _Ordem.prioridade:
        lista.sort((a, b) {
          final p = a.prioridade.index.compareTo(b.prioridade.index);
          return p != 0 ? p : recente(a, b);
        });
    }
    return lista;
  }

  Future<void> _novo(Dados dados) async {
    final criado = await Navigator.of(context).push<Chamado>(
      MaterialPageRoute(builder: (_) => const NovoChamadoPage()),
    );
    if (criado == null || !mounted) return;
    dados.inserir(criado);
    setState(() {
      _filtro = _Filtro.todos;
      _busca.clear();
      _selecionadoId = criado.id;
    });
  }

  void _abrir(Chamado chamado, bool painel) {
    if (painel) {
      setState(() => _selecionadoId = chamado.id);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text('Chamado ${chamado.id}')),
          body: SafeArea(
            child: ChamadoDetalhe(
              chamado: chamado,
              mostrarCabecalho: false,
              aoAbrirConversa: (chat) {
                Navigator.of(context).pop();
                widget.aoAbrirConversa(chat);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dados = SessaoScope.of(context).dados;
    return ComDados(
      dados: dados,
      builder: (context, dados) {
        final carga = _carga(dados);
        return LayoutBuilder(
          builder: (context, caixa) {
            final painel = caixa.maxWidth >= 1000;
            final estreito = caixa.maxWidth < 600;
            final todos = carga.dados;

            Chamado? selecionado;
            for (final c in todos ?? const <Chamado>[]) {
              if (c.id == _selecionadoId) selecionado = c;
            }

            final principal = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Cabecalho(
                  titulo: widget.origem.titulo,
                  total: todos?.length,
                  estreito: estreito,
                  carregando: carga.carregando,
                  aoAtualizar: () => _atualizar(dados),
                  aoNovo: () => _novo(dados),
                ),
                if (todos != null && todos.isNotEmpty) ...[
                  _Resumo(
                    chamados: todos,
                    atual: _filtro,
                    aoEscolher: (f) => setState(() => _filtro = f),
                  ),
                  _Barra(
                    busca: _busca,
                    ordem: _ordem,
                    visao: _visao,
                    estreito: estreito,
                    aoMudarBusca: () => setState(() {}),
                    aoOrdenar: (o) => setState(() => _ordem = o),
                    aoMudarVisao: (v) => setState(() => _visao = v),
                  ),
                ] else
                  const SizedBox(height: 8),
                Expanded(
                  child: _Corpo(
                    origem: widget.origem,
                    carga: carga,
                    visiveis: todos == null ? const [] : _visiveis(todos),
                    visao: estreito ? _Visao.grade : _visao,
                    selecionadoId: painel ? _selecionadoId : null,
                    espacoParaBotao: estreito,
                    aoAbrir: (c) => _abrir(c, painel),
                    aoAtualizar: () => _atualizar(dados),
                    aoNovo: () => _novo(dados),
                    aoLimpar: () => setState(() {
                      _filtro = _Filtro.todos;
                      _busca.clear();
                    }),
                  ),
                ),
              ],
            );

            final conteudo = painel && selecionado != null
                ? Row(
                    children: [
                      Expanded(child: principal),
                      const VerticalDivider(width: 1),
                      SizedBox(
                        width: 480,
                        child: ChamadoDetalhe(
                          key: ValueKey(selecionado.id),
                          chamado: selecionado,
                          aoFechar: () => setState(() => _selecionadoId = null),
                          aoAbrirConversa: widget.aoAbrirConversa,
                        ),
                      ),
                    ],
                  )
                : principal;

            return Stack(
              children: [
                Positioned.fill(child: conteudo),
                if (estreito && widget.origem == OrigemChamados.meus)
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton.extended(
                      onPressed: () => _novo(dados),
                      icon: const Icon(Icons.add),
                      label: const Text('Abrir chamado'),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

class _Cabecalho extends StatelessWidget {
  const _Cabecalho({
    required this.titulo,
    required this.total,
    required this.estreito,
    required this.carregando,
    required this.aoAtualizar,
    required this.aoNovo,
  });

  final String titulo;
  final int? total;
  final bool estreito;
  final bool carregando;
  final VoidCallback aoAtualizar;
  final VoidCallback aoNovo;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: tema.headlineMedium),
                if (total != null) ...[
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                            text: '$total',
                            style: Estilos.corpo(
                                tamanho: 15,
                                cor: Cores.texto,
                                peso: FontWeight.w600)),
                        TextSpan(text: total == 1 ? ' chamado' : ' chamados'),
                      ],
                    ),
                    style: tema.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          if (!estreito) ...[
            IconButton(
              tooltip: 'Atualizar lista',
              onPressed: carregando ? null : aoAtualizar,
              icon: const Icon(Icons.refresh),
            ),
            const SizedBox(width: 6),
            FilledButton.icon(
              onPressed: aoNovo,
              icon: const Icon(Icons.add),
              label: const Text('Abrir chamado'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Filtros por situação, como chips com a contagem ao lado. Cada um filtra a
/// lista; o escolhido fica com a borda e o texto em brasa.
class _Resumo extends StatelessWidget {
  const _Resumo({
    required this.chamados,
    required this.atual,
    required this.aoEscolher,
  });

  final List<Chamado> chamados;
  final _Filtro atual;
  final ValueChanged<_Filtro> aoEscolher;

  @override
  Widget build(BuildContext context) {
    Widget chip(_Filtro f) {
      final n = chamados.where((c) => f.aceita(c.status)).length;
      final ativo = f == atual;
      return Semantics(
        button: true,
        selected: ativo,
        label: '${f.rotulo}: $n',
        excludeSemantics: true,
        child: InkWell(
          onTap: () => aoEscolher(f),
          borderRadius: BorderRadius.circular(raioFolha),
          child: Container(
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ativo
                  ? Cores.brasa.withValues(alpha: .12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(raioFolha),
              border: Border.all(color: ativo ? Cores.brasa : Cores.borda),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  f.rotulo,
                  maxLines: 1,
                  style: Estilos.corpo(
                    tamanho: 14,
                    peso: FontWeight.w700,
                    cor: ativo ? Cores.brasa : Cores.suave,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: Cores.painelAlto,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '$n',
                    style: Estilos.corpo(
                      tamanho: 12,
                      peso: FontWeight.w700,
                      cor: ativo ? Cores.texto : Cores.apagado,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final f in _Filtro.values) ...[
              chip(f),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _Barra extends StatelessWidget {
  const _Barra({
    required this.busca,
    required this.ordem,
    required this.visao,
    required this.estreito,
    required this.aoMudarBusca,
    required this.aoOrdenar,
    required this.aoMudarVisao,
  });

  final TextEditingController busca;
  final _Ordem ordem;
  final _Visao visao;
  final bool estreito;
  final VoidCallback aoMudarBusca;
  final ValueChanged<_Ordem> aoOrdenar;
  final ValueChanged<_Visao> aoMudarVisao;

  @override
  Widget build(BuildContext context) {
    final campo = SizedBox(
      height: 46,
      child: TextField(
        controller: busca,
        onChanged: (_) => aoMudarBusca(),
        textInputAction: TextInputAction.search,
        style: Estilos.corpo(tamanho: 16),
        decoration: InputDecoration(
          hintText: estreito
              ? 'Buscar chamados'
              : 'Buscar por descrição, endereço ou número',
          prefixIcon: Center(
            widthFactor: 1,
            child: Text('>',
                style: Estilos.corpo(
                    tamanho: 16, cor: Cores.brasa, peso: FontWeight.w800)),
          ),
          contentPadding: EdgeInsets.zero,
          suffixIcon: busca.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpar busca',
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    busca.clear();
                    aoMudarBusca();
                  },
                ),
        ),
      ),
    );

    final ordenar = PopupMenuButton<_Ordem>(
      tooltip: 'Ordenar',
      initialValue: ordem,
      onSelected: aoOrdenar,
      itemBuilder: (_) => [
        for (final o in _Ordem.values)
          PopupMenuItem(value: o, child: Text(o.rotulo)),
      ],
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Cores.painel,
          borderRadius: BorderRadius.circular(raioFolha),
          border: Border.all(color: Cores.borda),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_vert, size: 20, color: Cores.suave),
            if (!estreito) ...[
              const SizedBox(width: 8),
              Text(ordem.rotulo,
                  style: Estilos.corpo(tamanho: 15, peso: FontWeight.w500)),
              const SizedBox(width: 4),
              Icon(Icons.expand_more, size: 20, color: Cores.suave),
            ],
          ],
        ),
      ),
    );

    Widget botaoVisao(_Visao v, IconData icone, String dica) {
      final ativo = v == visao;
      return Tooltip(
        message: dica,
        child: InkWell(
          onTap: () => aoMudarVisao(v),
          borderRadius: BorderRadius.circular(raioFolha),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: ativo ? Cores.painelAlto : Colors.transparent,
              borderRadius: BorderRadius.circular(raioFolha),
            ),
            child:
                Icon(icone, size: 20, color: ativo ? Cores.brasa : Cores.suave),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          Expanded(child: campo),
          const SizedBox(width: 10),
          ordenar,
          if (!estreito) ...[
            const SizedBox(width: 10),
            Container(
              height: 46,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Cores.painel,
                borderRadius: BorderRadius.circular(raioFolha),
                border: Border.all(color: Cores.borda),
              ),
              child: Row(
                children: [
                  botaoVisao(_Visao.grade, Icons.grid_view, 'Ver em cartões'),
                  botaoVisao(_Visao.lista, Icons.view_list, 'Ver em lista'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Corpo extends StatelessWidget {
  const _Corpo({
    required this.origem,
    required this.carga,
    required this.visiveis,
    required this.visao,
    required this.selecionadoId,
    required this.espacoParaBotao,
    required this.aoAbrir,
    required this.aoAtualizar,
    required this.aoNovo,
    required this.aoLimpar,
  });

  final OrigemChamados origem;
  final Carga<List<Chamado>> carga;
  final List<Chamado> visiveis;
  final _Visao visao;
  final int? selecionadoId;
  final bool espacoParaBotao;
  final ValueChanged<Chamado> aoAbrir;
  final Future<void> Function() aoAtualizar;
  final VoidCallback aoNovo;
  final VoidCallback aoLimpar;

  @override
  Widget build(BuildContext context) {
    final todos = carga.dados;
    if (todos == null && carga.erro == null) return const Carregando();
    if (todos == null) {
      return EstadoErro(erro: carga.erro!, aoTentar: aoAtualizar);
    }

    if (todos.isEmpty) {
      return origem == OrigemChamados.meus
          ? EstadoVazio(
              icone: Icons.inbox_outlined,
              titulo: 'Você ainda não abriu chamados',
              descricao:
                  'Descreva o problema e o endereço. Um técnico poderá aceitar o chamado.',
              acao: FilledButton.icon(
                onPressed: aoNovo,
                icon: const Icon(Icons.add),
                label: const Text('Abrir chamado'),
              ),
            )
          : const EstadoVazio(
              icone: Icons.task_alt_outlined,
              titulo: 'Nenhum chamado pendente',
              descricao:
                  'Quando alguém abrir um chamado, ele aparece aqui para você aceitar.',
            );
    }

    if (visiveis.isEmpty) {
      return EstadoVazio(
        icone: Icons.search_off,
        titulo: 'Nenhum chamado encontrado',
        descricao: 'Nenhum chamado corresponde à busca ou ao filtro escolhido.',
        acao: OutlinedButton(
            onPressed: aoLimpar, child: const Text('Limpar busca e filtro')),
      );
    }

    final folga = espacoParaBotao ? 96.0 : 28.0;
    return RefreshIndicator(
      onRefresh: aoAtualizar,
      child: visao == _Visao.grade
          ? GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 0, 20, folga),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 440,
                mainAxisExtent: 160,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: visiveis.length,
              itemBuilder: (context, i) => _Cartao(
                chamado: visiveis[i],
                selecionado: visiveis[i].id == selecionadoId,
                aoTocar: () => aoAbrir(visiveis[i]),
              ),
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 0, 20, folga),
              itemCount: visiveis.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _Linha(
                  chamado: visiveis[i],
                  selecionado: visiveis[i].id == selecionadoId,
                  aoTocar: () => aoAbrir(visiveis[i]),
                ),
              ),
            ),
    );
  }
}

/// Quadrado com o ícone da situação, como o ícone dos cartões de referência.
class _Icone extends StatelessWidget {
  const _Icone(this.status);

  final StatusChamado status;

  static IconData _icone(StatusChamado s) => switch (s) {
        StatusChamado.pendente => Icons.hourglass_empty,
        StatusChamado.aceito => Icons.assignment_ind_outlined,
        StatusChamado.aCaminho => Icons.local_shipping_outlined,
        StatusChamado.atendimento => Icons.build_outlined,
        StatusChamado.finalizado => Icons.check,
        StatusChamado.cancelado => Icons.close,
      };

  @override
  Widget build(BuildContext context) {
    final cor = corDoStatus(status);
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: cor.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(raioFolha),
        border: Border.all(color: cor.withValues(alpha: .5)),
      ),
      child: Icon(_icone(status), size: 22, color: cor),
    );
  }
}

class _Cartao extends StatelessWidget {
  const _Cartao({
    required this.chamado,
    required this.selecionado,
    required this.aoTocar,
  });

  final Chamado chamado;
  final bool selecionado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return PainelToque(
      selecionado: selecionado,
      aoTocar: aoTocar,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Icone(chamado.status),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '#${chamado.id}',
                        style: Estilos.corpo(
                            tamanho: 14,
                            peso: FontWeight.w800,
                            cor: Cores.creme),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: StatusTexto(chamado.status, tamanho: 15)),
                      if (chamado.criadoEm != null)
                        Text(
                          relativo(chamado.criadoEm!),
                          style: Estilos.corpo(tamanho: 12, cor: Cores.apagado),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    chamado.descricao,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Estilos.corpo(tamanho: 14, peso: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chamado.endereco,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tema.bodyMedium?.copyWith(fontSize: 13),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Etiqueta(
                        chamado.prioridade.label,
                        cor: Cores.prioridade(chamado.prioridade),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: RotaMini(chamado.status),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.chamado,
    required this.selecionado,
    required this.aoTocar,
  });

  final Chamado chamado;
  final bool selecionado;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return PainelToque(
      selecionado: selecionado,
      aoTocar: aoTocar,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: LayoutBuilder(
          builder: (context, caixa) {
            final comRota = caixa.maxWidth >= 700;
            return Row(
              children: [
                _Icone(chamado.status),
                const SizedBox(width: 12),
                SizedBox(
                  width: 64,
                  child: Text(
                    '#${chamado.id}',
                    style: Estilos.corpo(
                        tamanho: 14, peso: FontWeight.w800, cor: Cores.creme),
                  ),
                ),
                SizedBox(
                    width: 150,
                    child: StatusTexto(chamado.status, tamanho: 15)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chamado.descricao,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Estilos.corpo(tamanho: 14, peso: FontWeight.w600),
                      ),
                      Text(
                        chamado.endereco,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tema.bodyMedium?.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Etiqueta(chamado.prioridade.label,
                    cor: Cores.prioridade(chamado.prioridade)),
                if (comRota) ...[
                  const SizedBox(width: 16),
                  RotaMini(chamado.status),
                ],
                if (chamado.criadoEm != null) ...[
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 104,
                    child: Text(
                      relativo(chamado.criadoEm!),
                      textAlign: TextAlign.right,
                      style: Estilos.corpo(tamanho: 12, cor: Cores.apagado),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
