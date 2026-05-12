-- Execute este script no ISQL/IBExpert/FlameRobin, ajustando o caminho se necessario.
-- O caminho abaixo acompanha a configuracao padrao do ERP Financeiro.

create database 'localhost:C:\Projeto_Vendas\data\ERP_FINANCEIRO.FDB'
user 'SYSDBA'
password 'masterkey'
default character set UTF8;

commit;
