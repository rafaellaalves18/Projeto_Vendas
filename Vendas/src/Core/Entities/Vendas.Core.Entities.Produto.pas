unit Vendas.Core.Entities.Produto;

interface

uses
  System.SysUtils,
  Vendas.Core.Exceptions;

type
  TProduto = class
  private
    FId: Integer;
    FDescricao: string;
    FPrecoVenda: Currency;
    FAtivo: Boolean;
  public
    constructor Create;

    procedure Ativar;
    procedure Desativar;
    procedure Validar;

    property Id: Integer read FId write FId;
    property Descricao: string read FDescricao write FDescricao;
    property PrecoVenda: Currency read FPrecoVenda write FPrecoVenda;
    property Ativo: Boolean read FAtivo write FAtivo;
  end;

implementation

constructor TProduto.Create;
begin
  inherited Create;
  FAtivo := True;
end;

procedure TProduto.Ativar;
begin
  FAtivo := True;
end;

procedure TProduto.Desativar;
begin
  FAtivo := False;
end;

procedure TProduto.Validar;
begin
  if FId <= 0 then
    raise EVendasValidationException.Create('Informe um codigo valido para o produto.');

  if Trim(FDescricao) = '' then
    raise EVendasValidationException.Create('Informe a descricao do produto.');

  if FPrecoVenda <= 0 then
    raise EVendasValidationException.Create('Informe um preco de venda maior que zero.');
end;

end.
