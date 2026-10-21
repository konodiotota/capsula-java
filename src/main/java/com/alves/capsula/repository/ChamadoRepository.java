package com.alves.capsula.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alves.capsula.entity.Chamado;

public interface ChamadoRepository
    extends JpaRepository <Chamado, Long>{
        
    }