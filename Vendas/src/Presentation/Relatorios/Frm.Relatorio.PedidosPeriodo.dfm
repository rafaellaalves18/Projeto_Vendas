object frmRelatorioPedidosPeriodo: TfrmRelatorioPedidosPeriodo
  Left = 0
  Top = 0
  Caption = 'Relatorio de Pedidos por Periodo'
  ClientHeight = 300
  ClientWidth = 760
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = True
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 15
  object FPnlTitulo: TPanel
    Left = 0
    Top = 0
    Width = 760
    Height = 58
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object FLblTitulo: TLabel
      Left = 24
      Top = 16
      Width = 247
      Height = 21
      Caption = 'Relatorio de Pedidos por Periodo'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object FPnlFiltros: TPanel
    Left = 0
    Top = 58
    Width = 760
    Height = 110
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object FLblDataInicial: TLabel
      Left = 24
      Top = 8
      Width = 58
      Height = 15
      Caption = 'Data inicial'
    end
    object FLblDataFinal: TLabel
      Left = 160
      Top = 8
      Width = 50
      Height = 15
      Caption = 'Data final'
    end
    object FLblCliente: TLabel
      Left = 304
      Top = 8
      Width = 37
      Height = 15
      Caption = 'Cliente'
    end
    object FLblProduto: TLabel
      Left = 24
      Top = 62
      Width = 44
      Height = 15
      Caption = 'Produto'
    end
    object FDtpInicial: TDateTimePicker
      Left = 24
      Top = 28
      Width = 120
      Height = 23
      Date = 45000.000000000000000000
      Time = 45000.000000000000000000
      TabOrder = 0
    end
    object FDtpFinal: TDateTimePicker
      Left = 160
      Top = 28
      Width = 120
      Height = 23
      Date = 45000.000000000000000000
      Time = 45000.000000000000000000
      TabOrder = 1
    end
    object FEdtCodCliente: TEdit
      Left = 304
      Top = 28
      Width = 72
      Height = 23
      TabOrder = 2
      OnExit = edtCodClienteExit
      OnKeyPress = edtCodClienteKeyPress
    end
    object FEdtNomeCliente: TEdit
      Left = 384
      Top = 28
      Width = 320
      Height = 23
      ReadOnly = True
      TabOrder = 3
    end
    object FEdtCodProduto: TEdit
      Left = 24
      Top = 82
      Width = 72
      Height = 23
      TabOrder = 4
      OnExit = edtCodProdutoExit
      OnKeyPress = edtCodProdutoKeyPress
    end
    object FEdtDescProduto: TEdit
      Left = 104
      Top = 82
      Width = 376
      Height = 23
      ReadOnly = True
      TabOrder = 5
    end
  end
  object FPnlBotoes: TPanel
    Left = 0
    Top = 246
    Width = 760
    Height = 54
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object FBtnImprimir: TButton
      Left = 24
      Top = 12
      Width = 120
      Height = 28
      Caption = 'Imprimir'
      Default = True
      TabOrder = 0
      OnClick = btnImprimirClick
    end
    object FBtnSair: TButton
      Left = 152
      Top = 12
      Width = 120
      Height = 28
      Cancel = True
      Caption = 'Sair'
      TabOrder = 1
      OnClick = btnSairClick
    end
  end
  object FQryPedidos: TFDQuery
    SQL.Strings = (
      'select p.id_pedido, p.data_emissao, p.id_cliente, p.nome_cliente,'
      '       p.status, p.valor_total,'
      '       (select count(*)'
      '        from pedidos_venda_itens i'
      '        where i.id_pedido = p.id_pedido) as qtd_itens'
      'from pedidos_venda p'
      'where p.data_emissao >= :data_inicial'
      'and p.data_emissao < :data_final'
      'and (:id_cliente_filtro = 0 or p.id_cliente = :id_cliente)'
      'and (:id_produto_filtro = 0 or exists ('
      '  select 1 from pedidos_venda_itens ip'
      '  where ip.id_pedido = p.id_pedido'
      '  and ip.id_produto = :id_produto))'
      'order by p.data_emissao, p.id_pedido')
    Left = 40
    Top = 248
    object FQryPedidosID_PEDIDO: TIntegerField
      FieldName = 'ID_PEDIDO'
      Origin = 'ID_PEDIDO'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object FQryPedidosDATA_EMISSAO: TSQLTimeStampField
      FieldName = 'DATA_EMISSAO'
      Origin = 'DATA_EMISSAO'
      Required = True
    end
    object FQryPedidosID_CLIENTE: TIntegerField
      FieldName = 'ID_CLIENTE'
      Origin = 'ID_CLIENTE'
      Required = True
    end
    object FQryPedidosNOME_CLIENTE: TWideStringField
      FieldName = 'NOME_CLIENTE'
      Origin = 'NOME_CLIENTE'
      Required = True
      Size = 120
    end
    object FQryPedidosSTATUS: TWideStringField
      FieldName = 'STATUS'
      Origin = 'STATUS'
      Required = True
      Size = 30
    end
    object FQryPedidosVALOR_TOTAL: TBCDField
      FieldName = 'VALOR_TOTAL'
      Origin = 'VALOR_TOTAL'
      Required = True
      Precision = 18
      Size = 2
    end
    object FQryPedidosQTD_ITENS: TLargeintField
      AutoGenerateValue = arDefault
      FieldName = 'QTD_ITENS'
      Origin = 'QTD_ITENS'
      ProviderFlags = []
      ReadOnly = True
    end
  end
  object FQryResumo: TFDQuery
    SQL.Strings = (
      'select count(*) as qtd_pedidos,'
      '       coalesce(sum(p.valor_total), 0) as valor_total'
      'from pedidos_venda p'
      'where p.data_emissao >= :data_inicial'
      'and p.data_emissao < :data_final'
      'and (:id_cliente_filtro = 0 or p.id_cliente = :id_cliente)'
      'and (:id_produto_filtro = 0 or exists ('
      '  select 1 from pedidos_venda_itens ip'
      '  where ip.id_pedido = p.id_pedido'
      '  and ip.id_produto = :id_produto))')
    Left = 40
    Top = 304
    object FQryResumoQTD_PEDIDOS: TLargeintField
      AutoGenerateValue = arDefault
      FieldName = 'QTD_PEDIDOS'
      Origin = 'QTD_PEDIDOS'
      ProviderFlags = []
      ReadOnly = True
    end
    object FQryResumoVALOR_TOTAL: TBCDField
      AutoGenerateValue = arDefault
      FieldName = 'VALOR_TOTAL'
      Origin = 'VALOR_TOTAL'
      ProviderFlags = []
      ReadOnly = True
      Precision = 18
      Size = 2
    end
  end
  object FDSPedidos: TDataSource
    DataSet = FQryPedidos
    Left = 144
    Top = 248
  end
  object FDSResumo: TDataSource
    DataSet = FQryResumo
    Left = 144
    Top = 304
  end
  object FPipePedidos: TppDBPipeline
    DataSource = FDSPedidos
    RangeBegin = rbFirstRecord
    RangeEnd = reLastRecord
    UserName = 'Pedidos'
    Left = 248
    Top = 248
    object FPipePedidosppField1: TppField
      Alignment = taRightJustify
      FieldAlias = 'ID_PEDIDO'
      FieldName = 'ID_PEDIDO'
      FieldLength = 0
      DataType = dtInteger
      DisplayWidth = 10
      Position = 0
    end
    object FPipePedidosppField2: TppField
      FieldAlias = 'DATA_EMISSAO'
      FieldName = 'DATA_EMISSAO'
      FieldLength = 0
      DataType = dtDateTime
      DisplayWidth = 34
      Position = 1
    end
    object FPipePedidosppField3: TppField
      Alignment = taRightJustify
      FieldAlias = 'ID_CLIENTE'
      FieldName = 'ID_CLIENTE'
      FieldLength = 0
      DataType = dtInteger
      DisplayWidth = 10
      Position = 2
    end
    object FPipePedidosppField4: TppField
      FieldAlias = 'NOME_CLIENTE'
      FieldName = 'NOME_CLIENTE'
      FieldLength = 120
      DisplayWidth = 120
      Position = 3
    end
    object FPipePedidosppField5: TppField
      FieldAlias = 'STATUS'
      FieldName = 'STATUS'
      FieldLength = 30
      DisplayWidth = 30
      Position = 4
    end
    object FPipePedidosppField6: TppField
      Alignment = taRightJustify
      FieldAlias = 'VALOR_TOTAL'
      FieldName = 'VALOR_TOTAL'
      FieldLength = 2
      DataType = dtDouble
      DisplayWidth = 19
      Position = 5
    end
    object FPipePedidosppField7: TppField
      Alignment = taRightJustify
      FieldAlias = 'QTD_ITENS'
      FieldName = 'QTD_ITENS'
      FieldLength = 0
      DataType = dtLargeInt
      DisplayWidth = 10
      Position = 6
    end
  end
  object FPipeResumo: TppDBPipeline
    DataSource = FDSResumo
    RangeBegin = rbFirstRecord
    RangeEnd = reLastRecord
    UserName = 'Resumo'
    Left = 248
    Top = 304
    object FPipeResumoppField1: TppField
      Alignment = taRightJustify
      FieldAlias = 'QTD_PEDIDOS'
      FieldName = 'QTD_PEDIDOS'
      FieldLength = 0
      DataType = dtLargeInt
      DisplayWidth = 10
      Position = 0
    end
    object FPipeResumoppField2: TppField
      Alignment = taRightJustify
      FieldAlias = 'VALOR_TOTAL'
      FieldName = 'VALOR_TOTAL'
      FieldLength = 2
      DataType = dtDouble
      DisplayWidth = 19
      Position = 1
    end
  end
  object FReport: TppReport
    AutoStop = False
    DataPipeline = FPipePedidos
    PrinterSetup.BinName = 'Default'
    PrinterSetup.DocumentName = 'Pedidos por Periodo'
    PrinterSetup.Orientation = poLandscape
    PrinterSetup.PaperName = 'A4'
    PrinterSetup.PrinterName = 'Default'
    PrinterSetup.SaveDeviceSettings = False
    PrinterSetup.mmMarginBottom = 6350
    PrinterSetup.mmMarginLeft = 6350
    PrinterSetup.mmMarginRight = 6350
    PrinterSetup.mmMarginTop = 6350
    PrinterSetup.mmPaperHeight = 210000
    PrinterSetup.mmPaperWidth = 297000
    PrinterSetup.PaperSize = 9
    AllowPrintToArchive = True
    AllowPrintToFile = True
    ArchiveFileName = '($MyDocuments)\ReportArchive.raf'
    DeviceType = 'Screen'
    DefaultFileDeviceType = 'PDF'
    EmailSettings.ReportFormat = 'PDF'
    EmailSettings.ConnectionSettings.MailService = 'SMTP'
    EmailSettings.ConnectionSettings.WebMail.GmailSettings.OAuth2.AuthStorage = [oasAccessToken, oasRefreshToken, oasEncryptTokens]
    EmailSettings.ConnectionSettings.WebMail.GmailSettings.OAuth2.RedirectURI = 'http://localhost'
    EmailSettings.ConnectionSettings.WebMail.GmailSettings.OAuth2.RedirectPort = 0
    EmailSettings.ConnectionSettings.WebMail.GmailSettings.OAuth2.RefreshTokenLifeSpan = 365
    EmailSettings.ConnectionSettings.WebMail.Outlook365Settings.OAuth2.AuthStorage = [oasAccessToken, oasRefreshToken, oasEncryptTokens]
    EmailSettings.ConnectionSettings.WebMail.Outlook365Settings.OAuth2.RedirectURI = 'http://localhost'
    EmailSettings.ConnectionSettings.WebMail.Outlook365Settings.OAuth2.RedirectPort = 0
    EmailSettings.ConnectionSettings.WebMail.Outlook365Settings.OAuth2.RefreshTokenLifeSpan = 365
    EmailSettings.ConnectionSettings.EnableMultiPlugin = False
    EmailSettings.ConnectionSettings.ConnectionStatusInfo = [csiStatusBar]
    LanguageID = 'Default'
    OpenFile = False
    OutlineSettings.CreateNode = True
    OutlineSettings.CreatePageNodes = True
    OutlineSettings.Enabled = True
    OutlineSettings.Visible = True
    PassSetting = psTwoPass
    ThumbnailSettings.Enabled = True
    ThumbnailSettings.Visible = True
    ThumbnailSettings.DeadSpace = 30
    ThumbnailSettings.PageHighlight.Width = 3
    ThumbnailSettings.ThumbnailSize = tsSmall
    PDFSettings.EmbedFontOptions = [efUseSubset]
    PDFSettings.EncryptSettings.AllowCopy = True
    PDFSettings.EncryptSettings.AllowInteract = True
    PDFSettings.EncryptSettings.AllowModify = True
    PDFSettings.EncryptSettings.AllowPrint = True
    PDFSettings.EncryptSettings.AllowExtract = True
    PDFSettings.EncryptSettings.AllowAssemble = True
    PDFSettings.EncryptSettings.AllowQualityPrint = True
    PDFSettings.EncryptSettings.Enabled = False
    PDFSettings.EncryptSettings.KeyLength = kl40Bit
    PDFSettings.EncryptSettings.EncryptionType = etRC4
    PDFSettings.DigitalSignatureSettings.SignPDF = False
    PDFSettings.FontEncoding = feAnsi
    PDFSettings.ImageCompressionLevel = 25
    PDFSettings.PDFAFormat = pafNone
    PDFSettings.Layers = False
    PDFSettings.Outline = False
    PreviewFormSettings.PageBorder.mmPadding = 0
    PreviewFormSettings.WindowState = wsMaximized
    PreviewFormSettings.ZoomSetting = zs100Percent
    RTFSettings.AppName = 'ReportBuilder'
    RTFSettings.Author = 'ReportBuilder'
    RTFSettings.DefaultFont.Charset = DEFAULT_CHARSET
    RTFSettings.DefaultFont.Color = clWindowText
    RTFSettings.DefaultFont.Height = -13
    RTFSettings.DefaultFont.Name = 'Arial'
    RTFSettings.DefaultFont.Style = []
    RTFSettings.Title = 'Report'
    TextFileName = '($MyDocuments)\Report.pdf'
    TextSearchSettings.DefaultString = '<FindText>'
    TextSearchSettings.Enabled = True
    XLSSettings.AppName = 'ReportBuilder'
    XLSSettings.Author = 'ReportBuilder'
    XLSSettings.Subject = 'Report'
    XLSSettings.Title = 'Report'
    XLSSettings.WorksheetName = 'Report'
    Left = 360
    Top = 248
    Version = '23.03'
    mmColumnWidth = 284300
    DataPipelineName = 'FPipePedidos'
    object ppTitleBand1: TppTitleBand
      Border.mmPadding = 0
      mmBottomOffset = 0
      mmHeight = 36830
      mmPrintPosition = 0
      object ppShapeTitulo: TppShape
        DesignLayer = ppDesignLayer1
        UserName = 'ShapeTitulo'
        Brush.Color = 15921906
        Brush.Style = bsSolid
        Pen.Color = 12105912
        mmHeight = 14224
        mmLeft = 0
        mmTop = 0
        mmWidth = 284300
        BandType = 1
        LayerName = Foreground1
      end
      object ppLabelERP: TppLabel
        DesignLayer = ppDesignLayer1
        UserName = 'LabelERP'
        Border.mmPadding = 0
        Caption = 'ERP Vendas'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 4210752
        Font.Name = 'Arial'
        Font.Size = 12
        Font.Style = [fsBold]
        Transparent = True
        mmHeight = 4572
        mmLeft = 3810
        mmTop = 2540
        mmWidth = 35560
        BandType = 1
        LayerName = Foreground1
      end
      object ppLabelTituloReport: TppLabel
        DesignLayer = ppDesignLayer1
        UserName = 'LabelTituloReport'
        Border.mmPadding = 0
        Caption = 'Pedidos por Periodo'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 4210752
        Font.Name = 'Arial'
        Font.Size = 13
        Font.Style = [fsBold]
        TextAlignment = taCentered
        Transparent = True
        mmHeight = 5588
        mmLeft = 70000
        mmTop = 2540
        mmWidth = 140000
        BandType = 1
        LayerName = Foreground1
      end
      object ppLabelSubTitulo: TppLabel
        DesignLayer = ppDesignLayer1
        UserName = 'LabelSubTitulo'
        Border.mmPadding = 0
        Caption = 'Listagem consolidada de pedidos de venda'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Name = 'Arial'
        Font.Size = 7
        Font.Style = []
        TextAlignment = taCentered
        Transparent = True
        mmHeight = 3302
        mmLeft = 70000
        mmTop = 8890
        mmWidth = 140000
        BandType = 1
        LayerName = Foreground1
      end
      object FLblFiltroPeriodo: TppLabel
        DesignLayer = ppDesignLayer1
        UserName = 'LblFiltroPeriodo'
        Border.mmPadding = 0
        Caption = 'Periodo:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Name = 'Arial'
        Font.Size = 8
        Font.Style = []
        Transparent = True
        mmHeight = 3556
        mmLeft = 2540
        mmTop = 18288
        mmWidth = 120000
        BandType = 1
        LayerName = Foreground1
      end
      object FLblFiltroCliente: TppLabel
        DesignLayer = ppDesignLayer1
        UserName = 'LblFiltroCliente'
        Border.mmPadding = 0
        Caption = 'Cliente: Todos'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Name = 'Arial'
        Font.Size = 8
        Font.Style = []
        Transparent = True
        mmHeight = 3556
        mmLeft = 2540
        mmTop = 23876
        mmWidth = 270000
        BandType = 1
        LayerName = Foreground1
      end
      object FLblFiltroProduto: TppLabel
        DesignLayer = ppDesignLayer1
        UserName = 'LblFiltroProduto'
        Border.mmPadding = 0
        Caption = 'Produto: Todos'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Name = 'Arial'
        Font.Size = 8
        Font.Style = []
        Transparent = True
        mmHeight = 3556
        mmLeft = 2540
        mmTop = 29464
        mmWidth = 270000
        BandType = 1
        LayerName = Foreground1
      end
    end
    object ppHeaderBand1: TppHeaderBand
      Border.mmPadding = 0
      mmBottomOffset = 0
      mmHeight = 9144
      mmPrintPosition = 0
      object ppShapeHeader: TppShape
        DesignLayer = ppDesignLayer1
        UserName = 'ShapeHeader'
        Brush.Color = 15921906
        Brush.Style = bsSolid
        Pen.Color = 12105912
        mmHeight = 7112
        mmLeft = 0
        mmTop = 508
        mmWidth = 284300
        BandType = 0
        LayerName = Foreground1
      end
      object ppLabelPedido: TppLabel
        DesignLayer = ppDesignLayer1
        UserName = 'LabelPedido'
        Border.mmPadding = 0
        Caption = 'Pedido'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Name = 'Arial'
        Font.Size = 7
        Font.Style = [fsBold]
        Transparent = True
        mmHeight = 3302
        mmLeft = 2540
        mmTop = 2540
        mmWidth = 17000
        BandType = 0
        LayerName = Foreground1
      end
      object ppLabelEmissao: TppLabel
        DesignLayer = ppDesignLayer1
        UserName = 'LabelEmissao'
        Border.mmPadding = 0
        Caption = 'Emissao'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Name = 'Arial'
        Font.Size = 7
        Font.Style = [fsBold]
        Transparent = True
        mmHeight = 3302
        mmLeft = 24000
        mmTop = 2540
        mmWidth = 25000
        BandType = 0
        LayerName = Foreground1
      end
      object ppLabelCliente: TppLabel
        DesignLayer = ppDesignLayer1
        UserName = 'LabelCliente'
        Border.mmPadding = 0
        Caption = 'Cliente'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Name = 'Arial'
        Font.Size = 7
        Font.Style = [fsBold]
        Transparent = True
        mmHeight = 3302
        mmLeft = 55000
        mmTop = 2540
        mmWidth = 125000
        BandType = 0
        LayerName = Foreground1
      end
      object ppLabelStatus: TppLabel
        DesignLayer = ppDesignLayer1
        UserName = 'LabelStatus'
        Border.mmPadding = 0
        Caption = 'Status'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Name = 'Arial'
        Font.Size = 7
        Font.Style = [fsBold]
        Transparent = True
        mmHeight = 3302
        mmLeft = 184000
        mmTop = 2540
        mmWidth = 30000
        BandType = 0
        LayerName = Foreground1
      end
      object ppLabelItens: TppLabel
        DesignLayer = ppDesignLayer1
        UserName = 'LabelItens'
        Border.mmPadding = 0
        Caption = 'Itens'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Name = 'Arial'
        Font.Size = 7
        Font.Style = [fsBold]
        TextAlignment = taRightJustified
        Transparent = True
        mmHeight = 3302
        mmLeft = 220000
        mmTop = 2540
        mmWidth = 15000
        BandType = 0
        LayerName = Foreground1
      end
      object ppLabelTotal: TppLabel
        DesignLayer = ppDesignLayer1
        UserName = 'LabelTotal'
        Border.mmPadding = 0
        Caption = 'Total'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Name = 'Arial'
        Font.Size = 7
        Font.Style = [fsBold]
        TextAlignment = taRightJustified
        Transparent = True
        mmHeight = 3302
        mmLeft = 244000
        mmTop = 2540
        mmWidth = 35000
        BandType = 0
        LayerName = Foreground1
      end
    end
    object ppDetailBand1: TppDetailBand
      Border.mmPadding = 0
      mmBottomOffset = 0
      mmHeight = 7112
      mmPrintPosition = 0
      object dbPedidoId: TppDBText
        DesignLayer = ppDesignLayer1
        UserName = 'dbPedidoId'
        Border.mmPadding = 0
        DataField = 'ID_PEDIDO'
        DataPipeline = FPipePedidos
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Name = 'Arial'
        Font.Size = 8
        Font.Style = []
        Transparent = True
        DataPipelineName = 'FPipePedidos'
        mmHeight = 3556
        mmLeft = 2540
        mmTop = 1524
        mmWidth = 17000
        BandType = 4
        LayerName = Foreground1
      end
      object dbEmissao: TppDBText
        DesignLayer = ppDesignLayer1
        UserName = 'dbEmissao'
        Border.mmPadding = 0
        DataField = 'DATA_EMISSAO'
        DataPipeline = FPipePedidos
        DisplayFormat = 'dd/mm/yyyy'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Name = 'Arial'
        Font.Size = 8
        Font.Style = []
        Transparent = True
        DataPipelineName = 'FPipePedidos'
        mmHeight = 3556
        mmLeft = 24000
        mmTop = 1524
        mmWidth = 25000
        BandType = 4
        LayerName = Foreground1
      end
      object dbCliente: TppDBText
        DesignLayer = ppDesignLayer1
        UserName = 'dbCliente'
        Border.mmPadding = 0
        DataField = 'NOME_CLIENTE'
        DataPipeline = FPipePedidos
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Name = 'Arial'
        Font.Size = 8
        Font.Style = []
        Transparent = True
        DataPipelineName = 'FPipePedidos'
        mmHeight = 3556
        mmLeft = 55000
        mmTop = 1524
        mmWidth = 125000
        BandType = 4
        LayerName = Foreground1
      end
      object dbStatus: TppDBText
        DesignLayer = ppDesignLayer1
        UserName = 'dbStatus'
        Border.mmPadding = 0
        DataField = 'STATUS'
        DataPipeline = FPipePedidos
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Name = 'Arial'
        Font.Size = 8
        Font.Style = []
        Transparent = True
        DataPipelineName = 'FPipePedidos'
        mmHeight = 3556
        mmLeft = 184000
        mmTop = 1524
        mmWidth = 30000
        BandType = 4
        LayerName = Foreground1
      end
      object dbQtdItens: TppDBText
        DesignLayer = ppDesignLayer1
        UserName = 'dbQtdItens'
        Border.mmPadding = 0
        DataField = 'QTD_ITENS'
        DataPipeline = FPipePedidos
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Name = 'Arial'
        Font.Size = 8
        Font.Style = []
        TextAlignment = taRightJustified
        Transparent = True
        DataPipelineName = 'FPipePedidos'
        mmHeight = 3556
        mmLeft = 220000
        mmTop = 1524
        mmWidth = 15000
        BandType = 4
        LayerName = Foreground1
      end
      object dbValorTotal: TppDBText
        DesignLayer = ppDesignLayer1
        UserName = 'dbValorTotal'
        Border.mmPadding = 0
        DataField = 'VALOR_TOTAL'
        DataPipeline = FPipePedidos
        DisplayFormat = '#,##0.00;-#,##0.00'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Name = 'Arial'
        Font.Size = 8
        Font.Style = []
        TextAlignment = taRightJustified
        Transparent = True
        DataPipelineName = 'FPipePedidos'
        mmHeight = 3556
        mmLeft = 244000
        mmTop = 1524
        mmWidth = 35000
        BandType = 4
        LayerName = Foreground1
      end
      object ppLineDetail: TppLine
        DesignLayer = ppDesignLayer1
        UserName = 'LineDetail'
        Border.mmPadding = 0
        Pen.Color = 14737632
        Weight = 0.750000000000000000
        mmHeight = 0
        mmLeft = 0
        mmTop = 6604
        mmWidth = 284300
        BandType = 4
        LayerName = Foreground1
      end
    end
    object ppSummaryBand1: TppSummaryBand
      Border.mmPadding = 0
      mmBottomOffset = 0
      mmHeight = 19812
      mmPrintPosition = 0
      object ppLineSummary: TppLine
        DesignLayer = ppDesignLayer1
        UserName = 'LineSummary'
        Border.mmPadding = 0
        Pen.Color = 12105912
        Weight = 0.750000000000000000
        mmHeight = 0
        mmLeft = 0
        mmTop = 2540
        mmWidth = 284300
        BandType = 7
        LayerName = Foreground1
      end
      object ppShapeSummary: TppShape
        DesignLayer = ppDesignLayer1
        UserName = 'ShapeSummary'
        Brush.Color = 15921906
        Brush.Style = bsSolid
        Pen.Color = 12105912
        mmHeight = 9144
        mmLeft = 158000
        mmTop = 6096
        mmWidth = 126300
        BandType = 7
        LayerName = Foreground1
      end
      object ppLabelPedidosResumo: TppLabel
        DesignLayer = ppDesignLayer1
        UserName = 'LabelPedidosResumo'
        Border.mmPadding = 0
        Caption = 'Pedidos'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 4210752
        Font.Name = 'Arial'
        Font.Size = 8
        Font.Style = [fsBold]
        Transparent = True
        mmHeight = 3048
        mmLeft = 164000
        mmTop = 9144
        mmWidth = 18000
        BandType = 7
        LayerName = Foreground1
      end
      object dbQtdPedidos: TppDBText
        DesignLayer = ppDesignLayer1
        UserName = 'dbQtdPedidos'
        Border.mmPadding = 0
        DataField = 'QTD_PEDIDOS'
        DataPipeline = FPipeResumo
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Name = 'Arial'
        Font.Size = 9
        Font.Style = [fsBold]
        TextAlignment = taRightJustified
        Transparent = True
        DataPipelineName = 'FPipeResumo'
        mmHeight = 3810
        mmLeft = 184000
        mmTop = 8636
        mmWidth = 18000
        BandType = 7
        LayerName = Foreground1
      end
      object ppLabelTotalGeral: TppLabel
        DesignLayer = ppDesignLayer1
        UserName = 'LabelTotalGeral'
        Border.mmPadding = 0
        Caption = 'Total geral'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 4210752
        Font.Name = 'Arial'
        Font.Size = 8
        Font.Style = [fsBold]
        Transparent = True
        mmHeight = 3048
        mmLeft = 214000
        mmTop = 9144
        mmWidth = 25000
        BandType = 7
        LayerName = Foreground1
      end
      object dbTotalGeral: TppDBText
        DesignLayer = ppDesignLayer1
        UserName = 'dbTotalGeral'
        Border.mmPadding = 0
        DataField = 'VALOR_TOTAL'
        DataPipeline = FPipeResumo
        DisplayFormat = '#,##0.00;-#,##0.00'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Name = 'Arial'
        Font.Size = 10
        Font.Style = [fsBold]
        TextAlignment = taRightJustified
        Transparent = True
        DataPipelineName = 'FPipeResumo'
        mmHeight = 4572
        mmLeft = 242000
        mmTop = 8128
        mmWidth = 35000
        BandType = 7
        LayerName = Foreground1
      end
    end
    object ppFooterBand1: TppFooterBand
      Border.mmPadding = 0
      mmBottomOffset = 0
      mmHeight = 9144
      mmPrintPosition = 0
      object ppLineFooter: TppLine
        DesignLayer = ppDesignLayer1
        UserName = 'LineFooter'
        Border.mmPadding = 0
        Pen.Color = 14737632
        Weight = 0.750000000000000000
        mmHeight = 0
        mmLeft = 0
        mmTop = 1016
        mmWidth = 284300
        BandType = 8
        LayerName = Foreground1
      end
      object ppLabelImpressoEm: TppLabel
        DesignLayer = ppDesignLayer1
        UserName = 'LabelImpressoEm'
        Border.mmPadding = 0
        Caption = 'Impresso em'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Name = 'Arial'
        Font.Size = 7
        Font.Style = []
        Transparent = True
        mmHeight = 3048
        mmLeft = 0
        mmTop = 3810
        mmWidth = 17780
        BandType = 8
        LayerName = Foreground1
      end
      object ppSystemPrintDate: TppSystemVariable
        DesignLayer = ppDesignLayer1
        UserName = 'SystemPrintDate'
        Border.mmPadding = 0
        DisplayFormat = 'dd/mm/yyyy hh:nn'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Name = 'Arial'
        Font.Size = 7
        Font.Style = []
        Transparent = True
        VarType = vtPrintDateTime
        mmHeight = 3048
        mmLeft = 19050
        mmTop = 3810
        mmWidth = 30480
        BandType = 8
        LayerName = Foreground1
      end
      object ppSystemPageDesc: TppSystemVariable
        DesignLayer = ppDesignLayer1
        UserName = 'SystemPageDesc'
        Border.mmPadding = 0
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Name = 'Arial'
        Font.Size = 7
        Font.Style = []
        TextAlignment = taRightJustified
        Transparent = True
        VarType = vtPageSetDesc
        mmHeight = 3048
        mmLeft = 250000
        mmTop = 3810
        mmWidth = 32000
        BandType = 8
        LayerName = Foreground1
      end
    end
    object ppDesignLayers1: TppDesignLayers
      object ppDesignLayer1: TppDesignLayer
        UserName = 'Foreground1'
        LayerType = ltBanded
        Index = 0
      end
    end
    object ppParameterList1: TppParameterList
    end
  end
end
