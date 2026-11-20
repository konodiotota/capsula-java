import 'package:capsula_frontend/domain/capsula_gateway.dart';
import 'package:capsula_frontend/domain/models.dart';

/// Gateway em memória, só para testes de interface. Os dados abaixo existem
/// apenas nos testes e nunca são incluídos no aplicativo.
class GatewayDeTeste implements CapsulaGateway {
  GatewayDeTeste({required this.usuario}) {
    _chamados = [
      Chamado(
        id: 1,
        descricao: 'Texto de teste 1',
        endereco: 'Endereço de teste 1',
        status: StatusChamado.pendente,
        prioridade: Prioridade.baixa,
        solicitante: usuario,
        criadoEm: DateTime(2026, 11, 18, 9, 30),
      ),
    ];
  }

  final Usuario usuario;
  late List<Chamado> _chamados;
  final chamadas = <String>[];
  Object? erroNoLogin;

  Chamado _trocar(int id, StatusChamado status, {Usuario? tecnico}) {
    final i = _chamados.indexWhere((c) => c.id == id);
    final c = _chamados[i];
    final novo = Chamado(
      id: c.id,
      descricao: c.descricao,
      endereco: c.endereco,
      status: status,
      prioridade: c.prioridade,
      solicitante: c.solicitante,
      tecnico: tecnico ?? c.tecnico,
      criadoEm: c.criadoEm,
    );
    _chamados[i] = novo;
    return novo;
  }

  @override
  Future<Usuario> entrar(Credenciais credenciais) async {
    chamadas.add('entrar');
    if (erroNoLogin != null) throw erroNoLogin!;
    return usuario;
  }

  @override
  Future<Usuario> cadastrar(NovoUsuario novo) async {
    chamadas.add('cadastrar');
    return usuario;
  }

  @override
  Future<void> sair() async => chamadas.add('sair');

  @override
  Future<List<Chamado>> meusChamados() async => List.of(_chamados);

  @override
  Future<List<Chamado>> chamadosDisponiveis() async => [
        for (final c in _chamados)
          if (c.status == StatusChamado.pendente) c,
      ];

  @override
  Future<Chamado> criarChamado(NovoChamado chamado) async {
    chamadas.add('criar');
    final c = Chamado(
      id: _chamados.length + 1,
      descricao: chamado.descricao,
      endereco: chamado.endereco,
      status: StatusChamado.pendente,
      prioridade: Prioridade.baixa,
      solicitante: usuario,
      criadoEm: DateTime.now(),
    );
    _chamados.add(c);
    return c;
  }

  @override
  Future<Chamado> aceitarChamado(int id) async =>
      _trocar(id, StatusChamado.aceito, tecnico: usuario);
  @override
  Future<Chamado> iniciarDeslocamento(int id) async =>
      _trocar(id, StatusChamado.aCaminho);
  @override
  Future<Chamado> iniciarAtendimento(int id) async =>
      _trocar(id, StatusChamado.atendimento);
  @override
  Future<Chamado> finalizarAtendimento(int id) async =>
      _trocar(id, StatusChamado.finalizado);
  @override
  Future<Chamado> cancelarChamado(int id) async {
    chamadas.add('cancelar');
    return _trocar(id, StatusChamado.cancelado);
  }

  @override
  Future<List<HistoricoChamado>> historico(int chamadoId) async => [];
  @override
  Future<List<Chat>> meusChats() async => [];
  @override
  Future<Chat> abrirChat(int chamadoId) async =>
      throw const FalhaApi('sem chat');
  @override
  Future<List<Mensagem>> mensagens(int chatId) async => [];
  @override
  Future<Mensagem> enviarMensagem(int chatId, String conteudo) async =>
      throw const FalhaApi('sem chat');
}
