package com.alves.capsula.service;
import org.springframework.stereotype.Service;

import com.alves.capsula.entity.Chat;
import com.alves.capsula.repository.ChamadoRepository;
import com.alves.capsula.repository.ChatRepository;

@Service 
public class ChatService {
    //criar chat,  buscar chat pelo id, buscar chat pelo chamado, listar meus chats, validar acesso chat
    private final ChatRepository chatRepository;
    private final ChamadoRepository chamadoRepository;

    public ChatService(ChatRepository chatRepository, ChamadoRepository chamadoRepository){
        this.chatRepository = chatRepository;
        this.chamadoRepository = chamadoRepository;
    }

    public Chat criarChat()
}
