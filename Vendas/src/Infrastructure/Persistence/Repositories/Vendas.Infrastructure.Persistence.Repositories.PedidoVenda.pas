unit Vendas.Infrastructure.Persistence.Repositories.PedidoVenda;

interface

uses
  FireDAC.Comp.Client,
  Shared.Core.Types,
  Vendas.Core.Entities.PedidoVenda,
  Vendas.Application.Interfaces.Repositories;

type
  TPedidoVendaRepository = class(TInterfacedObject, IPedidoVendaRepository)
  private
    FConnection: TFDConnection;

    function DBToStatus(const AValue: string): TStatusPedidoVenda;
    function StatusToDB(const AValue: TStatusPedidoVenda): string;
    procedure InserirItem(const APedidoId, ASequencia: Integer;
      const AItem: TPedidoVendaItem);
  public
    constructor Create;

    function ObterPorId(const AId: Integer): TPedidoVenda;
    function ProximoCodigo: Integer;
    procedure Excluir(const AId: Integer);
    procedure Salvar(const APedido: TPedidoVenda);
  end;

implementation

uses
  System.SysUtils,
  Data.DB,
  Vendas.Infrastructure.Persistence.Conexao;

{ TPedidoVendaRepository }

constructor TPedidoVendaRepository.Create;
begin
  inherited Create;
  FConnection := TVendasConexao.Conexao;
end;

function TPedidoVendaRepository.DBToStatus(
  const AValue: string): TStatusPedidoVenda;
begin
  if SameText(AValue, 'CONFIRMADO') then
    Result := spvConfirmado
  else if SameText(AValue, 'CANCELADO') then
    Result := spvCancelado
  else
    Result := spvDigitacao;
end;

function TPedidoVendaRepository.StatusToDB(
  const AValue: TStatusPedidoVenda): string;
begin
  case AValue of
    spvConfirmado:
      Result := 'CONFIRMADO';
    spvCancelado:
      Result := 'CANCELADO';
  else
    Result := 'DIGITACAO';
  end;
end;

procedure TPedidoVendaRepository.Excluir(const AId: Integer);
var
  Query: TFDQuery;
  StartedTransaction: Boolean;
begin
  StartedTransaction := not FConnection.InTransaction;
  if StartedTransaction then
    FConnection.StartTransaction;

  Query := TFDQuery.Create(nil);
  try
    try
      Query.Connection := FConnection;

      Query.SQL.Text :=
        'delete from pedidos_venda_itens ' +
        'where id_pedido = :id_pedido';
      Query.ParamByName('id_pedido').AsInteger := AId;
      Query.ExecSQL;

      Query.SQL.Text :=
        'delete from pedidos_venda ' +
        'where id_pedido = :id_pedido';
      Query.ParamByName('id_pedido').AsInteger := AId;
      Query.ExecSQL;

      if StartedTransaction then
        FConnection.Commit;
    except
      if StartedTransaction and FConnection.InTransaction then
        FConnection.Rollback;
      raise;
    end;
  finally
    Query.Free;
  end;
end;

procedure TPedidoVendaRepository.InserirItem(
  const APedidoId, ASequencia: Integer; const AItem: TPedidoVendaItem);
var
  Query: TFDQuery;
begin
  AItem.Validar;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'insert into pedidos_venda_itens (' +
      '  id_pedido, sequencia, id_produto, descricao_produto, ' +
      '  quantidade, valor_unitario, valor_total' +
      ') values (' +
      '  :id_pedido, :sequencia, :id_produto, :descricao_produto, ' +
      '  :quantidade, :valor_unitario, :valor_total' +
      ')';
    Query.ParamByName('id_pedido').AsInteger := APedidoId;
    Query.ParamByName('sequencia').AsInteger := ASequencia;
    Query.ParamByName('id_produto').AsInteger := AItem.IdProduto;
    Query.ParamByName('descricao_produto').AsString := AItem.DescricaoProduto;
    Query.ParamByName('quantidade').AsFloat := AItem.Quantidade;
    Query.ParamByName('valor_unitario').AsCurrency := AItem.ValorUnitario;
    Query.ParamByName('valor_total').AsCurrency := AItem.ValorTotal;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

function TPedidoVendaRepository.ObterPorId(const AId: Integer): TPedidoVenda;
var
  Query: TFDQuery;
  Item: TPedidoVendaItem;
  Pedido: TPedidoVenda;
begin
  Result := nil;
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'select id_pedido, id_cliente, nome_cliente, data_emissao, ' +
      '       valor_total, status ' +
      'from pedidos_venda ' +
      'where id_pedido = :id_pedido';
    Query.ParamByName('id_pedido').AsInteger := AId;
    Query.Open;

    if Query.IsEmpty then
      Exit;

    Pedido := TPedidoVenda.Create;
    try
      Pedido.Id := Query.FieldByName('id_pedido').AsInteger;
      Pedido.IdCliente := Query.FieldByName('id_cliente').AsInteger;
      Pedido.NomeCliente := Query.FieldByName('nome_cliente').AsString;
      Pedido.DataEmissao := Query.FieldByName('data_emissao').AsDateTime;
      Pedido.ValorTotal := Query.FieldByName('valor_total').AsCurrency;
      Pedido.Status := DBToStatus(Query.FieldByName('status').AsString);

      Query.Close;
      Query.SQL.Text :=
        'select sequencia, id_produto, descricao_produto, quantidade, ' +
        '       valor_unitario, valor_total ' +
        'from pedidos_venda_itens ' +
        'where id_pedido = :id_pedido ' +
        'order by sequencia';
      Query.ParamByName('id_pedido').AsInteger := AId;
      Query.Open;

      while not Query.Eof do
      begin
        Item := TPedidoVendaItem.Create;
        Item.IdProduto := Query.FieldByName('id_produto').AsInteger;
        Item.DescricaoProduto := Query.FieldByName('descricao_produto').AsString;
        Item.Quantidade := Query.FieldByName('quantidade').AsFloat;
        Item.ValorUnitario := Query.FieldByName('valor_unitario').AsCurrency;
        Item.ValorTotal := Query.FieldByName('valor_total').AsCurrency;
        try
          Pedido.AdicionarItem(Item);
        except
          Item.Free;
          raise;
        end;
        Query.Next;
      end;

      Result := Pedido;
      Pedido := nil;
    finally
      Pedido.Free;
    end;
  finally
    Query.Free;
  end;
end;

function TPedidoVendaRepository.ProximoCodigo: Integer;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := FConnection;
    Query.SQL.Text :=
      'select next value for gen_pedidos_venda_id as proximo_codigo ' +
      'from rdb$database';
    Query.Open;
    Result := Query.FieldByName('proximo_codigo').AsInteger;
  finally
    Query.Free;
  end;
end;

procedure TPedidoVendaRepository.Salvar(const APedido: TPedidoVenda);
var
  Query: TFDQuery;
  I: Integer;
  StartedTransaction: Boolean;
begin
  if APedido = nil then
    raise EArgumentException.Create('Informe o pedido para salvar.');

  APedido.ValidarParaConfirmacao;
  APedido.CalcularTotal;

  StartedTransaction := not FConnection.InTransaction;
  if StartedTransaction then
    FConnection.StartTransaction;

  Query := TFDQuery.Create(nil);
  try
    try
      Query.Connection := FConnection;

      Query.SQL.Text :=
        'update or insert into pedidos_venda (' +
        '  id_pedido, id_cliente, nome_cliente, data_emissao, valor_total, status' +
        ') values (' +
        '  :id_pedido, :id_cliente, :nome_cliente, :data_emissao, :valor_total, :status' +
        ') matching (id_pedido)';
      Query.ParamByName('id_pedido').AsInteger := APedido.Id;
      Query.ParamByName('id_cliente').AsInteger := APedido.IdCliente;
      Query.ParamByName('nome_cliente').AsString := APedido.NomeCliente;
      Query.ParamByName('data_emissao').AsDateTime := APedido.DataEmissao;
      Query.ParamByName('valor_total').AsCurrency := APedido.ValorTotal;
      Query.ParamByName('status').AsString := StatusToDB(APedido.Status);
      Query.ExecSQL;

      Query.SQL.Text :=
        'delete from pedidos_venda_itens ' +
        'where id_pedido = :id_pedido';
      Query.ParamByName('id_pedido').AsInteger := APedido.Id;
      Query.ExecSQL;

      for I := 0 to APedido.Itens.Count - 1 do
        InserirItem(APedido.Id, I + 1, APedido.Itens[I]);

      if StartedTransaction then
        FConnection.Commit;
    except
      if StartedTransaction and FConnection.InTransaction then
        FConnection.Rollback;
      raise;
    end;
  finally
    Query.Free;
  end;
end;

end.
