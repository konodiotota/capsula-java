package com.alves.capsula.repository;
import com.alves.capsula.entity.Perfil;
import com.alves.capsula.entity.Usuario;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface UsuarioRepository
    extends JpaRepository<Usuario,Long>{
        List<Usuario> findBySolicitante_id(Long usuario_id);

        List<Usuario> findBySolicitante_idAndPerfil(
            Long usuario_id,
            Perfil perfil
        );
        Optional<Usuario> findByEmail(String email);
    }

