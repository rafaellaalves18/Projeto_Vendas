unit Vendas.Application.Services.EnvioRelatorioQuitacao;

interface

uses
  Shared.Application.Contracts.Financeiro;

type
  TEnvioRelatorioQuitacaoService = class
  private
    function BuscarDadosPedido(const APedidoId: Integer; out AIdCliente: Integer;
      out ANomeCliente, AEmail: string; out AValorTotal: Currency): Boolean;
    function EmailJaEnviado(const AContaReceberId, APedidoId: Integer): Boolean;
    function GerarArquivoPdf(const APedidoId: Integer): string;
    function ProximoEmailId: Integer;
    function RegistrarEnvio(const ADTO: TContaRecebidaDTO;
      const ADestinatario, AAssunto, AArquivoPdf: string): Integer;
    procedure AtualizarEnvio(const AEmailId: Integer; const AStatus,
      AMensagemErro: string);
    procedure RegistrarErroEmail(const AEmailId, APedidoId: Integer;
      const ADestinatario, AAssunto, AArquivoPdf, AMensagemErro: string);
  public
    procedure ProcessarQuitacao(const ADTO: TContaRecebidaDTO);
    function ProcessarPendentes: Integer;
  end;

implementation

uses
  System.IOUtils,
  System.SysUtils,
  FireDAC.Comp.Client,
  Data.DB,
  Frm.Relatorio.PedidoConfirmacao,
  Vendas.Infrastructure.Mail.SmtpClient,
  Vendas.Infrastructure.Persistence.Conexao;

const
  EMAIL_STATUS_PENDENTE = 'PENDENTE';
  EMAIL_STATUS_ENVIADO = 'ENVIADO';
  EMAIL_STATUS_ERRO = 'ERRO';
  MAX_TENTATIVAS_ENVIO = 3;

function TEnvioRelatorioQuitacaoService.BuscarDadosPedido(
  const APedidoId: Integer; out AIdCliente: Integer; out ANomeCliente,
  AEmail: string; out AValorTotal: Currency): Boolean;
var
  Query: TFDQuery;
begin
  AIdCliente := 0;
  ANomeCliente := '';
  AEmail := '';
  AValorTotal := 0;
  Result := False;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := TVendasConexao.Conexao;
    Query.SQL.Text :=
      'select p.id_cliente, p.nome_cliente, p.valor_total, c.email ' +
      'from pedidos_venda p ' +
      'left join clientes c on c.id_cliente = p.id_cliente ' +
      'where p.id_pedido = :id_pedido';
    Query.ParamByName('id_pedido').AsInteger := APedidoId;
    Query.Open;

    if Query.IsEmpty then
      Exit;

    AIdCliente := Query.FieldByName('id_cliente').AsInteger;
    ANomeCliente := Query.FieldByName('nome_cliente').AsString;
    AEmail := Trim(Query.FieldByName('email').AsString);
    AValorTotal := Query.FieldByName('valor_total').AsCurrency;
    Result := True;
  finally
    Query.Free;
  end;
end;

function TEnvioRelatorioQuitacaoService.EmailJaEnviado(
  const AContaReceberId, APedidoId: Integer): Boolean;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := TVendasConexao.Conexao;
    Query.SQL.Text :=
      'select count(*) ' +
      'from emails_quitacao ' +
      'where status = :status ' +
      'and ((:usa_conta = 1 and id_conta_receber = :id_conta_receber) ' +
      '     or id_pedido = :id_pedido)';
    Query.ParamByName('status').AsString := EMAIL_STATUS_ENVIADO;
    Query.ParamByName('usa_conta').AsInteger := Ord(AContaReceberId > 0);
    Query.ParamByName('id_conta_receber').AsInteger := AContaReceberId;
    Query.ParamByName('id_pedido').AsInteger := APedidoId;
    Query.Open;
    Result := Query.Fields[0].AsInteger > 0;
  finally
    Query.Free;
  end;
end;

function TEnvioRelatorioQuitacaoService.GerarArquivoPdf(
  const APedidoId: Integer): string;
var
  Dir: string;
begin
  Dir := TPath.Combine(ExtractFilePath(ParamStr(0)), 'relatorios_email');
  ForceDirectories(Dir);

  Result := TPath.Combine(Dir, Format('pedido_%d_quitacao_%s.pdf',
    [APedidoId, FormatDateTime('yyyymmdd_hhnnss', Now)]));
  TfrmRelatorioPedidoConfirmacao.ExportarPedidoPdf(APedidoId, Result);
end;

function TEnvioRelatorioQuitacaoService.ProximoEmailId: Integer;
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := TVendasConexao.Conexao;
    Query.SQL.Text :=
      'select next value for gen_emails_quitacao_id as id_email ' +
      'from rdb$database';
    Query.Open;
    Result := Query.FieldByName('id_email').AsInteger;
  finally
    Query.Free;
  end;
end;

function TEnvioRelatorioQuitacaoService.RegistrarEnvio(
  const ADTO: TContaRecebidaDTO; const ADestinatario, AAssunto,
  AArquivoPdf: string): Integer;
var
  Query: TFDQuery;
begin
  Result := ProximoEmailId;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := TVendasConexao.Conexao;
    Query.SQL.Text :=
      'insert into emails_quitacao (' +
      '  id_email, id_conta_receber, id_pedido, id_cliente, destinatario, ' +
      '  assunto, arquivo_pdf, status, tentativas, mensagem_erro, ' +
      '  data_criacao, data_envio' +
      ') values (' +
      '  :id_email, :id_conta_receber, :id_pedido, :id_cliente, :destinatario, ' +
      '  :assunto, :arquivo_pdf, :status, 0, null, current_timestamp, null' +
      ')';
    Query.ParamByName('id_email').AsInteger := Result;
    Query.ParamByName('id_conta_receber').AsInteger := ADTO.IdContaReceber;
    Query.ParamByName('id_pedido').AsInteger := ADTO.IdVenda;
    Query.ParamByName('id_cliente').AsInteger := ADTO.IdCliente;
    Query.ParamByName('destinatario').AsString := ADestinatario;
    Query.ParamByName('assunto').AsString := AAssunto;
    Query.ParamByName('arquivo_pdf').AsString := AArquivoPdf;
    Query.ParamByName('status').AsString := EMAIL_STATUS_PENDENTE;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TEnvioRelatorioQuitacaoService.AtualizarEnvio(
  const AEmailId: Integer; const AStatus, AMensagemErro: string);
var
  Query: TFDQuery;
begin
  Query := TFDQuery.Create(nil);
  try
    Query.Connection := TVendasConexao.Conexao;
    Query.SQL.Text :=
      'update emails_quitacao ' +
      'set status = :status, ' +
      '    tentativas = tentativas + 1, ' +
      '    mensagem_erro = :mensagem_erro, ' +
      '    data_envio = case when :status_envio = :status_enviado then current_timestamp else data_envio end ' +
      'where id_email = :id_email';
    Query.ParamByName('status').AsString := AStatus;
    Query.ParamByName('status_envio').AsString := AStatus;
    Query.ParamByName('status_enviado').AsString := EMAIL_STATUS_ENVIADO;
    Query.ParamByName('mensagem_erro').AsString := Copy(AMensagemErro, 1, 500);
    Query.ParamByName('id_email').AsInteger := AEmailId;
    Query.ExecSQL;
  finally
    Query.Free;
  end;
end;

procedure TEnvioRelatorioQuitacaoService.RegistrarErroEmail(
  const AEmailId, APedidoId: Integer; const ADestinatario, AAssunto,
  AArquivoPdf, AMensagemErro: string);
var
  LogDir: string;
  LogFile: string;
  Texto: string;
begin
  try
    LogDir := TPath.Combine(ExtractFilePath(ParamStr(0)), 'logs');
    ForceDirectories(LogDir);

    LogFile := TPath.Combine(LogDir,
      Format('email_envio_%s.txt', [FormatDateTime('yyyymmdd', Date)]));

    Texto :=
      StringOfChar('-', 80) + sLineBreak +
      'Data/hora: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + sLineBreak +
      Format('EmailId: %d', [AEmailId]) + sLineBreak +
      Format('PedidoId: %d', [APedidoId]) + sLineBreak +
      'Destinatario: ' + ADestinatario + sLineBreak +
      'Assunto: ' + AAssunto + sLineBreak +
      'Arquivo PDF: ' + AArquivoPdf + sLineBreak +
      'Erro: ' + AMensagemErro + sLineBreak + sLineBreak;

    TFile.AppendAllText(LogFile, Texto, TEncoding.UTF8);
  except
    // Falha no log nao pode mascarar o erro original do envio.
  end;
end;

procedure TEnvioRelatorioQuitacaoService.ProcessarQuitacao(
  const ADTO: TContaRecebidaDTO);
var
  IdCliente: Integer;
  NomeCliente: string;
  Email: string;
  ValorTotal: Currency;
  ArquivoPdf: string;
  Assunto: string;
  Corpo: string;
  EmailId: Integer;
begin
  if ADTO.IdVenda <= 0 then
    raise Exception.Create('Evento de quitacao sem pedido de origem.');

  if EmailJaEnviado(ADTO.IdContaReceber, ADTO.IdVenda) then
    Exit;

  if not BuscarDadosPedido(ADTO.IdVenda, IdCliente, NomeCliente, Email,
    ValorTotal) then
    raise Exception.CreateFmt('Pedido %d nao encontrado no ERP Vendas.',
      [ADTO.IdVenda]);

  ArquivoPdf := GerarArquivoPdf(ADTO.IdVenda);
  Assunto := Format('Comprovante de quitacao do pedido %d', [ADTO.IdVenda]);
  EmailId := RegistrarEnvio(ADTO, Email, Assunto, ArquivoPdf);

  try
    Corpo :=
      Format('Ola, %s,' + sLineBreak + sLineBreak +
        'Recebemos a quitacao do pedido %d no valor de R$ %s.' + sLineBreak +
        'O comprovante segue em anexo.' + sLineBreak + sLineBreak +
        'ERP Vendas',
        [NomeCliente, ADTO.IdVenda, FormatFloat('#,##0.00', ValorTotal)]);

    TSmtpEmailClient.EnviarEmail(Email, Assunto, Corpo, ArquivoPdf);
    AtualizarEnvio(EmailId, EMAIL_STATUS_ENVIADO, '');
  except
    on E: Exception do
    begin
      RegistrarErroEmail(EmailId, ADTO.IdVenda, Email, Assunto, ArquivoPdf,
        E.ClassName + ': ' + E.Message);
      AtualizarEnvio(EmailId, EMAIL_STATUS_ERRO, E.Message);
      raise;
    end;
  end;
end;

function TEnvioRelatorioQuitacaoService.ProcessarPendentes: Integer;
var
  Query: TFDQuery;
  EmailId: Integer;
  PedidoId: Integer;
  Destinatario: string;
  Assunto: string;
  ArquivoPdf: string;
  Corpo: string;
begin
  Result := 0;

  Query := TFDQuery.Create(nil);
  try
    Query.Connection := TVendasConexao.Conexao;
    Query.SQL.Text :=
      'select first 10 id_email, id_pedido, destinatario, assunto, arquivo_pdf ' +
      'from emails_quitacao ' +
      'where status in (:status_pendente, :status_erro) ' +
      'and tentativas < :max_tentativas ' +
      'order by data_criacao';
    Query.ParamByName('status_pendente').AsString := EMAIL_STATUS_PENDENTE;
    Query.ParamByName('status_erro').AsString := EMAIL_STATUS_ERRO;
    Query.ParamByName('max_tentativas').AsInteger := MAX_TENTATIVAS_ENVIO;
    Query.Open;

    while not Query.Eof do
    begin
      EmailId := Query.FieldByName('id_email').AsInteger;
      PedidoId := Query.FieldByName('id_pedido').AsInteger;
      Destinatario := Trim(Query.FieldByName('destinatario').AsString);
      Assunto := Query.FieldByName('assunto').AsString;
      ArquivoPdf := Query.FieldByName('arquivo_pdf').AsString;

      try
        if (Trim(ArquivoPdf) = '') or (not FileExists(ArquivoPdf)) then
          ArquivoPdf := GerarArquivoPdf(PedidoId);

        Corpo :=
          Format('Ola,' + sLineBreak + sLineBreak +
            'Recebemos a quitacao do pedido %d.' + sLineBreak +
            'O comprovante segue em anexo.' + sLineBreak + sLineBreak +
            'ERP Vendas', [PedidoId]);

        TSmtpEmailClient.EnviarEmail(Destinatario, Assunto, Corpo, ArquivoPdf);
        AtualizarEnvio(EmailId, EMAIL_STATUS_ENVIADO, '');
        Inc(Result);
      except
        on E: Exception do
        begin
          RegistrarErroEmail(EmailId, PedidoId, Destinatario, Assunto,
            ArquivoPdf, E.ClassName + ': ' + E.Message);
          AtualizarEnvio(EmailId, EMAIL_STATUS_ERRO, E.Message);
        end;
      end;

      Query.Next;
    end;
  finally
    Query.Free;
  end;
end;

end.
