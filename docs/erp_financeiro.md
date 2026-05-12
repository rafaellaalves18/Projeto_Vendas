# ERP Financeiro

## Visao geral

O ERP Financeiro e o executavel responsavel por contas a receber, baixa financeira, consulta, relatorios e dashboard de vendas.

O projeto fica em `Financeiro` e usa o banco Firebird `data\ERP_FINANCEIRO.FDB`.

## Inicializacao

O bootstrap esta em `Financeiro\ERPFinanceiro.dpr`.

Fluxo de inicializacao:

1. Inicializa a aplicacao VCL.
2. Conecta no Firebird via `TFinanceiroConexao`.
3. Executa `TFinanceiroDatabaseSchema.EnsureCreated`.
4. Executa `TAuthService.EnsureSecurity`.
5. Abre a tela de login com senha e codigo TOTP.
6. Carrega o formulario principal `TfrmPrincipalFinanceiro`.

## Divisao da arquitetura

### Presentation

Pasta: `Financeiro\src\Presentation`

Principais telas:

- `Frm.Principal.Financeiro`: menu principal, timer de consumo do RabbitMQ e acesso ao desbloqueio de usuarios.
- `Frm.Baixa.Financeiro`: pesquisa e baixa de contas a receber.
- `Frm.Consulta.Financeiro`: consulta financeira por cliente.
- `Frm.Relatorio.Financeiro`: relatorio financeiro por periodo, cliente, status e tipo de data.
- `Frm.Dashboard.Vendas`: dashboard baseado no banco de Vendas com indicadores, top produtos e top clientes.

### Application

Pasta: `Financeiro\src\Application`

Servico principal:

- `TContaReceberService`: aplica as regras de negocio para gerar, baixar e cancelar contas a receber.

Interface:

- `IContaReceberRepository`: contrato de persistencia da conta a receber.

### Core

Pasta: `Financeiro\src\Core`

Entidade principal:

- `TContaReceber`

Estados:

- `scrAberta`
- `scrRecebida`
- `scrCancelada`

Origem financeira:

- `ofVenda`

### Infrastructure

Pasta: `Financeiro\src\Infrastructure`

Componentes:

- `TFinanceiroConexao`: conexao FireDAC/Firebird do ERP Financeiro.
- `TFinanceiroDatabaseSchema`: criacao da estrutura de contas a receber.
- `TContaReceberRepository`: persistencia e consultas de contas a receber.
- `TVendaFinanceiroReceiver`: recebe venda confirmada e gera conta a receber.
- `TFinanceiroRabbitMQConsumer`: consome vendas confirmadas do RabbitMQ.
- `TVendasGateway`: publica evento de conta recebida para o ERP Vendas.

## Regras de negocio

### Geracao de conta a receber

A conta a receber nasce a partir de uma venda confirmada no ERP Vendas.

Contrato recebido: `TVendaFinanceiroDTO`.

Validacoes:

- Venda de origem obrigatoria.
- Cliente obrigatorio.
- Nome do cliente obrigatorio.
- Data de emissao obrigatoria.
- Valor total maior que zero.

Preenchimento:

- Origem: `VENDA`.
- Id de origem: codigo do pedido de venda.
- Data de emissao: data da venda.
- Data de vencimento: data de emissao + 30 dias.
- Valor: valor total da venda.
- Status inicial: `ABERTA`.

Idempotencia:

- A tabela `contas_receber` possui indice unico por `origem` e `id_origem`.
- Se a mesma venda for recebida mais de uma vez, o repositorio reaproveita o registro existente.

### Baixa financeira

Tela: `Frm.Baixa.Financeiro`.

Fluxo:

1. Usuario pesquisa contas abertas por cliente.
2. Seleciona a conta.
3. Aciona baixa.
4. `TContaReceberService.Baixar` valida a regra.
5. O repositorio grava a conta como recebida.
6. O Financeiro publica o evento de conta recebida para o ERP Vendas.

Validacoes:

- Conta obrigatoria.
- Conta ja recebida nao pode ser baixada novamente.
- Conta cancelada nao pode ser baixada.

Evento publicado para Vendas:

- Exchange: `erp.vendas`
- Queue: `erp.vendas.conta_recebida`
- Routing key: `financeiro.conta_recebida`

### Cancelamento

Regra:

- Somente contas em aberto podem ser canceladas.
- Conta ja cancelada nao pode ser cancelada novamente.

### Consulta financeira

Tela: `Frm.Consulta.Financeiro`.

Permite consultar contas por cliente e exibir:

- Codigo da conta.
- Codigo do cliente.
- Nome do cliente.
- Datas.
- Valor.
- Status.
- Total em aberto.

### Relatorio financeiro

Tela: `Frm.Relatorio.Financeiro`.

Filtros:

- Data inicial.
- Data final.
- Tipo de data: emissao ou vencimento.
- Codigo do cliente.
- Nome do cliente.
- Status.

Dados impressos:

- Codigo do cliente.
- Nome do cliente.
- Valor financeiro.
- Data de vencimento.
- Status.

Regra de data: a data final e tratada como limite exclusivo no dia seguinte, evitando perda de registros emitidos no ultimo dia do filtro.

### Dashboard de vendas

Tela: `Frm.Dashboard.Vendas`.

O dashboard e exibido dentro do ERP Financeiro, mas consulta diretamente o banco do ERP Vendas.

Indicadores:

- Total de pedidos.
- Total vendido.
- Ticket medio.
- Clientes distintos.

Listagens:

- Top 5 produtos mais vendidos.
- Top 5 clientes que mais compraram.

Relatorio/grafico:

- Botao de grafico gera ReportBuilder com grafico dos top 5 clientes.

## Banco de dados

Tabela principal:

- `contas_receber`

Campos principais:

- `id_conta_receber`
- `origem`
- `id_origem`
- `id_cliente`
- `nome_cliente`
- `data_emissao`
- `data_vencimento`
- `valor`
- `status`

Objetos auxiliares:

- `gen_contas_receber_id`
- `uk_contas_receber_origem`
- `usuarios`
- `gen_usuarios_id`

Scripts:

- `Financeiro\src\Infrastructure\Database\Scripts\000_criar_database.sql`
- `Financeiro\src\Infrastructure\Database\Scripts\001_criar_base_financeiro.sql`

A documentacao detalhada dos campos esta em `docs\banco_de_dados.md`.

## Integracao

### Entrada: venda confirmada

Origem: ERP Vendas.

Contrato: `TVendaFinanceiroDTO`.

Processamento:

1. `TFinanceiroRabbitMQConsumer.ProcessarMensagens`.
2. `TVendaFinanceiroReceiver.ReceberVendaConfirmada`.
3. `TContaReceberService.GerarPorVenda`.
4. `TContaReceberRepository.Salvar`.

### Saida: conta recebida

Destino: ERP Vendas.

Contrato: `TContaRecebidaDTO`.

Processamento:

1. Usuario baixa a conta.
2. Financeiro salva o status `RECEBIDA`.
3. `TVendasGateway.NotificarContaRecebida` publica o evento.
4. ERP Vendas consome e envia o relatorio por e-mail.

## Seguranca

A autenticacao e compartilhada pelo projeto `Shared`.

Regras:

- Login com usuario, senha e codigo TOTP.
- Compatibilidade com Microsoft Authenticator.
- Bloqueio apos 3 tentativas invalidas.
- Desbloqueio por administrador.
- Administrador inicial criado automaticamente no primeiro uso.

## Pontos de manutencao

- Regras financeiras ficam em `TContaReceberService` e `TContaReceber`.
- O formulario de baixa nao deve alterar status diretamente sem passar pelo service.
- Eventos externos devem trafegar pelos contratos do `Shared`.
- Novas origens financeiras devem atualizar `TOrigemFinanceira`, o repositorio e as regras de geracao.
- Alteracoes de schema devem ser refletidas em `TFinanceiroDatabaseSchema` e nos scripts SQL.
