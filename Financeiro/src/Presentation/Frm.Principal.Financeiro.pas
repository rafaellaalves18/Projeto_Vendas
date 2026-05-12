unit Frm.Principal.Financeiro;

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
  TfrmPrincipalFinanceiro = class(TForm)
    pnlMenu: TPanel;
    btnBaixaFinanceiro: TButton;
    btnConsultaFinanceiro: TButton;
    btnRelatorioFinanceiro: TButton;
    btnDashboardVendas: TButton;
    btnDesbloquearUsuarios: TButton;
    lblTitulo: TLabel;
    lblStatusRabbitMQ: TLabel;
    tmrRabbitMQ: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnBaixaFinanceiroClick(Sender: TObject);
    procedure btnConsultaFinanceiroClick(Sender: TObject);
    procedure btnRelatorioFinanceiroClick(Sender: TObject);
    procedure btnDashboardVendasClick(Sender: TObject);
    procedure btnDesbloquearUsuariosClick(Sender: TObject);
    procedure tmrRabbitMQTimer(Sender: TObject);
  private
    procedure ProcessarRabbitMQ;
    procedure SetStatusRabbitMQ(const AStatus: string);
  end;

var
  frmPrincipalFinanceiro: TfrmPrincipalFinanceiro;

implementation

{$R *.dfm}

uses
  Frm.Baixa.Financeiro,
  Frm.Consulta.Financeiro,
  Frm.Relatorio.Financeiro,
  Frm.Dashboard.Vendas,
  Financeiro.Infrastructure.Messaging.RabbitMQConsumer,
  Financeiro.Infrastructure.Persistence.ConnectionManager,
  Financeiro.Infrastructure.Persistence.DatabaseSchema,
  Shared.Core.Security.Auth,
  Shared.Presentation.Security.UsuarioUnlock;

procedure TfrmPrincipalFinanceiro.FormCreate(Sender: TObject);
begin
  tmrRabbitMQ.Enabled := False;
  btnDesbloquearUsuarios.Visible := TAuthSession.Administrador;

  try
    TFinanceiroConexao.Conectar;
    TFinanceiroDatabaseSchema.EnsureCreated;
  except
    on E: Exception do
    begin
      SetStatusRabbitMQ('Financeiro indisponivel: ' + E.Message);
      Exit;
    end;
  end;

  tmrRabbitMQ.Enabled := True;
  try
    ProcessarRabbitMQ;
  except
    on E: Exception do
      SetStatusRabbitMQ('RabbitMQ indisponivel: ' + E.Message);
  end;
end;

procedure TfrmPrincipalFinanceiro.FormDestroy(Sender: TObject);
begin
  TFinanceiroConexao.Desconectar;
end;

procedure TfrmPrincipalFinanceiro.btnDesbloquearUsuariosClick(Sender: TObject);
begin
  TfrmDesbloqueioUsuarios.Executar(Self, TFinanceiroConexao.Conexao);
end;

procedure TfrmPrincipalFinanceiro.btnBaixaFinanceiroClick(Sender: TObject);
var
  Form: TfrmBaixaFinanceiro;
begin
  Form := TfrmBaixaFinanceiro.Create(Self);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TfrmPrincipalFinanceiro.btnConsultaFinanceiroClick(Sender: TObject);
var
  Form: TfrmConsultaFinanceiro;
begin
  Form := TfrmConsultaFinanceiro.Create(Self);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TfrmPrincipalFinanceiro.btnRelatorioFinanceiroClick(Sender: TObject);
var
  Form: TfrmRelatorioFinanceiro;
begin
  Form := TfrmRelatorioFinanceiro.Create(Self);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TfrmPrincipalFinanceiro.btnDashboardVendasClick(Sender: TObject);
var
  Form: TfrmDashboardVendas;
begin
  Form := TfrmDashboardVendas.Create(Self);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TfrmPrincipalFinanceiro.ProcessarRabbitMQ;
var
  Consumer: TFinanceiroRabbitMQConsumer;
  Total: Integer;
begin
  Consumer := TFinanceiroRabbitMQConsumer.Create;
  try
    Total := Consumer.ProcessarMensagens;
    if Total > 0 then
      SetStatusRabbitMQ(Format('%d venda(s) processada(s) do RabbitMQ.', [Total]))
    else
      SetStatusRabbitMQ('Aguardando vendas no RabbitMQ...');
  finally
    Consumer.Free;
  end;
end;

procedure TfrmPrincipalFinanceiro.SetStatusRabbitMQ(const AStatus: string);
begin
  lblStatusRabbitMQ.Caption := AStatus;
end;

procedure TfrmPrincipalFinanceiro.tmrRabbitMQTimer(Sender: TObject);
begin
  tmrRabbitMQ.Enabled := False;
  try
    try
      ProcessarRabbitMQ;
    except
      on E: Exception do
        SetStatusRabbitMQ('RabbitMQ indisponivel: ' + E.Message);
    end;
  finally
    tmrRabbitMQ.Enabled := True;
  end;
end;

end.
