# Conexao Firebird 3.0

O ERP Vendas usa FireDAC com o driver `FB`.

Configuracao padrao:

- Servidor: `localhost`
- Porta: `3050`
- Usuario: `SYSDBA`
- Senha: `masterkey`
- Banco: `C:\Projeto_Vendas\data\ERP_VENDAS.FDB`
- Charset: `UTF8`

Para criar o banco, execute:

`Vendas\src\Infrastructure\Database\Scripts\firebird_3_0\000_criar_database.sql`

Para criar a estrutura inicial, execute:

`Vendas\src\Infrastructure\Database\Scripts\firebird_3_0\001_criar_base_vendas.sql`

A aplicacao cria automaticamente as tabelas `CLIENTES`, `PRODUTOS`, `PEDIDOS_VENDA` e `PEDIDOS_VENDA_ITENS`, junto com sequences/triggers necessarias, caso ainda nao existam.

## ERP Financeiro

Configuracao padrao:

- Servidor: `localhost`
- Porta: `3050`
- Usuario: `SYSDBA`
- Senha: `masterkey`
- Banco: `C:\Projeto_Vendas\data\ERP_FINANCEIRO.FDB`
- Charset: `UTF8`

Para criar o banco financeiro, execute:

`Financeiro\src\Infrastructure\Database\Scripts\000_criar_database.sql`

Para criar a estrutura inicial, execute:

`Financeiro\src\Infrastructure\Database\Scripts\001_criar_base_financeiro.sql`

O ERP Financeiro tambem garante automaticamente a tabela `CONTAS_RECEBER`, a sequence `GEN_CONTAS_RECEBER_ID` e o indice unico de origem ao iniciar.

Observacao: se compilar Win32, o `fbclient.dll` disponivel tambem precisa ser 32 bits. Se compilar Win64, use o client 64 bits.
