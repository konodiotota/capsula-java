package com.alves.capsula.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alves.capsula.entity.HistoricoChamado;

public interface HistoricoChamadoRepository
    extends JpaRepository<HistoricoChamado, Long>{
        List<HistoricoChamado> findByChamado_id(
            Long chamado_id
        );
    }