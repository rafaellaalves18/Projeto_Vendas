unit Vendas.Infrastructure.Persistence.DatabaseSchema;

interface

uses
  FireDAC.Comp.Client;

type
  TVendasDatabaseSchema = class
  private
    class function ObjectExists(const AConnection: TFDConnection;
      const ASQL, AName: string): Boolean; static;
    class procedure EnsureClientes(const AConnection: TFDConnection); static;
    class procedure EnsureConfigEmailPedido(const AConnection: TFDConnection); static;
    class procedure EnsureEmailQuitacao(const AConnection: TFDConnection); static;
    class procedure EnsureProdutos(const AConnection: TFDConnection); static;
    class procedure EnsurePedidos(const AConnection: TFDConnection); static;
  public
    class procedure EnsureCreated; static;
  end;

implementation

uses
  System.SysUtils,
  Vendas.Infrastructure.Persistence.Conexao;

{ TVendasDatabaseSchema }

class function TVendasDatabaseSchema.ObjectExists(
  const AConnection: TFDConnection; const ASQL, AName: string): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := AConnection;
    Query.SQL.Text := ASQL;
    Query.ParamByName('name').AsString := UpperCase(AName);
    Query.Open;
    Result := Query.Fields[0].AsInteger > 0;
  finally
    Query.Free;
  end;
end;

class procedure TVendasDatabaseSchema.EnsureClientes(
  const AConnection: TFDConnection);
begin
  if not ObjectExists(
    AConnection,
    'select count(*) ' +
    'from rdb$relations ' +
    'where rdb$relation_name = :name ' +
    'and coalesce(rdb$system_flag, 0) = 0',
    'CLIENTES') then
  begin
    AConnection.ExecSQL(
      'create table clientes (' +
      '  id_cliente integer not null, ' +
      '  nome varchar(120) not null, ' +
      '  documento varchar(20), ' +
      '  email varchar(120), ' +
      '  telefone varchar(30), ' +
      '  cidade varchar(80), ' +
      '  uf char(2), ' +
      '  constraint pk_clientes primary key (id_cliente)' +
      ')');
  end;

  if not ObjectExists(
    AConnection,
    'select count(*) from rdb$generators where rdb$generator_name = :name',
    'GEN_CLIENTES_ID') then
  begin
    AConnection.ExecSQL('create sequence gen_clientes_id');
  end;

  if not ObjectExists(
    AConnection,
    'select count(*) from rdb$triggers where rdb$trigger_name = :name',
    'BI_CLIENTES_ID') then
  begin
    AConnection.ExecSQL(
      'create trigger bi_clientes_id for clientes ' +
      'active before insert position 0 ' +
      'as ' +
      'begin ' +
      '  if (new.id_cliente is null) then ' +
      '    new.id_cliente = next value for gen_clientes_id; ' +
      'end');
  end;
end;

class procedure TVendasDatabaseSchema.EnsureProdutos(
  const AConnection: TFDConnection);
begin
  if not ObjectExists(
    AConnection,
    'select count(*) ' +
    'from rdb$relations ' +
    'where rdb$relation_name = :name ' +
    'and coalesce(rdb$system_flag, 0) = 0',
    'PRODUTOS') then
  begin
    AConnection.ExecSQL(
      'create table produtos (' +
      '  id_produto integer not null, ' +
      '  descricao varchar(120) not null, ' +
      '  preco_venda numeric(18, 2) not null, ' +
      '  ativo char(1) not null, ' +
      '  constraint pk_produtos primary key (id_produto)' +
      ')');
  end;

  if not ObjectExists(
    AConnection,
    'select count(*) from rdb$generators where rdb$generator_name = :name',
    'GEN_PRODUTOS_ID') then
  begin
    AConnection.ExecSQL('create sequence gen_produtos_id');
  end;

  if not ObjectExists(
    AConnection,
    'select count(*) from rdb$triggers where rdb$trigger_name = :name',
    'BI_PRODUTOS_ID') then
  begin
    AConnection.ExecSQL(
      'create trigger bi_produtos_id for produtos ' +
      'active before insert position 0 ' +
      'as ' +
      'begin ' +
      '  if (new.id_produto is null) then ' +
      '    new.id_produto = next value for gen_produtos_id; ' +
      'end');
  end;
end;

class procedure TVendasDatabaseSchema.EnsurePedidos(
  const AConnection: TFDConnection);
begin
  if not ObjectExists(
    AConnection,
    'select count(*) ' +
    'from rdb$relations ' +
    'where rdb$relation_name = :name ' +
    'and coalesce(rdb$system_flag, 0) = 0',
    'PEDIDOS_VENDA') then
  begin
    AConnection.ExecSQL(
      'create table pedidos_venda (' +
      '  id_pedido integer not null, ' +
      '  id_cliente integer not null, ' +
      '  nome_cliente varchar(120) not null, ' +
      '  data_emissao timestamp not null, ' +
      '  valor_total numeric(18, 2) not null, ' +
      '  status varchar(30) not null, ' +
      '  constraint pk_pedidos_venda primary key (id_pedido)' +
      ')');
  end;

  if not ObjectExists(
    AConnection,
    'select count(*) ' +
    'from rdb$relations ' +
    'where rdb$relation_name = :name ' +
    'and coalesce(rdb$system_flag, 0) = 0',
    'PEDIDOS_VENDA_ITENS') then
  begin
    AConnection.ExecSQL(
      'create table pedidos_venda_itens (' +
      '  id_pedido integer not null, ' +
      '  sequencia integer not null, ' +
      '  id_produto integer not null, ' +
      '  descricao_produto varchar(120) not null, ' +
      '  quantidade numeric(18, 4) not null, ' +
      '  valor_unitario numeric(18, 2) not null, ' +
      '  valor_total numeric(18, 2) not null, ' +
      '  constraint pk_pedidos_venda_itens primary key (id_pedido, sequencia), ' +
      '  constraint fk_pedidos_venda_itens_pedido foreign key (id_pedido) ' +
      '    references pedidos_venda (id_pedido)' +
      ')');
  end;

  if not ObjectExists(
    AConnection,
    'select count(*) from rdb$generators where rdb$generator_name = :name',
    'GEN_PEDIDOS_VENDA_ID') then
  begin
    AConnection.ExecSQL('create sequence gen_pedidos_venda_id');
  end;

  if not ObjectExists(
    AConnection,
    'select count(*) from rdb$triggers where rdb$trigger_name = :name',
    'BI_PEDIDOS_VENDA_ID') then
  begin
    AConnection.ExecSQL(
      'create trigger bi_pedidos_venda_id for pedidos_venda ' +
      'active before insert position 0 ' +
      'as ' +
      'begin ' +
      '  if (new.id_pedido is null) then ' +
      '    new.id_pedido = next value for gen_pedidos_venda_id; ' +
      'end');
  end;
end;

class procedure TVendasDatabaseSchema.EnsureEmailQuitacao(
  const AConnection: TFDConnection);
begin
  if not ObjectExists(
    AConnection,
    'select count(*) ' +
    'from rdb$relations ' +
    'where rdb$relation_name = :name ' +
    'and coalesce(rdb$system_flag, 0) = 0',
    'EMAILS_QUITACAO') then
  begin
    AConnection.ExecSQL(
      'create table emails_quitacao (' +
      '  id_email integer not null, ' +
      '  id_conta_receber integer, ' +
      '  id_pedido integer not null, ' +
      '  id_cliente integer not null, ' +
      '  destinatario varchar(120), ' +
      '  assunto varchar(200), ' +
      '  arquivo_pdf varchar(500), ' +
      '  status varchar(20) not null, ' +
      '  tentativas integer not null, ' +
      '  mensagem_erro varchar(500), ' +
      '  data_criacao timestamp not null, ' +
      '  data_envio timestamp, ' +
      '  constraint pk_emails_quitacao primary key (id_email)' +
      ')');
  end;

  if not ObjectExists(
    AConnection,
    'select count(*) from rdb$generators where rdb$generator_name = :name',
    'GEN_EMAILS_QUITACAO_ID') then
  begin
    AConnection.ExecSQL('create sequence gen_emails_quitacao_id');
  end;

  if not ObjectExists(
    AConnection,
    'select count(*) from rdb$triggers where rdb$trigger_name = :name',
    'BI_EMAILS_QUITACAO_ID') then
  begin
    AConnection.ExecSQL(
      'create trigger bi_emails_quitacao_id for emails_quitacao ' +
      'active before insert position 0 ' +
      'as ' +
      'begin ' +
      '  if (new.id_email is null) then ' +
      '    new.id_email = next value for gen_emails_quitacao_id; ' +
      'end');
  end;
end;

class procedure TVendasDatabaseSchema.EnsureConfigEmailPedido(
  const AConnection: TFDConnection);
begin
  if not ObjectExists(
    AConnection,
    'select count(*) ' +
    'from rdb$relations ' +
    'where rdb$relation_name = :name ' +
    'and coalesce(rdb$system_flag, 0) = 0',
    'CONFIG_EMAIL_PEDIDO') then
  begin
    AConnection.ExecSQL(
      'create table config_email_pedido (' +
      '  id_config integer not null, ' +
      '  host varchar(120) not null, ' +
      '  porta integer not null, ' +
      '  usuario varchar(120) not null, ' +
      '  senha varchar(200) not null, ' +
      '  email_remetente varchar(120) not null, ' +
      '  nome_remetente varchar(120) not null, ' +
      '  usar_tls char(1) not null, ' +
      '  data_atualizacao timestamp, ' +
      '  constraint pk_config_email_pedido primary key (id_config)' +
      ')');
  end;
end;

class procedure TVendasDatabaseSchema.EnsureCreated;
var
  Connection: TFDConnection;
begin
  Connection := TVendasConexao.Conexao;
  EnsureClientes(Connection);
  EnsureProdutos(Connection);
  EnsurePedidos(Connection);
  EnsureEmailQuitacao(Connection);
  EnsureConfigEmailPedido(Connection);
end;

end.
