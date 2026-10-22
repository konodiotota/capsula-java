# 📦 Capsula — Sistema de Chamados Técnicos

O **Capsula** é um projeto de sistema de gerenciamento de chamados técnicos desenvolvido com Java e Spring Boot. Seu objetivo é organizar e facilitar o acompanhamento de solicitações de suporte técnico, permitindo o registro de problemas, o gerenciamento de chamados e o histórico de atendimentos.

O projeto está sendo desenvolvido com foco em boas práticas de programação, organização em camadas, persistência de dados e segurança no acesso às informações.

## 🎯 Objetivo do projeto

Criar uma aplicação backend para centralizar o gerenciamento de chamados técnicos, facilitando o controle das solicitações e preparando a base para futuras integrações com uma interface web e aplicativos.

## 🛠️ Tecnologias utilizadas

- **Java** — linguagem principal do projeto.
- **Spring Boot** — criação e configuração da aplicação backend.
- **Spring Data JPA** — abstração do acesso e da persistência de dados.
- **Hibernate** — mapeamento objeto-relacional (ORM).
- **PostgreSQL** — banco de dados relacional.
- **Maven** — gerenciamento de dependências e build do projeto.

## 🏗️ Arquitetura

O projeto utiliza uma arquitetura em camadas para separar as responsabilidades e facilitar a manutenção do código.

```text
Capsula/
├── src/
│   └── main/
│       ├── java/
│       │   └── com/alves/capsula/
│       │       ├── entity/
│       │       ├── repository/
│       │       ├── service/
│       │       └── controller/
│       └── resources/
│           └── application.properties
├── pom.xml
└── README.md
```

**Responsabilidades das camadas:**

- **Entity:** representa as entidades e o mapeamento das tabelas do banco de dados.
- **Repository:** concentra as operações de acesso e consulta aos dados.
- **Service:** contém as regras de negócio e a lógica da aplicação.
- **Controller:** recebe as requisições HTTP e disponibiliza os endpoints da API.

## 📋 Entidades principais

### Usuario
Representa os usuários do sistema, com informações como nome, e-mail, senha armazenada de forma segura e perfil de acesso.

### Chamado
Representa uma solicitação de suporte técnico, incluindo sua descrição, situação, prioridade, solicitante, técnico responsável e datas relevantes.

### HistoricoChamado
Registra eventos relacionados aos chamados, permitindo acompanhar alterações de estado e o histórico de atendimento.

## ⚙️ Funcionalidades

### Implementação em andamento

- [x] Estrutura inicial das entidades.
- [x] Criação dos repositories.
- [ ] Desenvolvimento da camada de serviços.
- [ ] Implementação dos controllers e endpoints REST.
- [ ] Validação dos dados de entrada.
- [ ] Implementação da autenticação e autorização.
- [ ] Controle de acesso aos chamados por usuário.
- [ ] Registro e consulta do histórico de alterações.
- [ ] Testes automatizados.

> O checklist representa o andamento do desenvolvimento e deve ser atualizado conforme cada funcionalidade for implementada e testada.

## 🔐 Segurança e boas práticas

O projeto considera como objetivos de desenvolvimento:

- Controle de acesso baseado no perfil do usuário.
- Proteção de dados e credenciais.
- Validação das requisições recebidas pela API.
- Separação entre regras de negócio e acesso ao banco de dados.
- Restrição de acesso aos chamados conforme as permissões do usuário.
- Preparação para adoção de práticas de segurança alinhadas à LGPD.

A autenticação e as regras de autorização ainda precisam ser implementadas para que esses controles sejam efetivamente aplicados.

## 🚀 Como executar o projeto

### Pré-requisitos

- JDK compatível com a versão Java definida no projeto.
- Maven, caso não seja utilizado o Maven Wrapper.
- PostgreSQL instalado e configurado.

### 1. Clone o repositório

```bash
git clone https://github.com/konodiotota/capsula-java.git
cd capsula
```

### 2. Configure o banco de dados

Crie um banco de dados PostgreSQL para a aplicação e configure as credenciais nas propriedades do projeto.

Exemplo de configuração em `application.properties`:

```properties
spring.datasource.url=${DB_URL}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}

spring.jpa.hibernate.ddl-auto=update
```

Configure as variáveis de ambiente `DB_URL`, `DB_USERNAME` e `DB_PASSWORD` antes de iniciar a aplicação. O modo de criação do schema deve ser adequado ao ambiente, especialmente em produção.

### 3. Execute a aplicação

Com o Maven Wrapper:

```bash
./mvnw spring-boot:run
```

No Windows, utilizando PowerShell:

```powershell
.\mvnw.cmd spring-boot:run
```

Caso o Maven Wrapper não esteja disponível, utilize:

```bash
mvn spring-boot:run
```

## 📚 Aprendizados

Este projeto faz parte da minha jornada de desenvolvimento backend e tem como foco a aplicação prática de conceitos como:

- Programação orientada a objetos com Java.
- Desenvolvimento de APIs REST com Spring Boot.
- Persistência de dados com JPA e Hibernate.
- Relacionamentos entre entidades.
- Organização de aplicações em camadas.
- Implementação de regras de negócio.
- Autenticação, autorização e testes de software.

## 📌 Status do projeto

**Em desenvolvimento.**

O CapsulaWeb está sendo construído gradualmente, começando pela modelagem das entidades e pelo acesso aos dados, com evolução para as regras de negócio, a API REST e os mecanismos de segurança.

## 👨‍💻 Autor

**Henrique Alves da Silva**

- GitHub: [@konodiotota](https://github.com/konodiotota)
- LinkedIn: [Henrique Alves da Silva](https://www.linkedin.com/in/henrique-alves-b19aa4230/)

---

*Projeto desenvolvido para praticar e aprofundar conhecimentos em Java, Spring Boot e desenvolvimento backend.*
