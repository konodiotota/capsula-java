
package com.alves.capsula.model.dto;

import com.alves.capsula.entity.enums.StatusChamadoEnum;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@Setter
@Getter
public class HistoricoChamadoDTO {

    @NotNull(message = "Necessario o status anterior")
    private StatusChamadoEnum statusAnterior;

    @NotNull(message = "Necessario o status novo")
    private StatusChamadoEnum statusNovo;

    @Size(max = 250, message = "Quantidade maxima de 250 caracteres")
    private String observacoes;

}
