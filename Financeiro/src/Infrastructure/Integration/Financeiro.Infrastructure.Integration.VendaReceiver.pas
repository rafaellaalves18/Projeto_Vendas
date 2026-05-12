unit Financeiro.Infrastructure.Integration.VendaReceiver;

interface

uses
  Shared.Application.Contracts.Financeiro;

type
  TVendaFinanceiroReceiver = class
  public
    procedure ReceberVendaConfirmada(const AVenda: TVendaFinanceiroDTO);
  end;

implementation

uses
  Financeiro.Application.Services.ContaReceber,
  Financeiro.Core.Entities.ContaReceber,
  Financeiro.Infrastructure.Persistence.Repositories.ContaReceber;

procedure TVendaFinanceiroReceiver.ReceberVendaConfirmada(
  const AVenda: TVendaFinanceiroDTO);
var
  Service: TContaReceberService;
  Conta: TContaReceber;
  Repository: TContaReceberRepository;
begin
  Service := TContaReceberService.Create;
  try
    Conta := Service.GerarPorVenda(AVenda);
    try
      Repository := TContaReceberRepository.Create;
      try
        Repository.Salvar(Conta);
      finally
        Repository.Free;
      end;
    finally
      Conta.Free;
    end;
  finally
    Service.Free;
  end;
end;

end.
