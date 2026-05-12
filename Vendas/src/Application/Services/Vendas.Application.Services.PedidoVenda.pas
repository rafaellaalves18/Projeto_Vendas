unit Vendas.Application.Services.PedidoVenda;

interface

uses
  Shared.Application.Contracts.Financeiro,
  Vendas.Core.Entities.PedidoVenda;

type
  TPedidoVendaService = class
  private
    FFinanceiroIntegration: IFinanceiroIntegration;
    function MontarFinanceiroDTO(const APedido: TPedidoVenda): TVendaFinanceiroDTO;
  public
    constructor Create(const AFinanceiroIntegration: IFinanceiroIntegration);
    procedure ConfirmarPedido(const APedido: TPedidoVenda);
    procedure EnviarFinanceiro(const APedido: TPedidoVenda);
  end;

implementation

uses
  Vendas.Core.Exceptions;

constructor TPedidoVendaService.Create(
  const AFinanceiroIntegration: IFinanceiroIntegration);
begin
  inherited Create;
  FFinanceiroIntegration := AFinanceiroIntegration;
end;

procedure TPedidoVendaService.ConfirmarPedido(const APedido: TPedidoVenda);
begin
  if APedido = nil then
    raise EVendasValidationException.Create('Informe o pedido para confirmacao.');

  APedido.Confirmar;
  EnviarFinanceiro(APedido);
end;

procedure TPedidoVendaService.EnviarFinanceiro(const APedido: TPedidoVenda);
begin
  if APedido = nil then
    raise EVendasValidationException.Create('Informe o pedido para envio ao financeiro.');

  if FFinanceiroIntegration <> nil then
    FFinanceiroIntegration.GerarContasReceber(MontarFinanceiroDTO(APedido));
end;

function TPedidoVendaService.MontarFinanceiroDTO(
  const APedido: TPedidoVenda): TVendaFinanceiroDTO;
begin
  Result.IdVenda := APedido.Id;
  Result.IdCliente := APedido.IdCliente;
  Result.NomeCliente := APedido.NomeCliente;
  Result.DataEmissao := APedido.DataEmissao;
  Result.ValorTotal := APedido.ValorTotal;
end;

end.
