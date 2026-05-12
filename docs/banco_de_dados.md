# Banco de dados

## Visao geral

A solucao usa Firebird 3.0 com bancos separados por ERP:

- ERP Vendas: `data\ERP_VENDAS.FDB`
- ERP Financeiro: `data\ERP_FINANCEIRO.FDB`

Cada executavel possui sua propria conexao e seu proprio schema operacional. O projeto `Shared` nao possui banco proprio; ele fornece contratos, tipos, autenticacao e mensageria compartilhada.

## Scripts oficiais

### ERP Vendas

Pasta:

`Vendas\src\Infrastructure\Database\Scripts\firebird_3_0`

Scripts:

- `000_criar_database.sql`: cria o banco `ERP_VENDAS.FDB`.
- `001_criar_base_vendas.sql`: cria tabelas, sequences, triggers e indices do ERP Vendas.

### ERP Financeiro

Pasta:

`Financeiro\src\Infrastructure\Database\Scripts`

Scripts:

- `000_criar_database.sql`: cria o banco `ERP_FINANCEIRO.FDB`.
- `001_criar_base_financeiro.sql`: cria tabelas, sequences, triggers e indices do ERP Financeiro.

## Como executar

Os scripts assumem o caminho padrao `C:\Projeto_Vendas\data`. Se o projeto estiver em outro diretorio, ajuste o caminho dentro dos scripts `000_criar_database.sql`.

Exemplo via `isql.exe` do Firebird:

```bat
"C:\Program Files\Firebird\Firebird_3_0\isql.exe" -i Vendas\src\Infrastructure\Database\Scripts\firebird_3_0\000_criar_database.sql
"C:\Program Files\Firebird\Firebird_3_0\isql.exe" -user SYSDBA -password masterkey localhost:C:\Projeto_Vendas\data\ERP_VENDAS.FDB -i Vendas\src\Infrastructure\Database\Scripts\firebird_3_0\001_criar_base_vendas.sql

"C:\Program Files\Firebird\Firebird_3_0\isql.exe" -i Financeiro\src\Infrastructure\Database\Scripts\000_criar_database.sql
"C:\Program Files\Firebird\Firebird_3_0\isql.exe" -user SYSDBA -password masterkey localhost:C:\Projeto_Vendas\data\ERP_FINANCEIRO.FDB -i Financeiro\src\Infrastructure\Database\Scripts\001_criar_base_financeiro.sql
```

Observacoes:

- Os scripts de criacao de banco devem ser executados apenas quando o arquivo `.FDB` ainda nao existe.
- A aplicacao tambem executa rotinas `EnsureCreated` no startup para garantir objetos essenciais.
- O usuario administrador inicial e criado pela aplicacao no primeiro startup quando a tabela `usuarios` esta vazia.

## ERP Vendas

### clientes

Cadastro de clientes usados no pedido de venda.

| Campo | Tipo | Obrigatorio | Observacao |
| --- | --- | --- | --- |
| `id_cliente` | integer | Sim | Chave primaria |
| `nome` | varchar(120) | Sim | Nome do cliente |
| `documento` | varchar(20) | Nao | CPF/CNPJ ou documento equivalente |
| `email` | varchar(120) | Nao | Usado no envio do relatorio de quitacao |
| `telefone` | varchar(30) | Nao | Telefone de contato |
| `cidade` | varchar(80) | Nao | Cidade |
| `uf` | char(2) | Nao | UF |

Objetos:

- PK: `pk_clientes`
- Sequence: `gen_clientes_id`
- Trigger: `bi_clientes_id`

### produtos

Cadastro de produtos vendidos.

| Campo | Tipo | Obrigatorio | Observacao |
| --- | --- | --- | --- |
| `id_produto` | integer | Sim | Chave primaria |
| `descricao` | varchar(120) | Sim | Descricao comercial |
| `preco_venda` | numeric(18,2) | Sim | Valor unitario |
| `ativo` | char(1) | Sim | `S` ou `N` |

Objetos:

- PK: `pk_produtos`
- Sequence: `gen_produtos_id`
- Trigger: `bi_produtos_id`

### pedidos_venda

Cabecalho do pedido.

| Campo | Tipo | Obrigatorio | Observacao |
| --- | --- | --- | --- |
| `id_pedido` | integer | Sim | Chave primaria |
| `id_cliente` | integer | Sim | Codigo do cliente |
| `nome_cliente` | varchar(120) | Sim | Nome gravado no momento da venda |
| `data_emissao` | timestamp | Sim | Data de emissao |
| `valor_total` | numeric(18,2) | Sim | Soma dos itens |
| `status` | varchar(30) | Sim | `DIGITACAO`, `CONFIRMADO`, `CANCELADO` |

Objetos:

- PK: `pk_pedidos_venda`
- Sequence: `gen_pedidos_venda_id`
- Trigger: `bi_pedidos_venda_id`

### pedidos_venda_itens

Itens do pedido.

| Campo | Tipo | Obrigatorio | Observacao |
| --- | --- | --- | --- |
| `id_pedido` | integer | Sim | FK para `pedidos_venda` |
| `sequencia` | integer | Sim | Sequencia do item no pedido |
| `id_produto` | integer | Sim | Codigo do produto |
| `descricao_produto` | varchar(120) | Sim | Descricao gravada no momento da venda |
| `quantidade` | numeric(18,4) | Sim | Quantidade vendida |
| `valor_unitario` | numeric(18,2) | Sim | Valor unitario |
| `valor_total` | numeric(18,2) | Sim | Quantidade x valor unitario |

Objetos:

- PK: `pk_pedidos_venda_itens`
- FK: `fk_pedidos_venda_itens_pedido`

### config_email_pedido

Configuracao SMTP do remetente usado no envio automatico do relatorio.

| Campo | Tipo | Obrigatorio | Observacao |
| --- | --- | --- | --- |
| `id_config` | integer | Sim | Chave primaria, atualmente registro unico `1` |
| `host` | varchar(120) | Sim | Servidor SMTP |
| `porta` | integer | Sim | Porta SMTP |
| `usuario` | varchar(120) | Sim | Usuario SMTP |
| `senha` | varchar(200) | Sim | Senha SMTP ou senha de aplicativo |
| `email_remetente` | varchar(120) | Sim | E-mail do remetente |
| `nome_remetente` | varchar(120) | Sim | Nome exibido no remetente |
| `usar_tls` | char(1) | Sim | `E` STARTTLS, `I` SSL/TLS implicito, `N` sem TLS |
| `data_atualizacao` | timestamp | Nao | Ultima gravacao |

Objetos:

- PK: `pk_config_email_pedido`

### emails_quitacao

Controle de envio de e-mails apos quitacao financeira.

| Campo | Tipo | Obrigatorio | Observacao |
| --- | --- | --- | --- |
| `id_email` | integer | Sim | Chave primaria |
| `id_conta_receber` | integer | Nao | Conta de origem no Financeiro |
| `id_pedido` | integer | Sim | Pedido de venda |
| `id_cliente` | integer | Sim | Cliente |
| `destinatario` | varchar(120) | Nao | E-mail de destino |
| `assunto` | varchar(200) | Nao | Assunto enviado |
| `arquivo_pdf` | varchar(500) | Nao | Caminho do PDF gerado |
| `status` | varchar(20) | Sim | `PENDENTE`, `ENVIADO`, `ERRO` |
| `tentativas` | integer | Sim | Numero de tentativas |
| `mensagem_erro` | varchar(500) | Nao | Ultimo erro |
| `data_criacao` | timestamp | Sim | Criacao do registro |
| `data_envio` | timestamp | Nao | Data do envio com sucesso |

Objetos:

- PK: `pk_emails_quitacao`
- Sequence: `gen_emails_quitacao_id`
- Trigger: `bi_emails_quitacao_id`

## ERP Financeiro

### contas_receber

Tabela principal do financeiro.

| Campo | Tipo | Obrigatorio | Observacao |
| --- | --- | --- | --- |
| `id_conta_receber` | integer | Sim | Chave primaria |
| `origem` | varchar(30) | Sim | Atualmente `VENDA` |
| `id_origem` | integer | Sim | Codigo do pedido no ERP Vendas |
| `id_cliente` | integer | Sim | Codigo do cliente |
| `nome_cliente` | varchar(120) | Sim | Nome do cliente |
| `data_emissao` | timestamp | Sim | Data de emissao da venda |
| `data_vencimento` | timestamp | Sim | Data de vencimento financeira |
| `valor` | numeric(18,2) | Sim | Valor da conta |
| `status` | varchar(30) | Sim | `ABERTA`, `RECEBIDA`, `CANCELADA` |

Objetos:

- PK: `pk_contas_receber`
- Sequence: `gen_contas_receber_id`
- Unique index: `uk_contas_receber_origem` em `origem, id_origem`

Regra importante:

- O indice unico evita duplicidade de conta para a mesma venda.

## Tabela compartilhada de seguranca

Cada banco possui sua propria tabela `usuarios`. A regra e compartilhada pelo projeto `Shared`, mas os usuarios sao independentes por ERP.

### usuarios

| Campo | Tipo | Obrigatorio | Observacao |
| --- | --- | --- | --- |
| `id_usuario` | integer | Sim | Chave primaria |
| `nome_usuario` | varchar(120) | Sim | Login |
| `senha_hash` | varchar(128) | Sim | Hash PBKDF2/SHA1 |
| `senha_salt` | varchar(64) | Sim | Salt da senha |
| `otp_secret` | varchar(64) | Sim | Chave TOTP Base32 |
| `administrador` | char(1) | Sim | `S` ou `N` |
| `bloqueado` | char(1) | Sim | `S` ou `N` |
| `tentativas_invalidas` | integer | Sim | Contador de falhas |
| `ultimo_login` | timestamp | Nao | Atualizado no login valido |
| `criado_em` | timestamp | Sim | Criacao do usuario |

Objetos:

- PK: `pk_usuarios`
- Sequence: `gen_usuarios_id`
- Trigger: `bi_usuarios_id`
- Unique index: `uk_usuarios_nome` calculado por `upper(nome_usuario)`

Regras:

- Login exige usuario, senha e codigo TOTP.
- Bloqueio apos 3 tentativas invalidas.
- Desbloqueio feito por administrador.
- O primeiro administrador e criado automaticamente pela aplicacao quando nao existe nenhum usuario.

## Relacao com o codigo

As classes que garantem a estrutura em tempo de execucao sao:

- `TVendasDatabaseSchema`, no ERP Vendas.
- `TFinanceiroDatabaseSchema`, no ERP Financeiro.
- `TAuthService.EnsureSecurity`, no projeto `Shared`.

Os scripts foram mantidos alinhados com essas classes para permitir criacao manual dos bancos antes da primeira execucao.
