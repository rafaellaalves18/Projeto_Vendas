unit Financeiro.Application.Services.ContaReceber;

interface

uses
  Shared.Application.Contracts.Financeiro,
  Financeiro.Core.Entities.ContaReceber;

type
  TContaReceberService = class
  public
    procedure Baixar(const AConta: TContaReceber);
    procedure Cancelar(const AConta: TContaReceber);
    function GerarPorVenda(const AVenda: TVendaFinanceiroDTO): TContaReceber;
  end;

implementation

uses
  System.SysUtils,
  System.DateUtils,
  Shared.Core.Types,
  Financeiro.Core.Exceptions;

procedure TContaReceberService.Baixar(const AConta: TContaReceber);
begin
  if AConta = nil then
    raise EFinanceiroValidationException.Create('Selecione uma conta a receber para baixar.');

  case AConta.Status of
    scrRecebida:
      raise EFinanceiroValidationException.Create('A conta selecionada ja esta recebida.');
    scrCancelada:
      raise EFinanceiroValidationException.Create('A conta selecionada esta cancelada.');
  end;

  AConta.Receber;
  AConta.Validar;
end;

procedure TContaReceberService.Cancelar(const AConta: TContaReceber);
begin
  if AConta = nil then
    raise EFinanceiroValidationException.Create('Selecione uma conta a receber para cancelar.');

  if AConta.Status = scrCancelada then
    raise EFinanceiroValidationException.Create('A conta selecionada ja esta cancelada.');

  if AConta.Status <> scrAberta then
    raise EFinanceiroValidationException.Create('Somente contas a receber em aberto podem ser canceladas.');

  AConta.Cancelar;
  AConta.Validar;
end;

function TContaReceberService.GerarPorVenda(
  const AVenda: TVendaFinanceiroDTO): TContaReceber;
begin
  if AVenda.IdVenda <= 0 then
    raise EFinanceiroValidationException.Create('Informe a venda de origem.');

  if AVenda.IdCliente <= 0 then
    raise EFinanceiroValidationException.Create('Informe o cliente da venda.');

  if Trim(AVenda.NomeCliente) = '' then
    raise EFinanceiroValidationException.Create('Informe o nome do cliente.');

  if AVenda.DataEmissao <= 0 then
    raise EFinanceiroValidationException.Create('Informe a data de emissao da venda.');

  if AVenda.ValorTotal <= 0 then
    raise EFinanceiroValidationException.Create('Informe o valor total da venda.');

  Result := TContaReceber.Create;
  try
    Result.Origem := ofVenda;
    Result.IdOrigem := AVenda.IdVenda;
    Result.IdCliente := AVenda.IdCliente;
    Result.NomeCliente := AVenda.NomeCliente;
    Result.DataEmissao := AVenda.DataEmissao;
    Result.DataVencimento := IncDay(AVenda.DataEmissao, 30);
    Result.Valor := AVenda.ValorTotal;
    Result.Abrir;
    Result.Validar;
  except
    Result.Free;
    raise;
  end;
end;

end.
