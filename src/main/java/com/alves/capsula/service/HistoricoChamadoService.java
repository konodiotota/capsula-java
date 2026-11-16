package com.alves.capsula.service;

import org.springframework.stereotype.Service;
import com.alves.capsula.repository.HistoricoChamadoRepository;

import jakarta.transaction.Transactional;

import java.time.LocalDateTime;
import java.util.List;

import com.alves.capsula.entity.Chamado;
import com.alves.capsula.entity.HistoricoChamado;
import com.alves.capsula.entity.PerfilEnum;
import com.alves.capsula.entity.StatusChamadoEnum;
import com.alves.capsula.entity.Usuario;

@Service
public class HistoricoChamadoService {
    private final HistoricoChamadoRepository historicoChamadoRepository;

    public HistoricoChamadoService(HistoricoChamadoRepository historicoChamadoRepository){
        this.historicoChamadoRepository = historicoChamadoRepository;
    }
    public List<HistoricoChamado> buscarPorChamadoId(Long chamado_id){
        return historicoChamadoRepository.findByChamado_id(chamado_id);
    }

    public List<HistoricoChamado> listarChamadosStatus(StatusChamadoEnum status, Usuario usuarioLogado){
        if(usuarioLogado.getPerfil() == PerfilEnum.ADMINISTRADOR || usuarioLogado.getPerfil() == PerfilEnum.TECNICO){
            return historicoChamadoRepository.findByStatusNovo(status);
        }
        throw new SecurityException("Perfil não autorizado");
    }
    //o springsecurity sera responsavel por olhar se o usuario esta logado
    public List<HistoricoChamado> listarMeusChamados(Usuario usuarioLogado){
        List<HistoricoChamado> historico= historicoChamadoRepository.findByChamado_Solicitante_Id(usuarioLogado.getId());
        if (historico.isEmpty()){
            throw new RuntimeException("Nenhum chamado encontrado");
        } 
        return historico;
    }
    
    public List<HistoricoChamado> listarChamadosPorIdEUsuario (Usuario usuarioLogado, Long usuarioId){
        if (usuarioLogado.getPerfil() != PerfilEnum.ADMINISTRADOR &&
            usuarioLogado.getPerfil() != PerfilEnum.TECNICO) {
            throw new SecurityException("Perfil não autorizado.");
        }
        return historicoChamadoRepository.findByChamado_Solicitante_Id(usuarioId);
    }

    @Transactional
    public HistoricoChamado registrarHistorico(Usuario usuarioLogado, Chamado chamado, StatusChamadoEnum statusAnterior, StatusChamadoEnum statusNovo, String observacao){
        if(usuarioLogado == null ||usuarioLogado.getId() == null){
            throw new SecurityException("Usuario não logado");
        }
        if(chamado == null || chamado.getId() == null){
            throw new IllegalArgumentException("Chamado inválido");
        }
        if(statusNovo == null){
            throw new IllegalArgumentException("Novo status não informado");
        }
        if(statusAnterior == statusNovo){
            throw new IllegalArgumentException("Os dois status não deveriam ser iguais");
        }
        HistoricoChamado historico = new HistoricoChamado();
        historico.setUsuario(usuarioLogado);
        historico.setChamado(chamado);
        historico.setStatusAnterior(statusAnterior);
        historico.setStatusNovo(statusNovo);
        historico.setObservacoes(observacao);
        historico.setCriadoEm(LocalDateTime.now());
        if(chamado.getConcluidoEm() != null){
            historico.setConcluidoEm(chamado.getConcluidoEm());
        }
        return historicoChamadoRepository.save(historico);
    }
}
