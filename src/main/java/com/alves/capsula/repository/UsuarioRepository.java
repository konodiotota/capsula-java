package com.alves.capsula.repository;
import com.alves.capsula.entity.PerfilEnum;
import com.alves.capsula.entity.Usuario;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;

public interface UsuarioRepository
    extends JpaRepository<Usuario,Long>{
        List<Usuario> findByPerfil(PerfilEnum perfil);

        List<Usuario> findByUsuario_iddAndPerfil(
            Long usuario_id,
            PerfilEnum perfil
        );
        Optional<Usuario> findByEmail(String email);
    }

