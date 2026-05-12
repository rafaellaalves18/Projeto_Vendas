program ERPVendas;

uses
  System.SysUtils,
  Vcl.Forms,
  Vcl.Dialogs,
  Vendas.Infrastructure.Persistence.DMConexao in 'src\Infrastructure\Persistence\Connection\Vendas.Infrastructure.Persistence.DMConexao.pas' {dmConexaoVendas: TDataModule},
  Vendas.Infrastructure.Persistence.Conexao in 'src\Infrastructure\Persistence\Connection\Vendas.Infrastructure.Persistence.Conexao.pas',
  Frm.Principal.Vendas in 'src\Presentation\Frm.Principal.Vendas.pas' {frmPrincipalVendas},
  Frm.Cadastro.Cliente in 'src\Presentation\Clientes\Frm.Cadastro.Cliente.pas' {frmCadastroCliente},
  Frm.Cadastro.Produto in 'src\Presentation\Produtos\Frm.Cadastro.Produto.pas' {frmCadastroProduto},
  Frm.Pedido.Venda in 'src\Presentation\Pedidos\Frm.Pedido.Venda.pas' {frmPedidoVenda},
  Frm.Dados.Email.Pedido in 'src\Presentation\Configuracoes\Frm.Dados.Email.Pedido.pas' {frmDadosEmailPedido},
  Frm.Relatorio.PedidoConfirmacao in 'src\Presentation\Relatorios\Frm.Relatorio.PedidoConfirmacao.pas',
  Frm.Relatorio.PedidosPeriodo in 'src\Presentation\Relatorios\Frm.Relatorio.PedidosPeriodo.pas' {frmRelatorioPedidosPeriodo},
  Vendas.Application.Services.PedidoVenda in 'src\Application\Services\Vendas.Application.Services.PedidoVenda.pas',
  Vendas.Application.Interfaces.Repositories in 'src\Application\Interfaces\Vendas.Application.Interfaces.Repositories.pas',
  Vendas.Core.Entities.Cliente in 'src\Core\Entities\Vendas.Core.Entities.Cliente.pas',
  Vendas.Core.Entities.Produto in 'src\Core\Entities\Vendas.Core.Entities.Produto.pas',
  Vendas.Core.Entities.PedidoVenda in 'src\Core\Entities\Vendas.Core.Entities.PedidoVenda.pas',
  Vendas.Core.Exceptions in 'src\Core\Exceptions\Vendas.Core.Exceptions.pas',
  Vendas.Infrastructure.Persistence.DatabaseSchema in 'src\Infrastructure\Persistence\Schema\Vendas.Infrastructure.Persistence.DatabaseSchema.pas',
  Vendas.Infrastructure.Persistence.Repositories.Cliente in 'src\Infrastructure\Persistence\Repositories\Vendas.Infrastructure.Persistence.Repositories.Cliente.pas',
  Vendas.Infrastructure.Persistence.Repositories.Produto in 'src\Infrastructure\Persistence\Repositories\Vendas.Infrastructure.Persistence.Repositories.Produto.pas',
  Vendas.Infrastructure.Persistence.Repositories.PedidoVenda in 'src\Infrastructure\Persistence\Repositories\Vendas.Infrastructure.Persistence.Repositories.PedidoVenda.pas',
  Vendas.Infrastructure.Integration.FinanceiroGateway in 'src\Infrastructure\Integration\Vendas.Infrastructure.Integration.FinanceiroGateway.pas',
  Vendas.Infrastructure.Messaging.ContaRecebidaConsumer in 'src\Infrastructure\Messaging\Vendas.Infrastructure.Messaging.ContaRecebidaConsumer.pas',
  Vendas.Infrastructure.Mail.SmtpClient in 'src\Infrastructure\Mail\Vendas.Infrastructure.Mail.SmtpClient.pas',
  Vendas.Application.Services.EnvioRelatorioQuitacao in 'src\Application\Services\Vendas.Application.Services.EnvioRelatorioQuitacao.pas',
  Shared.Application.Contracts.Financeiro in '..\Shared\src\Application\Contracts\Shared.Application.Contracts.Financeiro.pas',
  Shared.Infrastructure.Messaging.RabbitMQ in '..\Shared\src\Infrastructure\Messaging\Shared.Infrastructure.Messaging.RabbitMQ.pas',
  Shared.Core.Types in '..\Shared\src\Core\Shared.Core.Types.pas',
  Shared.Core.Security.Auth in '..\Shared\src\Core\Shared.Core.Security.Auth.pas',
  Shared.Presentation.Security.Login in '..\Shared\src\Presentation\Security\Shared.Presentation.Security.Login.pas',
  Shared.Presentation.Security.AdminRecovery in '..\Shared\src\Presentation\Security\Shared.Presentation.Security.AdminRecovery.pas',
  Shared.Presentation.Security.UsuarioUnlock in '..\Shared\src\Presentation\Security\Shared.Presentation.Security.UsuarioUnlock.pas';

var
  BootstrapInfo: TAuthBootstrapInfo;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'ERP Vendas';
  Application.CreateForm(TdmConexaoVendas, dmConexaoVendas);

  try
    TVendasConexao.Conectar;
    TVendasDatabaseSchema.EnsureCreated;
    BootstrapInfo := TAuthService.EnsureSecurity(TVendasConexao.Conexao,
      Application.Title);
  except
    on E: Exception do
    begin
      ShowMessage(
        'Nao foi possivel conectar ao banco Firebird 3.0.' + sLineBreak +
        E.Message + sLineBreak + sLineBreak +
        'Banco configurado: ' + TVendasConexao.ArquivoBanco + sLineBreak +
        'Servidor: localhost:3050');
      Exit;
    end;
  end;

  try
    if not TfrmLoginERP.Executar(nil, TVendasConexao.Conexao,
      Application.Title, BootstrapInfo) then
      Exit;

    Application.CreateForm(TfrmPrincipalVendas, frmPrincipalVendas);
    Application.Run;
  finally
    TVendasConexao.Desconectar;
  end;
end.
