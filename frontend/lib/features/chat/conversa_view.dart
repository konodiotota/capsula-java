import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../app/sessao.dart';
import '../../domain/models.dart';
import '../../domain/regras.dart';
import '../../shared/formatadores.dart';
import '../../shared/widgets/feedback.dart';
import '../../theme/capsula_theme.dart';

/// Mensagens de um [Chat] e campo para escrever.
class ConversaView extends StatefulWidget {
  const ConversaView(
      {super.key, required this.chat, this.mostrarCabecalho = true});

  final Chat chat;
  final bool mostrarCabecalho;

  @override
  State<ConversaView> createState() => _ConversaViewState();
}

class _ConversaViewState extends State<ConversaView> {
  final _texto = TextEditingController();
  List<Mensagem>? _mensagens;
  Object? _erro;
  bool _enviando = false;
  Timer? _atualizador;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_mensagens == null && _erro == null) {
      _carregar();
      _atualizador ??= Timer.periodic(
          const Duration(seconds: 10), (_) => _carregar(silencioso: true));
    }
  }

  @override
  void dispose() {
    _atualizador?.cancel();
    _texto.dispose();
    super.dispose();
  }

  Future<void> _carregar({bool silencioso = false}) async {
    if (!silencioso) setState(() => _erro = null);
    try {
      final m = await SessaoScope.of(context).gateway.mensagens(widget.chat.id);
      if (mounted) setState(() => _mensagens = m);
    } catch (e) {
      if (mounted && !silencioso) setState(() => _erro = e);
    }
  }

  Future<void> _enviar() async {
    final conteudo = _texto.text.trim();
    if (conteudo.isEmpty || conteudo.length > Limites.mensagem) return;
    setState(() => _enviando = true);
    try {
      final nova = await SessaoScope.of(context)
          .gateway
          .enviarMensagem(widget.chat.id, conteudo);
      if (!mounted) return;
      _texto.clear();
      setState(() => _mensagens = [...?_mensagens, nova]);
    } catch (e) {
      if (mounted) mostrarAviso(context, mensagemDeErro(e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = SessaoScope.of(context).usuario!;
    final tema = Theme.of(context).textTheme;

    Widget corpo;
    if (_mensagens == null && _erro == null) {
      corpo = const Carregando();
    } else if (_mensagens == null) {
      corpo = EstadoErro(erro: _erro!, aoTentar: _carregar);
    } else if (_mensagens!.isEmpty) {
      corpo = const EstadoVazio(
        icone: Icons.chat_bubble_outline,
        titulo: 'Nenhuma mensagem ainda',
        descricao: 'Escreva a primeira mensagem sobre este chamado.',
      );
    } else {
      final invertidas = _mensagens!.reversed.toList();
      corpo = ListView.builder(
        reverse: true,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        itemCount: invertidas.length,
        itemBuilder: (context, i) => _Balao(
          mensagem: invertidas[i],
          minha: invertidas[i].remetenteNome == usuario.nome,
        ),
      );
    }

    return Column(
      children: [
        if (widget.mostrarCabecalho)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 12, 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Cores.borda)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Chamado ${widget.chat.chamadoId}',
                          style: tema.headlineSmall),
                      const SizedBox(height: 2),
                      Text(
                        'Técnico responsável: ${widget.chat.nomeTecnicoResponsavel}',
                        style: tema.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Atualizar mensagens',
                  onPressed: _carregar,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
        Expanded(child: corpo),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: Cores.painel,
            border: Border(top: BorderSide(color: Cores.borda)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _texto,
                    minLines: 1,
                    maxLines: 5,
                    maxLength: Limites.mensagem,
                    textCapitalization: TextCapitalization.sentences,
                    style: Estilos.corpo(tamanho: 16),
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            required maxLength}) =>
                        null,
                    decoration: InputDecoration(
                      hintText: 'Escreva uma mensagem',
                      fillColor: Cores.fundo,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 52,
                  width: 52,
                  child: IconButton.filled(
                    tooltip: 'Enviar mensagem',
                    style: IconButton.styleFrom(
                      backgroundColor: Cores.brasa,
                      foregroundColor: Cores.sobreBrasa,
                      disabledBackgroundColor: Cores.borda,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(raioFolha),
                      ),
                    ),
                    onPressed: _enviando ? null : _enviar,
                    icon: _enviando
                        ? SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Cores.sobreBrasa,
                            ),
                          )
                        : const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Balao extends StatelessWidget {
  const _Balao({required this.mensagem, required this.minha});

  final Mensagem mensagem;
  final bool minha;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: (MediaQuery.sizeOf(context).width * .78).clamp(0, 520),
          ),
          child: Column(
            crossAxisAlignment:
                minha ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: minha ? Cores.brasa : Cores.painel,
                  border: minha ? null : Border.all(color: Cores.borda),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(raioFolha),
                    topRight: const Radius.circular(raioFolha),
                    bottomLeft: Radius.circular(minha ? raioFolha : 0),
                    bottomRight: Radius.circular(minha ? 0 : raioFolha),
                  ),
                ),
                child: SelectableText(
                  mensagem.conteudo,
                  style: Estilos.corpo(
                    tamanho: 16,
                    cor: minha ? Cores.sobreBrasa : Cores.texto,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    if (!minha)
                      TextSpan(
                          text: '${primeiroNome(mensagem.remetenteNome)}  '),
                    TextSpan(
                      text: dataHora(mensagem.criadoEm),
                      style: Estilos.corpo(tamanho: 13, cor: Cores.apagado),
                    ),
                  ],
                ),
                style: Estilos.corpo(tamanho: 13, cor: Cores.suave),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
