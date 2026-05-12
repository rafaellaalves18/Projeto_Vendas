unit Frm.Dados.Email.Pedido;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls;

type
  TfrmDadosEmailPedido = class(TForm)
    pnlTitulo: TPanel;
    lblTitulo: TLabel;
    lblHost: TLabel;
    lblPorta: TLabel;
    lblUsuario: TLabel;
    lblSenha: TLabel;
    lblEmailRemetente: TLabel;
    lblNomeRemetente: TLabel;
    edtHost: TEdit;
    edtPorta: TEdit;
    edtUsuario: TEdit;
    edtSenha: TEdit;
    edtEmailRemetente: TEdit;
    edtNomeRemetente: TEdit;
    lblSeguranca: TLabel;
    cbxSeguranca: TComboBox;
    pnlBotoes: TPanel;
    btnSalvar: TButton;
    btnSair: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure edtPortaKeyPress(Sender: TObject; var Key: Char);
    procedure cbxSegurancaChange(Sender: TObject);
  private
    function CodigoSegurancaSMTP: string;
    function IndiceSegurancaSMTP(const AValor: string; APorta: Integer): Integer;
    function Porta: Integer;
    function ValidarDados: Boolean;
    procedure CarregarConfiguracao;
    procedure SalvarConfiguracao;
  public
  end;

implementation

{$R *.dfm}

uses
  Data.DB,
  FireDAC.Comp.Client,
  Vcl.Dialogs,
  Vendas.Infrastructure.Persistence.Conexao,
  Vendas.Infrastructure.Persistence.DatabaseSchema;

procedure TfrmDadosEmailPedido.FormCreate(Sender: TObject);
begin
  cbxSeguranca.ItemIndex := 0;
  TVendasDatabaseSchema.EnsureCreated;
  CarregarConfiguracao;
end;

function TfrmDadosEmailPedido.CodigoSegurancaSMTP: string;
begin
  case cbxSeguranca.ItemIndex of
    1:
      Result := 'I';
    2:
      Result := 'N';
  else
    Result := 'E';
  end;
end;

function TfrmDadosEmailPedido.IndiceSegurancaSMTP(const AValor: string;
  APorta: Integer): Integer;
var
  Valor: string;
begin
  Valor := UpperCase(Trim(AValor));

  if Valor = 'N' then
    Exit(2);

  if (Valor = 'I') or (APorta = 465) then
    Exit(1);

  Result := 0;
end;

function TfrmDadosEmailPedido.Porta: Integer;
begin
  Result := StrToIntDef(Trim(edtPorta.Text), 0);
end;

function TfrmDadosEmailPedido.ValidarDados: Boolean;
begin
  Result := False;

  if Trim(edtHost.Text) = '' then
  begin
    ShowMessage('Informe o servidor SMTP.');
    edtHost.SetFocus;
    Exit;
  end;

  if (Porta <= 0) or (Porta > 65535) then
  begin
    ShowMessage('Informe uma porta SMTP valida.');
    edtPorta.SetFocus;
    edtPorta.SelectAll;
    Exit;
  end;

  if Trim(edtUsuario.Text) = '' then
  begin
    ShowMessage('Informe o usuario SMTP.');
    edtUsuario.SetFocus;
    Exit;
  end;

  if Trim(edtSenha.Text) = '' then
  begin
    ShowMessage('Informe a senha SMTP.');
    edtSenha.SetFocus;
    Exit;
  end;

  if Trim(edtEmailRemetente.Text) = '' then
  begin
    ShowMessage('Informe o e-mail remetente.');
    edtEmailRemetente.SetFocus;
    Exit;
  end;

  if Trim(edtNomeRemetente.Text) = '' then
    edtNomeRemetente.Text := 'ERP Vendas';

  Result := True;
end;

procedure TfrmDadosEmailPedido.CarregarConfiguracao;
var
  Query: TFDQuery;
begin
  edtHost.Clear;
  edtPorta.Text := '587';
  edtUsuario.Clear;
  edtSenha.Clear;
  edtEmailRemetente.Clear;
  edtNomeRemetente.Text := 'ERP Vendas';
  cbxSeguranca.ItemIndex := 0;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := TVendasConexao.Conexao;
    Query.SQL.Text :=
      'select first 1 host, porta, usuario, senha, email_remetente, ' +
      '       nome_remetente, usar_tls ' +
      'from config_email_pedido ' +
      'where id_config = 1';
    Query.Open;

    if Query.IsEmpty then
      Exit;

    edtHost.Text := Query.FieldByName('host').AsString;
    edtPorta.Text := Query.FieldByName('porta').AsString;
    edtUsuario.Text := Query.FieldByName('usuario').AsString;
    edtSenha.Text := Query.FieldByName('senha').AsString;
    edtEmailRemetente.Text := Query.FieldByName('email_remetente').AsString;
    edtNomeRemetente.Text := Query.FieldByName('nome_remetente').AsString;
    cbxSeguranca.ItemIndex := IndiceSegurancaSMTP(
      Query.FieldByName('usar_tls').AsString,
      Query.FieldByName('porta').AsInteger
    );
  finally
    Query.Free;
  end;
end;

procedure TfrmDadosEmailPedido.SalvarConfiguracao;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := TVendasConexao.Conexao;
    Query.SQL.Text :=
      'update or insert into config_email_pedido (' +
      '  id_config, host, porta, usuario, senha, email_remetente, ' +
      '  nome_remetente, usar_tls, data_atualizacao' +
      ') values (' +
      '  1, :host, :porta, :usuario, :senha, :email_remetente, ' +
      '  :nome_remetente, :usar_tls, current_timestamp' +
      ') matching (id_config)';
    Query.ParamByName('host').AsString := Trim(edtHost.Text);
    Query.ParamByName('porta').AsInteger := Porta;
    Query.ParamByName('usuario').AsString := Trim(edtUsuario.Text);
    Query.ParamByName('senha').AsString := edtSenha.Text;
    Query.ParamByName('email_remetente').AsString := Trim(edtEmailRemetente.Text);
    Query.ParamByName('nome_remetente').AsString := Trim(edtNomeRemetente.Text);
    Query.ParamByName('usar_tls').AsString := CodigoSegurancaSMTP;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TfrmDadosEmailPedido.btnSalvarClick(Sender: TObject);
begin
  if not ValidarDados then
    Exit;

  SalvarConfiguracao;
  ShowMessage('Dados de e-mail do pedido salvos com sucesso.');
end;

procedure TfrmDadosEmailPedido.btnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmDadosEmailPedido.cbxSegurancaChange(Sender: TObject);
begin
  case cbxSeguranca.ItemIndex of
    0:
      if (Trim(edtPorta.Text) = '') or (Porta = 465) then
        edtPorta.Text := '587';
    1:
      if (Trim(edtPorta.Text) = '') or (Porta = 587) then
        edtPorta.Text := '465';
    2:
      if Trim(edtPorta.Text) = '' then
        edtPorta.Text := '25';
  end;
end;

procedure TfrmDadosEmailPedido.edtPortaKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', #8]) then
    Key := #0;
end;

end.
