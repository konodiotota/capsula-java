package com.alves.capsula.repository;
import com.alves.capsula.entity.Usuario;

import org.springframework.data.jpa.repository.JpaRepository;

public interface UsuarioRepository
    extends JpaRepository<Usuario,Long>{
    }

