package com.alves.capsula.entity;

import java.time.LocalDateTime;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
public class HistoricoChamado {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne  //dentro da tabela HistoricoChamado criaria uma coluna chamado_id que esta relacionado//
    @JoinColumn(name="chamado_id") //com a talela Chamado, podendo ser acessado usando a variavel chamado//
    private Chamados chamado;

    @ManyToOne
    @JoinColumn(name="usuario_id")
    private Usuarios usuario;

    @Enumerated(EnumType.STRING)
    private EstatusChamado estatusChamado;

    @Enumerated(EnumType.STRING)
    private EstatusChamado estatusAnteror;
    
    @Enumerated(EnumType.STRING)
    private EstatusChamado estatusNovo;

    private String observadoes;
    private LocalDateTime criado_em;

}
