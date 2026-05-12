unit Frm.Pedido.Venda;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.Grids,
  Vcl.ComCtrls,
  Vendas.Core.Entities.Cliente,
  Vendas.Core.Entities.Produto,
  Vendas.Core.Entities.PedidoVenda,
  Vendas.Application.Interfaces.Repositories;

type
  TfrmPedidoVenda = class(TForm)
    pnlTitulo: TPanel;
    lblTitulo: TLabel;
    pnlCabecalho: TPanel;
    lblNumero: TLabel;
    lblEmissao: TLabel;
    lblCliente: TLabel;
    lblNomeCliente: TLabel;
    edtNumero: TEdit;
    dtpEmissao: TDateTimePicker;
    edtCodCliente: TEdit;
    edtNomeCliente: TEdit;
    pnlItem: TPanel;
    lblCodProduto: TLabel;
    lblDescProduto: TLabel;
    lblQuantidade: TLabel;
    lblValorUnitario: TLabel;
    edtCodProduto: TEdit;
    edtDescProduto: TEdit;
    edtQuantidade: TEdit;
    edtValorUnitario: TEdit;
    btnAdicionarItem: TButton;
    sgItens: TStringGrid;
    pnlRodape: TPanel;
    lblTotalPedido: TLabel;
    edtValorTotal: TEdit;
    btnNovo: TButton;
    btnSalvar: TButton;
    btnRemoverItem: TButton;
    btnSair: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnAdicionarItemClick(Sender: TObject);
    procedure btnRemoverItemClick(Sender: TObject);
    procedure btnSairClick(Sender: TObject);
    procedure edtCodClienteExit(Sender: TObject);
    procedure edtCodClienteKeyPress(Sender: TObject; var Key: Char);
    procedure edtCodProdutoExit(Sender: TObject);
    procedure edtCodProdutoKeyPress(Sender: TObject; var Key: Char);
    procedure edtQuantidadeKeyPress(Sender: TObject; var Key: Char);
    procedure edtValorUnitarioKeyPress(Sender: TObject; var Key: Char);
  private
    FClienteRepository: IClienteRepository;
    FProdutoRepository: IProdutoRepository;
    FPedidoRepository: IPedidoVendaRepository;
    FItens: TObjectList<TPedidoVendaItem>;
    FCodClienteAtual: Integer;
    FCodProdutoAtual: Integer;
    FDescProdutoAtual: string;
    FPrecoProdutoAtual: Currency;

    function CurrParaStr(const AValor: Currency): string;
    function FocarControle(const AControl: TWinControl): Boolean;
    function MontarPedido: TPedidoVenda;
    function NovoNumeroPedido: Integer;
    function QtdParaStr(const AValor: Double): string;
    function StrParaCurr(const ATexto: string; out AValor: Currency): Boolean;
    function StrParaFloat(const ATexto: string; out AValor: Double): Boolean;
    function ValorTotalPedido: Currency;
    function ValidarItem: Boolean;
    function ValidarPedido: Boolean;
    procedure AdicionarLinhaGrid(const AItem: TPedidoVendaItem; const ARow: Integer);
    procedure AdicionarItem;
    procedure AtualizarTotal;
    procedure BuscarCliente;
    procedure BuscarProduto;
    procedure ConfigurarGrid;
    procedure FocarCliente;
    procedure FocarProduto;
    procedure LimparCamposCliente;
    procedure LimparCamposProduto;
    procedure NovoPedido;
    procedure ReconstruirGrid;
    procedure RemoverItemSelecionado;
    procedure SalvarPedido;
  end;

implementation

{$R *.dfm}

uses
  System.UITypes,
  Vcl.Dialogs,
  Shared.Core.Types,
  Vendas.Application.Services.PedidoVenda,
  Vendas.Infrastructure.Integration.FinanceiroGateway,
  Vendas.Infrastructure.Persistence.Repositories.Cliente,
  Vendas.Infrastructure.Persistence.Repositories.Produto,
  Vendas.Infrastructure.Persistence.Repositories.PedidoVenda,
  Frm.Relatorio.PedidoConfirmacao;

procedure TfrmPedidoVenda.FormCreate(Sender: TObject);
begin
  FClienteRepository := TClienteRepository.Create;
  FProdutoRepository := TProdutoRepository.Create;
  FPedidoRepository := TPedidoVendaRepository.Create;
  FItens := TObjectList<TPedidoVendaItem>.Create(True);

  ConfigurarGrid;
  NovoPedido;
end;

procedure TfrmPedidoVenda.FormDestroy(Sender: TObject);
begin
  FItens.Free;
end;

procedure TfrmPedidoVenda.FormShow(Sender: TObject);
begin
  FocarCliente;
end;

function TfrmPedidoVenda.FocarControle(
  const AControl: TWinControl): Boolean;
begin
  Result := Showing and (AControl <> nil) and AControl.CanFocus;
  if Result then
    AControl.SetFocus;
end;

function TfrmPedidoVenda.NovoNumeroPedido: Integer;
begin
  Result := FPedidoRepository.ProximoCodigo;
end;

function TfrmPedidoVenda.StrParaCurr(
  const ATexto: string; out AValor: Currency): Boolean;
var
  Fmt: TFormatSettings;
  Texto: string;
begin
  Fmt := TFormatSettings.Create('pt-BR');
  Texto := Trim(ATexto);

  if (Pos('.', Texto) > 0) and (Pos(',', Texto) = 0) then
    Texto := StringReplace(Texto, '.', ',', [rfReplaceAll]);

  Result := TryStrToCurr(Texto, AValor, Fmt);
end;

function TfrmPedidoVenda.StrParaFloat(
  const ATexto: string; out AValor: Double): Boolean;
var
  Fmt: TFormatSettings;
  Texto: string;
begin
  Fmt := TFormatSettings.Create('pt-BR');
  Texto := Trim(ATexto);

  if (Pos('.', Texto) > 0) and (Pos(',', Texto) = 0) then
    Texto := StringReplace(Texto, '.', ',', [rfReplaceAll]);

  Result := TryStrToFloat(Texto, AValor, Fmt);
end;

function TfrmPedidoVenda.CurrParaStr(const AValor: Currency): string;
var
  Fmt: TFormatSettings;
begin
  Fmt := TFormatSettings.Create('pt-BR');
  Result := FormatFloat('#,##0.00', AValor, Fmt);
end;

function TfrmPedidoVenda.QtdParaStr(const AValor: Double): string;
var
  Fmt: TFormatSettings;
begin
  Fmt := TFormatSettings.Create('pt-BR');
  Result := FormatFloat('#,##0.###', AValor, Fmt);
end;

procedure TfrmPedidoVenda.ConfigurarGrid;
const
  HEADERS: array[0..5] of string = (
    'Seq', 'Cod. Produto', 'Descricao', 'Quantidade', 'Vr. Unitario', 'Vr. Total');
  WIDTHS: array[0..5] of Integer = (48, 96, 360, 100, 110, 110);
var
  I: Integer;
begin
  sgItens.ColCount := 6;
  sgItens.RowCount := 2;
  sgItens.FixedCols := 0;
  sgItens.FixedRows := 1;
  sgItens.Options := sgItens.Options + [goRowSelect] - [goEditing];

  for I := 0 to High(HEADERS) do
  begin
    sgItens.Cells[I, 0] := HEADERS[I];
    sgItens.ColWidths[I] := WIDTHS[I];
  end;
end;

procedure TfrmPedidoVenda.LimparCamposCliente;
begin
  edtCodCliente.Clear;
  edtNomeCliente.Clear;
  FCodClienteAtual := 0;
end;

procedure TfrmPedidoVenda.LimparCamposProduto;
begin
  edtCodProduto.Clear;
  edtDescProduto.Clear;
  edtQuantidade.Text := '1';
  edtValorUnitario.Text := '0,00';
  FCodProdutoAtual := 0;
  FDescProdutoAtual := '';
  FPrecoProdutoAtual := 0;
end;

procedure TfrmPedidoVenda.NovoPedido;
begin
  edtNumero.Text := IntToStr(NovoNumeroPedido);
  dtpEmissao.DateTime := Now;

  LimparCamposCliente;
  LimparCamposProduto;
  FItens.Clear;
  ReconstruirGrid;
  AtualizarTotal;

  FocarCliente;
end;

procedure TfrmPedidoVenda.FocarCliente;
begin
  FocarControle(edtCodCliente);
end;

procedure TfrmPedidoVenda.FocarProduto;
begin
  FocarControle(edtCodProduto);
end;

procedure TfrmPedidoVenda.BuscarCliente;
var
  Cliente: TCliente;
  Codigo: Integer;
begin
  Codigo := StrToIntDef(Trim(edtCodCliente.Text), 0);
  if Codigo <= 0 then
  begin
    edtNomeCliente.Clear;
    FCodClienteAtual := 0;
    Exit;
  end;

  Cliente := FClienteRepository.ObterPorId(Codigo);
  try
    if Cliente = nil then
    begin
      ShowMessage('Cliente nao encontrado.');
      edtNomeCliente.Clear;
      FCodClienteAtual := 0;
      if FocarControle(edtCodCliente) then
        edtCodCliente.SelectAll;
      Exit;
    end;

    FCodClienteAtual := Cliente.Id;
    edtCodCliente.Text := IntToStr(Cliente.Id);
    edtNomeCliente.Text := Cliente.Nome;
  finally
    Cliente.Free;
  end;
end;

procedure TfrmPedidoVenda.BuscarProduto;
var
  Codigo: Integer;
  Produto: TProduto;
begin
  Codigo := StrToIntDef(Trim(edtCodProduto.Text), 0);
  if Codigo <= 0 then
  begin
    LimparCamposProduto;
    Exit;
  end;

  Produto := FProdutoRepository.ObterPorId(Codigo);
  try
    if Produto = nil then
    begin
      ShowMessage('Produto nao encontrado.');
      LimparCamposProduto;
      FocarProduto;
      Exit;
    end;

    if not Produto.Ativo then
    begin
      ShowMessage('Produto inativo.');
      LimparCamposProduto;
      FocarProduto;
      Exit;
    end;

    FCodProdutoAtual := Produto.Id;
    FDescProdutoAtual := Produto.Descricao;
    FPrecoProdutoAtual := Produto.PrecoVenda;
    edtCodProduto.Text := IntToStr(Produto.Id);
    edtDescProduto.Text := Produto.Descricao;
    edtValorUnitario.Text := CurrParaStr(Produto.PrecoVenda);
  finally
    Produto.Free;
  end;
end;

function TfrmPedidoVenda.ValidarItem: Boolean;
var
  CodigoCliente: Integer;
  CodigoProduto: Integer;
  Quantidade: Double;
  ValorUnitario: Currency;
begin
  Result := False;

  CodigoCliente := StrToIntDef(Trim(edtCodCliente.Text), 0);
  if CodigoCliente <> FCodClienteAtual then
    BuscarCliente;

  if FCodClienteAtual <= 0 then
  begin
    ShowMessage('Informe um cliente valido antes de adicionar itens.');
    FocarCliente;
    Exit;
  end;

  CodigoProduto := StrToIntDef(Trim(edtCodProduto.Text), 0);
  if CodigoProduto <> FCodProdutoAtual then
    BuscarProduto;

  if FCodProdutoAtual <= 0 then
  begin
    ShowMessage('Informe um produto valido.');
    FocarProduto;
    Exit;
  end;

  if (not StrParaFloat(edtQuantidade.Text, Quantidade)) or (Quantidade <= 0) then
  begin
    ShowMessage('Informe uma quantidade valida maior que zero.');
    if FocarControle(edtQuantidade) then
      edtQuantidade.SelectAll;
    Exit;
  end;

  if (not StrParaCurr(edtValorUnitario.Text, ValorUnitario)) or
     (ValorUnitario <= 0) then
  begin
    ShowMessage('Informe um valor unitario valido maior que zero.');
    if FocarControle(edtValorUnitario) then
      edtValorUnitario.SelectAll;
    Exit;
  end;

  Result := True;
end;

procedure TfrmPedidoVenda.AdicionarItem;
var
  Item: TPedidoVendaItem;
  Quantidade: Double;
  ValorUnitario: Currency;
begin
  if not ValidarItem then
    Exit;

  StrParaFloat(edtQuantidade.Text, Quantidade);
  StrParaCurr(edtValorUnitario.Text, ValorUnitario);

  Item := TPedidoVendaItem.Create(FCodProdutoAtual, FDescProdutoAtual, Quantidade,
    ValorUnitario);
  FItens.Add(Item);
  ReconstruirGrid;
  AtualizarTotal;
  LimparCamposProduto;

  FocarProduto;
end;

procedure TfrmPedidoVenda.AdicionarLinhaGrid(
  const AItem: TPedidoVendaItem; const ARow: Integer);
begin
  sgItens.Cells[0, ARow] := IntToStr(ARow);
  sgItens.Cells[1, ARow] := IntToStr(AItem.IdProduto);
  sgItens.Cells[2, ARow] := AItem.DescricaoProduto;
  sgItens.Cells[3, ARow] := QtdParaStr(AItem.Quantidade);
  sgItens.Cells[4, ARow] := CurrParaStr(AItem.ValorUnitario);
  sgItens.Cells[5, ARow] := CurrParaStr(AItem.ValorTotal);
end;

procedure TfrmPedidoVenda.ReconstruirGrid;
var
  I: Integer;
begin
  if FItens.Count = 0 then
  begin
    sgItens.RowCount := 2;
    for I := 0 to sgItens.ColCount - 1 do
      sgItens.Cells[I, 1] := '';
    Exit;
  end;

  sgItens.RowCount := FItens.Count + 1;
  for I := 0 to FItens.Count - 1 do
    AdicionarLinhaGrid(FItens[I], I + 1);
end;

function TfrmPedidoVenda.ValorTotalPedido: Currency;
var
  Item: TPedidoVendaItem;
begin
  Result := 0;
  for Item in FItens do
    Result := Result + Item.ValorTotal;
end;

procedure TfrmPedidoVenda.AtualizarTotal;
begin
  edtValorTotal.Text := 'R$ ' + CurrParaStr(ValorTotalPedido);
end;

procedure TfrmPedidoVenda.RemoverItemSelecionado;
var
  Row: Integer;
begin
  Row := sgItens.Row;
  if (Row <= 0) or (FItens.Count = 0) or (Row > FItens.Count) then
  begin
    ShowMessage('Selecione um item para remover.');
    Exit;
  end;

  if MessageDlg(
    Format('Remover o item "%s"?', [FItens[Row - 1].DescricaoProduto]),
    mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  FItens.Delete(Row - 1);
  ReconstruirGrid;
  AtualizarTotal;
end;

function TfrmPedidoVenda.ValidarPedido: Boolean;
var
  CodigoCliente: Integer;
begin
  Result := False;

  CodigoCliente := StrToIntDef(Trim(edtCodCliente.Text), 0);
  if CodigoCliente <> FCodClienteAtual then
    BuscarCliente;

  if FCodClienteAtual <= 0 then
  begin
    ShowMessage('Informe um cliente valido para o pedido.');
    FocarCliente;
    Exit;
  end;

  if FItens.Count = 0 then
  begin
    ShowMessage('Adicione ao menos um item ao pedido.');
    FocarProduto;
    Exit;
  end;

  Result := True;
end;

function TfrmPedidoVenda.MontarPedido: TPedidoVenda;
var
  I: Integer;
  Item: TPedidoVendaItem;
begin
  Result := TPedidoVenda.Create;
  try
    Result.Id := StrToIntDef(Trim(edtNumero.Text), 0);
    Result.IdCliente := FCodClienteAtual;
    Result.NomeCliente := Trim(edtNomeCliente.Text);
    Result.DataEmissao := dtpEmissao.DateTime;

    for I := 0 to FItens.Count - 1 do
    begin
      Item := TPedidoVendaItem.Create(FItens[I].IdProduto,
        FItens[I].DescricaoProduto, FItens[I].Quantidade,
        FItens[I].ValorUnitario);
      try
        Result.AdicionarItem(Item);
      except
        Item.Free;
        raise;
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

procedure TfrmPedidoVenda.SalvarPedido;
var
  Pedido: TPedidoVenda;
  Service: TPedidoVendaService;
  FinanceiroEnviado: Boolean;
  ErroFinanceiro: string;
  PedidoIdSalvo: Integer;
  RelatorioImpresso: Boolean;
begin
  if not ValidarPedido then
    Exit;

  FinanceiroEnviado := False;
  ErroFinanceiro := '';
  RelatorioImpresso := False;

  Pedido := MontarPedido;
  try
    Pedido.Confirmar;
    FPedidoRepository.Salvar(Pedido);
    PedidoIdSalvo := Pedido.Id;
    edtValorTotal.Text := 'R$ ' + CurrParaStr(Pedido.ValorTotal);

    Service := TPedidoVendaService.Create(TFinanceiroGateway.Create);
    try
      try
        Service.EnviarFinanceiro(Pedido);
        FinanceiroEnviado := True;
      except
        on E: Exception do
          ErroFinanceiro := E.Message;
      end;
    finally
      Service.Free;
    end;
  finally
    Pedido.Free;
  end;

  if FinanceiroEnviado then
    ShowMessage(Format(
      'Pedido %s salvo com sucesso.'#13#10 +
      'Total: %s'#13#10 +
      'Financeiro enviado para o RabbitMQ.',
      [edtNumero.Text, edtValorTotal.Text]))
  else
    ShowMessage(Format(
      'Pedido %s salvo com sucesso.'#13#10 +
      'Total: %s'#13#10#13#10 +
      'Nao foi possivel enviar para o Financeiro via RabbitMQ:'#13#10 +
      '%s',
      [edtNumero.Text, edtValorTotal.Text, ErroFinanceiro]));

  if PedidoIdSalvo > 0 then
  begin
    try
      TfrmRelatorioPedidoConfirmacao.ImprimirPedido(PedidoIdSalvo, True);
      RelatorioImpresso := True;
    except
      on E: Exception do
        ShowMessage('Pedido salvo, mas nao foi possivel imprimir o relatorio:' +
          sLineBreak + E.Message);
    end;
  end;

  if RelatorioImpresso then
    NovoPedido;
end;

procedure TfrmPedidoVenda.btnNovoClick(Sender: TObject);
begin
  NovoPedido;
end;

procedure TfrmPedidoVenda.btnSalvarClick(Sender: TObject);
begin
  SalvarPedido;
end;

procedure TfrmPedidoVenda.btnAdicionarItemClick(Sender: TObject);
begin
  AdicionarItem;
end;

procedure TfrmPedidoVenda.btnRemoverItemClick(Sender: TObject);
begin
  RemoverItemSelecionado;
end;

procedure TfrmPedidoVenda.btnSairClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmPedidoVenda.edtCodClienteExit(Sender: TObject);
begin
  if Trim(edtCodCliente.Text) <> '' then
    BuscarCliente;
end;

procedure TfrmPedidoVenda.edtCodClienteKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', #8, #13]) then
    Key := #0;

  if Key = #13 then
  begin
    Key := #0;
    BuscarCliente;
    FocarProduto;
  end;
end;

procedure TfrmPedidoVenda.edtCodProdutoExit(Sender: TObject);
begin
  if Trim(edtCodProduto.Text) <> '' then
    BuscarProduto;
end;

procedure TfrmPedidoVenda.edtCodProdutoKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', #8, #13]) then
    Key := #0;

  if Key = #13 then
  begin
    Key := #0;
    BuscarProduto;
    if FocarControle(edtQuantidade) then
    begin
      edtQuantidade.SelectAll;
    end;
  end;
end;

procedure TfrmPedidoVenda.edtQuantidadeKeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', ',', '.', #8, #13]) then
    Key := #0;

  if Key = #13 then
  begin
    Key := #0;
    if FocarControle(edtValorUnitario) then
    begin
      edtValorUnitario.SelectAll;
    end;
  end;
end;

procedure TfrmPedidoVenda.edtValorUnitarioKeyPress(
  Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['0'..'9', ',', '.', #8, #13]) then
    Key := #0;

  if Key = #13 then
  begin
    Key := #0;
    AdicionarItem;
  end;
end;

end.
