package com.alves.capsula.service;

import java.util.Optional;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import com.alves.capsula.entity.Usuario;
import com.alves.capsula.model.dto.UsuarioCadastroDTO;
import com.alves.capsula.repository.UsuarioRepository;

@Service 
public class UsuarioService {
    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    public UsuarioService(UsuarioRepository usuarioRepository,
        PasswordEncoder passwordEncoder
    ){this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    public Optional<Usuario> buscarUsuarioPorId(Long id){
        return usuarioRepository.findById(id);
    }

    public boolean emailJaCadastrado(String email){
        return usuarioRepository.findByEmail(email).isPresent();
    }
    
    public Usuario cadastrarUsuario(UsuarioCadastroDTO dados){
        if (emailJaCadastrado(dados.getEmail())){
            throw new IllegalArgumentException("Esse email ja esta cadastrado!");
        }
        Usuario usuario = new Usuario();
        usuario.setNome(dados.getNome());
        usuario.setEmail(dados.getEmail());
        usuario.setHashSenha(passwordEncoder.encode(dados.getSenha()));
        return usuarioRepository.save(usuario);
    }
}
