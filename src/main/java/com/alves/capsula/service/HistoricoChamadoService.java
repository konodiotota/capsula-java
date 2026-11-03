package com.alves.capsula.service;

import org.springframework.stereotype.Service;
import com.alves.capsula.repository.HistoricoChamadoRepository;
import java.util.List;
import com.alves.capsula.entity.HistoricoChamado;
import com.alves.capsula.entity.StatusChamadoEnum;

@Service
public class HistoricoChamadoService {
    private final HistoricoChamadoRepository historicoChamadoRepository;

    public HistoricoChamadoService(HistoricoChamadoRepository historicoChamadoRepository){
        this.historicoChamadoRepository = historicoChamadoRepository;
    }
    public List<HistoricoChamado> buscarPorChamadoId(Long chamado_id){
        return historicoChamadoRepository.findByChamado_id(chamado_id);
    }
    // usuario nao pode ver historico de outros usuarios, apenas ele mesmo
    //administrador pode ver todos os chamados (prioridade para os que estao aberto)
    //tecnico pode ver todos os chamados abertos e os que foram atendidos por ele mesmo
    public List<HistoricoChamado> listarChamadosStatus(StatusChamadoEnum status){
        
    }
}
