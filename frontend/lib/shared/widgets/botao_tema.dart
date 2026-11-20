import 'package:material_ui/material_ui.dart';

import '../../theme/capsula_theme.dart';
import '../../theme/tema_scope.dart';

/// Alterna entre o tema preto e o branco. Com [rotulo], vira uma linha larga
/// com texto, para a barra lateral e para a conta; sem ele, um quadrado só
/// com o ícone.
class BotaoTema extends StatelessWidget {
  const BotaoTema({super.key, this.rotulo = false});

  final bool rotulo;

  @override
  Widget build(BuildContext context) {
    final tema = TemaScope.of(context);
    final texto = tema.escuro ? 'Usar tema branco' : 'Usar tema preto';
    final icone = Icon(
      tema.escuro ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
      size: 20,
      color: Cores.brasa,
    );

    return Semantics(
      button: true,
      label: texto,
      excludeSemantics: true,
      child: Tooltip(
        message: texto,
        child: Material(
          color: Cores.painel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(raioFolha),
            side: BorderSide(color: Cores.bordaForte),
          ),
          child: InkWell(
            onTap: tema.alternar,
            borderRadius: BorderRadius.circular(raioFolha),
            child: rotulo
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: SizedBox(
                      height: 42,
                      child: Row(
                        children: [
                          icone,
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              texto,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Estilos.corpo(
                                  tamanho: 14, peso: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox.square(dimension: 44, child: Center(child: icone)),
          ),
        ),
      ),
    );
  }
}
