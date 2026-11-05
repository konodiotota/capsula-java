package com.alves.capsula.service;

import org.springframework.stereotype.Service;
import com.alves.capsula.repository.HistoricoChamadoRepository;
import java.util.List;

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
}
