package com.alves.capsula.repository;
import com.alves.capsula.entity.Perfil;
import com.alves.capsula.entity.Usuario;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

public interface UsuarioRepository
    extends JpaRepository<Usuario,Long>{
        List<Usuario> findByPerfil(
            Perfil perfil
        );
    }

