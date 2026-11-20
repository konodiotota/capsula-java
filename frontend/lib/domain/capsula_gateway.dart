import 'models.dart';

/// Contrato entre o app e o backend Capsula.
///
/// Cada método corresponde a uma operação que já existe nos serviços Java
/// (`ChamadoService`, `HistoricoChamadoService`, `ChatService`,
/// `UsuarioService`). Os controllers ainda não expõem rotas HTTP, portanto
/// nenhuma URL é presumida: quando existirem, implemente esta interface e
/// troque [SemApiCapsulaGateway] em `main.dart`.
abstract interface class CapsulaGateway {
  // Conta (AutenticacaoController / UsuarioController, ainda vazios).
  Future<Usuario> entrar(Credenciais credenciais);
  Future<Usuario> cadastrar(NovoUsuario usuario);
  Future<void> sair();

  // Chamados.
  Future<List<Chamado>> meusChamados();
  Future<List<Chamado>> chamadosDisponiveis();
  Future<Chamado> criarChamado(NovoChamado chamado);
  Future<Chamado> aceitarChamado(int chamadoId);
  Future<Chamado> iniciarDeslocamento(int chamadoId);
  Future<Chamado> iniciarAtendimento(int chamadoId);
  Future<Chamado> finalizarAtendimento(int chamadoId);
  Future<Chamado> cancelarChamado(int chamadoId);
  Future<List<HistoricoChamado>> historico(int chamadoId);

  // Conversas.
  Future<List<Chat>> meusChats();
  Future<Chat> abrirChat(int chamadoId);
  Future<List<Mensagem>> mensagens(int chatId);
  Future<Mensagem> enviarMensagem(int chatId, String conteudo);
}

/// Falha devolvida pelo servidor, já com texto que o usuário entende.
class FalhaApi implements Exception {
  const FalhaApi(this.mensagem);
  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Usada enquanto o backend não publica rotas HTTP.
class ApiAindaIndisponivel extends FalhaApi {
  const ApiAindaIndisponivel()
      : super(
          'O servidor da Capsula ainda não publica essa operação. '
          'Ela ficará disponível quando os controllers forem implementados.',
        );
}

class SemApiCapsulaGateway implements CapsulaGateway {
  const SemApiCapsulaGateway();

  Never _indisponivel() => throw const ApiAindaIndisponivel();

  @override
  Future<Usuario> entrar(Credenciais credenciais) async => _indisponivel();
  @override
  Future<Usuario> cadastrar(NovoUsuario usuario) async => _indisponivel();
  @override
  Future<void> sair() async {}
  @override
  Future<List<Chamado>> meusChamados() async => _indisponivel();
  @override
  Future<List<Chamado>> chamadosDisponiveis() async => _indisponivel();
  @override
  Future<Chamado> criarChamado(NovoChamado chamado) async => _indisponivel();
  @override
  Future<Chamado> aceitarChamado(int chamadoId) async => _indisponivel();
  @override
  Future<Chamado> iniciarDeslocamento(int chamadoId) async => _indisponivel();
  @override
  Future<Chamado> iniciarAtendimento(int chamadoId) async => _indisponivel();
  @override
  Future<Chamado> finalizarAtendimento(int chamadoId) async => _indisponivel();
  @override
  Future<Chamado> cancelarChamado(int chamadoId) async => _indisponivel();
  @override
  Future<List<HistoricoChamado>> historico(int chamadoId) async =>
      _indisponivel();
  @override
  Future<List<Chat>> meusChats() async => _indisponivel();
  @override
  Future<Chat> abrirChat(int chamadoId) async => _indisponivel();
  @override
  Future<List<Mensagem>> mensagens(int chatId) async => _indisponivel();
  @override
  Future<Mensagem> enviarMensagem(int chatId, String conteudo) async =>
      _indisponivel();
}
