
package com.alves.capsula.model.dto;

import java.time.LocalDateTime;

import com.alves.capsula.entity.enums.StatusChamadoEnum;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@Setter
@Getter
public class HistoricoChamadoResponseDTO {
    private Long id;
    private Long chamadoId;
    private String usuarioNome;
    private StatusChamadoEnum statusAnterior;
    private StatusChamadoEnum statusNovo;
    private String observacoes;
    private LocalDateTime criadoEm;
}
