unit Vendas.Infrastructure.Persistence.Conexao;

interface

uses
  FireDAC.Comp.Client;

type
  TVendasConexao = class
  public
    class function ArquivoBanco: string; static;
    class function Conexao: TFDConnection; static;
    class procedure Configurar; static;
    class procedure Conectar; static;
    class procedure Desconectar; static;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  Vendas.Infrastructure.Persistence.DMConexao;

class function TVendasConexao.ArquivoBanco: string;
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

  Result := TPath.Combine(DataDir, 'ERP_VENDAS.FDB');
end;

class function TVendasConexao.Conexao: TFDConnection;
begin
  if dmConexaoVendas = nil then
    dmConexaoVendas := TdmConexaoVendas.Create(nil);

  Result := dmConexaoVendas.FDConnection;
end;

class procedure TVendasConexao.Configurar;
var
  Conn: TFDConnection;
begin
  Conn := Conexao;

  if Conn.Connected then
    Conn.Connected := False;

  Conn.LoginPrompt := False;
  Conn.DriverName := 'FB';
  Conn.Params.Clear;
  Conn.Params.Values['DriverID'] := 'FB';
  Conn.Params.Values['Server'] := 'localhost';
  Conn.Params.Values['Port'] := '3050';
  Conn.Params.Values['Database'] := ArquivoBanco;
  Conn.Params.Values['User_Name'] := 'SYSDBA';
  Conn.Params.Values['Password'] := 'masterkey';
  Conn.Params.Values['CharacterSet'] := 'UTF8';
  Conn.Params.Values['Protocol'] := 'TCPIP';
end;

class procedure TVendasConexao.Conectar;
begin
  if Conexao.Connected then
    Exit;

  Configurar;

  if not Conexao.Connected then
    Conexao.Connected := True;
end;

class procedure TVendasConexao.Desconectar;
begin
  if (dmConexaoVendas <> nil) and dmConexaoVendas.FDConnection.Connected then
    dmConexaoVendas.FDConnection.Connected := False;
end;

end.
