package com.alves.capsula.repository;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

import com.alves.capsula.entity.Chamado;
import com.alves.capsula.entity.EstatusChamado;

public interface ChamadoRepository
    extends JpaRepository <Chamado, Long>{
        List<Chamado> findByEstatusChamado(EstatusChamado estatusChamado);
    }