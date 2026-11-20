/// Regras de negócio do backend aplicadas no cliente para orientar o usuário
/// antes do envio. O servidor continua sendo a fonte da verdade.
library;

import 'models.dart';

abstract final class Limites {
  static const nome = 250;
  static const senhaMin = 8;
  static const senhaMax = 50;
  static const descricao = 250;
  static const endereco = 250;
  static const mensagem = 5000;
}

abstract final class Validadores {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? nome(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Informe seu nome.';
    if (t.length > Limites.nome) {
      return 'O nome pode ter até ${Limites.nome} caracteres.';
    }
    return null;
  }

  static String? email(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Informe seu e-mail.';
    if (!_email.hasMatch(t)) return 'Informe um e-mail válido.';
    return null;
  }

  /// Entrar: só exige que haja senha. As regras de formato valem no cadastro.
  static String? senhaDeEntrada(String? v) =>
      (v == null || v.isEmpty) ? 'Informe sua senha.' : null;

  /// Cadastro: de 8 a 50 caracteres, com ao menos um caractere especial e
  /// sem espaços (`UsuarioService.cadastrarUsuario`).
  static String? senhaDeCadastro(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'Crie uma senha.';
    if (s.length < Limites.senhaMin || s.length > Limites.senhaMax) {
      return 'Use de ${Limites.senhaMin} a ${Limites.senhaMax} caracteres.';
    }
    if (s.contains(' ')) return 'A senha não pode ter espaços.';
    if (!RegExp(r'[^a-zA-Z0-9]').hasMatch(s)) {
      return 'Inclua ao menos um caractere especial, como ! ou @.';
    }
    return null;
  }

  static String? descricao(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Descreva o que precisa ser atendido.';
    if (t.length > Limites.descricao) {
      return 'A descrição pode ter até ${Limites.descricao} caracteres.';
    }
    return null;
  }

  static String? endereco(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return 'Informe o endereço do atendimento.';
    if (t.length > Limites.endereco) {
      return 'O endereço pode ter até ${Limites.endereco} caracteres.';
    }
    return null;
  }
}

enum AcaoChamado {
  aceitar('Aceitar chamado'),
  iniciarDeslocamento('Iniciar deslocamento'),
  iniciarAtendimento('Iniciar atendimento'),
  finalizar('Finalizar atendimento'),
  cancelar('Cancelar chamado');

  const AcaoChamado(this.rotulo);
  final String rotulo;

  /// Tempo verbal usado na confirmação depois que a ação é concluída.
  String get concluida => switch (this) {
        aceitar => 'Chamado aceito.',
        iniciarDeslocamento => 'Deslocamento iniciado.',
        iniciarAtendimento => 'Atendimento iniciado.',
        finalizar => 'Atendimento finalizado.',
        cancelar => 'Chamado cancelado.',
      };
}

/// O que o [usuario] pode fazer em [chamado], segundo `ChamadoService`.
abstract final class Permissoes {
  /// Ação que faz o chamado avançar no trajeto.
  static AcaoChamado? avancar(Chamado chamado, Usuario usuario) {
    if (!usuario.perfil.atende) return null;
    if (chamado.status == StatusChamado.pendente) return AcaoChamado.aceitar;
    if (chamado.tecnico?.id != usuario.id) return null;
    return switch (chamado.status) {
      StatusChamado.aceito => AcaoChamado.iniciarDeslocamento,
      StatusChamado.aCaminho => AcaoChamado.iniciarAtendimento,
      StatusChamado.atendimento => AcaoChamado.finalizar,
      _ => null,
    };
  }

  /// Só o dono cancela, e só enquanto o chamado está pendente.
  static bool cancelar(Chamado chamado, Usuario usuario) =>
      chamado.status == StatusChamado.pendente &&
      chamado.solicitante.id == usuario.id;

  /// A conversa existe quando há técnico responsável e o usuário é
  /// solicitante ou esse técnico.
  static bool conversar(Chamado chamado, Usuario usuario) {
    final tecnico = chamado.tecnico;
    if (tecnico == null) return false;
    return chamado.solicitante.id == usuario.id || tecnico.id == usuario.id;
  }
}
