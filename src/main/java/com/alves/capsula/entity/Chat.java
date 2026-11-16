package com.alves.capsula.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GenerationType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter 
@Setter
@NoArgsConstructor
public class Chat {
    //representa a conversa relacionado a um chamado
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long Id;

    @OneToOne
    @JoinColumn(name="chamado_id", nullable = false, unique = true)
    private Chamado chamado;

    @OneToOne
    @JoinColumn(name = "tecnico_id", nullable = false)
    private Usuario tecnicoResponsavel;

    @Column(nullable = false)
    private LocalDateTime criadoEm;
}
