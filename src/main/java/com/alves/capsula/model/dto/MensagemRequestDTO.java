package com.alves.capsula.model.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

@Getter 
@Setter 
public class MensagemRequestDTO {
    @NotBlank
    @Size(max = 5000)
    private String conteudo;
}
