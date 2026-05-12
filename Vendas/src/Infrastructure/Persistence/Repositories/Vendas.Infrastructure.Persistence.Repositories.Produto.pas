unit Vendas.Infrastructure.Persistence.Repositories.Produto;

interface

uses
  FireDAC.Comp.Client,
  Vendas.Core.Entities.Produto,
  Vendas.Application.Interfaces.Repositories;

type
  TProdutoRepository = class(TInterfacedObject, IProdutoRepository)
  private
    FConnection: TFDConnection;

    function BoolToDB(const AValue: Boolean): string;
    function DBToBool(const AValue: string): Boolean;
  public
    constructor Create;

    function ObterPorId(const AId: Integer): TProduto;
    function ProximoCodigo: Integer;
    procedure Excluir(const AId: Integer);
    procedure Salvar(const AProduto: TProduto);
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  Vendas.Infrastructure.Persistence.Conexao;

{ TProdutoRepository }

constructor TProdutoRepository.Create;
begin
  inherited Create;
  FConnection := TVendasConexao.Conexao;
end;

function TProdutoRepository.BoolToDB(const AValue: Boolean): string;
begin
  if AValue then
    Result := 'S'
  else
    Result := 'N';
end;

function TProdutoRepository.DBToBool(const AValue: string): Boolean;
begin
  Result := SameText(Trim(AValue), 'S');
end;

procedure TProdutoRepository.Excluir(const AId: Integer);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'delete from produtos ' +
      'where id_produto = :id_produto';
    Query.ParamByName('id_produto').AsInteger := AId;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

function TProdutoRepository.ObterPorId(const AId: Integer): TProduto;
var
  Query: TFDQuery;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'select id_produto, descricao, preco_venda, ativo ' +
      'from produtos ' +
      'where id_produto = :id_produto';
    Query.ParamByName('id_produto').AsInteger := AId;
    Query.Open;

    if not Query.IsEmpty then
    begin
      Result := TProduto.Create;
      Result.Id := Query.FieldByName('id_produto').AsInteger;
      Result.Descricao := Query.FieldByName('descricao').AsString;
      Result.PrecoVenda := Query.FieldByName('preco_venda').AsCurrency;
      Result.Ativo := DBToBool(Query.FieldByName('ativo').AsString);
    end;
  finally
    Query.Free;
  end;
end;

function TProdutoRepository.ProximoCodigo: Integer;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'select next value for gen_produtos_id as proximo_codigo ' +
      'from rdb$database';
    Query.Open;
    Result := Query.FieldByName('proximo_codigo').AsInteger;
  finally
    Query.Free;
  end;
end;

procedure TProdutoRepository.Salvar(const AProduto: TProduto);
var
  Query: TFDQuery;
begin
  if AProduto = nil then
    raise EArgumentException.Create('Informe o produto para salvar.');

  AProduto.Validar;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'update or insert into produtos (' +
      '  id_produto, descricao, preco_venda, ativo' +
      ') values (' +
      '  :id_produto, :descricao, :preco_venda, :ativo' +
      ') matching (id_produto)';

    Query.ParamByName('id_produto').AsInteger := AProduto.Id;
    Query.ParamByName('descricao').AsString := AProduto.Descricao;
    Query.ParamByName('preco_venda').AsCurrency := AProduto.PrecoVenda;
    Query.ParamByName('ativo').AsString := BoolToDB(AProduto.Ativo);
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

end.
