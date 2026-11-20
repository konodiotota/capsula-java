import 'package:material_ui/material_ui.dart';

import '../../app/sessao.dart';
import '../../domain/models.dart';
import '../../domain/regras.dart';
import '../../shared/widgets/botao_tema.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/fundo_animado.dart';
import '../../shared/widgets/marca.dart';
import '../../shared/widgets/painel.dart';
import '../../theme/capsula_theme.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _cadastro = false;
  bool _enviando = false;
  bool _verSenha = false;
  String? _erro;

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  void _alternar() => setState(() {
        _cadastro = !_cadastro;
        _erro = null;
        _form.currentState?.reset();
      });

  Future<void> _enviar() async {
    if (!_form.currentState!.validate()) return;
    final sessao = SessaoScope.of(context);
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      if (_cadastro) {
        await sessao.cadastrar(NovoUsuario(
          nome: _nome.text.trim(),
          email: _email.text.trim(),
          senha: _senha.text,
        ));
      } else {
        await sessao.entrar(
          Credenciais(email: _email.text.trim(), senha: _senha.text),
        );
      }
    } catch (e) {
      if (mounted) setState(() => _erro = mensagemDeErro(e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final largo = MediaQuery.sizeOf(context).width >= 960;
    final formulario = Janela(
      child: _Formulario(
        form: _form,
        nome: _nome,
        email: _email,
        senha: _senha,
        cadastro: _cadastro,
        enviando: _enviando,
        verSenha: _verSenha,
        erro: _erro,
        aoVerSenha: () => setState(() => _verSenha = !_verSenha),
        aoEnviar: _enviar,
        aoAlternar: _alternar,
      ),
    );

    final conteudo = largo
        ? Row(
            children: [
              const Expanded(flex: 6, child: _Apresentacao()),
              Expanded(
                flex: 5,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(48),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: formulario,
                    ),
                  ),
                ),
              ),
            ],
          )
        : SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                24,
                20,
                28 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Marca(),
                      const SizedBox(height: 28),
                      Text(
                        'Central de chamados',
                        style: Estilos.tituloExtrudado(tamanho: 40),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Abra um chamado e acompanhe cada etapa até o atendimento.',
                        style: Estilos.corpo(tamanho: 15, cor: Cores.creme),
                      ),
                      const SizedBox(height: 28),
                      formulario,
                    ],
                  ),
                ),
              ),
            ),
          );

    return Scaffold(
      body: FundoAnimado(
        child: Stack(
          children: [
            Positioned.fill(child: conteudo),
            const Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: BotaoTema(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lado esquerdo: o nome da central em pixel, a promessa e a ilustração.
class _Apresentacao extends StatelessWidget {
  const _Apresentacao();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, caixa) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(64, 48, 40, 48),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: caixa.maxHeight - 96),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Marca(),
              const SizedBox(height: 44),
              Text(
                'Central de\nchamados',
                style: Estilos.tituloExtrudado(tamanho: 68),
              ),
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Text(
                  'Abra um chamado e acompanhe cada etapa até o atendimento.',
                  style: Estilos.corpo(tamanho: 18, cor: Cores.creme),
                ),
              ),
              const SizedBox(height: 40),
              const _Ilustracao(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ilustração em blocos: um monitor com duas janelas de chamado.
class _Ilustracao extends StatelessWidget {
  const _Ilustracao();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: const Size(336, 216),
        painter: _IlustracaoPainter(),
      ),
    );
  }
}

class _IlustracaoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final u = size.width / 56;
    void bloco(double x, double y, double w, double h, Color cor) =>
        canvas.drawRect(
            Rect.fromLTWH(x * u, y * u, w * u, h * u), Paint()..color = cor);

    const aco = Color(0xFF3B3B42);
    const tela = Color(0xFF1B1B1F);
    const cinza = Color(0xFF6A6A72);
    const papel = Color(0xFFF2E2C0);

    // Monitor.
    bloco(12, 2, 36, 26, aco);
    bloco(13, 3, 34, 24, tela);
    bloco(26, 28, 8, 3, aco);
    bloco(21, 31, 18, 2, aco);
    // Gráfico de barras na tela.
    bloco(16, 17, 3, 7, Cores.brasa);
    bloco(20, 13, 3, 11, Cores.brasa);
    bloco(24, 9, 3, 15, Cores.brasa);
    bloco(16, 24, 11, 1, cinza);
    // Janela de chamado sobre o monitor.
    bloco(30, 6, 16, 12, papel);
    bloco(30, 6, 16, 2.5, Cores.brasa);
    bloco(32, 10, 9, 1, cinza);
    bloco(32, 12.5, 12, 1, cinza);
    bloco(32, 15, 5, 1.8, Cores.brasa);
    // Janela de chamado em primeiro plano.
    bloco(2, 22, 20, 13, papel);
    bloco(2, 22, 20, 2.5, Cores.brasa);
    bloco(4, 26, 12, 1, cinza);
    bloco(4, 28.5, 15, 1, cinza);
    bloco(15, 31, 5, 2, Cores.visto);
    // Balões de mensagem.
    bloco(44, 0, 8, 5, Cores.brasa);
    bloco(46, 5, 2, 1, Cores.brasa);
    bloco(45.5, 1.8, 1.4, 1.4, tela);
    bloco(47.6, 1.8, 1.4, 1.4, tela);
    bloco(49.7, 1.8, 1.4, 1.4, tela);
    bloco(50, 6.5, 6, 4, Cores.visto);
    bloco(52, 10.5, 2, 1, Cores.visto);
  }

  @override
  bool shouldRepaint(_IlustracaoPainter o) => true;
}

class _Formulario extends StatelessWidget {
  const _Formulario({
    required this.form,
    required this.nome,
    required this.email,
    required this.senha,
    required this.cadastro,
    required this.enviando,
    required this.verSenha,
    required this.erro,
    required this.aoVerSenha,
    required this.aoEnviar,
    required this.aoAlternar,
  });

  final GlobalKey<FormState> form;
  final TextEditingController nome;
  final TextEditingController email;
  final TextEditingController senha;
  final bool cadastro;
  final bool enviando;
  final bool verSenha;
  final String? erro;
  final VoidCallback aoVerSenha;
  final VoidCallback aoEnviar;
  final VoidCallback aoAlternar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Form(
      key: form,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              cadastro ? 'Criar conta' : 'Bem-vindo de volta',
              style: Estilos.titulo(tamanho: 28, cor: Cores.brasa),
            ),
            const SizedBox(height: 8),
            Text(
              cadastro
                  ? 'Sua conta será de cliente. Você poderá abrir chamados e conversar com o técnico.'
                  : 'Use o e-mail e a senha cadastrados.',
              style: tema.bodyMedium,
            ),
            const SizedBox(height: 24),
            if (cadastro) ...[
              TextFormField(
                controller: nome,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                maxLength: Limites.nome,
                buildCounter: _semContador,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
                validator: Validadores.nome,
              ),
              const SizedBox(height: 16),
            ],
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.mail_outline),
              ),
              validator: Validadores.email,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: senha,
              obscureText: !verSenha,
              textInputAction: TextInputAction.done,
              autofillHints: [
                cadastro ? AutofillHints.newPassword : AutofillHints.password,
              ],
              maxLength: cadastro ? Limites.senhaMax : null,
              buildCounter: _semContador,
              onFieldSubmitted: (_) => enviando ? null : aoEnviar(),
              decoration: InputDecoration(
                labelText: 'Senha',
                prefixIcon: const Icon(Icons.lock_outline),
                helperText: cadastro
                    ? 'De 8 a 50 caracteres, com um caractere especial e sem espaços.'
                    : null,
                helperMaxLines: 2,
                suffixIcon: IconButton(
                  tooltip: verSenha ? 'Ocultar senha' : 'Mostrar senha',
                  onPressed: aoVerSenha,
                  icon: Icon(
                    verSenha
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
              validator: cadastro
                  ? Validadores.senhaDeCadastro
                  : Validadores.senhaDeEntrada,
            ),
            if (erro != null) ...[
              const SizedBox(height: 16),
              Semantics(
                liveRegion: true,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Cores.alerta.withValues(alpha: .1),
                    border: Border(
                      left: BorderSide(color: Cores.alerta, width: 4),
                    ),
                  ),
                  child: Text(
                    erro!,
                    style: tema.bodyMedium?.copyWith(color: Cores.texto),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: enviando ? null : aoEnviar,
              child: enviando
                  ? SizedBox.square(
                      dimension: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Cores.sobreBrasa,
                      ),
                    )
                  : Text(cadastro ? 'Criar conta' : 'Entrar'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: enviando ? null : aoAlternar,
              child: Text(
                cadastro
                    ? 'Já tenho conta. Entrar'
                    : 'Não tenho conta. Criar conta',
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget? _semContador(
    BuildContext context, {
    required int currentLength,
    required bool isFocused,
    required int? maxLength,
  }) =>
      null;
}
