package com.alves.capsula.model.dto;

import com.alves.capsula.entity.enums.StatusChamadoEnum;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter 
@Setter
@NoArgsConstructor
public class ChamadoDTO {
    @Size(max = 250, message = "Descrição deve ter no maximo 250 caracteres")
    private String descricao;

    @NotNull(message = "Necessario ter o status do chamado")
    private StatusChamadoEnum statusChamado;

    @NotNull(message = "Necessario ter o endereco do chamado")
    @Size(max=250, message = "Maximo de caracteres 250")
    private String endereco;

}
