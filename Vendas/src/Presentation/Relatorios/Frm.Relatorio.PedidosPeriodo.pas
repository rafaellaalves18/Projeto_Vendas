unit Frm.Relatorio.PedidosPeriodo;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  FireDAC.Comp.Client,
  FireDAC.Comp.DataSet,
  Data.DB,
  ppBands,
  ppClass,
  ppCtrls,
  ppDB,
  ppDBPipe,
  ppDesignLayer,
  ppParameter,
  ppPrnabl,
  ppReport,
  ppTypes,
  ppVar,
  Vendas.Application.Interfaces.Repositories;

type
  TfrmRelatorioPedidosPeriodo = class(TForm)
    FPnlTitulo: TPanel;
    FPnlFiltros: TPanel;
    FPnlBotoes: TPanel;
    FLblTitulo: TLabel;
    FLblDataInicial: TLabel;
    FLblDataFinal: TLabel;
    FLblCliente: TLabel;
    FLblProduto: TLabel;
    FDtpInicial: TDateTimePicker;
    FDtpFinal: TDateTimePicker;
    FEdtCodCliente: TEdit;
    FEdtNomeCliente: TEdit;
    FEdtCodProduto: TEdit;
    FEdtDescProduto: TEdit;
    FBtnImprimir: TButton;
    FBtnSair: TButton;
    FQryPedidos: TFDQuery;
    FQryPedidosID_PEDIDO: TIntegerField;
    FQryPedidosDATA_EMISSAO: TSQLTimeStampField;
    FQryPedidosID_CLIENTE: TIntegerField;
    FQryPedidosNOME_CLIENTE: TWideStringField;
    FQryPedidosSTATUS: TWideStringField;
    FQryPedidosVALOR_TOTAL: TBCDField;
    FQryPedidosQTD_ITENS: TLargeintField;
    FQryResumo: TFDQuery;
    FQryResumoQTD_PEDIDOS: TLargeintField;
    FQryResumoVALOR_TOTAL: TBCDField;
    FDSPedidos: TDataSource;
    FDSResumo: TDataSource;
    FPipePedidos: TppDBPipeline;
    FPipeResumo: TppDBPipeline;
    FReport: TppReport;
    ppTitleBand1: TppTitleBand;
    ppHeaderBand1: TppHeaderBand;
    ppDetailBand1: TppDetailBand;
    ppSummaryBand1: TppSummaryBand;
    ppFooterBand1: TppFooterBand;
    ppDesignLayers1: TppDesignLayers;
    ppDesignLayer1: TppDesignLayer;
    ppParameterList1: TppParameterList;
    ppShapeTitulo: TppShape;
    ppLabelERP: TppLabel;
    ppLabelTituloReport: TppLabel;
    ppLabelSubTitulo: TppLabel;
    FLblFiltroPeriodo: TppLabel;
    FLblFiltroCliente: TppLabel;
    FLblFiltroProduto: TppLabel;
    ppShapeHeader: TppShape;
    ppLabelPedido: TppLabel;
    ppLabelEmissao: TppLabel;
    ppLabelCliente: TppLabel;
    ppLabelStatus: TppLabel;
    ppLabelItens: TppLabel;
    ppLabelTotal: TppLabel;
    dbPedidoId: TppDBText;
    dbEmissao: TppDBText;
    dbCliente: TppDBText;
    dbStatus: TppDBText;
    dbQtdItens: TppDBText;
    dbValorTotal: TppDBText;
    ppLineDetail: TppLine;
    ppLineSummary: TppLine;
    ppShapeSummary: TppShape;
    ppLabelPedidosResumo: TppLabel;
    dbQtdPedidos: TppDBText;
    ppLabelTotalGeral: TppLabel;
    dbTotalGeral: TppDBText;
    ppLineFooter: TppLine;
    ppLabelImpressoEm: TppLabel;
    ppSystemPrintDate: TppSystemVariable;
    ppSystemPageDesc: TppSystemVariable;
    procedure btnImprimirClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure edtCodClienteExit(Sender: TObject);
    procedure edtCodClienteKeyPress(Sender: TObject; var Key: Char);
    procedure edtCodProdutoExit(Sender: TObject);
    procedure edtCodProdutoKeyPress(Sender: TObject; var Key: Char);
  private
    FClienteRepository: IClienteRepository;
    FProdutoRepository: IProdutoRepository;

    function ClienteId: Integer;
    function DataFinalExclusiva: TDateTime;
    function DateFormat: string;
    function FocarControle(const AControl: TWinControl): Boolean;
    function ProdutoId: Integer;
    function SQLPedidosPeriodo: string;
    function SQLResumoPedidosPeriodo: string;
    function SQLWhereRelatorio: string;
    procedure AtualizarFiltrosReport;
    procedure BuscarCliente;
    procedure BuscarProduto;
    procedure GarantirParametros(const AQuery: TFDQuery);
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
  Vendas.Core.Entities.Cliente,
  Vendas.Core.Entities.Produto,
  Vendas.Infrastructure.Persistence.Conexao,
  Vendas.Infrastructure.Persistence.Repositories.Cliente,
  Vendas.Infrastructure.Persistence.Repositories.Produto;

constructor TfrmRelatorioPedidosPeriodo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FClienteRepository := TClienteRepository.Create;
  FProdutoRepository := TProdutoRepository.Create;

  FQryPedidos.Connection := TVendasConexao.Conexao;
  FQryResumo.Connection := TVendasConexao.Conexao;
  FPipePedidos.RangeBegin := rbFirstRecord;
  FPipePedidos.RangeEnd := reLastRecord;
  FPipeResumo.RangeBegin := rbFirstRecord;
  FPipeResumo.RangeEnd := reLastRecord;
  FReport.AutoStop := False;
  FReport.DataPipeline := FPipePedidos;

  FDtpInicial.Date := StartOfTheMonth(Date);
  FDtpFinal.Date := Date;
end;

function TfrmRelatorioPedidosPeriodo.ClienteId: Integer;
begin
  Result := StrToIntDef(Trim(FEdtCodCliente.Text), 0);
end;

function TfrmRelatorioPedidosPeriodo.ProdutoId: Integer;
begin
  Result := StrToIntDef(Trim(FEdtCodProduto.Text), 0);
end;

function TfrmRelatorioPedidosPeriodo.DateFormat: string;
begin
  Result := 'dd/mm/yyyy';
end;

function TfrmRelatorioPedidosPeriodo.DataFinalExclusiva: TDateTime;
begin
  Result := IncDay(Trunc(FDtpFinal.Date), 1);
end;

function TfrmRelatorioPedidosPeriodo.SQLWhereRelatorio: string;
begin
  Result :=
    'where p.data_emissao >= :data_inicial ' +
    'and p.data_emissao < :data_final ' +
    'and (:id_cliente_filtro = 0 or p.id_cliente = :id_cliente) ' +
    'and (:id_produto_filtro = 0 or exists ( ' +
    '  select 1 from pedidos_venda_itens ip ' +
    '  where ip.id_pedido = p.id_pedido ' +
    '  and ip.id_produto = :id_produto)) ';
end;

function TfrmRelatorioPedidosPeriodo.SQLPedidosPeriodo: string;
begin
  Result :=
    'select p.id_pedido, p.data_emissao, p.id_cliente, p.nome_cliente, ' +
    '       p.status, p.valor_total, ' +
    '       (select count(*) ' +
    '        from pedidos_venda_itens i ' +
    '        where i.id_pedido = p.id_pedido) as qtd_itens ' +
    'from pedidos_venda p ' +
    SQLWhereRelatorio +
    'order by p.data_emissao, p.id_pedido';
end;

function TfrmRelatorioPedidosPeriodo.SQLResumoPedidosPeriodo: string;
begin
  Result :=
    'select count(*) as qtd_pedidos, ' +
    '       coalesce(sum(p.valor_total), 0) as valor_total ' +
    'from pedidos_venda p ' +
    SQLWhereRelatorio;
end;

function TfrmRelatorioPedidosPeriodo.FocarControle(
  const AControl: TWinControl): Boolean;
begin
  Result := Showing and (AControl <> nil) and AControl.CanFocus;
  if Result then
    AControl.SetFocus;
end;

procedure TfrmRelatorioPedidosPeriodo.GarantirParametros(
  const AQuery: TFDQuery);

  procedure AddParam(const AName: string; const ADataType: TFieldType);
  begin
    if AQuery.Params.FindParam(AName) <> nil then
      Exit;

    with AQuery.Params.Add do
    begin
      Name := AName;
      DataType := ADataType;
      ParamType := ptInput;
    end;
  end;

begin
  AddParam('data_inicial', ftDateTime);
  AddParam('data_final', ftDateTime);
  AddParam('id_cliente_filtro', ftInteger);
  AddParam('id_cliente', ftInteger);
  AddParam('id_produto_filtro', ftInteger);
  AddParam('id_produto', ftInteger);
end;

procedure TfrmRelatorioPedidosPeriodo.BuscarCliente;
var
  Cliente: TCliente;
  Codigo: Integer;
begin
  Codigo := ClienteId;
  if Codigo <= 0 then
  begin
    FEdtNomeCliente.Clear;
    Exit;
  end;

  Cliente := FClienteRepository.ObterPorId(Codigo);
  try
    if Cliente = nil then
    begin
      ShowMessage('Cliente nao encontrado.');
      FEdtCodCliente.Clear;
      FEdtNomeCliente.Clear;
      FocarControle(FEdtCodCliente);
      Exit;
    end;

    FEdtCodCliente.Text := IntToStr(Cliente.Id);
    FEdtNomeCliente.Text := Cliente.Nome;
  finally
    Cliente.Free;
  end;
end;

procedure TfrmRelatorioPedidosPeriodo.BuscarProduto;
var
  Produto: TProduto;
  Codigo: Integer;
begin
  Codigo := ProdutoId;
  if Codigo <= 0 then
  begin
    FEdtDescProduto.Clear;
    Exit;
  end;

  Produto := FProdutoRepository.ObterPorId(Codigo);
  try
    if Produto = nil then
    begin
      ShowMessage('Produto nao encontrado.');
      FEdtCodProduto.Clear;
      FEdtDescProduto.Clear;
      FocarControle(FEdtCodProduto);
      Exit;
    end;

    FEdtCodProduto.Text := IntToStr(Produto.Id);
    FEdtDescProduto.Text := Produto.Descricao;
  finally
    Produto.Free;
  end;
end;

function TfrmRelatorioPedidosPeriodo.ValidarFiltros: Boolean;
begin
  Result := False;

  if Trunc(FDtpInicial.Date) > Trunc(FDtpFinal.Date) then
  begin
    ShowMessage('A data inicial nao pode ser maior que a data final.');
    FocarControle(FDtpInicial);
    Exit;
  end;

  if Trim(FEdtCodCliente.Text) <> '' then
  begin
    BuscarCliente;
    if ClienteId <= 0 then
      Exit;
  end
  else
    FEdtNomeCliente.Clear;

  if Trim(FEdtCodProduto.Text) <> '' then
  begin
    BuscarProduto;
    if ProdutoId <= 0 then
      Exit;
  end
  else
    FEdtDescProduto.Clear;

  Result := True;
end;

procedure TfrmRelatorioPedidosPeriodo.PrepararDados;

  procedure AplicarParametros(const AQuery: TFDQuery);
  begin
    AQuery.ParamByName('data_inicial').AsDateTime := Trunc(FDtpInicial.Date);
    AQuery.ParamByName('data_final').AsDateTime := DataFinalExclusiva;
    AQuery.ParamByName('id_cliente_filtro').AsInteger := ClienteId;
    AQuery.ParamByName('id_cliente').AsInteger := ClienteId;
    AQuery.ParamByName('id_produto_filtro').AsInteger := ProdutoId;
    AQuery.ParamByName('id_produto').AsInteger := ProdutoId;
  end;

begin
  FQryPedidos.Close;
  FQryPedidos.SQL.Text := SQLPedidosPeriodo;
  GarantirParametros(FQryPedidos);
  AplicarParametros(FQryPedidos);
  FQryPedidos.Open;
  FQryPedidos.FetchAll;
  FQryPedidos.First;

  FQryResumo.Close;
  FQryResumo.SQL.Text := SQLResumoPedidosPeriodo;
  GarantirParametros(FQryResumo);
  AplicarParametros(FQryResumo);
  FQryResumo.Open;
  FQryResumo.FetchAll;
  FQryResumo.First;
end;

procedure TfrmRelatorioPedidosPeriodo.AtualizarFiltrosReport;
var
  ClienteFiltro: string;
  ProdutoFiltro: string;
begin
  if ClienteId > 0 then
    ClienteFiltro := Format('%d - %s', [ClienteId, Trim(FEdtNomeCliente.Text)])
  else
    ClienteFiltro := 'Todos';

  if ProdutoId > 0 then
    ProdutoFiltro := Format('%d - %s', [ProdutoId, Trim(FEdtDescProduto.Text)])
  else
    ProdutoFiltro := 'Todos';

  FLblFiltroPeriodo.Caption := Format('Periodo: %s a %s',
    [FormatDateTime(DateFormat, FDtpInicial.Date),
     FormatDateTime(DateFormat, FDtpFinal.Date)]);
  FLblFiltroCliente.Caption := 'Cliente: ' + ClienteFiltro;
  FLblFiltroProduto.Caption := 'Produto: ' + ProdutoFiltro;
end;

procedure TfrmRelatorioPedidosPeriodo.ImprimirRelatorio;
begin
  if not ValidarFiltros then
    Exit;

  PrepararDados;
  if FQryPedidos.IsEmpty then
  begin
    ShowMessage('Nenhum pedido encontrado para os filtros informados.');
    Exit;
  end;

  AtualizarFiltrosReport;
  FQryPedidos.First;
  FQryResumo.First;
  FReport.Reset;
  FReport.DataPipeline := FPipePedidos;
  FReport.DeviceType := 'Screen';
  FReport.Print;
end;

procedure TfrmRelatorioPedidosPeriodo.btnImprimirClick(Sender: TObject);
begin
  ImprimirRelatorio;
end;

procedure TfrmRelatorioPedidosPeriodo.btnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmRelatorioPedidosPeriodo.edtCodClienteExit(Sender: TObject);
begin
  if Trim(FEdtCodCliente.Text) <> '' then
    BuscarCliente
  else
    FEdtNomeCliente.Clear;
end;

procedure TfrmRelatorioPedidosPeriodo.edtCodClienteKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', #8, #13]) then
    Key := #0;

  if Key = #13 then
  begin
    Key := #0;
    BuscarCliente;
    FocarControle(FEdtCodProduto);
  end;
end;

procedure TfrmRelatorioPedidosPeriodo.edtCodProdutoExit(Sender: TObject);
begin
  if Trim(FEdtCodProduto.Text) <> '' then
    BuscarProduto
  else
    FEdtDescProduto.Clear;
end;

procedure TfrmRelatorioPedidosPeriodo.edtCodProdutoKeyPress(Sender: TObject;
  var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', #8, #13]) then
    Key := #0;

  if Key = #13 then
  begin
    Key := #0;
    BuscarProduto;
    FocarControle(FBtnImprimir);
  end;
end;

end.
