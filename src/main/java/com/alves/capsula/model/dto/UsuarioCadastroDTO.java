package com.alves.capsula.model.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Setter
@Getter
@NoArgsConstructor 
public class UsuarioCadastroDTO {
    @NotBlank(message = "O nome é obrigatório!")
    @Size(max = 250, message = "Nome deve ter no maximo 250 caracteres")
    private String nome;

    @NotBlank(message = "Email é obrigatório!")
    @Email(message = "Informe um email válido!")
    private String email;

    @NotBlank(message = "Senha é obrigatório!")
    @Size(min = 8, max = 72)
    private String senha;
}
