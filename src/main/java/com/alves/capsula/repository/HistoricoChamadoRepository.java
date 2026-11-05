package com.alves.capsula.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alves.capsula.entity.HistoricoChamado;
import com.alves.capsula.entity.StatusChamadoEnum;

public interface HistoricoChamadoRepository
    extends JpaRepository<HistoricoChamado, Long>{
        List<HistoricoChamado> findByChamado_id(
            Long chamado_id
        );
        List<HistoricoChamado> findByStatusNovo(
            StatusChamadoEnum statusNovo
        );
        List<HistoricoChamado> findByChamado_Solicitante_Id(Long usuarioId);
        List<HistoricoChamado> findByChamado_Solicitante_IdAndChamado_Id(
            Long usuarioId, Long chamadoId
        );
    }