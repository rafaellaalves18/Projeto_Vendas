unit Vendas.Core.Entities.PedidoVenda;

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Shared.Core.Types,
  Vendas.Core.Exceptions;

type
  TPedidoVendaItem = class
  private
    FIdProduto: Integer;
    FDescricaoProduto: string;
    FQuantidade: Double;
    FValorUnitario: Currency;
    FValorTotal: Currency;
  public
    constructor Create; overload;
    constructor Create(const AIdProduto: Integer; const ADescricaoProduto: string;
      const AQuantidade: Double; const AValorUnitario: Currency); overload;

    procedure CalcularTotal;
    procedure Validar;

    property IdProduto: Integer read FIdProduto write FIdProduto;
    property DescricaoProduto: string read FDescricaoProduto write FDescricaoProduto;
    property Quantidade: Double read FQuantidade write FQuantidade;
    property ValorUnitario: Currency read FValorUnitario write FValorUnitario;
    property ValorTotal: Currency read FValorTotal write FValorTotal;
  end;

  TPedidoVenda = class
  private
    FId: Integer;
    FIdCliente: Integer;
    FNomeCliente: string;
    FDataEmissao: TDateTime;
    FValorTotal: Currency;
    FStatus: TStatusPedidoVenda;
    FItens: TObjectList<TPedidoVendaItem>;
  public
    constructor Create;
    destructor Destroy; override;

    procedure AdicionarItem(const AItem: TPedidoVendaItem);
    procedure CalcularTotal;
    procedure Confirmar;
    procedure LimparItens;
    procedure ValidarParaConfirmacao;

    property Id: Integer read FId write FId;
    property IdCliente: Integer read FIdCliente write FIdCliente;
    property NomeCliente: string read FNomeCliente write FNomeCliente;
    property DataEmissao: TDateTime read FDataEmissao write FDataEmissao;
    property ValorTotal: Currency read FValorTotal write FValorTotal;
    property Status: TStatusPedidoVenda read FStatus write FStatus;
    property Itens: TObjectList<TPedidoVendaItem> read FItens;
  end;

implementation

constructor TPedidoVendaItem.Create;
begin
  inherited Create;
end;

constructor TPedidoVendaItem.Create(const AIdProduto: Integer;
  const ADescricaoProduto: string; const AQuantidade: Double;
  const AValorUnitario: Currency);
begin
  inherited Create;
  FIdProduto := AIdProduto;
  FDescricaoProduto := Trim(ADescricaoProduto);
  FQuantidade := AQuantidade;
  FValorUnitario := AValorUnitario;
  CalcularTotal;
end;

procedure TPedidoVendaItem.CalcularTotal;
begin
  FValorTotal := FQuantidade * FValorUnitario;
end;

procedure TPedidoVendaItem.Validar;
begin
  if FIdProduto <= 0 then
    raise EVendasValidationException.Create('Informe um produto valido para o item.');

  if Trim(FDescricaoProduto) = '' then
    raise EVendasValidationException.Create('Informe a descricao do produto.');

  if FQuantidade <= 0 then
    raise EVendasValidationException.Create('Informe uma quantidade maior que zero.');

  if FValorUnitario <= 0 then
    raise EVendasValidationException.Create('Informe um valor unitario maior que zero.');
end;

constructor TPedidoVenda.Create;
begin
  inherited Create;
  FItens := TObjectList<TPedidoVendaItem>.Create(True);
  FDataEmissao := Now;
  FStatus := spvDigitacao;
end;

destructor TPedidoVenda.Destroy;
begin
  FItens.Free;
  inherited Destroy;
end;

procedure TPedidoVenda.AdicionarItem(const AItem: TPedidoVendaItem);
begin
  if AItem = nil then
    raise EVendasValidationException.Create('Informe um item valido para o pedido.');

  AItem.Validar;
  AItem.CalcularTotal;
  FItens.Add(AItem);
  CalcularTotal;
end;

procedure TPedidoVenda.CalcularTotal;
var
  Item: TPedidoVendaItem;
begin
  FValorTotal := 0;
  for Item in FItens do
  begin
    Item.CalcularTotal;
    FValorTotal := FValorTotal + Item.ValorTotal;
  end;
end;

procedure TPedidoVenda.Confirmar;
begin
  ValidarParaConfirmacao;
  CalcularTotal;
  FStatus := spvConfirmado;
end;

procedure TPedidoVenda.LimparItens;
begin
  FItens.Clear;
  FValorTotal := 0;
end;

procedure TPedidoVenda.ValidarParaConfirmacao;
begin
  if FId <= 0 then
    raise EVendasValidationException.Create('Informe um numero valido para o pedido.');

  if FIdCliente <= 0 then
    raise EVendasValidationException.Create('Informe um cliente valido para o pedido.');

  if Trim(FNomeCliente) = '' then
    raise EVendasValidationException.Create('Informe o nome do cliente.');

  if FItens.Count = 0 then
    raise EVendasValidationException.Create('Adicione ao menos um item ao pedido.');
end;

end.
