unit Financeiro.Infrastructure.Persistence.DatabaseSchema;

interface

uses
  FireDAC.Comp.Client;

type
  TFinanceiroDatabaseSchema = class
  private
    class function ObjectExists(const AConnection: TFDConnection;
      const ASQL, AName: string): Boolean; static;
    class procedure EnsureContasReceber(const AConnection: TFDConnection); static;
  public
    class procedure EnsureCreated; static;
  end;

implementation

uses
  System.SysUtils,
  Financeiro.Infrastructure.Persistence.ConnectionManager;

class function TFinanceiroDatabaseSchema.ObjectExists(
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

class procedure TFinanceiroDatabaseSchema.EnsureContasReceber(
  const AConnection: TFDConnection);
begin
  if not ObjectExists(
    AConnection,
    'select count(*) ' +
    'from rdb$relations ' +
    'where rdb$relation_name = :name ' +
    'and coalesce(rdb$system_flag, 0) = 0',
    'CONTAS_RECEBER') then
  begin
    AConnection.ExecSQL(
      'create table contas_receber (' +
      '  id_conta_receber integer not null, ' +
      '  origem varchar(30) not null, ' +
      '  id_origem integer not null, ' +
      '  id_cliente integer not null, ' +
      '  nome_cliente varchar(120) not null, ' +
      '  data_emissao timestamp not null, ' +
      '  data_vencimento timestamp not null, ' +
      '  valor numeric(18, 2) not null, ' +
      '  status varchar(30) not null, ' +
      '  constraint pk_contas_receber primary key (id_conta_receber)' +
      ')');
  end;

  if not ObjectExists(
    AConnection,
    'select count(*) from rdb$generators where rdb$generator_name = :name',
    'GEN_CONTAS_RECEBER_ID') then
  begin
    AConnection.ExecSQL('create sequence gen_contas_receber_id');
  end;

  if not ObjectExists(
    AConnection,
    'select count(*) from rdb$indices where rdb$index_name = :name',
    'UK_CONTAS_RECEBER_ORIGEM') then
  begin
    AConnection.ExecSQL(
      'create unique index uk_contas_receber_origem ' +
      'on contas_receber (origem, id_origem)');
  end;
end;

class procedure TFinanceiroDatabaseSchema.EnsureCreated;
begin
  EnsureContasReceber(TFinanceiroConexao.Conexao);
end;

end.
