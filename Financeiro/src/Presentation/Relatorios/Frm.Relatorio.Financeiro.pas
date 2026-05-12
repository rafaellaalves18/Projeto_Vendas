unit Frm.Relatorio.Financeiro;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  FireDAC.Comp.Client,
  Data.DB,
  ppBands,
  ppClass,
  ppCtrls,
  ppDB,
  ppDBPipe,
  ppDesignLayer,
  ppParameter,
  ppReport,
  ppTypes,
  ppVar, FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error,
  FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool,
  FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB, FireDAC.Phys.FBDef,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, ppStrtch,
  ppSubRpt, ppPrnabl, ppCache, ppProd, ppComm, ppRelatv, FireDAC.Comp.DataSet;

type
  TfrmRelatorioFinanceiro = class(TForm)
    FPnlTitulo: TPanel;
    FPnlFiltros: TPanel;
    FPnlBotoes: TPanel;
    FLblTitulo: TLabel;
    FLblDataInicial: TLabel;
    FLblDataFinal: TLabel;
    FLblTipoData: TLabel;
    FLblStatus: TLabel;
    FLblCliente: TLabel;
    FDtpInicial: TDateTimePicker;
    FDtpFinal: TDateTimePicker;
    FCbxTipoData: TComboBox;
    FCbxStatus: TComboBox;
    FEdtCodCliente: TEdit;
    FEdtNomeCliente: TEdit;
    FBtnVisualizar: TButton;
    FBtnSair: TButton;
    FConexaoFinanceiro: TFDConnection;
    FQryFinanceiro: TFDQuery;
    FQryResumo: TFDQuery;
    FDSFinanceiro: TDataSource;
    FDSResumo: TDataSource;
    FPipeFinanceiro: TppDBPipeline;
    FPipeResumo: TppDBPipeline;
    FQryFinanceiroID_CONTA_RECEBER: TIntegerField;
    FQryFinanceiroID_ORIGEM: TIntegerField;
    FQryFinanceiroID_CLIENTE: TIntegerField;
    FQryFinanceiroNOME_CLIENTE: TWideStringField;
    FQryFinanceiroDATA_EMISSAO: TSQLTimeStampField;
    FQryFinanceiroDATA_VENCIMENTO: TSQLTimeStampField;
    FQryFinanceiroVALOR_FINANCEIRO: TBCDField;
    FQryFinanceiroSTATUS: TWideStringField;
    FQryFinanceiroSTATUS_DESCRICAO: TWideStringField;
    FQryResumoQTD_CONTAS: TLargeintField;
    FQryResumoVALOR_TOTAL: TBCDField;
    FQryResumoVALOR_ABERTO: TBCDField;
    FQryResumoVALOR_FECHADO: TBCDField;
    FQryResumoVALOR_CANCELADO: TBCDField;
    ppReport1: TppReport;
    ppParameterList1: TppParameterList;
    ppDesignLayers1: TppDesignLayers;
    ppDesignLayer1: TppDesignLayer;
    ppHeaderBand1: TppHeaderBand;
    ppDetailBand1: TppDetailBand;
    ppFooterBand1: TppFooterBand;
    ppLabel1: TppLabel;
    ppLabel2: TppLabel;
    ppDBText1: TppDBText;
    ppLabel3: TppLabel;
    ppDBText2: TppDBText;
    ppLabel4: TppLabel;
    ppDBText3: TppDBText;
    ppLabel5: TppLabel;
    ppDBText4: TppDBText;
    ppLabel6: TppLabel;
    ppLine1: TppLine;
    procedure btnSairClick(Sender: TObject);
    procedure btnVisualizarClick(Sender: TObject);
    procedure edtCodClienteKeyPress(Sender: TObject; var Key: Char);
    procedure edtNomeClienteKeyPress(Sender: TObject; var Key: Char);
    procedure FConexaoFinanceiroBeforeConnect(Sender: TObject);
  private

    function CampoDataFiltro: string;
    function ClienteDescricao: string;
    function ClienteId: Integer;
    function DataFinalExclusiva: TDateTime;
    function DateFormat: string;
    function FocarControle(const AControl: TWinControl): Boolean;
    function NomeCliente: string;
    function SQLRelatorioFinanceiro: string;
    function SQLResumoFinanceiro: string;
    function SQLWhereRelatorio: string;
    function StatusDB: string;
    function StatusDescricao: string;
    function TipoDataDescricao: string;
    procedure ImprimirRelatorio;
    procedure PrepararDados;
    function ValidarFiltros: Boolean;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

uses
  System.SysUtils,
  System.DateUtils,
  Vcl.Dialogs,
  Financeiro.Infrastructure.Persistence.ConnectionManager;

constructor TfrmRelatorioFinanceiro.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FDtpInicial.Date := StartOfTheMonth(Date);
  FDtpFinal.Date := Date;
  FCbxTipoData.ItemIndex := 0;
  FCbxStatus.ItemIndex := 0;
end;

function TfrmRelatorioFinanceiro.CampoDataFiltro: string;
begin
  if FCbxTipoData.ItemIndex = 1 then
    Result := 'cr.data_emissao'
  else
    Result := 'cr.data_vencimento';
end;

function TfrmRelatorioFinanceiro.ClienteDescricao: string;
begin
  if (ClienteId > 0) and (NomeCliente <> '') then
    Result := Format('%d - %s', [ClienteId, NomeCliente])
  else if ClienteId > 0 then
    Result := IntToStr(ClienteId)
  else if NomeCliente <> '' then
    Result := NomeCliente
  else
    Result := 'Todos';
end;

function TfrmRelatorioFinanceiro.ClienteId: Integer;
begin
  Result := StrToIntDef(Trim(FEdtCodCliente.Text), 0);
end;

function TfrmRelatorioFinanceiro.DataFinalExclusiva: TDateTime;
begin
  Result := IncDay(Trunc(FDtpFinal.Date), 1);
end;

function TfrmRelatorioFinanceiro.DateFormat: string;
begin
  Result := 'dd/mm/yyyy';
end;

function TfrmRelatorioFinanceiro.FocarControle(
  const AControl: TWinControl): Boolean;
begin
  Result := Showing and (AControl <> nil) and AControl.CanFocus;
  if Result then
    AControl.SetFocus;
end;

function TfrmRelatorioFinanceiro.NomeCliente: string;
begin
  Result := Trim(FEdtNomeCliente.Text);
end;

function TfrmRelatorioFinanceiro.SQLWhereRelatorio: string;
begin
  Result :=
    'where ' + CampoDataFiltro + ' >= :data_inicial ' +
    'and ' + CampoDataFiltro + ' < :data_final ' +
    'and (:id_cliente_filtro = 0 or cr.id_cliente = :id_cliente) ' +
    'and (:nome_cliente_filtro = 0 or upper(cr.nome_cliente) like :nome_cliente) ' +
    'and (:status_filtro = 0 or cr.status = :status) ';
end;

function TfrmRelatorioFinanceiro.SQLRelatorioFinanceiro: string;
begin
  Result :=
    'select cr.id_conta_receber, cr.id_origem, cr.id_cliente, ' +
    '       cr.nome_cliente, cr.data_emissao, cr.data_vencimento, ' +
    '       cr.valor as valor_financeiro, cr.status, ' +
    '       case cr.status ' +
    '         when ''ABERTA'' then ''Aberta'' ' +
    '         when ''RECEBIDA'' then ''Fechada'' ' +
    '         when ''CANCELADA'' then ''Cancelada'' ' +
    '         else cr.status ' +
    '       end as status_descricao ' +
    'from contas_receber cr ' +
    SQLWhereRelatorio +
    'order by ' + CampoDataFiltro + ', cr.id_conta_receber';
end;

function TfrmRelatorioFinanceiro.SQLResumoFinanceiro: string;
begin
  Result :=
    'select count(*) as qtd_contas, ' +
    '       coalesce(sum(cr.valor), 0) as valor_total, ' +
    '       coalesce(sum(case when cr.status = ''ABERTA'' then cr.valor else 0 end), 0) as valor_aberto, ' +
    '       coalesce(sum(case when cr.status = ''RECEBIDA'' then cr.valor else 0 end), 0) as valor_fechado, ' +
    '       coalesce(sum(case when cr.status = ''CANCELADA'' then cr.valor else 0 end), 0) as valor_cancelado ' +
    'from contas_receber cr ' +
    SQLWhereRelatorio;
end;

function TfrmRelatorioFinanceiro.StatusDB: string;
begin
  case FCbxStatus.ItemIndex of
    1:
      Result := 'ABERTA';
    2:
      Result := 'RECEBIDA';
    3:
      Result := 'CANCELADA';
  else
    Result := '';
  end;
end;

function TfrmRelatorioFinanceiro.StatusDescricao: string;
begin
  if FCbxStatus.ItemIndex >= 0 then
    Result := FCbxStatus.Text
  else
    Result := 'Todos';
end;

function TfrmRelatorioFinanceiro.TipoDataDescricao: string;
begin
  if FCbxTipoData.ItemIndex >= 0 then
    Result := FCbxTipoData.Text
  else
    Result := 'Vencimento';
end;

function TfrmRelatorioFinanceiro.ValidarFiltros: Boolean;
begin
  Result := False;

  if Trunc(FDtpInicial.Date) > Trunc(FDtpFinal.Date) then
  begin
    ShowMessage('A data inicial nao pode ser maior que a data final.');
    FocarControle(FDtpInicial);
    Exit;
  end;

  Result := True;
end;

procedure TfrmRelatorioFinanceiro.PrepararDados;

  procedure AplicarParametros(const AQuery: TFDQuery);
  var
    Status: string;
  begin
    Status := StatusDB;

    AQuery.ParamByName('data_inicial').AsDateTime := Trunc(FDtpInicial.Date);
    AQuery.ParamByName('data_final').AsDateTime := DataFinalExclusiva;
    AQuery.ParamByName('id_cliente_filtro').AsInteger := ClienteId;
    AQuery.ParamByName('id_cliente').AsInteger := ClienteId;
    AQuery.ParamByName('nome_cliente_filtro').AsInteger := Ord(NomeCliente <> '');
    AQuery.ParamByName('nome_cliente').AsString :=
      '%' + UpperCase(NomeCliente) + '%';
    AQuery.ParamByName('status_filtro').AsInteger := Ord(Status <> '');
    AQuery.ParamByName('status').AsString := Status;
  end;

begin
  if not FConexaoFinanceiro.Connected then
    FConexaoFinanceiro.Connected := True;

  FQryFinanceiro.Close;
  FQryFinanceiro.SQL.Text := SQLRelatorioFinanceiro;
  AplicarParametros(FQryFinanceiro);
  FQryFinanceiro.Open;

  FQryResumo.Close;
  FQryResumo.SQL.Text := SQLResumoFinanceiro;
  AplicarParametros(FQryResumo);
  FQryResumo.Open;
end;

procedure TfrmRelatorioFinanceiro.FConexaoFinanceiroBeforeConnect(
  Sender: TObject);
begin
  TFinanceiroConexao.ConfigurarConexao(TFDConnection(Sender));
end;

procedure TfrmRelatorioFinanceiro.ImprimirRelatorio;
begin
  if not ValidarFiltros then
    Exit;

  PrepararDados;
  if FQryFinanceiro.IsEmpty then
  begin
    ShowMessage('Nenhum financeiro encontrado para os filtros informados.');
    Exit;
  end;

  ppLabel6.Caption := Format('%s: %s a %s | Cliente: %s | Status: %s',
    [TipoDataDescricao, FormatDateTime(DateFormat, FDtpInicial.Date),
     FormatDateTime(DateFormat, FDtpFinal.Date), ClienteDescricao,
     StatusDescricao]);

  ppReport1.Print;
end;

procedure TfrmRelatorioFinanceiro.btnVisualizarClick(Sender: TObject);
begin
  ImprimirRelatorio;
end;

procedure TfrmRelatorioFinanceiro.btnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelatorioFinanceiro.edtCodClienteKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', #8, #13]) then
    Key := #0;

  if Key = #13 then
  begin
    Key := #0;
    FocarControle(FEdtNomeCliente);
  end;
end;

procedure TfrmRelatorioFinanceiro.edtNomeClienteKeyPress(Sender: TObject;
  var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    ImprimirRelatorio;
  end;
end;

end.
