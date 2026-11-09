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

import jakarta.transaction.Transactional;

@Service 
public class ChamadoService {
    //item 2. Perfis e permissões documentação
    private final ChamadoRepository chamadoRepository;
    private final HistoricoChamadoService historicoChamadoService;

    public ChamadoService(ChamadoRepository chamadoRepository, HistoricoChamadoService historicoChamadoService){
        this.chamadoRepository = chamadoRepository; 
        this.historicoChamadoService = historicoChamadoService;
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
        chamado.setStatusChamado(StatusChamadoEnum.PENDENTE);
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

    @Transactional 
    public Chamado aceitarChamado(Long chamadoId, Usuario usuarioLogado){
        if(usuarioLogado.getPerfil() != PerfilEnum.ADMINISTRADOR &&
        usuarioLogado.getPerfil() != PerfilEnum.TECNICO) {
            throw new SecurityException("Usuario sem permissões");
        }
        Chamado chamado = chamadoRepository.findById(chamadoId).orElseThrow(() -> new RuntimeException("Esse chamado não esta disponivel"));
        if(chamado.getStatusChamado() != StatusChamadoEnum.PENDENTE){
            throw new IllegalStateException("Este chamado não esta mais disponivel");
        }
        StatusChamadoEnum statusAnterior = chamado.getStatusChamado();
        chamado.setTecnico(usuarioLogado);
        chamado.setIniciadoEm(LocalDateTime.now());
        chamado.setStatusChamado(StatusChamadoEnum.ACEITO);
        historicoChamadoService.registrarHistorico(usuarioLogado, chamado, statusAnterior, StatusChamadoEnum.ACEITO, "Chamado aceito");

        chamadoRepository.save(chamado);
        return chamado;
    }
    
    @Transactional 
    public Chamado iniciarDeslocamento(Long chamadoId, Usuario usuarioLogado){
        if(usuarioLogado.getPerfil() != PerfilEnum.ADMINISTRADOR &&
        usuarioLogado.getPerfil() != PerfilEnum.TECNICO) {
            throw new SecurityException("Usuario sem permissões");
        }

        Chamado chamado = chamadoRepository.findById(chamadoId).orElseThrow(() -> new RuntimeException("Esse chamado não esta disponivel"));

        if(chamado.getTecnico() == null || !chamado.getTecnico().getId().equals(usuarioLogado.getId())){
            throw new SecurityException("Você não é o tecnico responsavel pelo chamado");
        }

        if(chamado.getStatusChamado() != StatusChamadoEnum.ACEITO){
            throw new IllegalStateException("O chamado não esta no status aceito");
        }
        StatusChamadoEnum statusAnterior = chamado.getStatusChamado();
        chamado.setStatusChamado(StatusChamadoEnum.ACAMINHO);
        chamadoRepository.save(chamado);
        historicoChamadoService.registrarHistorico(usuarioLogado, chamado, statusAnterior, StatusChamadoEnum.ACAMINHO, "Tecnico em deslocamento");
        return chamado;
    }

    @Transactional
    public Chamado setStatusAtendimento(Long chamadoId, Usuario usuarioLogado){
        if(usuarioLogado.getPerfil() != PerfilEnum.ADMINISTRADOR &&
        usuarioLogado.getPerfil() != PerfilEnum.TECNICO) {
            throw new SecurityException("Usuario sem permissões");
        }

        Chamado chamado = chamadoRepository.findById(chamadoId).orElseThrow(() -> new RuntimeException("Esse chamado não esta disponivel"));

        if(chamado.getTecnico() == null || !chamado.getTecnico().getId().equals(usuarioLogado.getId())){
            throw new SecurityException("Você não é o tecnico responsavel pelo chamado");
        }

        if(chamado.getStatusChamado() != StatusChamadoEnum.ACAMINHO){
            throw new IllegalStateException("O chamado não esta no status acaminho");
        }
        StatusChamadoEnum statusAnterior = chamado.getStatusChamado();
        chamado.setStatusChamado(StatusChamadoEnum.ATENDIMENTO);
        chamadoRepository.save(chamado);
        historicoChamadoService.registrarHistorico(usuarioLogado, chamado, statusAnterior, StatusChamadoEnum.ATENDIMENTO, "Chamado em atendimento");
        return chamado;
    }

    @Transactional 
    public Chamado finalizarAtendimento(Long chamadoId, Usuario usuarioLogado){
        if(usuarioLogado.getPerfil() != PerfilEnum.ADMINISTRADOR &&
        usuarioLogado.getPerfil() != PerfilEnum.TECNICO) {
            throw new SecurityException("Usuario sem permissões");
        }

        Chamado chamado = chamadoRepository.findById(chamadoId).orElseThrow(() -> new RuntimeException("Esse chamado não esta disponivel"));

        if(chamado.getTecnico() == null || !chamado.getTecnico().getId().equals(usuarioLogado.getId())){
            throw new SecurityException("Você não é o tecnico responsavel pelo chamado");
        }

        if(chamado.getStatusChamado() != StatusChamadoEnum.ATENDIMENTO){
            throw new IllegalStateException("O chamado não esta no status atendimento");
        }
        StatusChamadoEnum statusAnterior = chamado.getStatusChamado();
        chamado.setConcluidoEm(LocalDateTime.now());
        chamado.setStatusChamado(StatusChamadoEnum.FINALIZADO);
        historicoChamadoService.registrarHistorico(usuarioLogado, chamado, statusAnterior, StatusChamadoEnum.FINALIZADO, "Atendimento finalizado");
        
        chamadoRepository.save(chamado);
        
        return chamado;
    }

    @Transactional
    public Chamado cancelarChamado(Long chamadoId, Usuario usuarioLogado){
        Chamado chamado = chamadoRepository.findById(chamadoId).orElseThrow(() -> new RuntimeException("Esse chamado não esta disponivel"));
        if(!chamado.getSolicitante().getId().equals(usuarioLogado.getId())){
            throw new SecurityException("Você não é o dono do chamado");
        }
        if(chamado.getStatusChamado() != StatusChamadoEnum.PENDENTE){
            throw new IllegalArgumentException("Apenas chamados pendentes podem ser cancelados");
        }
        StatusChamadoEnum statusAnterior = chamado.getStatusChamado();
        chamado.setStatusChamado(StatusChamadoEnum.CANCELADO);
        chamado.setConcluidoEm(LocalDateTime.now());

        chamadoRepository.save(chamado);
        historicoChamadoService.registrarHistorico(usuarioLogado, chamado, statusAnterior, StatusChamadoEnum.CANCELADO, "Chamado cancelado pelo solicitante");
        
        return chamado;
    }
}