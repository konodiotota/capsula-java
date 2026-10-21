package com.alves.capsula.entity;

import java.time.LocalDateTime;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@Table(name="HistoricoChamado")
public class HistoricoChamado {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne  //dentro da tabela HistoricoChamado criaria uma coluna chamado_id que esta relacionado//
    @JoinColumn(name="chamado_id") //com a talela Chamado, podendo ser acessado usando a variavel chamado//
    private Chamado chamado;

    @ManyToOne
    @JoinColumn(name="usuario_id")
    private Usuario usuario;
    
    @Column(name = "EstatusChamado", nullable = false, length = 25)
    @Enumerated(EnumType.STRING)
    private EstatusChamado estatusChamado;

    @Column(name = "EstatusAnterior", nullable = false, length = 25)
    @Enumerated(EnumType.STRING)
    private EstatusChamado estatusAnterior;
    
    @Column(name = "EstatusNovo", nullable = false, length = 25)
    @Enumerated(EnumType.STRING)
    private EstatusChamado estatusNovo;

    @Column(name="Observacoes", nullable = true, length = 250)
    private String observacoes;

    @Column(name = "Criado_em", nullable = false, length = 50)
    private LocalDateTime criado_em;

}
