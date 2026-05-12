unit Vendas.Infrastructure.Messaging.ContaRecebidaConsumer;

interface

type
  TContaRecebidaConsumer = class
  public
    function ProcessarMensagens: Integer;
  end;

implementation

uses
  System.Classes,
  System.SysUtils,
  Shared.Application.Contracts.Financeiro,
  Shared.Infrastructure.Messaging.RabbitMQ,
  Vendas.Application.Services.EnvioRelatorioQuitacao;

function TContaRecebidaConsumer.ProcessarMensagens: Integer;
var
  Config: TRabbitMQConfig;
  DTO: TContaRecebidaDTO;
  Erros: TStringList;
  I: Integer;
  Messages: TStringList;
  RabbitMQ: TRabbitMQClient;
  Service: TEnvioRelatorioQuitacaoService;
begin
  Result := 0;
  Config := TRabbitMQConfig.ContaRecebida;
  RabbitMQ := TRabbitMQClient.Create(Config);
  try
    Messages := RabbitMQ.Consume(10);
    try
      Erros := TStringList.Create;
      try
        Service := TEnvioRelatorioQuitacaoService.Create;
        try
          if Messages.Count > 0 then
          begin
            for I := 0 to Messages.Count - 1 do
            begin
              try
                DTO := JsonToContaRecebidaDTO(Messages[I]);
                Service.ProcessarQuitacao(DTO);
                Inc(Result);
              except
                on E: Exception do
                  Erros.Add(E.Message);
              end;
            end;
          end;

          Inc(Result, Service.ProcessarPendentes);
        finally
          Service.Free;
        end;

        if (Result = 0) and (Erros.Count > 0) then
          raise Exception.Create(Erros[0]);
      finally
        Erros.Free;
      end;
    finally
      Messages.Free;
    end;
  finally
    RabbitMQ.Free;
  end;
end;

end.
