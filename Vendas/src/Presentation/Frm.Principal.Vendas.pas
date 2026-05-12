unit Frm.Principal.Vendas;

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
  TfrmPrincipalVendas = class(TForm)
    pnlMenu: TPanel;
    btnClientes: TButton;
    btnProdutos: TButton;
    btnPedidos: TButton;
    btnRelPedidos: TButton;
    btnDadosEmailPedido: TButton;
    btnDesbloquearUsuarios: TButton;
    lblTitulo: TLabel;
    lblStatusQuitacao: TLabel;
    tmrContaRecebida: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure btnClientesClick(Sender: TObject);
    procedure btnProdutosClick(Sender: TObject);
    procedure btnPedidosClick(Sender: TObject);
    procedure btnRelPedidosClick(Sender: TObject);
    procedure btnDadosEmailPedidoClick(Sender: TObject);
    procedure btnDesbloquearUsuariosClick(Sender: TObject);
    procedure tmrContaRecebidaTimer(Sender: TObject);
  private
    procedure ProcessarQuitacoesRecebidas;
    procedure SetStatusQuitacao(const AStatus: string);
  end;

var
  frmPrincipalVendas: TfrmPrincipalVendas;

implementation

{$R *.dfm}

uses
  Frm.Cadastro.Cliente,
  Frm.Cadastro.Produto,
  Frm.Pedido.Venda,
  Frm.Relatorio.PedidosPeriodo,
  Frm.Dados.Email.Pedido,
  Shared.Core.Security.Auth,
  Shared.Presentation.Security.UsuarioUnlock,
  Vendas.Infrastructure.Messaging.ContaRecebidaConsumer,
  Vendas.Infrastructure.Persistence.Conexao;

procedure TfrmPrincipalVendas.FormCreate(Sender: TObject);
begin
  tmrContaRecebida.Enabled := False;
  btnDesbloquearUsuarios.Visible := TAuthSession.Administrador;
  btnDadosEmailPedido.Visible := TAuthSession.Administrador;
  try
    ProcessarQuitacoesRecebidas;
  except
    on E: Exception do
      SetStatusQuitacao('Envio automatico indisponivel: ' + E.Message);
  end;
  tmrContaRecebida.Enabled := True;
end;

procedure TfrmPrincipalVendas.ProcessarQuitacoesRecebidas;
var
  Consumer: TContaRecebidaConsumer;
  Total: Integer;
begin
  Consumer := TContaRecebidaConsumer.Create;
  try
    Total := Consumer.ProcessarMensagens;
    if Total > 0 then
      SetStatusQuitacao(Format('%d relatorio(s) de quitacao enviados por e-mail.', [Total]))
    else
      SetStatusQuitacao('Aguardando quitacoes do Financeiro...');
  finally
    Consumer.Free;
  end;
end;

procedure TfrmPrincipalVendas.SetStatusQuitacao(const AStatus: string);
begin
  lblStatusQuitacao.Caption := AStatus;
end;

procedure TfrmPrincipalVendas.btnClientesClick(Sender: TObject);
var
  Form: TfrmCadastroCliente;
begin
  Form := TfrmCadastroCliente.Create(Self);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TfrmPrincipalVendas.btnProdutosClick(Sender: TObject);
var
  Form: TfrmCadastroProduto;
begin
  Form := TfrmCadastroProduto.Create(Self);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TfrmPrincipalVendas.btnPedidosClick(Sender: TObject);
var
  Form: TfrmPedidoVenda;
begin
  Form := TfrmPedidoVenda.Create(Self);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TfrmPrincipalVendas.btnRelPedidosClick(Sender: TObject);
var
  Form: TfrmRelatorioPedidosPeriodo;
begin
  Form := TfrmRelatorioPedidosPeriodo.Create(Self);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TfrmPrincipalVendas.btnDadosEmailPedidoClick(Sender: TObject);
var
  Form: TfrmDadosEmailPedido;
begin
  Form := TfrmDadosEmailPedido.Create(Self);
  try
    Form.ShowModal;
  finally
    Form.Free;
  end;
end;

procedure TfrmPrincipalVendas.btnDesbloquearUsuariosClick(Sender: TObject);
begin
  TfrmDesbloqueioUsuarios.Executar(Self, TVendasConexao.Conexao);
end;

procedure TfrmPrincipalVendas.tmrContaRecebidaTimer(Sender: TObject);
begin
  tmrContaRecebida.Enabled := False;
  try
    try
      ProcessarQuitacoesRecebidas;
    except
      on E: Exception do
        SetStatusQuitacao('Envio automatico indisponivel: ' + E.Message);
    end;
  finally
    tmrContaRecebida.Enabled := True;
  end;
end;

end.
