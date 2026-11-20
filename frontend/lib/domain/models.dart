/// Modelos do cliente, espelhando entidades e DTOs do backend Java.
///
/// Os nomes das constantes em [apiName] são exatamente os valores dos enums
/// Java (`PerfilEnum`, `StatusChamadoEnum`, `PrioridadeEnum`).
library;

enum Perfil {
  cliente('CLIENTE', 'Cliente'),
  tecnico('TECNICO', 'Técnico'),
  administrador('ADMINISTRADOR', 'Administrador');

  const Perfil(this.apiName, this.label);
  final String apiName;
  final String label;

  static Perfil fromApi(String value) =>
      values.firstWhere((e) => e.apiName == value);

  /// Técnicos e administradores veem e aceitam chamados pendentes.
  bool get atende => this != Perfil.cliente;
}

enum StatusChamado {
  pendente('PENDENTE', 'Pendente'),
  aceito('ACEITO', 'Aceito'),
  aCaminho('ACAMINHO', 'A caminho'),
  atendimento('ATENDIMENTO', 'Em atendimento'),
  finalizado('FINALIZADO', 'Finalizado'),
  cancelado('CANCELADO', 'Cancelado');

  const StatusChamado(this.apiName, this.label);
  final String apiName;
  final String label;

  static StatusChamado fromApi(String value) =>
      values.firstWhere((e) => e.apiName == value);

  /// Estações do trajeto, na ordem em que o backend permite avançar.
  static const trajeto = [pendente, aceito, aCaminho, atendimento, finalizado];

  /// Posição no trajeto; `-1` para [cancelado], que sai do trajeto.
  int get etapa => trajeto.indexOf(this);

  bool get encerrado => this == finalizado || this == cancelado;
}

enum Prioridade {
  urgente('URGENTE', 'Urgente'),
  alta('ALTA', 'Alta'),
  media('MEDIA', 'Média'),
  baixa('BAIXA', 'Baixa');

  const Prioridade(this.apiName, this.label);
  final String apiName;
  final String label;

  static Prioridade fromApi(String value) =>
      values.firstWhere((e) => e.apiName == value);
}

class Usuario {
  const Usuario({
    required this.id,
    required this.nome,
    required this.perfil,
    this.email,
  });

  final int id;
  final String nome;
  final String? email;
  final Perfil perfil;
}

/// Entidade `Chamado`. O backend ainda não define um DTO de resposta; os
/// campos seguem a entidade.
class Chamado {
  const Chamado({
    required this.id,
    required this.descricao,
    required this.endereco,
    required this.status,
    required this.prioridade,
    required this.solicitante,
    this.tecnico,
    this.latitude,
    this.longitude,
    this.criadoEm,
    this.concluidoEm,
  });

  final int id;
  final String descricao;
  final String endereco;
  final StatusChamado status;
  final Prioridade prioridade;
  final Usuario solicitante;
  final Usuario? tecnico;
  final double? latitude;
  final double? longitude;
  final DateTime? criadoEm;
  final DateTime? concluidoEm;

  bool get temCoordenadas => latitude != null && longitude != null;
}

/// `HistoricoChamadoResponseDTO`.
class HistoricoChamado {
  const HistoricoChamado({
    required this.id,
    required this.chamadoId,
    required this.usuarioNome,
    required this.statusAnterior,
    required this.statusNovo,
    required this.criadoEm,
    this.observacoes,
  });

  final int id;
  final int chamadoId;
  final String usuarioNome;
  final StatusChamado statusAnterior;
  final StatusChamado statusNovo;
  final String? observacoes;
  final DateTime criadoEm;
}

/// `ChatResponseDTO`.
class Chat {
  const Chat({
    required this.id,
    required this.chamadoId,
    required this.tecnicoResponsavelId,
    required this.nomeTecnicoResponsavel,
    required this.criadoEm,
  });

  final int id;
  final int chamadoId;
  final int tecnicoResponsavelId;
  final String nomeTecnicoResponsavel;
  final DateTime criadoEm;
}

/// `MensagemResponseDTO`.
class Mensagem {
  const Mensagem({
    required this.id,
    required this.remetenteNome,
    required this.destinatarioNome,
    required this.conteudo,
    required this.criadoEm,
  });

  final int id;
  final String remetenteNome;
  final String destinatarioNome;
  final String conteudo;
  final DateTime criadoEm;
}

/// `ChamadoRequestDTO`.
class NovoChamado {
  const NovoChamado({required this.descricao, required this.endereco});
  final String descricao;
  final String endereco;
}

/// `UsuarioCadastroRequestDTO`.
class NovoUsuario {
  const NovoUsuario({
    required this.nome,
    required this.email,
    required this.senha,
  });
  final String nome;
  final String email;
  final String senha;
}

class Credenciais {
  const Credenciais({required this.email, required this.senha});
  final String email;
  final String senha;
}
