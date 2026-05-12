unit Vendas.Core.Entities.Cliente;

interface

uses
  System.SysUtils,
  Vendas.Core.Exceptions;

type
  TCliente = class
  private
    FId: Integer;
    FNome: string;
    FDocumento: string;
    FEmail: string;
    FTelefone: string;
    FCidade: string;
    FUF: string;

    procedure SetUF(const AValue: string);
  public
    procedure Validar;

    property Id: Integer read FId write FId;
    property Nome: string read FNome write FNome;
    property Documento: string read FDocumento write FDocumento;
    property Email: string read FEmail write FEmail;
    property Telefone: string read FTelefone write FTelefone;
    property Cidade: string read FCidade write FCidade;
    property UF: string read FUF write SetUF;
  end;

implementation

procedure TCliente.SetUF(const AValue: string);
begin
  FUF := UpperCase(Trim(AValue));
end;

procedure TCliente.Validar;
begin
  if FId <= 0 then
    raise EVendasValidationException.Create('Informe um codigo valido para o cliente.');

  if Trim(FNome) = '' then
    raise EVendasValidationException.Create('Informe o nome do cliente.');

  if (FUF <> '') and (Length(FUF) <> 2) then
    raise EVendasValidationException.Create('Informe a UF com 2 caracteres.');
end;

end.
