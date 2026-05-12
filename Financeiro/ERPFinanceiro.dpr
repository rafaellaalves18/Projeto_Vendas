program ERPFinanceiro;

uses
  System.SysUtils,
  Vcl.Forms,
  Vcl.Dialogs,
  Frm.Principal.Financeiro in 'src\Presentation\Frm.Principal.Financeiro.pas' {frmPrincipalFinanceiro},
  Frm.Baixa.Financeiro in 'src\Presentation\BaixaFinanceiro\Frm.Baixa.Financeiro.pas' {frmBaixaFinanceiro},
  Frm.Consulta.Financeiro in 'src\Presentation\ConsultaFinanceiro\Frm.Consulta.Financeiro.pas' {frmConsultaFinanceiro},
  Frm.Relatorio.Financeiro in 'src\Presentation\Relatorios\Frm.Relatorio.Financeiro.pas' {frmRelatorioFinanceiro},
  Frm.Dashboard.Vendas in 'src\Presentation\DashboardVendas\Frm.Dashboard.Vendas.pas' {frmDashboardVendas},
  Financeiro.Application.Services.ContaReceber in 'src\Application\Services\Financeiro.Application.Services.ContaReceber.pas',
  Financeiro.Application.Interfaces.Repositories in 'src\Application\Interfaces\Financeiro.Application.Interfaces.Repositories.pas',
  Financeiro.Core.Entities.ContaReceber in 'src\Core\Entities\Financeiro.Core.Entities.ContaReceber.pas',
  Financeiro.Core.Exceptions in 'src\Core\Exceptions\Financeiro.Core.Exceptions.pas',
  Financeiro.Infrastructure.Persistence.ConnectionManager in 'src\Infrastructure\Persistence\Connection\Financeiro.Infrastructure.Persistence.ConnectionManager.pas',
  Financeiro.Infrastructure.Persistence.DatabaseSchema in 'src\Infrastructure\Persistence\Schema\Financeiro.Infrastructure.Persistence.DatabaseSchema.pas',
  Financeiro.Infrastructure.Persistence.Repositories.ContaReceber in 'src\Infrastructure\Persistence\Repositories\Financeiro.Infrastructure.Persistence.Repositories.ContaReceber.pas',
  Financeiro.Infrastructure.Integration.VendaReceiver in 'src\Infrastructure\Integration\Financeiro.Infrastructure.Integration.VendaReceiver.pas',
  Financeiro.Infrastructure.Integration.VendasGateway in 'src\Infrastructure\Integration\Financeiro.Infrastructure.Integration.VendasGateway.pas',
  Financeiro.Infrastructure.Messaging.RabbitMQConsumer in 'src\Infrastructure\Messaging\Financeiro.Infrastructure.Messaging.RabbitMQConsumer.pas',
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
  Application.Title := 'ERP Financeiro';

  try
    TFinanceiroConexao.Conectar;
    TFinanceiroDatabaseSchema.EnsureCreated;
    BootstrapInfo := TAuthService.EnsureSecurity(TFinanceiroConexao.Conexao,
      Application.Title);
  except
    on E: Exception do
    begin
      ShowMessage(
        'Nao foi possivel conectar ao banco Firebird 3.0.' + sLineBreak +
        E.Message + sLineBreak + sLineBreak +
        'Banco configurado: ' + TFinanceiroConexao.ArquivoBanco + sLineBreak +
        'Servidor: localhost:3050');
      Exit;
    end;
  end;

  try
    if not TfrmLoginERP.Executar(nil, TFinanceiroConexao.Conexao,
      Application.Title, BootstrapInfo) then
      Exit;

    Application.CreateForm(TfrmPrincipalFinanceiro, frmPrincipalFinanceiro);
    Application.Run;
  finally
    TFinanceiroConexao.Desconectar;
  end;
end.
