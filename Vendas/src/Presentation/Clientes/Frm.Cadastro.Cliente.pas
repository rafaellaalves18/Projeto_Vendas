unit Frm.Cadastro.Cliente;

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
  Vendas.Core.Entities.Cliente,
  Vendas.Application.Interfaces.Repositories;

type
  TfrmCadastroCliente = class(TForm)
    pnlTitulo: TPanel;
    lblTitulo: TLabel;
    pnlCampos: TPanel;
    lblCodigo: TLabel;
    lblNome: TLabel;
    lblDocumento: TLabel;
    lblEmail: TLabel;
    lblTelefone: TLabel;
    lblCidade: TLabel;
    lblUF: TLabel;
    edtCodigo: TEdit;
    edtNome: TEdit;
    edtDocumento: TEdit;
    edtEmail: TEdit;
    edtTelefone: TEdit;
    edtCidade: TEdit;
    edtUF: TEdit;
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
  private
    FRepository: IClienteRepository;

    function ClienteExiste(const ACodigo: Integer): Boolean;
    function FocarControle(const AControl: TWinControl): Boolean;
    function MontarCliente: TCliente;
    function NovoCodigo: Integer;
    function ValidarCampos: Boolean;
    procedure CarregarCliente(const ACodigo: Integer);
    procedure LimparCamposCliente;
    procedure NovoRegistro;
    procedure PreencherCampos(const ACliente: TCliente);
    procedure SalvarCliente;
    procedure ExcluirCliente;
    procedure FocarNome;
  end;

implementation

{$R *.dfm}

uses
  System.UITypes,
  Vcl.Dialogs,
  Vendas.Infrastructure.Persistence.Repositories.Cliente;

procedure TfrmCadastroCliente.FormCreate(Sender: TObject);
begin
  FRepository := TClienteRepository.Create;
  NovoRegistro;
end;

procedure TfrmCadastroCliente.FormShow(Sender: TObject);
begin
  FocarNome;
end;

function TfrmCadastroCliente.FocarControle(
  const AControl: TWinControl): Boolean;
begin
  Result := Showing and (AControl <> nil) and AControl.CanFocus;
  if Result then
    AControl.SetFocus;
end;

function TfrmCadastroCliente.ClienteExiste(const ACodigo: Integer): Boolean;
var
  Cliente: TCliente;
begin
  Cliente := FRepository.ObterPorId(ACodigo);
  try
    Result := Cliente <> nil;
  finally
    Cliente.Free;
  end;
end;

function TfrmCadastroCliente.NovoCodigo: Integer;
begin
  Result := FRepository.ProximoCodigo;
end;

procedure TfrmCadastroCliente.LimparCamposCliente;
begin
  edtNome.Clear;
  edtDocumento.Clear;
  edtEmail.Clear;
  edtTelefone.Clear;
  edtCidade.Clear;
  edtUF.Clear;
end;

procedure TfrmCadastroCliente.NovoRegistro;
begin
  edtCodigo.Text := IntToStr(NovoCodigo);
  LimparCamposCliente;

  FocarNome;
end;

procedure TfrmCadastroCliente.FocarNome;
begin
  FocarControle(edtNome);
end;

procedure TfrmCadastroCliente.PreencherCampos(const ACliente: TCliente);
begin
  edtCodigo.Text := IntToStr(ACliente.Id);
  edtNome.Text := ACliente.Nome;
  edtDocumento.Text := ACliente.Documento;
  edtEmail.Text := ACliente.Email;
  edtTelefone.Text := ACliente.Telefone;
  edtCidade.Text := ACliente.Cidade;
  edtUF.Text := ACliente.UF;
end;

procedure TfrmCadastroCliente.CarregarCliente(const ACodigo: Integer);
var
  Cliente: TCliente;
begin
  if ACodigo <= 0 then
    Exit;

  Cliente := FRepository.ObterPorId(ACodigo);
  try
    if Cliente <> nil then
      PreencherCampos(Cliente);
  finally
    Cliente.Free;
  end;
end;

function TfrmCadastroCliente.ValidarCampos: Boolean;
begin
  Result := False;

  if StrToIntDef(Trim(edtCodigo.Text), 0) <= 0 then
  begin
    ShowMessage('Informe um codigo valido para o cliente.');
    FocarControle(edtCodigo);
    Exit;
  end;

  if Trim(edtNome.Text) = '' then
  begin
    ShowMessage('Informe o nome do cliente.');
    FocarControle(edtNome);
    Exit;
  end;

  if (Trim(edtUF.Text) <> '') and (Length(Trim(edtUF.Text)) <> 2) then
  begin
    ShowMessage('Informe a UF com 2 caracteres.');
    FocarControle(edtUF);
    Exit;
  end;

  Result := True;
end;

function TfrmCadastroCliente.MontarCliente: TCliente;
begin
  Result := TCliente.Create;
  Result.Id := StrToIntDef(Trim(edtCodigo.Text), 0);
  Result.Nome := Trim(edtNome.Text);
  Result.Documento := Trim(edtDocumento.Text);
  Result.Email := Trim(edtEmail.Text);
  Result.Telefone := Trim(edtTelefone.Text);
  Result.Cidade := Trim(edtCidade.Text);
  Result.UF := UpperCase(Trim(edtUF.Text));
end;

procedure TfrmCadastroCliente.SalvarCliente;
var
  Cliente: TCliente;
begin
  if not ValidarCampos then
    Exit;

  Cliente := MontarCliente;
  try
    FRepository.Salvar(Cliente);
  finally
    Cliente.Free;
  end;

  ShowMessage(Format('Cliente %s salvo com sucesso.', [edtCodigo.Text]));
end;

procedure TfrmCadastroCliente.ExcluirCliente;
var
  Codigo: Integer;
begin
  Codigo := StrToIntDef(Trim(edtCodigo.Text), 0);
  if Codigo <= 0 then
  begin
    ShowMessage('Informe o codigo do cliente para excluir.');
    FocarControle(edtCodigo);
    Exit;
  end;

  if not ClienteExiste(Codigo) then
  begin
    ShowMessage('Cliente nao encontrado.');
    FocarControle(edtCodigo);
    Exit;
  end;

  if MessageDlg(
    Format('Confirma a exclusao do cliente %d?', [Codigo]),
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  FRepository.Excluir(Codigo);

  ShowMessage('Cliente excluido com sucesso.');
  NovoRegistro;
end;

procedure TfrmCadastroCliente.btnNovoClick(Sender: TObject);
begin
  NovoRegistro;
end;

procedure TfrmCadastroCliente.btnSalvarClick(Sender: TObject);
begin
  SalvarCliente;
end;

procedure TfrmCadastroCliente.btnExcluirClick(Sender: TObject);
begin
  ExcluirCliente;
end;

procedure TfrmCadastroCliente.btnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmCadastroCliente.edtCodigoExit(Sender: TObject);
var
  Codigo: Integer;
begin
  Codigo := StrToIntDef(Trim(edtCodigo.Text), 0);
  if ClienteExiste(Codigo) then
    CarregarCliente(Codigo);
end;

procedure TfrmCadastroCliente.edtCodigoKeyPress(Sender: TObject; var Key: Char);
var
  Codigo: Integer;
begin
  if not CharInSet(Key, ['0'..'9', #8, #13]) then
    Key := #0;

  if Key = #13 then
  begin
    Key := #0;
    Codigo := StrToIntDef(Trim(edtCodigo.Text), 0);
    if ClienteExiste(Codigo) then
      CarregarCliente(Codigo)
    else
      LimparCamposCliente;

    FocarNome;
  end;
end;

end.
