import 'package:material_ui/material_ui.dart';

import 'app/sessao.dart';
import 'domain/capsula_gateway.dart';
import 'features/auth/auth_page.dart';
import 'features/shell/app_shell.dart';
import 'theme/capsula_theme.dart';
import 'theme/tema_scope.dart';

void main() {
  // Troque por uma implementação HTTP quando o backend publicar suas rotas.
  runApp(const CapsulaApp(gateway: SemApiCapsulaGateway()));
}

class CapsulaApp extends StatefulWidget {
  const CapsulaApp({super.key, required this.gateway});

  final CapsulaGateway gateway;

  @override
  State<CapsulaApp> createState() => _CapsulaAppState();
}

class _CapsulaAppState extends State<CapsulaApp> {
  late final Sessao _sessao = Sessao(widget.gateway);
  bool _escuro = true;

  /// Troca a paleta e reconstrói a árvore inteira: as telas leem [Cores] ao
  /// construir, então precisam ser reconstruídas, sem perder o estado delas.
  void _alternarTema() {
    _escuro = !_escuro;
    Cores.usar(_escuro ? Paleta.escuro : Paleta.claro);
    setState(() {});
    void marcar(Element e) {
      e.markNeedsBuild();
      e.visitChildren(marcar);
    }

    (context as Element).visitChildren(marcar);
  }

  @override
  void dispose() {
    _sessao.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Cores.usar(_escuro ? Paleta.escuro : Paleta.claro);
    return TemaScope(
      escuro: _escuro,
      alternar: _alternarTema,
      child: MaterialApp(
        title: 'Capsula',
        debugShowCheckedModeBanner: false,
        theme: construirTema(),
        // O escopo fica acima do Navigator para que rotas empilhadas o enxerguem.
        builder: (context, child) =>
            SessaoScope(sessao: _sessao, child: child!),
        home: ListenableBuilder(
          listenable: _sessao,
          builder: (context, _) =>
              _sessao.autenticado ? const AppShell() : const AuthPage(),
        ),
      ),
    );
  }
}
