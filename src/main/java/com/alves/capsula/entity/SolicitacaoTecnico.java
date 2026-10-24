package com.alves.capsula.entity;

import java.time.LocalDateTime;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor 
@Entity
@Table(name = "solicitacao_tecnico")
public class SolicitacaoTecnico {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional= false)
    @JoinColumn(name="usuario_id", nullable=false)
    private Usuario usuario;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private StatusChamadoEnum estatus;

    @Column(name="data_solicitacao", nullable = false)
    private LocalDateTime dataSolitacao;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="administrador_id", nullable = false)
    private Usuario administradorResponsavel;

    @ManyToOne (fetch = FetchType.LAZY)
    @JoinColumn(name = "administrador_nome", nullable = false)
    private Usuario nomeAdministradorResponsavel;

    @Column(name="data_decisao", nullable = false)
    private LocalDateTime data_decisao;

}
