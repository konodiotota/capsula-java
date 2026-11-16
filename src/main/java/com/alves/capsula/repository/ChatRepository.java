package com.alves.capsula.repository;


import com.alves.capsula.entity.Chat;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ChatRepository 
    extends JpaRepository<Chat, Long>{
        Optional<Chat> findByChamado_Id(Long chamadoId);
    }

