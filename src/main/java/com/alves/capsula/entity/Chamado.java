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
    
    @Column(name="StatusChamado", nullable = false, length = 25)
    @Enumerated(EnumType.STRING)
    private StatusChamadoEnum statusChamado;

    @ManyToOne
    @JoinColumn(name= "usuario_id")
    private Usuario solicitante;

    @ManyToOne
    @JoinColumn(name = "tecnico_id")
    private Usuario tecnico;
    
    @Column(name="Prioridade",nullable = false, length = 25)
    @Enumerated(EnumType.STRING)
    private PrioridadeEnum prioridade;

    @Column(name = "Endereco", nullable = false, length = 250)
    private String endereco;

    @Column(name = "Latitude", nullable = true, length = 40)
    private Double latitude;

    @Column(name="Longitude", nullable = true, length = 40)
    private Double longitude;

    @Column(name = "Criado_em", nullable = true, length = 100)
    private LocalDateTime criadoEm;

    @Column(name = "Iniciado_em", nullable = true, length = 100)
    private LocalDateTime iniciadoEm;

    @Column(name = "Concluido_em", nullable = true, length = 100)
    private LocalDateTime concluidoEm;
}
