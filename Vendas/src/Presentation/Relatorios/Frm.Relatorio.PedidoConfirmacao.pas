unit Frm.Relatorio.PedidoConfirmacao;

interface

uses
  System.Classes,
  Vcl.Forms,
  FireDAC.Comp.Client,
  Data.DB,
  ppBands,
  ppClass,
  ppDB,
  ppDBPipe,
  ppReport,
  ppTypes;

type
  TfrmRelatorioPedidoConfirmacao = class(TForm)
  private
    FPedidoId: Integer;
    FQryPedido: TFDQuery;
    FQryItens: TFDQuery;
    FDSPedido: TDataSource;
    FDSItens: TDataSource;
    FPipePedido: TppDBPipeline;
    FPipeItens: TppDBPipeline;
    FReport: TppReport;

    function CurrFormat: string;
    function DateTimeFormat: string;
    procedure AddBox(const ABand: TppBand; const ALeft, ATop, AWidth,
      AHeight: Single; const AFillColor: TColor = clWhite);
    procedure AddDBText(const ABand: TppBand; const AName, AField: string;
      const APipeline: TppDataPipeline; const ALeft, ATop, AWidth,
      AHeight: Single; const AFontSize: Integer = 8;
      const ABold: Boolean = False;
      const AAlignment: TppTextAlignment = taLeftJustified;
      const ADisplayFormat: string = '');
    procedure AddLabel(const ABand: TppBand; const ACaption: string;
      const ALeft, ATop, AWidth, AHeight: Single;
      const AFontSize: Integer = 8; const ABold: Boolean = False;
      const AAlignment: TppTextAlignment = taLeftJustified;
      const AFontColor: TColor = clBlack);
    procedure AddLine(const ABand: TppBand; const ALeft, ATop,
      AWidth: Single; const AColor: TColor = clSilver);
    procedure ConfigurarDados;
    procedure ConfigurarReport;
    procedure CriarBandas;
    procedure CriarCabecalho;
    procedure CriarDetalhe;
    procedure CriarRodape;
    procedure CriarResumo;
  public
    constructor Create(AOwner: TComponent); override;

    procedure PrepararPedido(const APedidoId: Integer);
    procedure ExportarPdf(const AFileName: string);
    procedure Visualizar;
    procedure Imprimir;

    class procedure ImprimirPedido(const APedidoId: Integer;
      const APreview: Boolean = True);
    class procedure ExportarPedidoPdf(const APedidoId: Integer;
      const AFileName: string);
  end;

implementation

uses
  System.SysUtils,
  Vcl.Graphics,
  ppCtrls,
  ppPDFDevice,
  ppPrnabl,
  ppVar,
  Vendas.Infrastructure.Persistence.Conexao;

const
  PAGE_WIDTH = 7.35;
  COLOR_BORDER = $00B8B8B8;
  COLOR_LIGHT = $00F3F3F3;
  COLOR_DARK = $00404040;

constructor TfrmRelatorioPedidoConfirmacao.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);

  Caption := 'Relatorio de Confirmacao de Pedido';
  Position := poScreenCenter;

  ConfigurarDados;
  ConfigurarReport;
end;

function TfrmRelatorioPedidoConfirmacao.CurrFormat: string;
begin
  Result := '#,##0.00;-#,##0.00';
end;

function TfrmRelatorioPedidoConfirmacao.DateTimeFormat: string;
begin
  Result := 'dd/mm/yyyy';
end;

procedure TfrmRelatorioPedidoConfirmacao.ConfigurarDados;
begin
  FQryPedido := TFDQuery.Create(Self);
  FQryPedido.Connection := TVendasConexao.Conexao;
  FQryPedido.SQL.Text :=
    'select p.id_pedido, p.id_cliente, p.nome_cliente, p.data_emissao, ' +
    '       p.valor_total, p.status, c.documento, c.email, c.telefone, ' +
    '       c.cidade, c.uf ' +
    'from pedidos_venda p ' +
    'left join clientes c on c.id_cliente = p.id_cliente ' +
    'where p.id_pedido = :id_pedido';

  FQryItens := TFDQuery.Create(Self);
  FQryItens.Connection := TVendasConexao.Conexao;
  FQryItens.SQL.Text :=
    'select sequencia, id_produto, descricao_produto, quantidade, ' +
    '       valor_unitario, valor_total ' +
    'from pedidos_venda_itens ' +
    'where id_pedido = :id_pedido ' +
    'order by sequencia';

  FDSPedido := TDataSource.Create(Self);
  FDSPedido.DataSet := FQryPedido;

  FDSItens := TDataSource.Create(Self);
  FDSItens.DataSet := FQryItens;

  FPipePedido := TppDBPipeline.Create(Self);
  FPipePedido.Name := 'plPedidoConfirmacao';
  FPipePedido.UserName := 'Pedido';
  FPipePedido.DataSource := FDSPedido;

  FPipeItens := TppDBPipeline.Create(Self);
  FPipeItens.Name := 'plPedidoConfirmacaoItens';
  FPipeItens.UserName := 'Itens';
  FPipeItens.DataSource := FDSItens;
end;

procedure TfrmRelatorioPedidoConfirmacao.ConfigurarReport;
begin
  FReport := TppReport.Create(Self);
  FReport.Name := 'rptPedidoConfirmacao';
  FReport.AutoStop := True;
  FReport.DataPipeline := FPipeItens;
  FReport.DeviceType := 'Screen';
  FReport.PassSetting := psTwoPass;
  FReport.Units := utInches;
  FReport.PrinterSetup.DocumentName := 'Confirmacao de Pedido';
  FReport.PrinterSetup.Orientation := poPortrait;
  FReport.PrinterSetup.PaperName := 'A4';
  FReport.PrinterSetup.PaperHeight := 11.69;
  FReport.PrinterSetup.PaperWidth := 8.27;
  FReport.PrinterSetup.MarginBottom := 0.25;
  FReport.PrinterSetup.MarginLeft := 0.35;
  FReport.PrinterSetup.MarginRight := 0.35;
  FReport.PrinterSetup.MarginTop := 0.25;
  FReport.CreateDefaultBands;

  CriarBandas;
  CriarCabecalho;
  CriarDetalhe;
  CriarResumo;
  CriarRodape;
end;

procedure TfrmRelatorioPedidoConfirmacao.CriarBandas;
var
  TitleBand: TppTitleBand;
  SummaryBand: TppSummaryBand;
begin
  TitleBand := TppTitleBand.Create(FReport);
  TitleBand.Report := FReport;
  TitleBand.Height := 2.20;

  FReport.HeaderBand.Height := 0.34;
  FReport.DetailBand.Height := 0.26;
  FReport.FooterBand.Height := 0.34;

  SummaryBand := TppSummaryBand.Create(FReport);
  SummaryBand.Report := FReport;
  SummaryBand.Height := 0.92;
end;

procedure TfrmRelatorioPedidoConfirmacao.AddBox(const ABand: TppBand;
  const ALeft, ATop, AWidth, AHeight: Single; const AFillColor: TColor);
var
  Shape: TppShape;
begin
  Shape := TppShape.Create(ABand.Report);
  Shape.Band := ABand;
  Shape.Left := ALeft;
  Shape.Top := ATop;
  Shape.Width := AWidth;
  Shape.Height := AHeight;
  Shape.Pen.Color := COLOR_BORDER;
  Shape.Brush.Style := bsSolid;
  Shape.Brush.Color := AFillColor;
end;

procedure TfrmRelatorioPedidoConfirmacao.AddLabel(const ABand: TppBand;
  const ACaption: string; const ALeft, ATop, AWidth, AHeight: Single;
  const AFontSize: Integer; const ABold: Boolean;
  const AAlignment: TppTextAlignment; const AFontColor: TColor);
var
  LabelComp: TppLabel;
begin
  LabelComp := TppLabel.Create(ABand.Report);
  LabelComp.Band := ABand;
  LabelComp.Left := ALeft;
  LabelComp.Top := ATop;
  LabelComp.Width := AWidth;
  LabelComp.Height := AHeight;
  LabelComp.Caption := ACaption;
  LabelComp.TextAlignment := AAlignment;
  LabelComp.Font.Name := 'Arial';
  LabelComp.Font.Size := AFontSize;
  LabelComp.Font.Color := AFontColor;
  if ABold then
    LabelComp.Font.Style := [fsBold];
end;

procedure TfrmRelatorioPedidoConfirmacao.AddDBText(const ABand: TppBand;
  const AName, AField: string; const APipeline: TppDataPipeline; const ALeft,
  ATop, AWidth, AHeight: Single; const AFontSize: Integer; const ABold: Boolean;
  const AAlignment: TppTextAlignment; const ADisplayFormat: string);
var
  DBText: TppDBText;
begin
  DBText := TppDBText.Create(ABand.Report);
  DBText.Name := AName;
  DBText.Band := ABand;
  DBText.Left := ALeft;
  DBText.Top := ATop;
  DBText.Width := AWidth;
  DBText.Height := AHeight;
  DBText.DataPipeline := APipeline;
  DBText.DataField := AField;
  DBText.TextAlignment := AAlignment;
  DBText.Font.Name := 'Arial';
  DBText.Font.Size := AFontSize;
  if ABold then
    DBText.Font.Style := [fsBold];
  if ADisplayFormat <> '' then
    DBText.DisplayFormat := ADisplayFormat;
end;

procedure TfrmRelatorioPedidoConfirmacao.AddLine(const ABand: TppBand;
  const ALeft, ATop, AWidth: Single; const AColor: TColor);
var
  Line: TppLine;
begin
  Line := TppLine.Create(ABand.Report);
  Line.Band := ABand;
  Line.Left := ALeft;
  Line.Top := ATop;
  Line.Width := AWidth;
  Line.Height := 0;
  Line.Pen.Color := AColor;
end;

procedure TfrmRelatorioPedidoConfirmacao.CriarCabecalho;
begin
  AddBox(FReport.TitleBand, 0, 0, PAGE_WIDTH, 0.58, COLOR_LIGHT);
  AddLabel(FReport.TitleBand, 'Confirmacao de Pedido', 0.16, 0.11, 3.20,
    0.22, 14, True, taLeftJustified, COLOR_DARK);
  AddLabel(FReport.TitleBand, 'ERP Vendas', 0.17, 0.36, 1.20, 0.12, 7,
    False, taLeftJustified, clGray);

  AddLabel(FReport.TitleBand, 'Pedido', 5.35, 0.12, 0.60, 0.12, 7, True,
    taRightJustified, COLOR_DARK);
  AddDBText(FReport.TitleBand, 'dbPedidoId', 'ID_PEDIDO', FPipePedido, 6.02,
    0.10, 1.08, 0.20, 12, True, taRightJustified);
  AddLabel(FReport.TitleBand, 'Emissao', 5.35, 0.36, 0.60, 0.12, 7, True,
    taRightJustified, COLOR_DARK);
  AddDBText(FReport.TitleBand, 'dbDataEmissao', 'DATA_EMISSAO', FPipePedido,
    6.02, 0.34, 1.08, 0.15, 8, False, taRightJustified, DateTimeFormat);

  AddLabel(FReport.TitleBand, 'DADOS DO CLIENTE', 0.05, 0.80, 1.45, 0.14, 8,
    True, taLeftJustified, COLOR_DARK);
  AddBox(FReport.TitleBand, 0, 0.98, PAGE_WIDTH, 0.48);
  AddLabel(FReport.TitleBand, 'Codigo cliente', 0.16, 1.07, 0.90, 0.12, 7,
    True);
  AddDBText(FReport.TitleBand, 'dbClienteId', 'ID_CLIENTE', FPipePedido, 0.16,
    1.24, 0.86, 0.14, 8, False);
  AddLabel(FReport.TitleBand, 'Nome do cliente', 1.22, 1.07, 1.05, 0.12, 7,
    True);
  AddDBText(FReport.TitleBand, 'dbNomeCliente', 'NOME_CLIENTE', FPipePedido,
    1.22, 1.24, 3.70, 0.14, 8, True);
  AddLabel(FReport.TitleBand, 'Valor total', 5.45, 1.07, 0.80, 0.12, 7, True,
    taRightJustified);
  AddDBText(FReport.TitleBand, 'dbValorTotalCab', 'VALOR_TOTAL', FPipePedido,
    6.12, 1.21, 1.00, 0.18, 10, True, taRightJustified, CurrFormat);

  AddLabel(FReport.TitleBand, 'PRODUTOS DO PEDIDO', 0.05, 1.68, 1.60, 0.14,
    8, True, taLeftJustified, COLOR_DARK);

  AddBox(FReport.HeaderBand, 0, 0.02, PAGE_WIDTH, 0.27, COLOR_LIGHT);
  AddLabel(FReport.HeaderBand, 'Cod.', 0.12, 0.09, 0.44, 0.13, 7, True);
  AddLabel(FReport.HeaderBand, 'Produto', 0.72, 0.09, 3.70, 0.13, 7, True);
  AddLabel(FReport.HeaderBand, 'Qtd', 4.55, 0.09, 0.55, 0.13, 7, True,
    taRightJustified);
  AddLabel(FReport.HeaderBand, 'Valor unit.', 5.25, 0.09, 0.82, 0.13, 7,
    True, taRightJustified);
  AddLabel(FReport.HeaderBand, 'Total', 6.18, 0.09, 0.92, 0.13, 7, True,
    taRightJustified);
end;

procedure TfrmRelatorioPedidoConfirmacao.CriarDetalhe;
begin
  AddDBText(FReport.DetailBand, 'dbItemProduto', 'ID_PRODUTO', FPipeItens,
    0.12, 0.06, 0.44, 0.14, 8);
  AddDBText(FReport.DetailBand, 'dbItemDescricao', 'DESCRICAO_PRODUTO',
    FPipeItens, 0.72, 0.06, 3.70, 0.14, 8);
  AddDBText(FReport.DetailBand, 'dbItemQtd', 'QUANTIDADE', FPipeItens, 4.55,
    0.06, 0.55, 0.14, 8, False, taRightJustified, '#,##0.####');
  AddDBText(FReport.DetailBand, 'dbItemUnitario', 'VALOR_UNITARIO', FPipeItens,
    5.25, 0.06, 0.82, 0.14, 8, False, taRightJustified, CurrFormat);
  AddDBText(FReport.DetailBand, 'dbItemTotal', 'VALOR_TOTAL', FPipeItens, 6.24,
    0.06, 0.86, 0.14, 8, False, taRightJustified, CurrFormat);
  AddLine(FReport.DetailBand, 0, 0.24, PAGE_WIDTH, $00E0E0E0);
end;

procedure TfrmRelatorioPedidoConfirmacao.CriarResumo;
begin
  AddLine(FReport.SummaryBand, 0, 0.10, PAGE_WIDTH, COLOR_BORDER);

  AddBox(FReport.SummaryBand, 4.62, 0.25, 2.73, 0.42, COLOR_LIGHT);
  AddLabel(FReport.SummaryBand, 'TOTAL DO PEDIDO', 4.82, 0.38, 1.20, 0.13, 8,
    True, taLeftJustified, COLOR_DARK);
  AddDBText(FReport.SummaryBand, 'dbTotalPedido', 'VALOR_TOTAL', FPipePedido,
    6.05, 0.33, 1.08, 0.20, 12, True, taRightJustified, CurrFormat);
end;

procedure TfrmRelatorioPedidoConfirmacao.CriarRodape;
var
  PrintDate: TppSystemVariable;
  PageDesc: TppSystemVariable;
begin
  AddLine(FReport.FooterBand, 0, 0.04, PAGE_WIDTH, $00E0E0E0);
  AddLabel(FReport.FooterBand, 'Impresso em', 0, 0.15, 0.70, 0.12, 7, False,
    taLeftJustified, clGray);

  PrintDate := TppSystemVariable.Create(FReport);
  PrintDate.Band := FReport.FooterBand;
  PrintDate.Left := 0.75;
  PrintDate.Top := 0.15;
  PrintDate.Width := 1.20;
  PrintDate.Height := 0.12;
  PrintDate.VarType := vtPrintDateTime;
  PrintDate.DisplayFormat := DateTimeFormat;
  PrintDate.Font.Name := 'Arial';
  PrintDate.Font.Size := 7;
  PrintDate.Font.Color := clGray;

  PageDesc := TppSystemVariable.Create(FReport);
  PageDesc.Band := FReport.FooterBand;
  PageDesc.Left := 6.15;
  PageDesc.Top := 0.15;
  PageDesc.Width := 1.15;
  PageDesc.Height := 0.12;
  PageDesc.VarType := vtPageSetDesc;
  PageDesc.TextAlignment := taRightJustified;
  PageDesc.Font.Name := 'Arial';
  PageDesc.Font.Size := 7;
  PageDesc.Font.Color := clGray;
end;

procedure TfrmRelatorioPedidoConfirmacao.PrepararPedido(
  const APedidoId: Integer);
begin
  if APedidoId <= 0 then
    raise EArgumentException.Create('Informe um pedido valido para impressao.');

  FPedidoId := APedidoId;

  FQryPedido.Close;
  FQryPedido.ParamByName('id_pedido').AsInteger := FPedidoId;
  FQryPedido.Open;

  if FQryPedido.IsEmpty then
    raise EArgumentException.CreateFmt('Pedido %d nao encontrado.', [FPedidoId]);

  FQryItens.Close;
  FQryItens.ParamByName('id_pedido').AsInteger := FPedidoId;
  FQryItens.Open;

  if FQryItens.IsEmpty then
    raise EArgumentException.CreateFmt('Pedido %d nao possui itens para impressao.',
      [FPedidoId]);

  FQryPedido.First;
  FQryItens.First;
end;

procedure TfrmRelatorioPedidoConfirmacao.Visualizar;
begin
  FQryPedido.First;
  FQryItens.First;
  FReport.DeviceType := 'Screen';
  FReport.Print;
end;

procedure TfrmRelatorioPedidoConfirmacao.ExportarPdf(const AFileName: string);
begin
  if Trim(AFileName) = '' then
    raise EArgumentException.Create('Informe o arquivo PDF de destino.');

  FReport.AllowPrintToFile := True;
  FQryPedido.First;
  FQryItens.First;
  FReport.DeviceType := 'PDF';
  FReport.TextFileName := AFileName;
  FReport.Print;
end;

procedure TfrmRelatorioPedidoConfirmacao.Imprimir;
begin
  FQryPedido.First;
  FQryItens.First;
  FReport.DeviceType := 'Printer';
  FReport.Print;
end;

class procedure TfrmRelatorioPedidoConfirmacao.ImprimirPedido(
  const APedidoId: Integer; const APreview: Boolean);
var
  Form: TfrmRelatorioPedidoConfirmacao;
begin
  Form := TfrmRelatorioPedidoConfirmacao.Create(nil);
  try
    Form.PrepararPedido(APedidoId);
    if APreview then
      Form.Visualizar
    else
      Form.Imprimir;
  finally
    Form.Free;
  end;
end;

class procedure TfrmRelatorioPedidoConfirmacao.ExportarPedidoPdf(
  const APedidoId: Integer; const AFileName: string);
var
  Form: TfrmRelatorioPedidoConfirmacao;
begin
  Form := TfrmRelatorioPedidoConfirmacao.Create(nil);
  try
    Form.PrepararPedido(APedidoId);
    Form.ExportarPdf(AFileName);
  finally
    Form.Free;
  end;
end;

end.
