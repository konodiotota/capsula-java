import 'package:material_ui/material_ui.dart';

import '../domain/capsula_gateway.dart';
import '../domain/models.dart';
import 'dados.dart';

/// Estado de autenticação e acesso ao [CapsulaGateway] para toda a árvore.
class Sessao extends ChangeNotifier {
  Sessao(this.gateway);

  final CapsulaGateway gateway;
  Usuario? _usuario;
  Dados? _dados;

  Usuario? get usuario => _usuario;
  bool get autenticado => _usuario != null;

  /// Listas do usuário autenticado. Só existe depois do login.
  Dados get dados => _dados!;

  void _iniciar(Usuario usuario) {
    _usuario = usuario;
    _dados = Dados(gateway, usuario)..iniciar();
    notifyListeners();
  }

  Future<void> entrar(Credenciais credenciais) async =>
      _iniciar(await gateway.entrar(credenciais));

  /// Cria a conta e entra em seguida. O cadastro sempre cria um cliente.
  Future<void> cadastrar(NovoUsuario novo) async {
    await gateway.cadastrar(novo);
    await entrar(Credenciais(email: novo.email, senha: novo.senha));
  }

  Future<void> sair() async {
    await gateway.sair();
    _dados?.encerrar();
    _dados = null;
    _usuario = null;
    notifyListeners();
  }
}

class SessaoScope extends InheritedNotifier<Sessao> {
  const SessaoScope({super.key, required Sessao sessao, required super.child})
      : super(notifier: sessao);

  static Sessao of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SessaoScope>();
    assert(scope != null, 'SessaoScope ausente na árvore de widgets');
    return scope!.notifier!;
  }
}
