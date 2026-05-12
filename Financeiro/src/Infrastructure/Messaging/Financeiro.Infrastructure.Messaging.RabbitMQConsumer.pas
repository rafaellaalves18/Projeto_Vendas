unit Financeiro.Infrastructure.Messaging.RabbitMQConsumer;

interface

type
  TFinanceiroRabbitMQConsumer = class
  public
    function ProcessarMensagens: Integer;
  end;

implementation

uses
  System.Classes,
  Shared.Application.Contracts.Financeiro,
  Shared.Infrastructure.Messaging.RabbitMQ,
  Financeiro.Infrastructure.Integration.VendaReceiver;

function TFinanceiroRabbitMQConsumer.ProcessarMensagens: Integer;
var
  RabbitMQ: TRabbitMQClient;
  Messages: TStringList;
  Receiver: TVendaFinanceiroReceiver;
  I: Integer;
  Venda: TVendaFinanceiroDTO;
begin
  Result := 0;

  RabbitMQ := TRabbitMQClient.Create;
  try
    Messages := RabbitMQ.Consume(10);
    try
      Receiver := TVendaFinanceiroReceiver.Create;
      try
        for I := 0 to Messages.Count - 1 do
        begin
          Venda := JsonToVendaFinanceiroDTO(Messages[I]);
          Receiver.ReceberVendaConfirmada(Venda);
          Inc(Result);
        end;
      finally
        Receiver.Free;
      end;
    finally
      Messages.Free;
    end;
  finally
    RabbitMQ.Free;
  end;
end;

end.
