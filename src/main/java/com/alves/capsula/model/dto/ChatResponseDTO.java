package com.alves.capsula.model.dto;

import java.time.LocalDateTime;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter 
@Setter 
@NoArgsConstructor 
public class ChatResponseDTO {
    private Long id;
    private Long chamadoId;
    private Long tecnicoResponsavelId;
    private String nomeTecnicoResponsavel;
    private LocalDateTime criadoEm;
}
