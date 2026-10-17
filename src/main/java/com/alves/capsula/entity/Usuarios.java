package com.alves.capsula.entity;

import jakarta.persistence.*;

@Entity
public class Usuarios {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String nome;
    private String email;
    private String hashSenha;
    
    @Enumerated(EnumType.STRING)
    private Perfil perfil;

    public Usuarios(){
    }

    public Usuarios(Long id, String nome, String email, String hashSenha, Perfil perfil){
        this.id = id;
        this.nome = nome;
        this.email = email;
        this.hashSenha = hashSenha;
        this.perfil = perfil;
    }
    public String getNome(){
        return nome;
    }
    public void setNome(String nome){
        this.nome = nome;
    }
    public String getEmail(){
        return email;
    }
    public void setEmail(String email){
        this.email = email;
    }
    public String hashSenha(){
        return hashSenha;
    }
    public void SethashSenha(String hashSenha){
        this.hashSenha = hashSenha;
    }
    public Perfil getPerfil(){
        return perfil;
    }
    public void setPerfil(Perfil perfil){
        this.perfil = perfil;
    }
}
