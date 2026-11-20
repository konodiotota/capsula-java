import 'package:material_ui/material_ui.dart';

import '../../app/dados.dart';
import '../../app/sessao.dart';
import '../../domain/models.dart';
import '../../shared/formatadores.dart';
import '../../shared/widgets/feedback.dart';
import '../../theme/capsula_theme.dart';
import 'conversa_view.dart';

/// Tela cheia de uma conversa, usada em telas estreitas.
class ConversaPage extends StatelessWidget {
  const ConversaPage({super.key, required this.chat});

  final Chat chat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Chamado ${chat.chamadoId}'),
            Text(
              chat.nomeTecnicoResponsavel,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 14),
            ),
          ],
        ),
      ),
      body: ConversaView(chat: chat, mostrarCabecalho: false),
    );
  }
}

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key, this.chatInicial});

  /// Conversa a selecionar quando a tela abre em modo lado a lado.
  final Chat? chatInicial;

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  int? _selecionadoId;

  @override
  void initState() {
    super.initState();
    _selecionadoId = widget.chatInicial?.id;
  }

  @override
  void didUpdateWidget(covariant ChatsPage antigo) {
    super.didUpdateWidget(antigo);
    final novo = widget.chatInicial;
    if (novo != null && novo.id != antigo.chatInicial?.id) {
      setState(() => _selecionadoId = novo.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dados = SessaoScope.of(context).dados;
    final tema = Theme.of(context).textTheme;

    return ComDados(
      dados: dados,
      builder: (context, dados) {
        final carga = dados.chats;
        final chats = carga.dados;

        Widget lista(bool lado) {
          if (chats == null && carga.erro == null) return const Carregando();
          if (chats == null) {
            return EstadoErro(erro: carga.erro!, aoTentar: dados.carregarChats);
          }
          if (chats.isEmpty) {
            return const EstadoVazio(
              icone: Icons.forum_outlined,
              titulo: 'Nenhuma conversa ainda',
              descricao:
                  'A conversa de um chamado abre depois que um técnico aceita o atendimento. '
                  'Abra-a pelo chamado.',
            );
          }
          return RefreshIndicator(
            onRefresh: dados.carregarChats,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
              itemCount: chats.length,
              itemBuilder: (context, i) {
                final chat = chats[i];
                final selecionado = lado && chat.id == _selecionadoId;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(raioFolha),
                      onTap: () {
                        if (lado) {
                          setState(() => _selecionadoId = chat.id);
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ConversaPage(chat: chat),
                            ),
                          );
                        }
                      },
                      child: Ink(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: selecionado ? Cores.painelAlto : Cores.painel,
                          borderRadius: BorderRadius.circular(raioFolha),
                          border: Border.all(
                            color: selecionado ? Cores.brasa : Cores.borda,
                            width: selecionado ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Iniciais(iniciais(chat.nomeTecnicoResponsavel),
                                tamanho: 44),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chamado ${chat.chamadoId}',
                                    style: Estilos.titulo(tamanho: 20),
                                  ),
                                  Text(
                                    chat.nomeTecnicoResponsavel,
                                    style: tema.bodyMedium,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              relativo(chat.criadoEm),
                              style: Estilos.corpo(
                                  tamanho: 13, cor: Cores.apagado),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, caixa) {
            final lado = caixa.maxWidth >= 900;
            final coluna = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 12, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Conversas', style: tema.headlineMedium),
                            if (chats != null) ...[
                              const SizedBox(height: 4),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${chats.length}',
                                      style: Estilos.corpo(
                                          tamanho: 15,
                                          cor: Cores.texto,
                                          peso: FontWeight.w600),
                                    ),
                                    TextSpan(
                                        text: chats.length == 1
                                            ? ' conversa'
                                            : ' conversas'),
                                  ],
                                ),
                                style: tema.bodyMedium,
                              ),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Atualizar conversas',
                        onPressed:
                            carga.carregando ? null : dados.carregarChats,
                        icon: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(child: lista(lado)),
              ],
            );
            if (!lado) return coluna;

            Chat? selecionado;
            for (final c in chats ?? const <Chat>[]) {
              if (c.id == _selecionadoId) selecionado = c;
            }
            if (selecionado == null &&
                widget.chatInicial?.id == _selecionadoId) {
              selecionado = widget.chatInicial;
            }

            return Row(
              children: [
                SizedBox(width: 380, child: coluna),
                const VerticalDivider(width: 1),
                Expanded(
                  child: selecionado == null
                      ? const EstadoVazio(
                          icone: Icons.forum_outlined,
                          titulo: 'Escolha uma conversa',
                          descricao: 'As mensagens do chamado aparecem aqui.',
                        )
                      : ConversaView(
                          key: ValueKey(selecionado.id), chat: selecionado),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
