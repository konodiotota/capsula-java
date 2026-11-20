import 'package:material_ui/material_ui.dart';

import '../../app/sessao.dart';
import '../../domain/models.dart';
import '../../domain/regras.dart';
import '../../shared/widgets/feedback.dart';
import '../../theme/capsula_theme.dart';

/// Formulário de `ChamadoRequestDTO`. Devolve o [Chamado] criado ao fechar.
class NovoChamadoPage extends StatefulWidget {
  const NovoChamadoPage({super.key});

  @override
  State<NovoChamadoPage> createState() => _NovoChamadoPageState();
}

class _NovoChamadoPageState extends State<NovoChamadoPage> {
  final _form = GlobalKey<FormState>();
  final _descricao = TextEditingController();
  final _endereco = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _descricao.dispose();
    _endereco.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    final gateway = SessaoScope.of(context).gateway;
    setState(() => _enviando = true);
    try {
      final criado = await gateway.criarChamado(NovoChamado(
        descricao: _descricao.text.trim(),
        endereco: _endereco.text.trim(),
      ));
      if (!mounted) return;
      mostrarAviso(context, 'Chamado ${criado.id} criado.');
      Navigator.of(context).pop(criado);
    } catch (e) {
      if (mounted) mostrarAviso(context, mensagemDeErro(e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Abrir chamado')),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _form,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                children: [
                  Text('O que precisa ser atendido?',
                      style: tema.headlineSmall),
                  const SizedBox(height: 8),
                  Text(
                    'O chamado começa como pendente. Quando um técnico aceitar, '
                    'você poderá conversar com ele.',
                    style: tema.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: _descricao,
                    maxLength: Limites.descricao,
                    minLines: 5,
                    maxLines: 8,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            required maxLength}) =>
                        Text(
                      '$currentLength/$maxLength',
                      style: Estilos.corpo(tamanho: 13, cor: Cores.apagado),
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      alignLabelWithHint: true,
                    ),
                    validator: Validadores.descricao,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _endereco,
                    maxLength: Limites.endereco,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.streetAddress,
                    buildCounter: (_,
                            {required currentLength,
                            required isFocused,
                            required maxLength}) =>
                        Text(
                      '$currentLength/$maxLength',
                      style: Estilos.corpo(tamanho: 13, cor: Cores.apagado),
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Endereço do atendimento',
                      prefixIcon: Icon(Icons.place_outlined),
                    ),
                    validator: Validadores.endereco,
                    onFieldSubmitted: (_) => _enviando ? null : _enviar(),
                  ),
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton(
                      onPressed: _enviando ? null : _enviar,
                      child: _enviando
                          ? SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                color: Cores.sobreBrasa,
                              ),
                            )
                          : const Text('Abrir chamado'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
