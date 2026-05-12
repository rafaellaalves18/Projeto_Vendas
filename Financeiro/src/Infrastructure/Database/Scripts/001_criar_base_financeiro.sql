-- Script Firebird 3.0 para a base inicial do ERP Financeiro.
-- A aplicacao tambem garante estas tabelas em tempo de execucao.

create table contas_receber (
  id_conta_receber integer not null,
  origem varchar(30) not null,
  id_origem integer not null,
  id_cliente integer not null,
  nome_cliente varchar(120) not null,
  data_emissao timestamp not null,
  data_vencimento timestamp not null,
  valor numeric(18, 2) not null,
  status varchar(30) not null,
  constraint pk_contas_receber primary key (id_conta_receber)
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

create sequence gen_contas_receber_id;

create sequence gen_usuarios_id;

set term ^ ;

create trigger bi_usuarios_id for usuarios
active before insert position 0
as
begin
  if (new.id_usuario is null) then
    new.id_usuario = next value for gen_usuarios_id;
end^

set term ; ^

create unique index uk_contas_receber_origem
  on contas_receber (origem, id_origem);

create unique index uk_usuarios_nome on usuarios computed by (upper(nome_usuario));

commit;
