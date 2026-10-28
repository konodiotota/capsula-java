
package com.alves.capsula.service;

import org.springframework.stereotype.Service;
import com.alves.capsula.repository.HistoricoChamadoRepository;


@Service
public class HistoricoChamadoService {

    private final HistoricoChamadoRepository historicoChamadoRepository;

    public HistoricoChamadoService(
            HistoricoChamadoRepository historicoChamadoRepository) {
        this.historicoChamadoRepository = historicoChamadoRepository;
    }
    public List<HistoricoChamado> listarHistorico(){
        return HistoricoChamadoRepository.findBySolicitante_idAndChamadoEstatus(
            Long usuario_id,
            StatusChamadoEnum status
        );
    }
}
