unit Frm.Dashboard.Vendas;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.DBGrids,
  Vcl.Graphics,
  Data.DB,
  FireDAC.Comp.Client,
  ppBands,
  ppClass,
  ppCtrls,
  ppReport,
  ppTypes,
  ppVar,
  ppChrt,
  VclTee.Chart,
  VclTee.Series,
  VclTee.TeEngine;

type
  TfrmDashboardVendas = class(TForm)
    pnlTitulo: TPanel;
    lblTitulo: TLabel;
    pnlAcoes: TPanel;
    btnAtualizar: TButton;
    btnGraficoTopClientes: TButton;
    btnFechar: TButton;
    pnlIndicadores: TPanel;
    pnlOrdensFinalizadas: TPanel;
    lblTituloOrdensFinalizadas: TLabel;
    lblOrdensFinalizadas: TLabel;
    pnlOrdensPendentes: TPanel;
    lblTituloOrdensPendentes: TLabel;
    lblOrdensPendentes: TLabel;
    pnlValorProjetado: TPanel;
    lblTituloValorProjetado: TLabel;
    lblValorProjetado: TLabel;
    pnlValorVendido: TPanel;
    lblTituloValorVendido: TLabel;
    lblValorVendido: TLabel;
    pnlGrids: TPanel;
    gbTopProdutos: TGroupBox;
    dbgTopProdutos: TDBGrid;
    gbTopClientes: TGroupBox;
    dbgTopClientes: TDBGrid;
    qryResumo: TFDQuery;
    qryTopProdutos: TFDQuery;
    qryTopClientes: TFDQuery;
    dsTopProdutos: TDataSource;
    dsTopClientes: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnGraficoTopClientesClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    procedure AddLabelReport(const ABand: TppBand; const ACaption: string;
      const ALeft, ATop, AWidth, AHeight: Single;
      const AFontSize: Integer; const ABold: Boolean = False;
      const AAlignment: TppTextAlignment = taLeftJustified;
      const AFontColor: TColor = clBlack);
    function CurrParaStr(const AValor: Currency): string;
    procedure AbrirConsulta(const AQuery: TFDQuery; const ASQL: string);
    procedure AtualizarDashboard;
    procedure ConfigurarCamposTopClientes;
    procedure ConfigurarCamposTopProdutos;
    procedure ConfigurarColunasTopClientes;
    procedure ConfigurarColunasTopProdutos;
    procedure ConfigurarConexao;
    procedure ConfigurarGrids;
    procedure ConfigurarReportGraficoTopClientes(const AReport: TppReport;
      const AQuery: TFDQuery);
    procedure AtualizarIndicadores;
    procedure AtualizarTopClientes;
    procedure AtualizarTopProdutos;
    procedure ImprimirGraficoTopClientes;
    procedure PopularSerieTopClientes(const AQuery: TFDQuery;
      const ASeries: TBarSeries);
    function SQLResumo: string;
    function SQLTopClientes: string;
    function SQLTopProdutos: string;
  end;

implementation

{$R *.dfm}

uses
  Vcl.Dialogs,
  Vendas.Infrastructure.Persistence.Conexao,
  Vendas.Infrastructure.Persistence.DatabaseSchema;

procedure TfrmDashboardVendas.AddLabelReport(const ABand: TppBand;
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

function TfrmDashboardVendas.CurrParaStr(const AValor: Currency): string;
var
  Fmt: TFormatSettings;
begin
  Fmt := TFormatSettings.Create('pt-BR');
  Result := 'R$ ' + FormatFloat('#,##0.00', AValor, Fmt);
end;

procedure TfrmDashboardVendas.ConfigurarConexao;
begin
  TVendasConexao.Conectar;
  TVendasDatabaseSchema.EnsureCreated;

  qryResumo.Connection := TVendasConexao.Conexao;
  qryTopProdutos.Connection := TVendasConexao.Conexao;
  qryTopClientes.Connection := TVendasConexao.Conexao;
end;

procedure TfrmDashboardVendas.ConfigurarGrids;
begin
  dbgTopProdutos.Options := dbgTopProdutos.Options + [dgTitles, dgRowSelect] -
    [dgEditing];
  dbgTopClientes.Options := dbgTopClientes.Options + [dgTitles, dgRowSelect] -
    [dgEditing];

  ConfigurarColunasTopProdutos;
  ConfigurarColunasTopClientes;
end;

procedure TfrmDashboardVendas.ConfigurarColunasTopProdutos;
begin
  dbgTopProdutos.Columns.Clear;
  dbgTopProdutos.Columns.Add.FieldName := 'id_produto';
  dbgTopProdutos.Columns.Add.FieldName := 'descricao_produto';
  dbgTopProdutos.Columns.Add.FieldName := 'quantidade_vendida';
  dbgTopProdutos.Columns.Add.FieldName := 'valor_vendido';

  dbgTopProdutos.Columns[0].Width := 60;
  dbgTopProdutos.Columns[1].Width := 280;
  dbgTopProdutos.Columns[2].Width := 90;
  dbgTopProdutos.Columns[3].Width := 120;
end;

procedure TfrmDashboardVendas.ConfigurarColunasTopClientes;
begin
  dbgTopClientes.Columns.Clear;
  dbgTopClientes.Columns.Add.FieldName := 'id_cliente';
  dbgTopClientes.Columns.Add.FieldName := 'nome_cliente';
  dbgTopClientes.Columns.Add.FieldName := 'qtd_pedidos';
  dbgTopClientes.Columns.Add.FieldName := 'valor_comprado';

  dbgTopClientes.Columns[0].Width := 60;
  dbgTopClientes.Columns[1].Width := 280;
  dbgTopClientes.Columns[2].Width := 80;
  dbgTopClientes.Columns[3].Width := 130;
end;

function TfrmDashboardVendas.SQLResumo: string;
begin
  Result :=
    'select ' +
    '  coalesce(sum(case when status = ''CONFIRMADO'' then 1 else 0 end), 0) as ordens_finalizadas, ' +
    '  coalesce(sum(case when status = ''DIGITACAO'' then 1 else 0 end), 0) as ordens_pendentes, ' +
    '  coalesce(sum(case when status = ''DIGITACAO'' then valor_total else 0 end), 0) as valor_projetado, ' +
    '  coalesce(sum(case when status = ''CONFIRMADO'' then valor_total else 0 end), 0) as valor_vendido ' +
    'from pedidos_venda';
end;

function TfrmDashboardVendas.SQLTopProdutos: string;
begin
  Result :=
    'select first 5 ' +
    '  i.id_produto, ' +
    '  i.descricao_produto, ' +
    '  sum(i.quantidade) as quantidade_vendida, ' +
    '  sum(i.valor_total) as valor_vendido ' +
    'from pedidos_venda_itens i ' +
    'join pedidos_venda p on p.id_pedido = i.id_pedido ' +
    'where p.status = ''CONFIRMADO'' ' +
    'group by i.id_produto, i.descricao_produto ' +
    'order by sum(i.quantidade) desc, sum(i.valor_total) desc';
end;

function TfrmDashboardVendas.SQLTopClientes: string;
begin
  Result :=
    'select first 5 ' +
    '  p.id_cliente, ' +
    '  p.nome_cliente, ' +
    '  count(*) as qtd_pedidos, ' +
    '  sum(p.valor_total) as valor_comprado ' +
    'from pedidos_venda p ' +
    'where p.status = ''CONFIRMADO'' ' +
    'group by p.id_cliente, p.nome_cliente ' +
    'order by sum(p.valor_total) desc, count(*) desc';
end;

procedure TfrmDashboardVendas.AbrirConsulta(
  const AQuery: TFDQuery; const ASQL: string);
begin
  AQuery.Close;
  AQuery.SQL.Text := ASQL;
  AQuery.Open;
end;

procedure TfrmDashboardVendas.AtualizarIndicadores;
begin
  AbrirConsulta(qryResumo, SQLResumo);

  lblOrdensFinalizadas.Caption :=
    qryResumo.FieldByName('ordens_finalizadas').AsString;
  lblOrdensPendentes.Caption :=
    qryResumo.FieldByName('ordens_pendentes').AsString;
  lblValorProjetado.Caption :=
    CurrParaStr(qryResumo.FieldByName('valor_projetado').AsCurrency);
  lblValorVendido.Caption :=
    CurrParaStr(qryResumo.FieldByName('valor_vendido').AsCurrency);
end;

procedure TfrmDashboardVendas.ConfigurarCamposTopProdutos;
begin
  qryTopProdutos.FieldByName('id_produto').DisplayLabel := 'Cod.';
  qryTopProdutos.FieldByName('descricao_produto').DisplayLabel := 'Produto';
  qryTopProdutos.FieldByName('quantidade_vendida').DisplayLabel := 'Qtd.';
  qryTopProdutos.FieldByName('valor_vendido').DisplayLabel := 'Valor vendido';

  TNumericField(qryTopProdutos.FieldByName('quantidade_vendida')).DisplayFormat :=
    '#,##0.####';
  TNumericField(qryTopProdutos.FieldByName('valor_vendido')).DisplayFormat :=
    '#,##0.00';
end;

procedure TfrmDashboardVendas.ConfigurarCamposTopClientes;
begin
  qryTopClientes.FieldByName('id_cliente').DisplayLabel := 'Cod.';
  qryTopClientes.FieldByName('nome_cliente').DisplayLabel := 'Cliente';
  qryTopClientes.FieldByName('qtd_pedidos').DisplayLabel := 'Pedidos';
  qryTopClientes.FieldByName('valor_comprado').DisplayLabel := 'Valor comprado';

  TNumericField(qryTopClientes.FieldByName('valor_comprado')).DisplayFormat :=
    '#,##0.00';
end;

procedure TfrmDashboardVendas.AtualizarTopProdutos;
begin
  AbrirConsulta(qryTopProdutos, SQLTopProdutos);
  ConfigurarCamposTopProdutos;
end;

procedure TfrmDashboardVendas.AtualizarTopClientes;
begin
  AbrirConsulta(qryTopClientes, SQLTopClientes);
  ConfigurarCamposTopClientes;
end;

procedure TfrmDashboardVendas.PopularSerieTopClientes(const AQuery: TFDQuery;
  const ASeries: TBarSeries);
var
  Cliente: string;
  ValorComprado: Double;
begin
  ASeries.Clear;
  AQuery.First;

  while not AQuery.Eof do
  begin
    Cliente := AQuery.FieldByName('nome_cliente').AsString;
    ValorComprado := AQuery.FieldByName('valor_comprado').AsFloat;
    ASeries.Add(ValorComprado, Cliente, clTeeColor);
    AQuery.Next;
  end;

  AQuery.First;
end;

procedure TfrmDashboardVendas.ConfigurarReportGraficoTopClientes(
  const AReport: TppReport; const AQuery: TFDQuery);
var
  ChartComp: TppTeeChart;
  TitleBand: TppTitleBand;
  BarSeries: TBarSeries;
  PrintDate: TppSystemVariable;
  PageDesc: TppSystemVariable;
begin
  AReport.AutoStop := True;
  AReport.DeviceType := 'Screen';
  AReport.PassSetting := psTwoPass;
  AReport.Units := utMillimeters;
  AReport.PrinterSetup.DocumentName := 'Top 5 Clientes';
  AReport.PrinterSetup.Orientation := poLandscape;
  AReport.PrinterSetup.PaperName := 'A4';
  AReport.PrinterSetup.PaperHeight := 210.0;
  AReport.PrinterSetup.PaperWidth := 297.0;
  AReport.PrinterSetup.MarginBottom := 6.35;
  AReport.PrinterSetup.MarginLeft := 6.35;
  AReport.PrinterSetup.MarginRight := 6.35;
  AReport.PrinterSetup.MarginTop := 6.35;
  AReport.CreateDefaultBands;

  TitleBand := TppTitleBand.Create(AReport);
  TitleBand.Report := AReport;
  TitleBand.Height := 148.0;

  AReport.HeaderBand.Height := 0.0;
  AReport.DetailBand.Height := 1.0;
  AReport.FooterBand.Height := 8.0;

  AddLabelReport(TitleBand, 'Dashboard de Vendas', 6.0, 2.0, 60.0,
    5.0, 12, True, taLeftJustified, clNavy);
  AddLabelReport(TitleBand, 'Top 5 clientes que mais compraram',
    66.0, 2.0, 150.0, 6.0, 16, True, taCentered, clBlack);
  AddLabelReport(TitleBand,
    'Ranking por valor total de pedidos confirmados', 66.0, 10.0, 150.0,
    4.0, 9, False, taCentered, clGray);

  ChartComp := TppTeeChart.Create(AReport);
  ChartComp.Band := TitleBand;
  ChartComp.Left := 8.0;
  ChartComp.Top := 22.0;
  ChartComp.Width := 268.0;
  ChartComp.Height := 122.0;

  ChartComp.Chart.Title.Text.Clear;
  ChartComp.Chart.Title.Text.Add('Clientes por valor comprado');
  ChartComp.Chart.Color := clWhite;
  ChartComp.Chart.View3D := False;
  ChartComp.Chart.Legend.Visible := False;
  ChartComp.Chart.LeftAxis.Title.Caption := 'Valor comprado (R$)';
  ChartComp.Chart.BottomAxis.Title.Caption := 'Cliente';
  ChartComp.Chart.BottomAxis.LabelsAngle := 30;

  BarSeries := TBarSeries.Create(ChartComp.Chart);
  BarSeries.Title := 'Valor comprado';
  BarSeries.Marks.Visible := True;
  BarSeries.ValueFormat := '#,##0.00';
  ChartComp.Chart.AddSeries(BarSeries);
  PopularSerieTopClientes(AQuery, BarSeries);

  AddLabelReport(AReport.FooterBand, 'Impresso em', 6.0, 2.0, 20.0, 4.0,
    7, False, taLeftJustified, clGray);

  PrintDate := TppSystemVariable.Create(AReport);
  PrintDate.Band := AReport.FooterBand;
  PrintDate.Left := 27.0;
  PrintDate.Top := 2.0;
  PrintDate.Width := 40.0;
  PrintDate.Height := 4.0;
  PrintDate.VarType := vtPrintDateTime;
  PrintDate.DisplayFormat := 'dd/mm/yyyy hh:nn';
  PrintDate.Font.Name := 'Arial';
  PrintDate.Font.Size := 7;
  PrintDate.Font.Color := clGray;

  PageDesc := TppSystemVariable.Create(AReport);
  PageDesc.Band := AReport.FooterBand;
  PageDesc.Left := 245.0;
  PageDesc.Top := 2.0;
  PageDesc.Width := 30.0;
  PageDesc.Height := 4.0;
  PageDesc.VarType := vtPageSetDesc;
  PageDesc.TextAlignment := taRightJustified;
  PageDesc.Font.Name := 'Arial';
  PageDesc.Font.Size := 7;
  PageDesc.Font.Color := clGray;
end;

procedure TfrmDashboardVendas.ImprimirGraficoTopClientes;
var
  QueryGrafico: TFDQuery;
  Report: TppReport;
begin
  QueryGrafico := TFDQuery.Create(nil);
  Report := TppReport.Create(nil);
  try
    QueryGrafico.Connection := TVendasConexao.Conexao;
    AbrirConsulta(QueryGrafico, SQLTopClientes);

    if QueryGrafico.IsEmpty then
    begin
      ShowMessage('Nenhum cliente encontrado para gerar o grafico.');
      Exit;
    end;

    ConfigurarReportGraficoTopClientes(Report, QueryGrafico);
    Report.Print;
  finally
    Report.Free;
    QueryGrafico.Free;
  end;
end;

procedure TfrmDashboardVendas.AtualizarDashboard;
begin
  AtualizarIndicadores;
  AtualizarTopProdutos;
  AtualizarTopClientes;
end;

procedure TfrmDashboardVendas.FormCreate(Sender: TObject);
begin
  try
    ConfigurarConexao;
    ConfigurarGrids;
    AtualizarDashboard;
  except
    on E: Exception do
      ShowMessage('Nao foi possivel carregar o dashboard de vendas: ' + E.Message);
  end;
end;

procedure TfrmDashboardVendas.FormDestroy(Sender: TObject);
begin
  TVendasConexao.Desconectar;
end;

procedure TfrmDashboardVendas.btnAtualizarClick(Sender: TObject);
begin
  try
    AtualizarDashboard;
  except
    on E: Exception do
      ShowMessage('Nao foi possivel atualizar o dashboard: ' + E.Message);
  end;
end;

procedure TfrmDashboardVendas.btnGraficoTopClientesClick(Sender: TObject);
begin
  try
    ImprimirGraficoTopClientes;
  except
    on E: Exception do
      ShowMessage('Nao foi possivel gerar o grafico de clientes: ' + E.Message);
  end;
end;

procedure TfrmDashboardVendas.btnFecharClick(Sender: TObject);
begin
  Close;
end;

end.
