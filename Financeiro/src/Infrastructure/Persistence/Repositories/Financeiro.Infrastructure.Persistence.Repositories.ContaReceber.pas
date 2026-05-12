unit Financeiro.Infrastructure.Persistence.Repositories.ContaReceber;

interface

uses
  System.Generics.Collections,
  FireDAC.Comp.Client,
  Shared.Core.Types,
  Financeiro.Core.Entities.ContaReceber,
  Financeiro.Application.Interfaces.Repositories;

type
  TContaReceberRepository = class(TInterfacedObject, IContaReceberRepository)
  private
    FConnection: TFDConnection;

    function DBToOrigem(const AValue: string): TOrigemFinanceira;
    function DBToStatus(const AValue: string): TStatusContaReceber;
    function QueryToConta(const AQuery: TFDQuery): TContaReceber;
    function OrigemToDB(const AValue: TOrigemFinanceira): string;
    function ProximoCodigo: Integer;
    function StatusToDB(const AValue: TStatusContaReceber): string;
  public
    constructor Create;

    function ObterPorId(const AId: Integer): TContaReceber;
    function ObterPorOrigem(const AOrigem: TOrigemFinanceira;
      const AIdOrigem: Integer): TContaReceber;
    function PesquisarPorCliente(const AIdCliente: Integer;
      const ANomeCliente: string; const AApenasAbertas: Boolean): TObjectList<TContaReceber>;
    procedure Salvar(const AConta: TContaReceber);
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  Financeiro.Infrastructure.Persistence.ConnectionManager;

constructor TContaReceberRepository.Create;
begin
  inherited Create;
  FConnection := TFinanceiroConexao.Conexao;
end;

function TContaReceberRepository.DBToOrigem(
  const AValue: string): TOrigemFinanceira;
begin
  if SameText(AValue, 'VENDA') then
    Exit(ofVenda);

  raise EConvertError.CreateFmt('Origem financeira invalida: %s.', [AValue]);
end;

function TContaReceberRepository.DBToStatus(
  const AValue: string): TStatusContaReceber;
begin
  if SameText(AValue, 'RECEBIDA') then
    Result := scrRecebida
  else if SameText(AValue, 'CANCELADA') then
    Result := scrCancelada
  else
    Result := scrAberta;
end;

function TContaReceberRepository.OrigemToDB(
  const AValue: TOrigemFinanceira): string;
begin
  case AValue of
    ofVenda:
      Result := 'VENDA';
  else
    raise EConvertError.Create('Origem financeira nao mapeada.');
  end;
end;

function TContaReceberRepository.StatusToDB(
  const AValue: TStatusContaReceber): string;
begin
  case AValue of
    scrRecebida:
      Result := 'RECEBIDA';
    scrCancelada:
      Result := 'CANCELADA';
  else
    Result := 'ABERTA';
  end;
end;

function TContaReceberRepository.QueryToConta(
  const AQuery: TFDQuery): TContaReceber;
begin
  Result := TContaReceber.Create;
  try
    Result.Id := AQuery.FieldByName('id_conta_receber').AsInteger;
    Result.Origem := DBToOrigem(AQuery.FieldByName('origem').AsString);
    Result.IdOrigem := AQuery.FieldByName('id_origem').AsInteger;
    Result.IdCliente := AQuery.FieldByName('id_cliente').AsInteger;
    Result.NomeCliente := AQuery.FieldByName('nome_cliente').AsString;
    Result.DataEmissao := AQuery.FieldByName('data_emissao').AsDateTime;
    Result.DataVencimento := AQuery.FieldByName('data_vencimento').AsDateTime;
    Result.Valor := AQuery.FieldByName('valor').AsCurrency;
    Result.Status := DBToStatus(AQuery.FieldByName('status').AsString);
  except
    Result.Free;
    raise;
  end;
end;

function TContaReceberRepository.ProximoCodigo: Integer;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'select next value for gen_contas_receber_id as proximo_codigo ' +
      'from rdb$database';
    Query.Open;
    Result := Query.FieldByName('proximo_codigo').AsInteger;
  finally
    Query.Free;
  end;
end;

function TContaReceberRepository.ObterPorId(
  const AId: Integer): TContaReceber;
var
  Query: TFDQuery;
begin
  Result := nil;

  if AId <= 0 then
    Exit;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'select id_conta_receber, origem, id_origem, id_cliente, ' +
      '       nome_cliente, data_emissao, data_vencimento, valor, status ' +
      'from contas_receber ' +
      'where id_conta_receber = :id_conta_receber';
    Query.ParamByName('id_conta_receber').AsInteger := AId;
    Query.Open;

    if Query.IsEmpty then
      Exit;

    Result := QueryToConta(Query);
  finally
    Query.Free;
  end;
end;

function TContaReceberRepository.ObterPorOrigem(
  const AOrigem: TOrigemFinanceira; const AIdOrigem: Integer): TContaReceber;
var
  Query: TFDQuery;
begin
  Result := nil;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'select id_conta_receber, origem, id_origem, id_cliente, ' +
      '       nome_cliente, data_emissao, data_vencimento, valor, status ' +
      'from contas_receber ' +
      'where origem = :origem ' +
      'and id_origem = :id_origem';
    Query.ParamByName('origem').AsString := OrigemToDB(AOrigem);
    Query.ParamByName('id_origem').AsInteger := AIdOrigem;
    Query.Open;

    if Query.IsEmpty then
      Exit;

    Result := QueryToConta(Query);
  finally
    Query.Free;
  end;
end;

function TContaReceberRepository.PesquisarPorCliente(const AIdCliente: Integer;
  const ANomeCliente: string; const AApenasAbertas: Boolean): TObjectList<TContaReceber>;
var
  Query: TFDQuery;
  SQL: string;
begin
  Result := TObjectList<TContaReceber>.Create(True);

  try
    Query := TFDQuery.Create(nil);
    try
      Query.Connection := FConnection;

      SQL :=
        'select id_conta_receber, origem, id_origem, id_cliente, ' +
        '       nome_cliente, data_emissao, data_vencimento, valor, status ' +
        'from contas_receber ' +
        'where 1 = 1 ';

      if AIdCliente > 0 then
        SQL := SQL + 'and id_cliente = :id_cliente ';

      if Trim(ANomeCliente) <> '' then
        SQL := SQL + 'and upper(nome_cliente) like :nome_cliente ';

      if AApenasAbertas then
        SQL := SQL + 'and status = :status ';

      SQL := SQL + 'order by data_vencimento, id_conta_receber';

      Query.SQL.Text := SQL;

      if AIdCliente > 0 then
        Query.ParamByName('id_cliente').AsInteger := AIdCliente;

      if Trim(ANomeCliente) <> '' then
        Query.ParamByName('nome_cliente').AsString :=
          '%' + UpperCase(Trim(ANomeCliente)) + '%';

      if AApenasAbertas then
        Query.ParamByName('status').AsString := StatusToDB(scrAberta);

      Query.Open;
      while not Query.Eof do
      begin
        Result.Add(QueryToConta(Query));
        Query.Next;
      end;
    finally
      Query.Free;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TContaReceberRepository.Salvar(const AConta: TContaReceber);
var
  Query: TFDQuery;
  ContaExistente: TContaReceber;
begin
  if AConta = nil then
    raise EArgumentException.Create('Informe a conta a receber para salvar.');

  AConta.Validar;

  ContaExistente := ObterPorOrigem(AConta.Origem, AConta.IdOrigem);
  try
    if ContaExistente <> nil then
      AConta.Id := ContaExistente.Id
    else if AConta.Id <= 0 then
      AConta.Id := ProximoCodigo;
  finally
    ContaExistente.Free;
  end;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'update or insert into contas_receber (' +
      '  id_conta_receber, origem, id_origem, id_cliente, nome_cliente, ' +
      '  data_emissao, data_vencimento, valor, status' +
      ') values (' +
      '  :id_conta_receber, :origem, :id_origem, :id_cliente, :nome_cliente, ' +
      '  :data_emissao, :data_vencimento, :valor, :status' +
      ') matching (id_conta_receber)';
    Query.ParamByName('id_conta_receber').AsInteger := AConta.Id;
    Query.ParamByName('origem').AsString := OrigemToDB(AConta.Origem);
    Query.ParamByName('id_origem').AsInteger := AConta.IdOrigem;
    Query.ParamByName('id_cliente').AsInteger := AConta.IdCliente;
    Query.ParamByName('nome_cliente').AsString := AConta.NomeCliente;
    Query.ParamByName('data_emissao').AsDateTime := AConta.DataEmissao;
    Query.ParamByName('data_vencimento').AsDateTime := AConta.DataVencimento;
    Query.ParamByName('valor').AsCurrency := AConta.Valor;
    Query.ParamByName('status').AsString := StatusToDB(AConta.Status);
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

end.
