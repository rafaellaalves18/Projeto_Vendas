unit Vendas.Infrastructure.Mail.SmtpClient;

interface

type
  TSmtpSecurityMode = (ssmStartTLS, ssmImplicitTLS, ssmNoTLS);

  TSmtpConfig = record
    Host: string;
    Port: Integer;
    UserName: string;
    Password: string;
    FromEmail: string;
    FromName: string;
    SecurityMode: TSmtpSecurityMode;

    class function LoadDefault: TSmtpConfig; static;
  end;

  TSmtpEmailClient = class
  public
    class procedure EnviarEmail(const ADestinatario, AAssunto, ACorpo,
      AAnexo: string); static;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  Data.DB,
  FireDAC.Comp.Client,
  IdAttachmentFile,
  IdExplicitTLSClientServerBase,
  IdMessage,
  IdSMTP,
  IdSSLOpenSSL,
  IdSSLOpenSSLHeaders,
  Vendas.Infrastructure.Persistence.Conexao;

const
  SMTP_SECURITY_IMPLICIT = 'I';
  SMTP_SECURITY_NONE = 'N';

function NormalizarModoSegurancaSMTP(const AValor: string;
  APorta: Integer): TSmtpSecurityMode;
var
  Valor: string;
begin
  Valor := UpperCase(Trim(AValor));

  if Valor = SMTP_SECURITY_NONE then
    Exit(ssmNoTLS);

  if (Valor = SMTP_SECURITY_IMPLICIT) or (APorta = 465) then
    Exit(ssmImplicitTLS);

  Result := ssmStartTLS;
end;

function DescricaoSegurancaSMTP(const AConfig: TSmtpConfig): string;
begin
  case AConfig.SecurityMode of
    ssmImplicitTLS:
      Result := 'SSL/TLS implicito';
    ssmNoTLS:
      Result := 'sem TLS';
  else
    Result := 'STARTTLS';
  end;
end;

function DiretorioRaizProjeto: string;
var
  AppDir: string;
  Dir: string;
  PreviousDir: string;
begin
  AppDir := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  Dir := AppDir;

  repeat
    if FileExists(TPath.Combine(Dir, 'ProjetoVendas.groupproj')) then
      Break;

    PreviousDir := Dir;
    Dir := ExtractFileDir(Dir);
  until SameText(Dir, PreviousDir);

  if not FileExists(TPath.Combine(Dir, 'ProjetoVendas.groupproj')) then
    Dir := AppDir;

  Result := Dir;
end;

function DiretorioOpenSSL: string;
var
  AppDir: string;
  LibDir: string;
begin
  AppDir := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));

  if FileExists(TPath.Combine(AppDir, 'libeay32.dll')) and
     FileExists(TPath.Combine(AppDir, 'ssleay32.dll')) then
    Exit(AppDir);

  LibDir := TPath.Combine(
    TPath.Combine(TPath.Combine(DiretorioRaizProjeto, 'Vendas'), 'lib'),
    TPath.Combine('openssl', 'x86')
  );

  if FileExists(TPath.Combine(LibDir, 'libeay32.dll')) and
     FileExists(TPath.Combine(LibDir, 'ssleay32.dll')) then
    Exit(LibDir);

  Result := '';
end;

procedure ConfigurarOpenSSL;
var
  DirOpenSSL: string;
begin
  DirOpenSSL := DiretorioOpenSSL;
  if DirOpenSSL = '' then
    raise Exception.Create(
      'Nao foram encontradas as DLLs OpenSSL 32-bit para envio de e-mail. ' +
      'Mantenha libeay32.dll e ssleay32.dll ao lado do ERPVendas.exe ou em Vendas\lib\openssl\x86.'
    );

  IdOpenSSLSetLibPath(DirOpenSSL);

  if not LoadOpenSSLLibrary then
    raise Exception.Create(
      'Nao foi possivel carregar as DLLs OpenSSL usadas no envio de e-mail. ' +
      WhichFailedToLoad
    );
end;

function MensagemErroTLS(const AConfig: TSmtpConfig; const AErro: Exception): string;
begin
  Result := Format(
    'Falha na negociacao SSL/TLS com o servidor SMTP. ' +
    'Configuracao atual: host=%s, porta=%d, seguranca=%s, OpenSSL=%s. ' +
    'Erro original: %s: %s',
    [
      AConfig.Host,
      AConfig.Port,
      DescricaoSegurancaSMTP(AConfig),
      OpenSSLVersion,
      AErro.ClassName,
      AErro.Message
    ]
  );
end;

function DeveTentarFallbackGmail(const AConfig: TSmtpConfig): Boolean;
begin
  Result :=
    SameText(AConfig.Host, 'smtp.gmail.com') and
    (AConfig.Port = 587) and
    (AConfig.SecurityMode = ssmStartTLS);
end;

procedure EnviarEmailSMTP(const AConfig: TSmtpConfig; const ADestinatario,
  AAssunto, ACorpo, AAnexo: string);
var
  Message: TIdMessage;
  SMTP: TIdSMTP;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  Message := TIdMessage.Create(nil);
  SMTP := TIdSMTP.Create(nil);
  try
    Message.From.Address := AConfig.FromEmail;
    Message.From.Name := AConfig.FromName;
    Message.Recipients.EmailAddresses := ADestinatario;
    Message.Subject := AAssunto;
    Message.Body.Text := ACorpo;

    if Trim(AAnexo) <> '' then
      TIdAttachmentFile.Create(Message.MessageParts, AAnexo);

    SMTP.Host := AConfig.Host;
    SMTP.Port := AConfig.Port;
    SMTP.Username := AConfig.UserName;
    SMTP.Password := AConfig.Password;
    SMTP.ConnectTimeout := 15000;
    SMTP.ReadTimeout := 45000;

    if AConfig.SecurityMode <> ssmNoTLS then
    begin
      ConfigurarOpenSSL;

      SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(SMTP);
      SSLHandler.SSLOptions.Mode := sslmClient;
      SSLHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
      SSLHandler.SSLOptions.CipherList := 'HIGH:!aNULL:!eNULL:!SSLv2:!SSLv3';
      SMTP.IOHandler := SSLHandler;

      if AConfig.SecurityMode = ssmImplicitTLS then
        SMTP.UseTLS := utUseImplicitTLS
      else
        SMTP.UseTLS := utUseExplicitTLS;
    end
    else
      SMTP.UseTLS := utNoTLSSupport;

    SMTP.Connect;
    try
      SMTP.Send(Message);
    finally
      SMTP.Disconnect;
    end;
  finally
    Message.Free;
    SMTP.Free;
  end;
end;

class function TSmtpConfig.LoadDefault: TSmtpConfig;
var
  Query: TFDQuery;
begin
  Result.Host := '';
  Result.Port := 587;
  Result.UserName := '';
  Result.Password := '';
  Result.FromEmail := '';
  Result.FromName := 'ERP Vendas';
  Result.SecurityMode := ssmStartTLS;

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

    Result.Host := Trim(Query.FieldByName('host').AsString);
    Result.Port := Query.FieldByName('porta').AsInteger;
    Result.UserName := Trim(Query.FieldByName('usuario').AsString);
    Result.Password := Query.FieldByName('senha').AsString;
    Result.FromEmail := Trim(Query.FieldByName('email_remetente').AsString);
    Result.FromName := Trim(Query.FieldByName('nome_remetente').AsString);
    Result.SecurityMode := NormalizarModoSegurancaSMTP(
      Query.FieldByName('usar_tls').AsString,
      Result.Port
    );
  finally
    Query.Free;
  end;
end;

class procedure TSmtpEmailClient.EnviarEmail(const ADestinatario, AAssunto,
  ACorpo, AAnexo: string);
var
  Config: TSmtpConfig;
  ConfigFallback: TSmtpConfig;
begin
  Config := TSmtpConfig.LoadDefault;
  if Trim(Config.Host) = '' then
    raise Exception.Create('Configure os dados de e-mail do pedido no ERP Vendas.');

  if Trim(Config.FromEmail) = '' then
    raise Exception.Create('Configure o e-mail remetente em Dados Email Pedido.');

  if Trim(ADestinatario) = '' then
    raise Exception.Create('Cliente sem e-mail cadastrado.');

  try
    EnviarEmailSMTP(Config, ADestinatario, AAssunto, ACorpo, AAnexo);
  except
    on E: EIdTLSClientTLSHandShakeFailed do
    begin
      if DeveTentarFallbackGmail(Config) then
      begin
        ConfigFallback := Config;
        ConfigFallback.Port := 465;
        ConfigFallback.SecurityMode := ssmImplicitTLS;
        try
          EnviarEmailSMTP(ConfigFallback, ADestinatario, AAssunto, ACorpo, AAnexo);
          Exit;
        except
          on EFallback: EIdTLSClientTLSHandShakeFailed do
            raise Exception.Create(MensagemErroTLS(ConfigFallback, EFallback));
        end;
      end;

      raise Exception.Create(MensagemErroTLS(Config, E));
    end;
    on E: EIdOpenSSLError do
      raise Exception.Create(MensagemErroTLS(Config, E));
  end;
end;

end.
