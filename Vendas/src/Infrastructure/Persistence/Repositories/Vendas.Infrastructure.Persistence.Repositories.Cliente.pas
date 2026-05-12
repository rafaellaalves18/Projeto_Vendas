unit Vendas.Infrastructure.Persistence.Repositories.Cliente;

interface

uses
  FireDAC.Comp.Client,
  Vendas.Core.Entities.Cliente,
  Vendas.Application.Interfaces.Repositories;

type
  TClienteRepository = class(TInterfacedObject, IClienteRepository)
  private
    FConnection: TFDConnection;
  public
    constructor Create;

    function ObterPorId(const AId: Integer): TCliente;
    function ProximoCodigo: Integer;
    procedure Excluir(const AId: Integer);
    procedure Salvar(const ACliente: TCliente);
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  Vendas.Infrastructure.Persistence.Conexao;

{ TClienteRepository }

constructor TClienteRepository.Create;
begin
  inherited Create;
  FConnection := TVendasConexao.Conexao;
end;

procedure TClienteRepository.Excluir(const AId: Integer);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'delete from clientes ' +
      'where id_cliente = :id_cliente';
    Query.ParamByName('id_cliente').AsInteger := AId;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

function TClienteRepository.ObterPorId(const AId: Integer): TCliente;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'select id_cliente, nome, documento, email, telefone, cidade, uf ' +
      'from clientes ' +
      'where id_cliente = :id_cliente';
    Query.ParamByName('id_cliente').AsInteger := AId;
    Query.Open;

    if not Query.IsEmpty then
    begin
      Result := TCliente.Create;
      Result.Id := Query.FieldByName('id_cliente').AsInteger;
      Result.Nome := Query.FieldByName('nome').AsString;
      Result.Documento := Query.FieldByName('documento').AsString;
      Result.Email := Query.FieldByName('email').AsString;
      Result.Telefone := Query.FieldByName('telefone').AsString;
      Result.Cidade := Query.FieldByName('cidade').AsString;
      Result.UF := Query.FieldByName('uf').AsString;
    end;
  finally
    Query.Free;
  end;
end;

function TClienteRepository.ProximoCodigo: Integer;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'select next value for gen_clientes_id as proximo_codigo ' +
      'from rdb$database';
    Query.Open;
    Result := Query.FieldByName('proximo_codigo').AsInteger;
  finally
    Query.Free;
  end;
end;

procedure TClienteRepository.Salvar(const ACliente: TCliente);
var
  Query: TFDQuery;
begin
  if ACliente = nil then
    raise EArgumentException.Create('Informe o cliente para salvar.');

  ACliente.Validar;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'update or insert into clientes (' +
      '  id_cliente, nome, documento, email, telefone, cidade, uf' +
      ') values (' +
      '  :id_cliente, :nome, :documento, :email, :telefone, :cidade, :uf' +
      ') matching (id_cliente)';

    Query.ParamByName('id_cliente').AsInteger := ACliente.Id;
    Query.ParamByName('nome').AsString := ACliente.Nome;
    Query.ParamByName('documento').AsString := ACliente.Documento;
    Query.ParamByName('email').AsString := ACliente.Email;
    Query.ParamByName('telefone').AsString := ACliente.Telefone;
    Query.ParamByName('cidade').AsString := ACliente.Cidade;
    Query.ParamByName('uf').AsString := ACliente.UF;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

end.
