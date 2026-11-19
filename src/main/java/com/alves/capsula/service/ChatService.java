package com.alves.capsula.service;

import java.time.LocalDateTime;
import java.util.List;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import com.alves.capsula.entity.Chamado;
import com.alves.capsula.entity.Chat;
import com.alves.capsula.entity.Usuario;
import com.alves.capsula.repository.ChamadoRepository;
import com.alves.capsula.repository.ChatRepository;
import com.alves.capsula.repository.UsuarioRepository;

import jakarta.transaction.Transactional;

@Service
public class ChatService {
    private final ChatRepository chatRepository;
    private final ChamadoRepository chamadoRepository;
    private final UsuarioRepository usuarioRepository;

    public ChatService(
            ChatRepository chatRepository,
            ChamadoRepository chamadoRepository,
            UsuarioRepository usuarioRepository) {
        this.chatRepository = chatRepository;
        this.chamadoRepository = chamadoRepository;
        this.usuarioRepository = usuarioRepository;
    }
    @Transactional
    public Chat criarChat(Long chamadoId, Usuario usuarioLogado) {
        Usuario usuarioAutenticado = obterUsuarioAutenticado(usuarioLogado);
        Chamado chamado = obterChamado(chamadoId);

        validarParticipanteDoChamado(chamado, usuarioAutenticado);

        if (chamado.getTecnico() == null || chamado.getTecnico().getId() == null) {
            throw new IllegalStateException("O chamado ainda não possui técnico responsável");
        }

        return chatRepository.findByChamado_Id(chamado.getId())
                .orElseGet(() -> salvarChat(chamado));
    }

    @Deprecated(forRemoval = false)
    @Transactional
    public Chat criarChat(Chamado chamado, Usuario tecnicoResponsavel, Usuario usuarioLogado) {
        if (chamado == null || chamado.getId() == null) {
            throw new IllegalArgumentException("Chamado inválido");
        }

        return criarChat(chamado.getId(), usuarioLogado);
    }

    public Chat buscarChatPorId(Long chatId, Usuario usuarioLogado) {
        Usuario usuarioAutenticado = obterUsuarioAutenticado(usuarioLogado);
        Chat chat = chatRepository.findById(validarId(chatId, "Chat"))
                .orElseThrow(() -> new IllegalArgumentException("Chat não encontrado"));

        validarAcessoAoChatPersistido(chat, usuarioAutenticado);
        return chat;
    }

    public Chat buscarChatPorChamado(Long chamadoId, Usuario usuarioLogado) {
        Usuario usuarioAutenticado = obterUsuarioAutenticado(usuarioLogado);
        Chat chat = chatRepository.findByChamado_Id(validarId(chamadoId, "Chamado"))
                .orElseThrow(() -> new IllegalArgumentException("Chat não encontrado para o chamado"));

        validarAcessoAoChatPersistido(chat, usuarioAutenticado);
        return chat;
    }

    public List<Chat> listarMeusChats(Usuario usuarioLogado) {
        Usuario usuarioAutenticado = obterUsuarioAutenticado(usuarioLogado);
        return chatRepository.findChatsDoUsuario(usuarioAutenticado.getId());
    }


    public void validarAcessoChat(Long chatId, Usuario usuarioLogado) {
        Usuario usuarioAutenticado = obterUsuarioAutenticado(usuarioLogado);
        Chat chat = chatRepository.findById(validarId(chatId, "Chat"))
                .orElseThrow(() -> new IllegalArgumentException("Chat não encontrado"));

        validarAcessoAoChatPersistido(chat, usuarioAutenticado);
    }

    private void validarAcessoAoChatPersistido(Chat chat, Usuario usuarioAutenticado) {
        if (chat.getChamado() == null) {
            throw new IllegalStateException("Chat sem chamado válido");
        }

        validarParticipanteDoChamado(chat.getChamado(), usuarioAutenticado);

        if (chat.getTecnicoResponsavel() == null
                || chat.getTecnicoResponsavel().getId() == null
                || chat.getChamado().getTecnico() == null
                || chat.getChamado().getTecnico().getId() == null
                || !chat.getTecnicoResponsavel().getId().equals(chat.getChamado().getTecnico().getId())) {
            throw new IllegalStateException("Chat possui participante técnico inválido");
        }
    }

    private Chat salvarChat(Chamado chamado) {
        Chat chat = new Chat();
        chat.setChamado(chamado);
        chat.setTecnicoResponsavel(chamado.getTecnico());
        chat.setCriadoEm(LocalDateTime.now());
        return chatRepository.save(chat);
    }

    private Chamado obterChamado(Long chamadoId) {
        return chamadoRepository.findById(validarId(chamadoId, "Chamado"))
                .orElseThrow(() -> new IllegalArgumentException("Chamado não encontrado"));
    }

    private Usuario obterUsuarioAutenticado(Usuario usuarioLogado) {
        if (usuarioLogado == null || usuarioLogado.getId() == null) {
            throw new AccessDeniedException("Usuário não autenticado");
        }

        return usuarioRepository.findById(usuarioLogado.getId())
                .orElseThrow(() -> new AccessDeniedException("Usuário não autenticado"));
    }

    private void validarParticipanteDoChamado(Chamado chamado, Usuario usuarioAutenticado) {
        if (chamado.getSolicitante() == null || chamado.getSolicitante().getId() == null) {
            throw new IllegalStateException("Chamado sem solicitante válido");
        }

        boolean ehSolicitante = chamado.getSolicitante().getId().equals(usuarioAutenticado.getId());
        boolean ehTecnicoResponsavel = chamado.getTecnico() != null
                && chamado.getTecnico().getId() != null
                && chamado.getTecnico().getId().equals(usuarioAutenticado.getId());

        if (!ehSolicitante && !ehTecnicoResponsavel) {
            throw new AccessDeniedException("Usuário não participa deste chamado");
        }
    }

    private Long validarId(Long id, String recurso) {
        if (id == null || id <= 0) {
            throw new IllegalArgumentException(recurso + " inválido");
        }
        return id;
    }
}
