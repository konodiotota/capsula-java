package com.alves.capsula.entity;

import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@Table(name = "Usuario")
@Entity
public class Usuario {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "Nome", nullable = false, length = 250)
    private String nome;

    @Column(name = "Email", nullable = true, length = 250)
    private String email;

    @Column(name = "HashSenha", nullable=false, length = 150)
    private String hashSenha;
    
    @Column(name="Perfil", nullable = false, length = 25)
    @Enumerated(EnumType.STRING)
    private Perfil perfil;
}