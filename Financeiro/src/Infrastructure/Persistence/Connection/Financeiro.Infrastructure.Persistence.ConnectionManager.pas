unit Financeiro.Infrastructure.Persistence.ConnectionManager;

interface

uses
  FireDAC.Comp.Client;

type
  TFinanceiroConexao = class
  public
    class function ArquivoBanco: string; static;
    class function Conexao: TFDConnection; static;
    class procedure Configurar; static;
    class procedure ConfigurarConexao(const AConnection: TFDConnection); static;
    class procedure Conectar; static;
    class procedure Desconectar; static;
    class function NomeConexao: string; static;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  FireDAC.Stan.Def,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.DApt,
  FireDAC.VCLUI.Wait;

var
  FConexao: TFDConnection;

class function TFinanceiroConexao.ArquivoBanco: string;
var
  Dir: string;
  PreviousDir: string;
  DataDir: string;
begin
  Dir := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));

  repeat
    if FileExists(TPath.Combine(Dir, 'ProjetoVendas.groupproj')) then
      Break;

    PreviousDir := Dir;
    Dir := ExtractFileDir(Dir);
  until SameText(Dir, PreviousDir);

  if not FileExists(TPath.Combine(Dir, 'ProjetoVendas.groupproj')) then
    Dir := ExcludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));

  DataDir := TPath.Combine(Dir, 'data');
  ForceDirectories(DataDir);

  Result := TPath.Combine(DataDir, 'ERP_FINANCEIRO.FDB');
end;

class function TFinanceiroConexao.Conexao: TFDConnection;
begin
  if FConexao = nil then
  begin
    FConexao := TFDConnection.Create(nil);
    FConexao.LoginPrompt := False;
  end;

  Result := FConexao;
end;

class procedure TFinanceiroConexao.Configurar;
var
  Conn: TFDConnection;
begin
  Conn := Conexao;
  ConfigurarConexao(Conn);
end;

class procedure TFinanceiroConexao.ConfigurarConexao(
  const AConnection: TFDConnection);
begin
  if AConnection.Connected then
    AConnection.Connected := False;

  AConnection.LoginPrompt := False;
  AConnection.DriverName := 'FB';
  AConnection.Params.Clear;
  AConnection.Params.Values['DriverID'] := 'FB';
  AConnection.Params.Values['Server'] := 'localhost';
  AConnection.Params.Values['Port'] := '3050';
  AConnection.Params.Values['Database'] := ArquivoBanco;
  AConnection.Params.Values['User_Name'] := 'SYSDBA';
  AConnection.Params.Values['Password'] := 'masterkey';
  AConnection.Params.Values['CharacterSet'] := 'UTF8';
  AConnection.Params.Values['Protocol'] := 'TCPIP';
end;

class procedure TFinanceiroConexao.Conectar;
begin
  if Conexao.Connected then
    Exit;

  Configurar;

  if not Conexao.Connected then
    Conexao.Connected := True;
end;

class procedure TFinanceiroConexao.Desconectar;
begin
  if FConexao <> nil then
    FConexao.Connected := False;
end;

class function TFinanceiroConexao.NomeConexao: string;
begin
  Result := 'ERP_FINANCEIRO';
end;

initialization

finalization
  FConexao.Free;

end.
