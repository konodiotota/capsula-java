import 'package:material_ui/material_ui.dart';

import '../../app/dados.dart';
import '../../app/sessao.dart';
import '../../domain/models.dart';
import '../../shared/formatadores.dart';
import '../../shared/widgets/botao_tema.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/marca.dart';
import '../../theme/capsula_theme.dart';
import '../chamados/chamados_page.dart';
import '../chat/chats_page.dart';
import '../conta/conta_page.dart';

enum Destino {
  meus(
      'Meus chamados', 'Chamados', Icons.assignment_outlined, Icons.assignment),
  disponiveis('Disponíveis', 'Disponíveis', Icons.inbox_outlined, Icons.inbox),
  conversas('Conversas', 'Conversas', Icons.forum_outlined, Icons.forum),
  conta('Minha conta', 'Conta', Icons.person_outline, Icons.person);

  const Destino(this.rotulo, this.rotuloCurto, this.icone, this.iconeAtivo);
  final String rotulo;
  final String rotuloCurto;
  final IconData icone;
  final IconData iconeAtivo;
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  Destino _destino = Destino.meus;
  Chat? _chatInicial;

  bool get _largo => MediaQuery.sizeOf(context).width >= 840;

  void _abrirConversa(Chat chat) {
    SessaoScope.of(context).dados.carregarChats();
    if (_largo) {
      setState(() {
        _destino = Destino.conversas;
        _chatInicial = chat;
      });
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => ConversaPage(chat: chat)),
      );
    }
  }

  Widget _pagina(Destino d) => switch (d) {
        Destino.meus => ChamadosPage(
            origem: OrigemChamados.meus,
            aoAbrirConversa: _abrirConversa,
          ),
        Destino.disponiveis => ChamadosPage(
            origem: OrigemChamados.disponiveis,
            aoAbrirConversa: _abrirConversa,
          ),
        Destino.conversas => ChatsPage(chatInicial: _chatInicial),
        Destino.conta => const ContaPage(),
      };

  @override
  Widget build(BuildContext context) {
    final sessao = SessaoScope.of(context);
    final usuario = sessao.usuario!;
    final destinos = [
      Destino.meus,
      if (usuario.perfil.atende) Destino.disponiveis,
      Destino.conversas,
      Destino.conta,
    ];
    final indice = destinos.indexOf(_destino).clamp(0, destinos.length - 1);
    final largo = _largo;

    // As páginas ficam montadas para preservar filtros e rolagem ao trocar.
    final conteudo = IndexedStack(
      index: indice,
      children: [for (final d in destinos) _pagina(d)],
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: largo
            ? Row(
                children: [
                  _Lateral(
                    destinos: destinos,
                    atual: _destino,
                    aoMudar: (d) => setState(() => _destino = d),
                  ),
                  Expanded(child: conteudo),
                ],
              )
            : conteudo,
      ),
      bottomNavigationBar: largo
          ? null
          : NavigationBar(
              selectedIndex: indice,
              onDestinationSelected: (i) =>
                  setState(() => _destino = destinos[i]),
              destinations: [
                for (final d in destinos)
                  NavigationDestination(
                    icon: Icon(d.icone),
                    selectedIcon: Icon(d.iconeAtivo),
                    label: d.rotuloCurto,
                  ),
              ],
            ),
    );
  }
}

class _Lateral extends StatelessWidget {
  const _Lateral({
    required this.destinos,
    required this.atual,
    required this.aoMudar,
  });

  final List<Destino> destinos;
  final Destino atual;
  final ValueChanged<Destino> aoMudar;

  @override
  Widget build(BuildContext context) {
    final sessao = SessaoScope.of(context);
    final usuario = sessao.usuario!;

    Widget grupo(String titulo, List<Destino> itens, Dados dados) {
      final visiveis = itens.where(destinos.contains).toList();
      if (visiveis.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 22, 12, 8),
            child: Text(titulo,
                style: Estilos.corpo(
                    tamanho: 13, cor: Cores.apagado, peso: FontWeight.w600)),
          ),
          for (final d in visiveis)
            _ItemLateral(
              destino: d,
              ativo: d == atual,
              contador: switch (d) {
                Destino.meus => dados.meus.dados?.length,
                Destino.disponiveis => dados.pendentesDisponiveis,
                Destino.conversas => dados.chats.dados?.length,
                Destino.conta => null,
              },
              aoTocar: () => aoMudar(d),
            ),
        ],
      );
    }

    return Container(
      width: 248,
      decoration: BoxDecoration(
        color: Cores.lateral,
        border: Border(right: BorderSide(color: Cores.borda)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 26, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12),
            child: Marca(),
          ),
          Expanded(
            child: ComDados(
              dados: sessao.dados,
              builder: (context, dados) => ListView(
                padding: EdgeInsets.zero,
                children: [
                  grupo('Atendimentos', [Destino.meus, Destino.disponiveis],
                      dados),
                  grupo('Comunicação', [Destino.conversas], dados),
                  grupo('Conta', [Destino.conta], dados),
                ],
              ),
            ),
          ),
          const BotaoTema(rotulo: true),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Cores.painel,
              borderRadius: BorderRadius.circular(raioFolha),
              border: Border.all(color: Cores.borda),
            ),
            child: Row(
              children: [
                Iniciais(iniciais(usuario.nome), tamanho: 38),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        primeiroNome(usuario.nome),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Estilos.corpo(tamanho: 15, peso: FontWeight.w600),
                      ),
                      Text(
                        usuario.perfil.label,
                        style: Estilos.corpo(tamanho: 13, cor: Cores.suave),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemLateral extends StatelessWidget {
  const _ItemLateral({
    required this.destino,
    required this.ativo,
    required this.contador,
    required this.aoTocar,
  });

  final Destino destino;
  final bool ativo;
  final int? contador;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Semantics(
        button: true,
        selected: ativo,
        child: InkWell(
          onTap: aoTocar,
          borderRadius: BorderRadius.circular(raioFolha),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: ativo ? Cores.painelAlto : Colors.transparent,
              borderRadius: BorderRadius.circular(raioFolha),
              border: Border(
                left: BorderSide(
                    color: ativo ? Cores.brasa : Colors.transparent, width: 3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  ativo ? destino.iconeAtivo : destino.icone,
                  size: 20,
                  color: ativo ? Cores.brasa : Cores.suave,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    destino.rotulo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Estilos.corpo(
                      tamanho: 14,
                      peso: FontWeight.w700,
                      cor: ativo ? Cores.texto : Cores.suave,
                    ),
                  ),
                ),
                if (contador != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Cores.fundo,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: ativo
                              ? Cores.brasa.withValues(alpha: .6)
                              : Cores.borda),
                    ),
                    child: Text(
                      '$contador',
                      style: Estilos.corpo(
                        tamanho: 12,
                        peso: FontWeight.w800,
                        cor: ativo ? Cores.brasa : Cores.suave,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
