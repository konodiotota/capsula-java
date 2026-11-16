package com.alves.capsula.model.dto;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.Setter;

@Getter 
@Setter 
public class ResponseMensagemDTO {
    private Long id;
    private String remetenteNome;
    private String destinatarioNome;
    private String conteudo;
    private LocalDateTime criadoEm;
}
