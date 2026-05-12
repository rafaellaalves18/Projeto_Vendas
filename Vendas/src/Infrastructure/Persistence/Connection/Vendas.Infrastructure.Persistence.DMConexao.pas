unit Vendas.Infrastructure.Persistence.DMConexao;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Comp.Client;

type
  TdmConexaoVendas = class(TDataModule)
    FDConnection: TFDConnection;
  end;

var
  dmConexaoVendas: TdmConexaoVendas;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.VCLUI.Wait,
  FireDAC.DApt;

end.
