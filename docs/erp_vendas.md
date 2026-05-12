# ERP Vendas

## Visao geral

O ERP Vendas e o executavel comercial da solucao. Ele concentra cadastro de clientes, cadastro de produtos, lancamento de pedidos, relatorios de vendas e a integracao com o ERP Financeiro.

O projeto fica em `Vendas` e usa o banco Firebird `data\ERP_VENDAS.FDB`.

## Inicializacao

O bootstrap esta em `Vendas\ERPVendas.dpr`.

Fluxo de inicializacao:

1. Inicializa a aplicacao VCL.
2. Cria o data module de conexao.
3. Conecta no Firebird via `TVendasConexao`.
4. Executa `TVendasDatabaseSchema.EnsureCreated` para garantir as tabelas basicas.
5. Executa `TAuthService.EnsureSecurity` para criar/validar a estrutura de usuarios.
6. Abre a tela de login com senha e codigo TOTP.
7. Carrega o formulario principal `TfrmPrincipalVendas`.

## Divisao da arquitetura

### Presentation

Pasta: `Vendas\src\Presentation`

Contem formularios VCL e orquestracao de tela. A regra de negocio central fica fora dos formularios sempre que existe uma rotina de dominio ou aplicacao.

Principais telas:

- `Frm.Principal.Vendas`: menu principal, permissao de botoes administrativos e timer de quitacoes recebidas.
- `Frm.Cadastro.Cliente`: cadastro e pesquisa de clientes.
- `Frm.Cadastro.Produto`: cadastro e pesquisa de produtos.
- `Frm.Pedido.Venda`: lancamento do pedido, inclusao de itens, gravacao, impressao da confirmacao e envio ao Financeiro.
- `Frm.Dados.Email.Pedido`: cadastro dos dados SMTP do remetente.
- `Frm.Relatorio.PedidoConfirmacao`: modelo impresso/PDF do pedido.
- `Frm.Relatorio.PedidosPeriodo`: relatorio por periodo com filtros de cliente e produto.

### Application

Pasta: `Vendas\src\Application`

Contem casos de uso e contratos internos.

Servicos:

- `TPedidoVendaService`: confirma pedido e monta o DTO financeiro.
- `TEnvioRelatorioQuitacaoService`: processa quitacao recebida do Financeiro, gera PDF do pedido, registra tentativa e envia e-mail.

Interfaces:

- `IClienteRepository`
- `IProdutoRepository`
- `IPedidoVendaRepository`

### Core

Pasta: `Vendas\src\Core`

Contem entidades e excecoes de negocio.

Entidades:

- `TCliente`: dados cadastrais do cliente.
- `TProduto`: produto comercializado.
- `TPedidoVenda`: cabecalho do pedido.
- `TPedidoVendaItem`: item do pedido.

Regras de dominio principais:

- Pedido precisa ter cliente valido.
- Pedido precisa ter ao menos um item.
- Item precisa ter produto, descricao, quantidade maior que zero e valor unitario maior que zero.
- O total do item e calculado por quantidade vezes valor unitario.
- O total do pedido e a soma dos itens.
- A confirmacao coloca o pedido no status `spvConfirmado`.

### Infrastructure

Pasta: `Vendas\src\Infrastructure`

Contem persistencia, integracao, mensageria e e-mail.

Componentes:

- `TVendasConexao`: configura e mantem a conexao FireDAC/Firebird.
- `TVendasDatabaseSchema`: cria tabelas, sequences e triggers necessarias.
- Repositorios FireDAC de cliente, produto e pedido.
- `TFinanceiroGateway`: publica venda confirmada no RabbitMQ.
- `TContaRecebidaConsumer`: consome evento de conta recebida vindo do Financeiro.
- `TSmtpEmailClient`: envia e-mail com anexo PDF usando configuracao gravada no banco.

## Regras de negocio

### Cadastro de cliente

- Nome e obrigatorio.
- Documento, e-mail, telefone, cidade e UF sao complementares.
- O e-mail do cliente e usado no envio automatico do comprovante de quitacao.

### Cadastro de produto

- Descricao e obrigatoria.
- Preco de venda deve ser maior que zero.
- Produto possui flag de ativo.

### Pedido de venda

Fluxo:

1. Usuario informa cliente.
2. Usuario inclui produtos.
3. O sistema calcula totais dos itens e do pedido.
4. Ao salvar, o pedido e confirmado.
5. O pedido e persistido em `pedidos_venda` e `pedidos_venda_itens`.
6. O ERP imprime o relatorio de confirmacao.
7. A tela e limpa para o proximo pedido.
8. O ERP publica o evento de venda confirmada para o Financeiro.

Regra importante: o pedido so e enviado ao Financeiro depois de gravado e confirmado.

### Integracao com Financeiro

O contrato compartilhado e `TVendaFinanceiroDTO`, definido no projeto `Shared`.

Dados enviados:

- Codigo da venda.
- Codigo do cliente.
- Nome do cliente.
- Data de emissao.
- Valor total.

O envio acontece pelo RabbitMQ Management HTTP API, sem dependencia AMQP externa no Delphi.

Fila usada para venda confirmada:

- Exchange: `erp.financeiro`
- Queue: `erp.financeiro.venda_confirmada`
- Routing key: `venda.confirmada`

### Quitacao e envio de e-mail

Quando o Financeiro baixa uma conta a receber, ele publica um evento `TContaRecebidaDTO`.

O ERP Vendas consome esse evento e executa:

1. Verifica se o e-mail daquela conta/pedido ja foi enviado.
2. Busca cliente, pedido e e-mail.
3. Gera PDF do pedido em `relatorios_email`.
4. Registra a tentativa em `emails_quitacao`.
5. Envia o e-mail com o PDF anexado.
6. Atualiza o status como `ENVIADO` ou `ERRO`.
7. Registra falhas em arquivo texto na pasta `logs`.

Regras:

- E-mail sem destinatario gera erro controlado.
- Reenvio automatico considera registros `PENDENTE` ou `ERRO`.
- O limite atual de reprocessamento e 3 tentativas.
- O envio usa os dados da tabela `config_email_pedido`.

### Configuracao de e-mail

Tela: `Dados Email Pedido`.

Tabela: `config_email_pedido`.

Campos principais:

- Host SMTP.
- Porta.
- Usuario.
- Senha.
- E-mail remetente.
- Nome remetente.
- Modo de seguranca SMTP.

Modos suportados:

- `STARTTLS`, normalmente porta `587`.
- `SSL/TLS implicito`, normalmente porta `465`.
- Sem TLS.

Para Gmail, a senha deve ser uma senha de aplicativo.

## Relatorios

### Confirmacao de pedido

Unit: `Frm.Relatorio.PedidoConfirmacao`.

Uso:

- Impressao logo apos gravar pedido.
- Exportacao em PDF para envio por e-mail.

Dados:

- Codigo do cliente.
- Nome do cliente.
- Valor total.
- Data de emissao.
- Produtos do pedido.
- Total final.

### Pedidos por periodo

Unit: `Frm.Relatorio.PedidosPeriodo`.

Filtros:

- Data inicial.
- Data final.
- Cliente opcional.
- Produto opcional.

Regra de data: a data final e tratada como limite exclusivo no dia seguinte, garantindo que pedidos emitidos ao longo do dia final sejam considerados.

## Banco de dados

Tabelas principais:

- `clientes`
- `produtos`
- `pedidos_venda`
- `pedidos_venda_itens`
- `emails_quitacao`
- `config_email_pedido`
- `usuarios`

Sequences principais:

- `gen_clientes_id`
- `gen_produtos_id`
- `gen_pedidos_venda_id`
- `gen_emails_quitacao_id`
- `gen_usuarios_id`

Scripts:

- `Vendas\src\Infrastructure\Database\Scripts\firebird_3_0\000_criar_database.sql`
- `Vendas\src\Infrastructure\Database\Scripts\firebird_3_0\001_criar_base_vendas.sql`

A documentacao detalhada dos campos esta em `docs\banco_de_dados.md`.

## Seguranca

A autenticacao e compartilhada com o Financeiro pelo projeto `Shared`.

Regras:

- Usuario e senha.
- Codigo TOTP compativel com Microsoft Authenticator.
- Senha armazenada com PBKDF2/SHA1 e salt.
- Chave TOTP em Base32.
- Bloqueio apos 3 tentativas invalidas.
- Desbloqueio somente por administrador.
- Fluxo de recuperacao do administrador inicial antes do primeiro login.

## Pontos de manutencao

- Regras comerciais devem ficar nas entidades ou servicos de aplicacao.
- Forms devem orquestrar tela, validacao visual e chamada de servicos.
- Repositorios devem se limitar a persistencia FireDAC.
- Integracao com outros ERPs deve passar por DTOs do `Shared`.
- Alteracoes de schema devem ser refletidas em `TVendasDatabaseSchema` e nos scripts SQL.
