package com.model.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;

@Entity
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nome;
    private String email;
    private String hashSenha;
    private String perfil;
    private Long empresaId;
    private boolean ativo = true;

    public Usuario() {
    }

    public Usuario(Long id, String nome, String email, String hashSenha, String perfil, Long empresaId, boolean ativo) {
        this.id = id;
        this.nome = nome;
        this.email = email;
        this.hashSenha = hashSenha;
        this.perfil = perfil;
        this.empresaId = empresaId;
        this.ativo = ativo;
    }
}
