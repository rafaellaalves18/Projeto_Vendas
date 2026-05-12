unit Frm.Baixa.Financeiro;

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
  TfrmBaixaFinanceiro = class(TForm)
    pnlTitulo: TPanel;
    lblTitulo: TLabel;
    pnlPesquisa: TPanel;
    lblCodCliente: TLabel;
    lblNomeCliente: TLabel;
    edtCodCliente: TEdit;
    edtNomeCliente: TEdit;
    btnPesquisar: TButton;
    sgContas: TStringGrid;
    pnlBotoes: TPanel;
    btnGravar: TButton;
    btnCancelar: TButton;
    btnFechar: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnPesquisarClick(Sender: TObject);
    procedure btnGravarClick(Sender: TObject);
    procedure btnCancelarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure edtCodClienteKeyPress(Sender: TObject; var Key: Char);
    procedure edtNomeClienteKeyPress(Sender: TObject; var Key: Char);
    procedure sgContasDblClick(Sender: TObject);
  private
    FContas: TObjectList<TContaReceber>;
    FRepository: IContaReceberRepository;

    function ContaSelecionada: TContaReceber;
    function CurrParaStr(const AValor: Currency): string;
    function DataParaStr(const AData: TDateTime): string;
    function FocarControle(const AControl: TWinControl): Boolean;
    function StatusParaStr(const AStatus: TStatusContaReceber): string;
    procedure BaixarFinanceiro;
    procedure CancelarFinanceiro;
    procedure ConfigurarGrid;
    procedure LimparGrid;
    procedure PesquisarFinanceiro;
    procedure PreencherLinhaGrid(const AConta: TContaReceber; const ARow: Integer);
    procedure ReconstruirGrid;
  end;

implementation

{$R *.dfm}

uses
  System.UITypes,
  Vcl.Dialogs,
  Financeiro.Application.Services.ContaReceber,
  Financeiro.Infrastructure.Integration.VendasGateway,
  Financeiro.Infrastructure.Persistence.Repositories.ContaReceber;

procedure TfrmBaixaFinanceiro.FormCreate(Sender: TObject);
begin
  FRepository := TContaReceberRepository.Create;
  FContas := TObjectList<TContaReceber>.Create(True);

  ConfigurarGrid;
  LimparGrid;
end;

procedure TfrmBaixaFinanceiro.FormDestroy(Sender: TObject);
begin
  FContas.Free;
end;

procedure TfrmBaixaFinanceiro.FormShow(Sender: TObject);
begin
  FocarControle(edtCodCliente);
end;

function TfrmBaixaFinanceiro.FocarControle(
  const AControl: TWinControl): Boolean;
begin
  Result := Showing and (AControl <> nil) and AControl.CanFocus;
  if Result then
    AControl.SetFocus;
end;

function TfrmBaixaFinanceiro.CurrParaStr(const AValor: Currency): string;
var
  Fmt: TFormatSettings;
begin
  Fmt := TFormatSettings.Create('pt-BR');
  Result := FormatFloat('#,##0.00', AValor, Fmt);
end;

function TfrmBaixaFinanceiro.DataParaStr(const AData: TDateTime): string;
begin
  if AData > 0 then
    Result := FormatDateTime('dd/mm/yyyy', AData)
  else
    Result := '';
end;

function TfrmBaixaFinanceiro.StatusParaStr(
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

procedure TfrmBaixaFinanceiro.ConfigurarGrid;
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

procedure TfrmBaixaFinanceiro.LimparGrid;
var
  I: Integer;
begin
  sgContas.RowCount := 2;
  for I := 0 to sgContas.ColCount - 1 do
    sgContas.Cells[I, 1] := '';
end;

procedure TfrmBaixaFinanceiro.PreencherLinhaGrid(
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

procedure TfrmBaixaFinanceiro.ReconstruirGrid;
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

procedure TfrmBaixaFinanceiro.PesquisarFinanceiro;
var
  CodigoCliente: Integer;
  NomeCliente: string;
  NovasContas: TObjectList<TContaReceber>;
begin
  CodigoCliente := StrToIntDef(Trim(edtCodCliente.Text), 0);
  NomeCliente := Trim(edtNomeCliente.Text);

  if (CodigoCliente <= 0) and (NomeCliente = '') then
  begin
    ShowMessage('Informe o codigo ou nome do cliente para pesquisar.');
    FocarControle(edtCodCliente);
    Exit;
  end;

  NovasContas := nil;
  try
    NovasContas := FRepository.PesquisarPorCliente(
      CodigoCliente, NomeCliente, True);

    FContas.Free;
    FContas := NovasContas;
    NovasContas := nil;

    ReconstruirGrid;

    if FContas.Count = 0 then
      ShowMessage('Nenhum financeiro em aberto encontrado para o cliente.');
  finally
    NovasContas.Free;
  end;
end;

function TfrmBaixaFinanceiro.ContaSelecionada: TContaReceber;
begin
  Result := nil;

  if (FContas = nil) or (FContas.Count = 0) then
    Exit;

  if (sgContas.Row <= 0) or (sgContas.Row > FContas.Count) then
    Exit;

  Result := FContas[sgContas.Row - 1];
end;

procedure TfrmBaixaFinanceiro.BaixarFinanceiro;
var
  Conta: TContaReceber;
  Service: TContaReceberService;
  NotificacaoVendasEnviada: Boolean;
  ErroNotificacaoVendas: string;
begin
  Conta := ContaSelecionada;
  if Conta = nil then
  begin
    ShowMessage('Selecione o financeiro que sera baixado.');
    Exit;
  end;

  if MessageDlg(
    Format('Confirma a baixa da conta %d no valor de R$ %s?',
      [Conta.Id, CurrParaStr(Conta.Valor)]),
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  Service := TContaReceberService.Create;
  NotificacaoVendasEnviada := False;
  ErroNotificacaoVendas := '';
  try
    try
      Service.Baixar(Conta);
      FRepository.Salvar(Conta);
      try
        TVendasGateway.NotificarContaRecebida(Conta);
        NotificacaoVendasEnviada := True;
      except
        on E: Exception do
          ErroNotificacaoVendas := E.Message;
      end;
    except
      on E: Exception do
      begin
        ShowMessage(E.Message);
        Exit;
      end;
    end;
  finally
    Service.Free;
  end;

  if NotificacaoVendasEnviada then
    ShowMessage('Baixa gravada com sucesso. ERP Vendas notificado para envio do relatorio por e-mail.')
  else
    ShowMessage(
      'Baixa gravada com sucesso.' + sLineBreak + sLineBreak +
      'Nao foi possivel notificar o ERP Vendas para envio automatico do relatorio:' +
      sLineBreak + ErroNotificacaoVendas);
  PesquisarFinanceiro;
end;

procedure TfrmBaixaFinanceiro.CancelarFinanceiro;
var
  Conta: TContaReceber;
  ContaAtual: TContaReceber;
  Service: TContaReceberService;
begin
  Conta := ContaSelecionada;
  if Conta = nil then
  begin
    ShowMessage('Selecione o financeiro que sera cancelado.');
    Exit;
  end;

  if Conta.Status <> scrAberta then
  begin
    ShowMessage('Somente contas a receber em aberto podem ser canceladas.');
    Exit;
  end;

  if MessageDlg(
    Format('Confirma o cancelamento da conta %d no valor de R$ %s?',
      [Conta.Id, CurrParaStr(Conta.Valor)]),
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  ContaAtual := nil;
  Service := nil;
  try
    try
      ContaAtual := FRepository.ObterPorId(Conta.Id);
      if ContaAtual = nil then
      begin
        ShowMessage('Conta a receber nao encontrada.');
        Exit;
      end;

      Service := TContaReceberService.Create;
      Service.Cancelar(ContaAtual);
      FRepository.Salvar(ContaAtual);
    except
      on E: Exception do
      begin
        ShowMessage(E.Message);
        Exit;
      end;
    end;
  finally
    Service.Free;
    ContaAtual.Free;
  end;

  ShowMessage('Financeiro cancelado com sucesso.');
  PesquisarFinanceiro;
end;

procedure TfrmBaixaFinanceiro.btnPesquisarClick(Sender: TObject);
begin
  PesquisarFinanceiro;
end;

procedure TfrmBaixaFinanceiro.btnGravarClick(Sender: TObject);
begin
  BaixarFinanceiro;
end;

procedure TfrmBaixaFinanceiro.btnCancelarClick(Sender: TObject);
begin
  CancelarFinanceiro;
end;

procedure TfrmBaixaFinanceiro.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmBaixaFinanceiro.edtCodClienteKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', #8, #13]) then
    Key := #0;

  if Key = #13 then
  begin
    Key := #0;
    PesquisarFinanceiro;
  end;
end;

procedure TfrmBaixaFinanceiro.edtNomeClienteKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    PesquisarFinanceiro;
  end;
end;

procedure TfrmBaixaFinanceiro.sgContasDblClick(Sender: TObject);
begin
  BaixarFinanceiro;
end;

end.
