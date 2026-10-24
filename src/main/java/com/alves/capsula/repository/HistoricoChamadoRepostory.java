package com.alves.capsula.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alves.capsula.entity.HistoricoChamado;
import com.alves.capsula.entity.StatusChamadoEnum;

public interface HistoricoChamadoRepostory
    extends JpaRepository<HistoricoChamado, Long>{
        List<HistoricoChamado> findBySolicitante_idAndEstatusChamado(
            Long usuario_id,
            StatusChamadoEnum estatusChamado
        );
    }