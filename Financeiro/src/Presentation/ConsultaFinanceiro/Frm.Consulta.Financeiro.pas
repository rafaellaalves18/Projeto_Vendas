unit Frm.Consulta.Financeiro;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Grids,
  Shared.Core.Types,
  Financeiro.Core.Entities.ContaReceber,
  Financeiro.Application.Interfaces.Repositories;

type
  TfrmConsultaFinanceiro = class(TForm)
    pnlTitulo: TPanel;
    lblTitulo: TLabel;
    pnlPesquisa: TPanel;
    lblNomeCliente: TLabel;
    edtNomeCliente: TEdit;
    btnPesquisar: TButton;
    sgContas: TStringGrid;
    pnlRodape: TPanel;
    lblValorAberto: TLabel;
    edtValorAberto: TEdit;
    btnFechar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnPesquisarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure edtNomeClienteKeyPress(Sender: TObject; var Key: Char);
  private
    FContas: TObjectList<TContaReceber>;
    FRepository: IContaReceberRepository;

    function CurrParaStr(const AValor: Currency): string;
    function DataParaStr(const AData: TDateTime): string;
    function FocarControle(const AControl: TWinControl): Boolean;
    function StatusParaStr(const AStatus: TStatusContaReceber): string;
    function ValorAberto: Currency;
    procedure AtualizarValorAberto;
    procedure ConfigurarGrid;
    procedure LimparGrid;
    procedure PesquisarFinanceiro;
    procedure PreencherLinhaGrid(const AConta: TContaReceber; const ARow: Integer);
    procedure ReconstruirGrid;
  end;

implementation

{$R *.dfm}

uses
  Vcl.Dialogs,
  Financeiro.Infrastructure.Persistence.Repositories.ContaReceber;

procedure TfrmConsultaFinanceiro.FormCreate(Sender: TObject);
begin
  FRepository := TContaReceberRepository.Create;
  FContas := TObjectList<TContaReceber>.Create(True);

  ConfigurarGrid;
  LimparGrid;
  AtualizarValorAberto;
end;

procedure TfrmConsultaFinanceiro.FormDestroy(Sender: TObject);
begin
  FContas.Free;
end;

procedure TfrmConsultaFinanceiro.FormShow(Sender: TObject);
begin
  FocarControle(edtNomeCliente);
end;

function TfrmConsultaFinanceiro.FocarControle(
  const AControl: TWinControl): Boolean;
begin
  Result := Showing and (AControl <> nil) and AControl.CanFocus;
  if Result then
    AControl.SetFocus;
end;

function TfrmConsultaFinanceiro.CurrParaStr(const AValor: Currency): string;
var
  Fmt: TFormatSettings;
begin
  Fmt := TFormatSettings.Create('pt-BR');
  Result := FormatFloat('#,##0.00', AValor, Fmt);
end;

function TfrmConsultaFinanceiro.DataParaStr(const AData: TDateTime): string;
begin
  if AData > 0 then
    Result := FormatDateTime('dd/mm/yyyy', AData)
  else
    Result := '';
end;

function TfrmConsultaFinanceiro.StatusParaStr(
  const AStatus: TStatusContaReceber): string;
begin
  case AStatus of
    scrRecebida:
      Result := 'Recebida';
    scrCancelada:
      Result := 'Cancelada';
  else
    Result := 'Aberta';
  end;
end;

procedure TfrmConsultaFinanceiro.ConfigurarGrid;
const
  HEADERS: array[0..7] of string = (
    'Conta', 'Venda', 'Cliente', 'Nome Cliente', 'Emissao',
    'Vencimento', 'Valor', 'Status');
  WIDTHS: array[0..7] of Integer = (70, 70, 80, 300, 95, 95, 110, 90);
var
  I: Integer;
begin
  sgContas.ColCount := 8;
  sgContas.RowCount := 2;
  sgContas.FixedCols := 0;
  sgContas.FixedRows := 1;
  sgContas.Options := sgContas.Options + [goRowSelect] - [goEditing];

  for I := 0 to High(HEADERS) do
  begin
    sgContas.Cells[I, 0] := HEADERS[I];
    sgContas.ColWidths[I] := WIDTHS[I];
  end;
end;

procedure TfrmConsultaFinanceiro.LimparGrid;
var
  I: Integer;
begin
  sgContas.RowCount := 2;
  for I := 0 to sgContas.ColCount - 1 do
    sgContas.Cells[I, 1] := '';
end;

procedure TfrmConsultaFinanceiro.PreencherLinhaGrid(
  const AConta: TContaReceber; const ARow: Integer);
begin
  sgContas.Cells[0, ARow] := IntToStr(AConta.Id);
  sgContas.Cells[1, ARow] := IntToStr(AConta.IdOrigem);
  sgContas.Cells[2, ARow] := IntToStr(AConta.IdCliente);
  sgContas.Cells[3, ARow] := AConta.NomeCliente;
  sgContas.Cells[4, ARow] := DataParaStr(AConta.DataEmissao);
  sgContas.Cells[5, ARow] := DataParaStr(AConta.DataVencimento);
  sgContas.Cells[6, ARow] := CurrParaStr(AConta.Valor);
  sgContas.Cells[7, ARow] := StatusParaStr(AConta.Status);
end;

procedure TfrmConsultaFinanceiro.ReconstruirGrid;
var
  I: Integer;
begin
  if FContas.Count = 0 then
  begin
    LimparGrid;
    Exit;
  end;

  sgContas.RowCount := FContas.Count + 1;
  for I := 0 to FContas.Count - 1 do
    PreencherLinhaGrid(FContas[I], I + 1);

  sgContas.Row := 1;
end;

function TfrmConsultaFinanceiro.ValorAberto: Currency;
var
  Conta: TContaReceber;
begin
  Result := 0;

  for Conta in FContas do
    if Conta.Status = scrAberta then
      Result := Result + Conta.Valor;
end;

procedure TfrmConsultaFinanceiro.AtualizarValorAberto;
begin
  edtValorAberto.Text := 'R$ ' + CurrParaStr(ValorAberto);
end;

procedure TfrmConsultaFinanceiro.PesquisarFinanceiro;
var
  NomeCliente: string;
  NovasContas: TObjectList<TContaReceber>;
begin
  NomeCliente := Trim(edtNomeCliente.Text);

  if NomeCliente = '' then
  begin
    ShowMessage('Informe o nome do cliente para consultar.');
    FocarControle(edtNomeCliente);
    Exit;
  end;

  NovasContas := nil;
  try
    NovasContas := FRepository.PesquisarPorCliente(0, NomeCliente, False);

    FContas.Free;
    FContas := NovasContas;
    NovasContas := nil;

    ReconstruirGrid;
    AtualizarValorAberto;

    if FContas.Count = 0 then
      ShowMessage('Nenhum financeiro encontrado para o cliente.');
  finally
    NovasContas.Free;
  end;
end;

procedure TfrmConsultaFinanceiro.btnPesquisarClick(Sender: TObject);
begin
  PesquisarFinanceiro;
end;

procedure TfrmConsultaFinanceiro.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmConsultaFinanceiro.edtNomeClienteKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    PesquisarFinanceiro;
  end;
end;

end.
