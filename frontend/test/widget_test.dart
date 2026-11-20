import 'package:capsula_frontend/domain/capsula_gateway.dart';
import 'package:capsula_frontend/domain/models.dart';
import 'package:capsula_frontend/domain/regras.dart';
import 'package:capsula_frontend/main.dart';
import 'package:capsula_frontend/theme/capsula_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'fontes_de_teste.dart';
import 'gateway_de_teste.dart';

const _cliente = Usuario(
  id: 7,
  nome: 'Pessoa de Teste',
  email: 'teste@exemplo.com',
  perfil: Perfil.cliente,
);

Future<void> _abrir(WidgetTester t, CapsulaGateway g,
    {Size tela = const Size(1280, 800)}) async {
  t.view.physicalSize = tela;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  // O fundo do login é animado em laço; sem isso o pumpAndSettle não termina.
  t.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
  await t.pumpWidget(CapsulaApp(gateway: g));
  await t.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(carregarFontesDoApp);

  group('regras do backend', () {
    test('senha de cadastro segue UsuarioService', () {
      expect(Validadores.senhaDeCadastro('curta!'), isNotNull);
      expect(Validadores.senhaDeCadastro('semespecial1'), isNotNull);
      expect(Validadores.senhaDeCadastro('com espaco!1'), isNotNull);
      expect(Validadores.senhaDeCadastro('senha@forte1'), isNull);
    });

    test('fluxo de ações por perfil e status', () {
      const tecnico = Usuario(id: 9, nome: 'T', perfil: Perfil.tecnico);
      Chamado c(StatusChamado s, {Usuario? tec}) => Chamado(
            id: 1,
            descricao: 'd',
            endereco: 'e',
            status: s,
            prioridade: Prioridade.baixa,
            solicitante: _cliente,
            tecnico: tec,
          );

      expect(Permissoes.avancar(c(StatusChamado.pendente), _cliente), isNull);
      expect(Permissoes.avancar(c(StatusChamado.pendente), tecnico),
          AcaoChamado.aceitar);
      expect(Permissoes.avancar(c(StatusChamado.aceito, tec: tecnico), tecnico),
          AcaoChamado.iniciarDeslocamento);
      expect(
          Permissoes.avancar(
              c(StatusChamado.aceito,
                  tec: const Usuario(
                      id: 1, nome: 'Outro', perfil: Perfil.tecnico)),
              tecnico),
          isNull);
      expect(Permissoes.cancelar(c(StatusChamado.pendente), _cliente), isTrue);
      expect(
          Permissoes.cancelar(c(StatusChamado.aceito, tec: tecnico), _cliente),
          isFalse);
      expect(
          Permissoes.conversar(c(StatusChamado.pendente), _cliente), isFalse);
      expect(
          Permissoes.conversar(c(StatusChamado.aceito, tec: tecnico), _cliente),
          isTrue);
    });
  });

  group('entrada', () {
    testWidgets('sem API publicada mostra o motivo e não entra', (t) async {
      await _abrir(t, const SemApiCapsulaGateway());
      await t.enterText(
          find.widgetWithText(TextFormField, 'E-mail'), 'a@b.com');
      await t.enterText(
          find.widgetWithText(TextFormField, 'Senha'), 'qualquer');
      await t.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await t.pumpAndSettle();
      expect(find.textContaining('ainda não publica'), findsOneWidget);
      expect(find.text('Chamados'), findsNothing);
    });

    testWidgets('cadastro valida a senha antes de enviar', (t) async {
      final g = GatewayDeTeste(usuario: _cliente);
      await _abrir(t, g);
      await t.tap(find.text('Não tenho conta. Criar conta'));
      await t.pumpAndSettle();
      await t.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Pessoa');
      await t.enterText(
          find.widgetWithText(TextFormField, 'E-mail'), 'a@b.com');
      await t.enterText(
          find.widgetWithText(TextFormField, 'Senha'), 'semespecial1');
      await t.tap(find.widgetWithText(FilledButton, 'Criar conta'));
      await t.pumpAndSettle();
      expect(find.textContaining('caractere especial'), findsWidgets);
      expect(g.chamadas, isEmpty);
    });
  });

  group('cliente', () {
    testWidgets('lista, detalha e cancela um chamado pendente (largo)',
        (t) async {
      final g = GatewayDeTeste(usuario: _cliente);
      await _abrir(t, g);
      await t.enterText(
          find.widgetWithText(TextFormField, 'E-mail'), 'a@b.com');
      await t.enterText(find.widgetWithText(TextFormField, 'Senha'), 'x');
      await t.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await t.pumpAndSettle();

      expect(find.text('Texto de teste 1'), findsOneWidget);
      // Cliente não vê a fila de atendimento.
      expect(find.text('Disponíveis'), findsNothing);
      // A faixa de totais conta a lista carregada.
      expect(find.textContaining('Pendentes'), findsOneWidget);

      await t.tap(find.text('Texto de teste 1'));
      await t.pumpAndSettle();
      expect(find.text('Trajeto'), findsOneWidget);
      expect(find.text('Cancelar chamado'), findsOneWidget);
      expect(find.text('Aceitar chamado'), findsNothing);

      await t.tap(find.text('Cancelar chamado'));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(FilledButton, 'Cancelar chamado'));
      await t.pumpAndSettle();
      expect(g.chamadas, contains('cancelar'));
      expect(find.text('Chamado cancelado.'), findsOneWidget);
    });

    testWidgets('abre chamado e ele aparece na lista (estreito)', (t) async {
      final g = GatewayDeTeste(usuario: _cliente);
      await _abrir(t, g, tela: const Size(390, 800));
      await t.enterText(
          find.widgetWithText(TextFormField, 'E-mail'), 'a@b.com');
      await t.enterText(find.widgetWithText(TextFormField, 'Senha'), 'x');
      await t.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await t.pumpAndSettle();

      // No celular o botão é flutuante.
      await t.tap(find.widgetWithText(FloatingActionButton, 'Abrir chamado'));
      await t.pumpAndSettle();
      await t.tap(find.widgetWithText(FilledButton, 'Abrir chamado'));
      await t.pumpAndSettle();
      expect(find.text('Informe o endereço do atendimento.'), findsOneWidget);

      await t.enterText(
          find.widgetWithText(TextFormField, 'Descrição'), 'Novo texto');
      await t.enterText(
          find.widgetWithText(TextFormField, 'Endereço do atendimento'),
          'Novo endereço');
      await t.tap(find.widgetWithText(FilledButton, 'Abrir chamado'));
      await t.pumpAndSettle();
      expect(g.chamadas, contains('criar'));
      expect(find.text('Novo texto'), findsOneWidget);
    });
  });

  group('técnico', () {
    testWidgets('vê a fila e aceita um chamado', (t) async {
      const tecnico =
          Usuario(id: 9, nome: 'Técnico de Teste', perfil: Perfil.tecnico);
      final g = GatewayDeTeste(usuario: tecnico);
      await _abrir(t, g);
      await t.enterText(
          find.widgetWithText(TextFormField, 'E-mail'), 'a@b.com');
      await t.enterText(find.widgetWithText(TextFormField, 'Senha'), 'x');
      await t.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await t.pumpAndSettle();

      // A fila é um destino da barra lateral, com o total de pendentes.
      await t.tap(find.text('Disponíveis'));
      await t.pumpAndSettle();
      await t.tap(find.text('Texto de teste 1'));
      await t.pumpAndSettle();
      await t.tap(find.text('Aceitar chamado'));
      await t.pumpAndSettle();
      expect(find.text('Iniciar deslocamento'), findsOneWidget);
    });
  });

  group('tema', () {
    testWidgets('alterna entre preto e branco no login e na conta', (t) async {
      final g = GatewayDeTeste(usuario: _cliente);
      await _abrir(t, g);

      expect(Cores.escura, isTrue);
      await t.tap(find.byTooltip('Usar tema branco'));
      await t.pumpAndSettle();
      expect(Cores.escura, isFalse);
      expect(find.byTooltip('Usar tema preto'), findsOneWidget);

      // O estado digitado sobrevive à troca.
      await t.enterText(
          find.widgetWithText(TextFormField, 'E-mail'), 'a@b.com');
      await t.tap(find.byTooltip('Usar tema preto'));
      await t.pumpAndSettle();
      expect(Cores.escura, isTrue);
      expect(find.text('a@b.com'), findsOneWidget);
    });
  });
}
