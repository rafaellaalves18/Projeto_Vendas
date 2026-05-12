unit Frm.Cadastro.Produto;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vendas.Core.Entities.Produto,
  Vendas.Application.Interfaces.Repositories;

type
  TfrmCadastroProduto = class(TForm)
    pnlTitulo: TPanel;
    lblTitulo: TLabel;
    pnlCampos: TPanel;
    lblCodigo: TLabel;
    lblDescricao: TLabel;
    lblPrecoVenda: TLabel;
    edtCodigo: TEdit;
    edtDescricao: TEdit;
    edtPrecoVenda: TEdit;
    chkAtivo: TCheckBox;
    pnlBotoes: TPanel;
    btnNovo: TButton;
    btnSalvar: TButton;
    btnExcluir: TButton;
    btnSair: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure edtCodigoExit(Sender: TObject);
    procedure edtCodigoKeyPress(Sender: TObject; var Key: Char);
    procedure edtPrecoVendaExit(Sender: TObject);
    procedure edtPrecoVendaKeyPress(Sender: TObject; var Key: Char);
  private
    FRepository: IProdutoRepository;

    function CurrParaStr(const AValor: Currency): string;
    function FocarControle(const AControl: TWinControl): Boolean;
    function MontarProduto: TProduto;
    function NovoCodigo: Integer;
    function ProdutoExiste(const ACodigo: Integer): Boolean;
    function StrParaCurr(const ATexto: string; out AValor: Currency): Boolean;
    function ValidarCampos: Boolean;
    procedure CarregarProduto(const ACodigo: Integer);
    procedure ExcluirProduto;
    procedure FocarDescricao;
    procedure LimparCamposProduto;
    procedure NovoRegistro;
    procedure PreencherCampos(const AProduto: TProduto);
    procedure SalvarProduto;
  end;

implementation

{$R *.dfm}

uses
  System.UITypes,
  Vcl.Dialogs,
  Vendas.Infrastructure.Persistence.Repositories.Produto;

procedure TfrmCadastroProduto.FormCreate(Sender: TObject);
begin
  FRepository := TProdutoRepository.Create;
  NovoRegistro;
end;

procedure TfrmCadastroProduto.FormShow(Sender: TObject);
begin
  FocarDescricao;
end;

function TfrmCadastroProduto.FocarControle(
  const AControl: TWinControl): Boolean;
begin
  Result := Showing and (AControl <> nil) and AControl.CanFocus;
  if Result then
    AControl.SetFocus;
end;

function TfrmCadastroProduto.ProdutoExiste(const ACodigo: Integer): Boolean;
var
  Produto: TProduto;
begin
  Produto := FRepository.ObterPorId(ACodigo);
  try
    Result := Produto <> nil;
  finally
    Produto.Free;
  end;
end;

function TfrmCadastroProduto.NovoCodigo: Integer;
begin
  Result := FRepository.ProximoCodigo;
end;

function TfrmCadastroProduto.StrParaCurr(
  const ATexto: string; out AValor: Currency): Boolean;
var
  Fmt: TFormatSettings;
  Texto: string;
begin
  Fmt := TFormatSettings.Create('pt-BR');
  Texto := Trim(ATexto);

  if (Pos('.', Texto) > 0) and (Pos(',', Texto) = 0) then
    Texto := StringReplace(Texto, '.', ',', [rfReplaceAll]);

  Result := TryStrToCurr(Texto, AValor, Fmt);
end;

function TfrmCadastroProduto.CurrParaStr(const AValor: Currency): string;
var
  Fmt: TFormatSettings;
begin
  Fmt := TFormatSettings.Create('pt-BR');
  Result := FormatFloat('#,##0.00', AValor, Fmt);
end;

procedure TfrmCadastroProduto.LimparCamposProduto;
begin
  edtDescricao.Clear;
  edtPrecoVenda.Text := '0,00';
  chkAtivo.Checked := True;
end;

procedure TfrmCadastroProduto.NovoRegistro;
begin
  edtCodigo.Text := IntToStr(NovoCodigo);
  LimparCamposProduto;

  FocarDescricao;
end;

procedure TfrmCadastroProduto.FocarDescricao;
begin
  FocarControle(edtDescricao);
end;

procedure TfrmCadastroProduto.PreencherCampos(const AProduto: TProduto);
begin
  edtCodigo.Text := IntToStr(AProduto.Id);
  edtDescricao.Text := AProduto.Descricao;
  edtPrecoVenda.Text := CurrParaStr(AProduto.PrecoVenda);
  chkAtivo.Checked := AProduto.Ativo;
end;

procedure TfrmCadastroProduto.CarregarProduto(const ACodigo: Integer);
var
  Produto: TProduto;
begin
  if ACodigo <= 0 then
    Exit;

  Produto := FRepository.ObterPorId(ACodigo);
  try
    if Produto <> nil then
      PreencherCampos(Produto);
  finally
    Produto.Free;
  end;
end;

function TfrmCadastroProduto.ValidarCampos: Boolean;
var
  PrecoVenda: Currency;
begin
  Result := False;

  if StrToIntDef(Trim(edtCodigo.Text), 0) <= 0 then
  begin
    ShowMessage('Informe um codigo valido para o produto.');
    FocarControle(edtCodigo);
    Exit;
  end;

  if Trim(edtDescricao.Text) = '' then
  begin
    ShowMessage('Informe a descricao do produto.');
    FocarControle(edtDescricao);
    Exit;
  end;

  if (not StrParaCurr(edtPrecoVenda.Text, PrecoVenda)) or (PrecoVenda <= 0) then
  begin
    ShowMessage('Informe um preco de venda valido maior que zero.');
    if FocarControle(edtPrecoVenda) then
      edtPrecoVenda.SelectAll;
    Exit;
  end;

  Result := True;
end;

function TfrmCadastroProduto.MontarProduto: TProduto;
var
  PrecoVenda: Currency;
begin
  StrParaCurr(edtPrecoVenda.Text, PrecoVenda);

  Result := TProduto.Create;
  Result.Id := StrToIntDef(Trim(edtCodigo.Text), 0);
  Result.Descricao := Trim(edtDescricao.Text);
  Result.PrecoVenda := PrecoVenda;
  Result.Ativo := chkAtivo.Checked;
end;

procedure TfrmCadastroProduto.SalvarProduto;
var
  Produto: TProduto;
begin
  if not ValidarCampos then
    Exit;

  Produto := MontarProduto;
  try
    FRepository.Salvar(Produto);
    edtPrecoVenda.Text := CurrParaStr(Produto.PrecoVenda);
  finally
    Produto.Free;
  end;

  ShowMessage(Format('Produto %s salvo com sucesso.', [edtCodigo.Text]));
end;

procedure TfrmCadastroProduto.ExcluirProduto;
var
  Codigo: Integer;
begin
  Codigo := StrToIntDef(Trim(edtCodigo.Text), 0);
  if Codigo <= 0 then
  begin
    ShowMessage('Informe o codigo do produto para excluir.');
    FocarControle(edtCodigo);
    Exit;
  end;

  if not ProdutoExiste(Codigo) then
  begin
    ShowMessage('Produto nao encontrado.');
    FocarControle(edtCodigo);
    Exit;
  end;

  if MessageDlg(
    Format('Confirma a exclusao do produto %d?', [Codigo]),
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  FRepository.Excluir(Codigo);

  ShowMessage('Produto excluido com sucesso.');
  NovoRegistro;
end;

procedure TfrmCadastroProduto.btnNovoClick(Sender: TObject);
begin
  NovoRegistro;
end;

procedure TfrmCadastroProduto.btnSalvarClick(Sender: TObject);
begin
  SalvarProduto;
end;

procedure TfrmCadastroProduto.btnExcluirClick(Sender: TObject);
begin
  ExcluirProduto;
end;

procedure TfrmCadastroProduto.btnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCadastroProduto.edtCodigoExit(Sender: TObject);
var
  Codigo: Integer;
begin
  Codigo := StrToIntDef(Trim(edtCodigo.Text), 0);
  if ProdutoExiste(Codigo) then
    CarregarProduto(Codigo);
end;

procedure TfrmCadastroProduto.edtCodigoKeyPress(Sender: TObject; var Key: Char);
var
  Codigo: Integer;
begin
  if not CharInSet(Key, ['0'..'9', #8, #13]) then
    Key := #0;

  if Key = #13 then
  begin
    Key := #0;
    Codigo := StrToIntDef(Trim(edtCodigo.Text), 0);
    if ProdutoExiste(Codigo) then
      CarregarProduto(Codigo)
    else
      LimparCamposProduto;

    FocarDescricao;
  end;
end;

procedure TfrmCadastroProduto.edtPrecoVendaExit(Sender: TObject);
var
  PrecoVenda: Currency;
begin
  if StrParaCurr(edtPrecoVenda.Text, PrecoVenda) then
    edtPrecoVenda.Text := CurrParaStr(PrecoVenda);
end;

procedure TfrmCadastroProduto.edtPrecoVendaKeyPress(
  Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', ',', '.', #8]) then
    Key := #0;
end;

end.
