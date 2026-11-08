package com.alves.capsula.service;

import java.time.LocalDateTime;
import java.util.List;
import org.springframework.stereotype.Service;


import com.alves.capsula.entity.Chamado;
import com.alves.capsula.entity.PerfilEnum;
import com.alves.capsula.entity.PrioridadeEnum;
import com.alves.capsula.entity.StatusChamadoEnum;
import com.alves.capsula.entity.Usuario;
import com.alves.capsula.model.dto.ChamadoDTO;
import com.alves.capsula.repository.ChamadoRepository;

@Service 
public class ChamadoService {
    //item 2. Perfis e permissões documentação
    private final ChamadoRepository chamadoRepository;

    public ChamadoService(ChamadoRepository chamadoRepository){
        this.chamadoRepository = chamadoRepository; 
    }
    //Necessario entender sobre SLA (Service Level Agreement), tempo maximo para atendimento
    public Chamado criarChamado(ChamadoDTO dados, Usuario usuarioLogado){
        if(usuarioLogado == null){
            throw new SecurityException("Usuario não está logado");
        }
        Chamado chamado = new Chamado();
        chamado.setCriadoEm(LocalDateTime.now());
        chamado.setDescricao(dados.getDescricao());
        chamado.setEndereco(dados.getEndereco());
        chamado.setPrioridade(PrioridadeEnum.BAIXA);
        chamado.setSolicitante(usuarioLogado);
        chamado.setStatusChamado(StatusChamadoEnum.CRIADO);
        chamado.setTecnico(null );
        return chamadoRepository.save(chamado);
    }
    //Interessante criar um chat entre cliente e tecnico para resolver o chamado, podendo ser presencial ou remoto

    public List<Chamado> verChamadosDisponiveis(Usuario usuarioLogado){
        if(usuarioLogado.getPerfil() != PerfilEnum.ADMINISTRADOR &&
           usuarioLogado.getPerfil() != PerfilEnum.TECNICO){
        throw new SecurityException("Usuario sem permissões");
        }
    return chamadoRepository.findByStatusChamado(StatusChamadoEnum.PENDENTE);
    }

    public Chamado aceitarChamado(Long chamadoId, Usuario usuarioLogado){
        if(usuarioLogado.getPerfil() != PerfilEnum.ADMINISTRADOR &&
        usuarioLogado.getPerfil() != PerfilEnum.TECNICO) {
            throw new SecurityException("Usuario sem permissões");
        }
        Chamado chamado = chamadoRepository.findById(chamadoId).orElseThrow(() -> new RuntimeException("Esse chamado não esta disponivel"));
        if(chamado.getStatusChamado() != StatusChamadoEnum.PENDENTE){
            throw new IllegalStateException("Este chamado não esta mais disponivel");
        }
        chamado.setTecnico(usuarioLogado);
        chamado.setIniciadoEm(LocalDateTime.now());
        chamado.setStatusChamado(StatusChamadoEnum.ACEITO);
        return chamadoRepository.save(chamado);
    }
    
    public Chamado iniciarDeslocamento(Long chamadoId, Usuario usuarioLogado){
        if(usuarioLogado.getPerfil() != PerfilEnum.ADMINISTRADOR &&
        usuarioLogado.getPerfil() != PerfilEnum.TECNICO) {
            throw new SecurityException("Usuario sem permissões");
        }

        Chamado chamado = chamadoRepository.findById(chamadoId).orElseThrow(() -> new RuntimeException("Esse chamado não esta disponivel"));

        if(!chamado.getTecnico().getId().equals(usuarioLogado.getId())){
            throw new SecurityException("Você não é o tecnico responsavel pelo chamado");
        }

        if(chamado.getStatusChamado() != StatusChamadoEnum.ACEITO){
            throw new IllegalStateException("O chamado não esta no status aceito");
        }

        chamado.setStatusChamado(StatusChamadoEnum.ACAMINHO);
        return chamadoRepository.save(chamado);
    }

    public Chamado setStatusAtendimento(Long chamadoId, Usuario usuarioLogado){
        if(usuarioLogado.getPerfil() != PerfilEnum.ADMINISTRADOR &&
        usuarioLogado.getPerfil() != PerfilEnum.TECNICO) {
            throw new SecurityException("Usuario sem permissões");
        }

        Chamado chamado = chamadoRepository.findById(chamadoId).orElseThrow(() -> new RuntimeException("Esse chamado não esta disponivel"));

        if(!chamado.getTecnico().getId().equals(usuarioLogado.getId())){
            throw new SecurityException("Você não é o tecnico responsavel pelo chamado");
        }

        if(chamado.getStatusChamado() != StatusChamadoEnum.ACAMINHO){
            throw new IllegalStateException("O chamado não esta no status acaminho");
        }
        chamado.setStatusChamado(StatusChamadoEnum.ATENDIMENTO);
        return chamadoRepository.save(chamado);
    }

    public Chamado finalizarAtendimento(Long chamadoId, Usuario usuarioLogado){
        if(usuarioLogado.getPerfil() != PerfilEnum.ADMINISTRADOR &&
        usuarioLogado.getPerfil() != PerfilEnum.TECNICO) {
            throw new SecurityException("Usuario sem permissões");
        }

        Chamado chamado = chamadoRepository.findById(chamadoId).orElseThrow(() -> new RuntimeException("Esse chamado não esta disponivel"));

        if(!chamado.getTecnico().getId().equals(usuarioLogado.getId())){
            throw new SecurityException("Você não é o tecnico responsavel pelo chamado");
        }

        if(chamado.getStatusChamado() != StatusChamadoEnum.ATENDIMENTO){
            throw new IllegalStateException("O chamado não esta no status atendimento");
        }
        chamado.setConcluidoEm(LocalDateTime.now());
        chamado.setStatusChamado(StatusChamadoEnum.FINALIZADO);
        return chamadoRepository.save(chamado);
    }
}