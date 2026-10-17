package com.alves.capsula.entity;
import java.time.LocalDateTime;

import jakarta.persistence.*;

@Entity 
public class Chamados {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String descricao;

    @Enumerated(EnumType.STRING)
    private EstatusChamado estatusChamado;

    @ManyToOne
    @JoinColumn(name= "usuario_id")
    private Usuarios solicitante;

    @ManyToOne
    @JoinColumn(name = "tecnico_id")
    private Usuarios tecnico;
    
    @Enumerated(EnumType.STRING)
    private Prioridade prioridade;

    private String endereco;
    private double latitude;
    private double longitude;
    private LocalDateTime criado_em;
    private LocalDateTime iniciado_em;
    private LocalDateTime concluido_em;

    public Chamados(){
    }
    public Chamados(Long id, String descricao, EstatusChamado estatusChamado, Usuarios solicitante, Usuarios tecnico, Prioridade prioridade, String endereco, double latitude, double longitude, LocalDateTime criado_em, LocalDateTime iniciado_em, LocalDateTime concluido_em){
        this.id = id;
        this.descricao = descricao;
        this.estatusChamado = estatusChamado;
        this.solicitante = solicitante;
        this.tecnico = tecnico;
        this.prioridade = prioridade;
        this.endereco = endereco;
        this.latitude = latitude;
        this.longitude = longitude;
        this.criado_em = criado_em;
        this.iniciado_em = iniciado_em;
        this.concluido_em = concluido_em;
    }
    public String getDescricao(){
        return descricao;
    }
    public void setDescricao(String descricao){
        this.descricao = descricao;
    }
    public EstatusChamado getEstatusChamado(){
        return estatusChamado;
    }
    public void setEstatusChamado(EstatusChamado estatusChamado){
        this.estatusChamado = estatusChamado;
    }
    public Usuarios solicitante(){
        return solicitante;
    }
    public void setSolicitante(Usuarios solicitante){
        this.solicitante = solicitante;
    }
    public Usuarios getTecnico(){
        return tecnico;
    }
    public void setTecnico(Usuarios tecnico){
        this.tecnico = tecnico;
    }
    public String endereco(){
        return endereco;
    }
    public void setEndereco(String endereco){
        this.endereco = endereco;
    }
        public double getlatitude(){
        return latitude;
    }
    public void setLatitude(double latitude){
        this.latitude = latitude;
    }
        public double getLongitude(){
        return longitude;
    }
    public void setlongitude(double longitude){
        this.longitude = longitude;
    }
    public LocalDateTime getcriado_em(){
        return criado_em;
    }
    public void setCriado_em(LocalDateTime criado_em){
        this.criado_em = criado_em;
    }
    public LocalDateTime getIniciado_em(){
        return iniciado_em;
    }
    public void setIniciado_em(LocalDateTime iniciado_em){
        this.iniciado_em = iniciado_em;
    }
    public LocalDateTime getConcluido_em(){
        return concluido_em;
    }
    public void setConcluido_em(LocalDateTime concluido_em){
        this.concluido_em = concluido_em;
    }
}
