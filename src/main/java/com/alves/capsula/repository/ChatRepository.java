package com.alves.capsula.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.alves.capsula.entity.Chat;

public interface ChatRepository extends JpaRepository<Chat, Long> {
    Optional<Chat> findByChamado_Id(Long chamadoId);

    @Query("""
            select chat
            from Chat chat
            where chat.chamado.solicitante.id = :usuarioId
               or chat.tecnicoResponsavel.id = :usuarioId
            order by chat.criadoEm desc
            """)
    List<Chat> findChatsDoUsuario(@Param("usuarioId") Long usuarioId);
}
