# Clean Architecture

A solucao foi separada em dois executaveis VCL independentes, pois o ERP Financeiro sera uma aplicacao separada do ERP Vendas.

Cada modulo segue quatro camadas:

- `src\Presentation`: formularios VCL e eventos de tela.
- `src\Application`: servicos de aplicacao e interfaces/portas.
- `src\Infrastructure`: conexao, repositorios, integracoes externas e scripts SQL de versao.
- `src\Core`: entidades, tipos centrais e excecoes.

## Modulos

ERP Vendas:
- Cadastro de cliente.
- Cadastro de produto.
- Pedido de venda.
- Gateway de integracao com o Financeiro.
- Envio automatico de relatorio por e-mail apos quitacao financeira.
- Relatorios de pedido e periodo.

ERP Financeiro:
- Contas a receber.
- Entrada de vendas confirmadas pelo modulo de Vendas.
- Regras financeiras isoladas do cadastro comercial.
- Baixa financeira com retorno ao ERP Vendas.
- Relatorio financeiro e dashboard de vendas.

Shared:
- DTOs/contratos de integracao.
- Tipos comuns sem dependencia de tela, FireDAC ou banco.
- Autenticacao compartilhada com senha, TOTP e bloqueio por tentativas.

## Fluxo previsto

1. Usuario confirma uma venda no ERP Vendas.
2. O servico de pedido monta o contrato `TVendaFinanceiroDTO`.
3. O gateway do Vendas publica esse contrato no RabbitMQ.
4. O Financeiro consome a fila, gera a conta a receber e grava no banco `ERP_FINANCEIRO.FDB`.

## RabbitMQ

A integracao atual usa a API HTTP de gerenciamento do RabbitMQ, sem biblioteca AMQP externa no Delphi.

Configuracao padrao:

- Host: `localhost`
- Porta HTTP: `15672`
- Usuario: `guest`
- Senha: `guest`
- Exchange: `erp.financeiro`
- Queue: `erp.financeiro.venda_confirmada`
- Routing key: `venda.confirmada`

Para ambiente local, habilite o plugin de gerenciamento:

`rabbitmq-plugins enable rabbitmq_management`

## Documentos detalhados

- `docs\erp_vendas.md`: arquitetura, rotinas e regras do ERP Vendas.
- `docs\erp_financeiro.md`: arquitetura, rotinas e regras do ERP Financeiro.
- `docs\banco_de_dados.md`: bancos, tabelas, campos, scripts e ordem de execucao.
- `docs\revisao_tecnica.md`: ajustes de revisao, decisoes e pontos de evolucao.
