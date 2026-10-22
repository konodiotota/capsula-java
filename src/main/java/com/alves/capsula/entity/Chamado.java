package com.alves.capsula.entity;
import java.time.LocalDateTime;

import lombok.*;
import jakarta.persistence.*;

@Table(name= "Chamado")
@Getter
@Setter
@NoArgsConstructor
@Entity 

public class Chamado {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) 
    private Long id;

    @Column(name = "Descricao", nullable = false, length = 250)
    private String descricao;
    
    @Column(name="EstatusChamado", nullable = false, length = 25)
    @Enumerated(EnumType.STRING)
    private EstatusChamado estatusChamado;

    @Column(name= "Solicitante", nullable = false, length = 250)
    @ManyToOne
    @JoinColumn(name= "usuario_id")
    private Usuario solicitante;

    @Column(name="NomeTecnico", nullable = false, length= 250)
    @ManyToOne
    @JoinColumn(name = "tecnico_id")
    private Usuario tecnico;
    
    @Column(name="Prioridade",nullable = false, length = 25)
    @Enumerated(EnumType.STRING)
    private Prioridade prioridade;

    @Column(name = "Endereco", nullable = false, length = 350)
    private String endereco;

    @Column(name = "Latitude", nullable = false, length = 40)
    private double latitude;

    @Column(name="Longitude", nullable = false, length = 40)
    private double longitude;

    @Column(name = "Criado_em", nullable = false, length = 100)
    private LocalDateTime criado_em;

    @Column(name = "Iniciado_em", nullable = false, length = 100)
    private LocalDateTime iniciado_em;

    @Column(name = "Concluido_em", nullable = false, length = 100)
    private LocalDateTime concluido_em;
}
