package com.alves.capsula.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

import com.alves.capsula.entity.Chat;
import com.alves.capsula.entity.Mensagem;

public interface MensagemRepository extends JpaRepository<Mensagem, Long>{
    Optional<Chat> findByChat_IdOrderByCriadoEmAsc(Long chatId);
}
