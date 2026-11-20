import 'package:material_ui/material_ui.dart';

import '../../domain/capsula_gateway.dart';
import '../../domain/models.dart';
import '../../theme/capsula_theme.dart';

/// Texto de erro pronto para o usuário.
String mensagemDeErro(Object erro) => erro is FalhaApi
    ? erro.mensagem
    : 'Não foi possível concluir. Verifique sua conexão e tente de novo.';

void mostrarAviso(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(texto)));
}

/// Tela vazia: diz o que falta e oferece o próximo passo.
class EstadoVazio extends StatelessWidget {
  const EstadoVazio({
    super.key,
    required this.icone,
    required this.titulo,
    required this.descricao,
    this.acao,
  });

  final IconData icone;
  final String titulo;
  final String descricao;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Cores.painel,
                  borderRadius: BorderRadius.circular(raioFolha),
                  border: Border.all(color: Cores.borda),
                ),
                child: Icon(icone, size: 26, color: Cores.suave),
              ),
              const SizedBox(height: 16),
              Text(titulo, style: tema.titleLarge),
              const SizedBox(height: 8),
              Text(descricao, style: tema.bodyMedium),
              if (acao != null) ...[const SizedBox(height: 22), acao!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Falha ao carregar: mostra o motivo e permite tentar de novo.
class EstadoErro extends StatelessWidget {
  const EstadoErro({super.key, required this.erro, required this.aoTentar});

  final Object erro;
  final VoidCallback aoTentar;

  @override
  Widget build(BuildContext context) {
    return EstadoVazio(
      icone: Icons.cloud_off_outlined,
      titulo: 'Não foi possível carregar',
      descricao: mensagemDeErro(erro),
      acao: OutlinedButton.icon(
        onPressed: aoTentar,
        icon: const Icon(Icons.refresh),
        label: const Text('Tentar de novo'),
      ),
    );
  }
}

class Carregando extends StatelessWidget {
  const Carregando({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: SizedBox.square(
          dimension: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      );
}

/// Marca de prioridade, em texto na cor da prioridade.
class PrioridadeTexto extends StatelessWidget {
  const PrioridadeTexto(this.prioridade, {super.key});

  final Prioridade prioridade;

  @override
  Widget build(BuildContext context) {
    return Text(
      'Prioridade ${prioridade.label.toLowerCase()}',
      style: Estilos.corpo(
        tamanho: 14,
        peso: FontWeight.w600,
        cor: Cores.prioridade(prioridade),
      ),
    );
  }
}

/// Prioridade como chip com ponto, como nas listas de referência.
class Etiqueta extends StatelessWidget {
  const Etiqueta(this.texto, {super.key, required this.cor});

  final String texto;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: .14),
        border: Border.all(color: cor.withValues(alpha: .55)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            texto.toUpperCase(),
            style: Estilos.corpo(tamanho: 12, cor: cor, peso: FontWeight.w800)
                .copyWith(height: 1.2),
          ),
          const SizedBox(width: 6),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: cor, borderRadius: BorderRadius.circular(2)),
          ),
        ],
      ),
    );
  }
}

/// Iniciais da pessoa num quadrado com borda.
class Iniciais extends StatelessWidget {
  const Iniciais(this.texto, {super.key, this.tamanho = 40});

  final String texto;
  final double tamanho;

  @override
  Widget build(BuildContext context) => Container(
        width: tamanho,
        height: tamanho,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Cores.painelAlto,
          borderRadius: BorderRadius.circular(raioFolha),
          border:
              Border.all(color: Cores.brasa.withValues(alpha: .7), width: 1.5),
        ),
        child: Text(
          texto,
          style: Estilos.titulo(tamanho: tamanho * .42, cor: Cores.brasa),
        ),
      );
}
