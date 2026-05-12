unit Financeiro.Core.Entities.ContaReceber;

interface

uses
  System.SysUtils,
  Shared.Core.Types,
  Financeiro.Core.Exceptions;

type
  TContaReceber = class
  private
    FId: Integer;
    FOrigem: TOrigemFinanceira;
    FIdOrigem: Integer;
    FIdCliente: Integer;
    FNomeCliente: string;
    FDataEmissao: TDateTime;
    FDataVencimento: TDateTime;
    FValor: Currency;
    FStatus: TStatusContaReceber;
  public
    constructor Create;

    procedure Abrir;
    procedure Cancelar;
    procedure Receber;
    procedure Validar;

    property Id: Integer read FId write FId;
    property Origem: TOrigemFinanceira read FOrigem write FOrigem;
    property IdOrigem: Integer read FIdOrigem write FIdOrigem;
    property IdCliente: Integer read FIdCliente write FIdCliente;
    property NomeCliente: string read FNomeCliente write FNomeCliente;
    property DataEmissao: TDateTime read FDataEmissao write FDataEmissao;
    property DataVencimento: TDateTime read FDataVencimento write FDataVencimento;
    property Valor: Currency read FValor write FValor;
    property Status: TStatusContaReceber read FStatus write FStatus;
  end;

implementation

constructor TContaReceber.Create;
begin
  inherited Create;
  FOrigem := ofVenda;
  FStatus := scrAberta;
end;

procedure TContaReceber.Abrir;
begin
  FStatus := scrAberta;
end;

procedure TContaReceber.Cancelar;
begin
  FStatus := scrCancelada;
end;

procedure TContaReceber.Receber;
begin
  FStatus := scrRecebida;
end;

procedure TContaReceber.Validar;
begin
  if FIdOrigem <= 0 then
    raise EFinanceiroValidationException.Create('Informe a origem da conta a receber.');

  if FIdCliente <= 0 then
    raise EFinanceiroValidationException.Create('Informe o cliente da conta a receber.');

  if Trim(FNomeCliente) = '' then
    raise EFinanceiroValidationException.Create('Informe o nome do cliente.');

  if FDataEmissao <= 0 then
    raise EFinanceiroValidationException.Create('Informe a data de emissao.');

  if FDataVencimento <= 0 then
    raise EFinanceiroValidationException.Create('Informe a data de vencimento.');

  if FValor <= 0 then
    raise EFinanceiroValidationException.Create('Informe um valor maior que zero.');
end;

end.
