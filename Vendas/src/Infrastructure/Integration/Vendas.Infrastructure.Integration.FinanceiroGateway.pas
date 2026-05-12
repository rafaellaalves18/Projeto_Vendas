unit Vendas.Infrastructure.Integration.FinanceiroGateway;

interface

uses
  Shared.Application.Contracts.Financeiro;

type
  TFinanceiroGateway = class(TInterfacedObject, IFinanceiroIntegration)
  public
    procedure GerarContasReceber(const AVenda: TVendaFinanceiroDTO);
  end;

implementation

uses
  Shared.Infrastructure.Messaging.RabbitMQ;

procedure TFinanceiroGateway.GerarContasReceber(
  const AVenda: TVendaFinanceiroDTO);
var
  RabbitMQ: TRabbitMQClient;
begin
  RabbitMQ := TRabbitMQClient.Create;
  try
    RabbitMQ.Publish(VendaFinanceiroDTOToJson(AVenda));
  finally
    RabbitMQ.Free;
  end;
end;

end.
