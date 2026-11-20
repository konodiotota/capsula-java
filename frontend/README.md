# Capsula — frontend Flutter

Um código para **Android, iOS, Windows, macOS, Linux e web**, com tema escuro (azul-marinho e amarelo de sinalização).

- **Telas largas:** barra lateral agrupada com contadores, faixa de totais que também filtra, busca, ordenação, cartões ou lista, e detalhe em painel lateral com as ações fixas no rodapé.
- **Celular:** barra inferior, botão flutuante "Abrir chamado" e páginas empilhadas.
- **Trajeto:** cada chamado é uma linha de cinco estações (`PENDENTE` a `FINALIZADO`), preenchida a partir do histórico real.
- Contadores e totais saem das listas carregadas; nada é preenchido com dados de exemplo.

## O que o app cobre (tudo vem do backend atual)

| Área | Origem no backend |
|---|---|
| Entrar e criar conta (cliente) | `UsuarioCadastroRequestDTO`, `UsuarioService` (senha de 8 a 50 caracteres, com caractere especial e sem espaços) |
| Abrir chamado (descrição e endereço, até 250 caracteres) | `ChamadoRequestDTO`, `ChamadoService.criarChamado` |
| Meus chamados e fila de chamados disponíveis (técnico e administrador) | `ChamadoRepository`, `ChamadoService.verChamadosDisponiveis` |
| Aceitar, iniciar deslocamento, iniciar atendimento, finalizar | `ChamadoService` (somente o técnico responsável avança) |
| Cancelar | `ChamadoService.cancelarChamado` (só o dono, só pendente) |
| Trajeto com quem registrou cada etapa e quando | `HistoricoChamadoResponseDTO` |
| Conversas e mensagens (até 5000 caracteres) | `ChatService`, `ChatResponseDTO`, `Mensagem*DTO` |
| Endereço e coordenadas no detalhe | `Chamado.endereco`, `latitude`, `longitude` |

Regras do backend repetidas no cliente (`lib/domain/regras.dart`) só orientam o usuário; o servidor decide.

## Backend ainda sem API

Os controllers estão vazios, então **nenhuma rota foi presumida**. O app depende de `CapsulaGateway` (`lib/domain/capsula_gateway.dart`), que espelha as operações dos serviços Java. Hoje `main.dart` usa `SemApiCapsulaGateway`: o login mostra que o servidor não publica a operação.

Para conectar: implemente `CapsulaGateway` com o cliente HTTP escolhido e troque-o em `main.dart`. Pontos que o backend precisa resolver antes:

- Autenticação e `/me` (AutenticacaoController e UsuarioController vazios).
- Não há DTO de resposta para `Chamado`; o modelo do app segue a entidade.
- Não existe consulta de chamados por técnico: o técnico não consegue listar o que já aceitou depois de recarregar.
- `MensagemService` está vazio e `MensagemRepository.findByChat_IdOrderByCriadoEmAsc` devolve `Optional<Chat>`, não uma lista de mensagens.
- `MensagemResponseDTO` traz só nomes; o app identifica "minhas mensagens" pelo nome do remetente.
- `HistoricoChamadoService.listarMeusChamados` lança erro quando não há chamados; o gateway deve tratar isso como lista vazia.
- Prioridade nasce `BAIXA` e nenhum fluxo a altera; por isso o formulário não a pede.
- Mapa: nenhum provedor foi escolhido. Passe `mapBuilder` a `MapaChamado` quando houver um.

## Executar

```sh
flutter pub get
flutter run -d chrome      # web
flutter run -d windows     # desktop (requer Visual Studio com C++)
flutter run                # celular conectado ou emulador
flutter test
```

Fontes (Barlow e Barlow Condensed, licença OFL) estão em `assets/fonts/` e funcionam offline.
