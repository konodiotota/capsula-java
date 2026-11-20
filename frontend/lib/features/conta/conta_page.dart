import 'package:material_ui/material_ui.dart';

import '../../app/sessao.dart';
import '../../shared/formatadores.dart';
import '../../shared/widgets/botao_tema.dart';
import '../../shared/widgets/feedback.dart';
import '../../theme/capsula_theme.dart';

class ContaPage extends StatefulWidget {
  const ContaPage({super.key});

  @override
  State<ContaPage> createState() => _ContaPageState();
}

class _ContaPageState extends State<ContaPage> {
  bool _saindo = false;

  Future<void> _sair() async {
    final sessao = SessaoScope.of(context);
    setState(() => _saindo = true);
    try {
      await sessao.sair();
    } catch (e) {
      if (mounted) {
        setState(() => _saindo = false);
        mostrarAviso(context, mensagemDeErro(e));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = SessaoScope.of(context).usuario!;
    final tema = Theme.of(context).textTheme;

    Widget campo(String rotulo, String valor) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              SizedBox(width: 110, child: Text(rotulo, style: tema.bodyMedium)),
              Expanded(child: Text(valor, style: tema.bodyLarge)),
            ],
          ),
        );

    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          children: [
            Text('Minha conta', style: tema.headlineMedium),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Cores.painel,
                borderRadius: BorderRadius.circular(raioFolha),
                border: Border.all(color: Cores.borda),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Iniciais(iniciais(usuario.nome), tamanho: 60),
                      const SizedBox(width: 16),
                      Expanded(
                          child: Text(usuario.nome, style: tema.titleLarge)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  if (usuario.email != null) campo('E-mail', usuario.email!),
                  if (usuario.email != null) const Divider(),
                  campo('Perfil', usuario.perfil.label),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const BotaoTema(rotulo: true),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _saindo ? null : _sair,
                icon: const Icon(Icons.logout),
                label: const Text('Sair da conta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
