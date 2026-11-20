import 'package:material_ui/material_ui.dart';

/// Tema atual (escuro ou claro) e a ação de alternar, para qualquer tela.
class TemaScope extends InheritedWidget {
  const TemaScope({
    super.key,
    required this.escuro,
    required this.alternar,
    required super.child,
  });

  final bool escuro;
  final VoidCallback alternar;

  static TemaScope of(BuildContext context) {
    final escopo = context.dependOnInheritedWidgetOfExactType<TemaScope>();
    assert(escopo != null, 'TemaScope ausente na árvore de widgets');
    return escopo!;
  }

  @override
  bool updateShouldNotify(TemaScope antigo) => escuro != antigo.escuro;
}
