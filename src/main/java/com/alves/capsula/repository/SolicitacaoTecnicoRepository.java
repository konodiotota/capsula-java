package com.alves.capsula.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alves.capsula.entity.SolicitacaoTecnico;
import com.alves.capsula.entity.StatusSolicitacaoEnum;

public interface SolicitacaoTecnicoRepository 
    extends JpaRepository<SolicitacaoTecnico,Long>{
        
    }
