# Projeto Vendas

Base Delphi VCL para dois ERPs separados:

- ERP Vendas: cadastro de clientes, produtos e pedidos de venda.
- ERP Financeiro: contas a receber geradas a partir das vendas via RabbitMQ.

Abra `ProjetoVendas.groupproj` no Delphi para carregar os dois projetos.

## Organizacao

- `Vendas`: executavel do ERP de Vendas.
- `Financeiro`: executavel do ERP Financeiro.
- `Shared`: contratos e tipos compartilhados entre os modulos.
- `docs`: decisoes de arquitetura e integracao.
- `data`: bancos Firebird locais.

Os bancos sao separados:

- Vendas: `data\ERP_VENDAS.FDB`
- Financeiro: `data\ERP_FINANCEIRO.FDB`

Cada modulo segue quatro camadas principais:

- `src\Presentation`: formularios e eventos de tela.
- `src\Application`: servicos de aplicacao e interfaces.
- `src\Infrastructure`: conexao, repositorios, integracoes e scripts SQL.
- `src\Core`: entidades, tipos centrais e excecoes.

## Documentacao

- [Arquitetura geral](docs/arquitetura.md)
- [ERP Vendas](docs/erp_vendas.md)
- [ERP Financeiro](docs/erp_financeiro.md)
- [Banco de dados](docs/banco_de_dados.md)
- [Revisao tecnica](docs/revisao_tecnica.md)
- [Conexao Firebird](docs/conexao_firebird.md)
