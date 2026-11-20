import 'package:material_ui/material_ui.dart';

import '../domain/capsula_gateway.dart';
import '../domain/models.dart';

/// Resultado de uma carga: dados, falha e se há uma nova carga em andamento.
class Carga<T> {
  const Carga({this.dados, this.erro, this.carregando = false});

  final T? dados;
  final Object? erro;
  final bool carregando;
}

/// Listas compartilhadas entre as telas, para que a barra lateral, a lista e
/// o detalhe mostrem sempre os mesmos números.
class Dados extends ChangeNotifier {
  Dados(this.gateway, this.usuario);

  final CapsulaGateway gateway;
  final Usuario usuario;
  bool _encerrado = false;

  Carga<List<Chamado>> meus = const Carga(carregando: true);
  Carga<List<Chamado>> disponiveis = const Carga();
  Carga<List<Chat>> chats = const Carga(carregando: true);

  /// Chamados pendentes na fila de atendimento, ou `null` se ainda não carregou.
  int? get pendentesDisponiveis => disponiveis.dados
      ?.where((c) => c.status == StatusChamado.pendente)
      .length;

  void iniciar() {
    carregarMeus();
    carregarChats();
    if (usuario.perfil.atende) carregarDisponiveis();
  }

  /// Para de notificar depois que a sessão termina.
  void encerrar() => _encerrado = true;

  void _emitir() {
    if (!_encerrado) notifyListeners();
  }

  Future<void> carregarMeus() async {
    meus = Carga(dados: meus.dados, carregando: true);
    _emitir();
    try {
      meus = Carga(dados: await gateway.meusChamados());
    } catch (e) {
      meus = Carga(dados: meus.dados, erro: e);
    }
    _emitir();
  }

  Future<void> carregarDisponiveis() async {
    disponiveis = Carga(dados: disponiveis.dados, carregando: true);
    _emitir();
    try {
      disponiveis = Carga(dados: await gateway.chamadosDisponiveis());
    } catch (e) {
      disponiveis = Carga(dados: disponiveis.dados, erro: e);
    }
    _emitir();
  }

  Future<void> carregarChats() async {
    chats = Carga(dados: chats.dados, carregando: true);
    _emitir();
    try {
      chats = Carga(dados: await gateway.meusChats());
    } catch (e) {
      chats = Carga(dados: chats.dados, erro: e);
    }
    _emitir();
  }

  /// Troca o chamado nas duas listas depois de uma ação.
  void atualizar(Chamado novo) {
    List<Chamado>? trocar(List<Chamado>? itens) => itens == null
        ? null
        : [for (final c in itens) c.id == novo.id ? novo : c];
    meus = Carga(dados: trocar(meus.dados), erro: meus.erro);
    disponiveis =
        Carga(dados: trocar(disponiveis.dados), erro: disponiveis.erro);
    _emitir();
  }

  void inserir(Chamado novo) {
    meus = Carga(dados: [novo, ...?meus.dados]);
    _emitir();
  }
}

/// Reconstrói [builder] sempre que as listas mudam.
class ComDados extends StatelessWidget {
  const ComDados({super.key, required this.dados, required this.builder});

  final Dados dados;
  final Widget Function(BuildContext context, Dados dados) builder;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: dados,
        builder: (context, _) => builder(context, dados),
      );
}
