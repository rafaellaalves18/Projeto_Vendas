-- Script Firebird 3.0 para a base inicial do ERP Vendas.
-- A aplicacao tambem garante estas tabelas em tempo de execucao.

create table clientes (
  id_cliente integer not null,
  nome varchar(120) not null,
  documento varchar(20),
  email varchar(120),
  telefone varchar(30),
  cidade varchar(80),
  uf char(2),
  constraint pk_clientes primary key (id_cliente)
);

create sequence gen_clientes_id;

set term ^ ;

create trigger bi_clientes_id for clientes
active before insert position 0
as
begin
  if (new.id_cliente is null) then
    new.id_cliente = next value for gen_clientes_id;
end^

set term ; ^

create table produtos (
  id_produto integer not null,
  descricao varchar(120) not null,
  preco_venda numeric(18, 2) not null,
  ativo char(1) not null,
  constraint pk_produtos primary key (id_produto)
);

create sequence gen_produtos_id;

set term ^ ;

create trigger bi_produtos_id for produtos
active before insert position 0
as
begin
  if (new.id_produto is null) then
    new.id_produto = next value for gen_produtos_id;
end^

set term ; ^

create table pedidos_venda (
  id_pedido integer not null,
  id_cliente integer not null,
  nome_cliente varchar(120) not null,
  data_emissao timestamp not null,
  valor_total numeric(18, 2) not null,
  status varchar(30) not null,
  constraint pk_pedidos_venda primary key (id_pedido)
);

create table pedidos_venda_itens (
  id_pedido integer not null,
  sequencia integer not null,
  id_produto integer not null,
  descricao_produto varchar(120) not null,
  quantidade numeric(18, 4) not null,
  valor_unitario numeric(18, 2) not null,
  valor_total numeric(18, 2) not null,
  constraint pk_pedidos_venda_itens primary key (id_pedido, sequencia),
  constraint fk_pedidos_venda_itens_pedido foreign key (id_pedido)
    references pedidos_venda (id_pedido)
);

create table config_email_pedido (
  id_config integer not null,
  host varchar(120) not null,
  porta integer not null,
  usuario varchar(120) not null,
  senha varchar(200) not null,
  email_remetente varchar(120) not null,
  nome_remetente varchar(120) not null,
  usar_tls char(1) not null,
  data_atualizacao timestamp,
  constraint pk_config_email_pedido primary key (id_config)
);

create table emails_quitacao (
  id_email integer not null,
  id_conta_receber integer,
  id_pedido integer not null,
  id_cliente integer not null,
  destinatario varchar(120),
  assunto varchar(200),
  arquivo_pdf varchar(500),
  status varchar(20) not null,
  tentativas integer not null,
  mensagem_erro varchar(500),
  data_criacao timestamp not null,
  data_envio timestamp,
  constraint pk_emails_quitacao primary key (id_email)
);

create table usuarios (
  id_usuario integer not null,
  nome_usuario varchar(120) not null,
  senha_hash varchar(128) not null,
  senha_salt varchar(64) not null,
  otp_secret varchar(64) not null,
  administrador char(1) default 'N' not null,
  bloqueado char(1) default 'N' not null,
  tentativas_invalidas integer default 0 not null,
  ultimo_login timestamp,
  criado_em timestamp default current_timestamp not null,
  constraint pk_usuarios primary key (id_usuario)
);

create sequence gen_emails_quitacao_id;

create sequence gen_pedidos_venda_id;

create sequence gen_usuarios_id;

set term ^ ;

create trigger bi_pedidos_venda_id for pedidos_venda
active before insert position 0
as
begin
  if (new.id_pedido is null) then
    new.id_pedido = next value for gen_pedidos_venda_id;
end^

create trigger bi_emails_quitacao_id for emails_quitacao
active before insert position 0
as
begin
  if (new.id_email is null) then
    new.id_email = next value for gen_emails_quitacao_id;
end^

create trigger bi_usuarios_id for usuarios
active before insert position 0
as
begin
  if (new.id_usuario is null) then
    new.id_usuario = next value for gen_usuarios_id;
end^

set term ; ^

create unique index uk_usuarios_nome on usuarios computed by (upper(nome_usuario));

commit;
