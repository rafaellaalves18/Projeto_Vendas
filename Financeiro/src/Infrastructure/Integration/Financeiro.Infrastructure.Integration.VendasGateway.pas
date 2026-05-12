unit Financeiro.Infrastructure.Integration.VendasGateway;

interface

uses
  Financeiro.Core.Entities.ContaReceber;

type
  TVendasGateway = class
  public
    class procedure NotificarContaRecebida(const AConta: TContaReceber); static;
  end;

implementation

uses
  System.SysUtils,
  Shared.Application.Contracts.Financeiro,
  Shared.Infrastructure.Messaging.RabbitMQ;

class procedure TVendasGateway.NotificarContaRecebida(
  const AConta: TContaReceber);
var
  Config: TRabbitMQConfig;
  DTO: TContaRecebidaDTO;
  RabbitMQ: TRabbitMQClient;
begin
  if AConta = nil then
    Exit;

  DTO.IdContaReceber := AConta.Id;
  DTO.IdVenda := AConta.IdOrigem;
  DTO.IdCliente := AConta.IdCliente;
  DTO.NomeCliente := AConta.NomeCliente;
  DTO.DataRecebimento := Now;
  DTO.ValorRecebido := AConta.Valor;

  Config := TRabbitMQConfig.ContaRecebida;
  RabbitMQ := TRabbitMQClient.Create(Config);
  try
    RabbitMQ.Publish(ContaRecebidaDTOToJson(DTO));
  finally
    RabbitMQ.Free;
  end;
end;

end.
