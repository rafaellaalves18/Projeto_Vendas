object frmDashboardVendas: TfrmDashboardVendas
  Left = 0
  Top = 0
  Caption = 'Dashboard de Vendas'
  ClientHeight = 620
  ClientWidth = 980
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 15
  object pnlTitulo: TPanel
    Left = 0
    Top = 0
    Width = 980
    Height = 58
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 24
      Top = 16
      Width = 170
      Height = 21
      Caption = 'Dashboard de Vendas'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlAcoes: TPanel
    Left = 0
    Top = 58
    Width = 980
    Height = 48
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object btnAtualizar: TButton
      Left = 24
      Top = 10
      Width = 112
      Height = 28
      Caption = 'Atualizar'
      Default = True
      TabOrder = 0
      OnClick = btnAtualizarClick
    end
    object btnGraficoTopClientes: TButton
      Left = 144
      Top = 10
      Width = 168
      Height = 28
      Caption = 'Grafico top clientes'
      TabOrder = 1
      OnClick = btnGraficoTopClientesClick
    end
    object btnFechar: TButton
      Left = 320
      Top = 10
      Width = 112
      Height = 28
      Cancel = True
      Caption = 'Fechar'
      TabOrder = 2
      OnClick = btnFecharClick
    end
  end
  object pnlIndicadores: TPanel
    Left = 0
    Top = 106
    Width = 980
    Height = 132
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object pnlOrdensFinalizadas: TPanel
      Left = 24
      Top = 12
      Width = 220
      Height = 92
      BevelOuter = bvLowered
      TabOrder = 0
      object lblTituloOrdensFinalizadas: TLabel
        Left = 16
        Top = 14
        Width = 167
        Height = 15
        Caption = 'Ordens de vendas finalizadas'
      end
      object lblOrdensFinalizadas: TLabel
        Left = 16
        Top = 42
        Width = 12
        Height = 28
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -21
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlOrdensPendentes: TPanel
      Left = 260
      Top = 12
      Width = 220
      Height = 92
      BevelOuter = bvLowered
      TabOrder = 1
      object lblTituloOrdensPendentes: TLabel
        Left = 16
        Top = 14
        Width = 154
        Height = 15
        Caption = 'Ordens de vendas pendentes'
      end
      object lblOrdensPendentes: TLabel
        Left = 16
        Top = 42
        Width = 12
        Height = 28
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -21
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlValorProjetado: TPanel
      Left = 496
      Top = 12
      Width = 220
      Height = 92
      BevelOuter = bvLowered
      TabOrder = 2
      object lblTituloValorProjetado: TLabel
        Left = 16
        Top = 14
        Width = 184
        Height = 15
        Caption = 'Valor projetado a ser concluido'
      end
      object lblValorProjetado: TLabel
        Left = 16
        Top = 42
        Width = 67
        Height = 28
        Caption = 'R$ 0,00'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -21
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlValorVendido: TPanel
      Left = 732
      Top = 12
      Width = 220
      Height = 92
      BevelOuter = bvLowered
      TabOrder = 3
      object lblTituloValorVendido: TLabel
        Left = 16
        Top = 14
        Width = 130
        Height = 15
        Caption = 'Valor realmente vendido'
      end
      object lblValorVendido: TLabel
        Left = 16
        Top = 42
        Width = 67
        Height = 28
        Caption = 'R$ 0,00'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -21
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
  object pnlGrids: TPanel
    Left = 0
    Top = 238
    Width = 980
    Height = 382
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 3
    object gbTopProdutos: TGroupBox
      Left = 24
      Top = 8
      Width = 448
      Height = 348
      Caption = 'Top 5 produtos mais vendidos'
      TabOrder = 0
      object dbgTopProdutos: TDBGrid
        Left = 2
        Top = 17
        Width = 444
        Height = 329
        Align = alClient
        DataSource = dsTopProdutos
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
    object gbTopClientes: TGroupBox
      Left = 492
      Top = 8
      Width = 460
      Height = 348
      Caption = 'Top 5 clientes que mais compraram'
      TabOrder = 1
      object dbgTopClientes: TDBGrid
        Left = 2
        Top = 17
        Width = 456
        Height = 329
        Align = alClient
        DataSource = dsTopClientes
        TabOrder = 0
        TitleFont.Charset = DEFAULT_CHARSET
        TitleFont.Color = clWindowText
        TitleFont.Height = -12
        TitleFont.Name = 'Segoe UI'
        TitleFont.Style = []
      end
    end
  end
  object qryResumo: TFDQuery
    Left = 48
    Top = 536
  end
  object qryTopProdutos: TFDQuery
    Left = 128
    Top = 536
  end
  object qryTopClientes: TFDQuery
    Left = 224
    Top = 536
  end
  object dsTopProdutos: TDataSource
    DataSet = qryTopProdutos
    Left = 128
    Top = 584
  end
  object dsTopClientes: TDataSource
    DataSet = qryTopClientes
    Left = 224
    Top = 584
  end
end
