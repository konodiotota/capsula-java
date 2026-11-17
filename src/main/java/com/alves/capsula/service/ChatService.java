package com.alves.capsula.service;
import org.springframework.stereotype.Service;

import com.alves.capsula.entity.Chamado;
import com.alves.capsula.entity.Chat;
import com.alves.capsula.entity.Usuario;
import com.alves.capsula.repository.ChatRepository;

@Service 
public class ChatService {
    //criar chat,  buscar chat pelo id, buscar chat pelo chamado, listar meus chats, validar acesso chat
    private final ChatRepository chatRepository;

    public ChatService(ChatRepository chatRepository){
        this.chatRepository = chatRepository;
    }

    public Chat criarChat(Chamado chamado, Usuario tecnicoResponsavel, Usuario usuarioLogado){
        if(usuarioLogado == null || usuarioLogado.getId()== null){
            throw new SecurityException("Usuario precisa estar logado");
        }
    }
}
