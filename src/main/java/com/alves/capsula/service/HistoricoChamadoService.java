package com.alves.capsula.service;

import java.util.List;

import org.springframework.stereotype.Service;

import com.alves.capsula.entity.HistoricoChamado;
import com.alves.capsula.repository.HistoricoChamadoRepository;

@Service
public class HistoricoChamadoService {
    private final HistoricoChamadoRepository historicoChamadoRepository;

    public HistoricoChamadoService(HistoricoChamadoRepository historicoChamadoRepository){
        this.historicoChamadoRepository = historicoChamadoRepository;
    }
    public List<HistoricoChamado> ListarChamadosPorIdUsuario() {
        
    }
}
