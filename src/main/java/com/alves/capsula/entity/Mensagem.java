package com.alves.capsula.entity;

import java.time.LocalDateTime;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.GenerationType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity 
@Getter 
@Setter 
@NoArgsConstructor 
public class Mensagem {
    //representa as mensagens dentro da conversa
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "chat_id", nullable = false)
    private Chat chat;

    @ManyToOne
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario remetente;

    @ManyToOne
    @JoinColumn(name = "tecnico_id", nullable = false)
    private Usuario destinatario;

    @Column(length = 5000)
    private String conteudo;

    @Column(nullable = false)
    private LocalDateTime criadoEm;
}
