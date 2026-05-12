object frmConsultaFinanceiro: TfrmConsultaFinanceiro
  Left = 0
  Top = 0
  Caption = 'Consulta Financeira'
  ClientHeight = 520
  ClientWidth = 900
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 15
  object pnlTitulo: TPanel
    Left = 0
    Top = 0
    Width = 900
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 24
      Top = 17
      Width = 146
      Height = 21
      Caption = 'Consulta Financeira'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlPesquisa: TPanel
    Left = 0
    Top = 56
    Width = 900
    Height = 88
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblNomeCliente: TLabel
      Left = 24
      Top = 16
      Width = 76
      Height = 15
      Caption = 'Nome Cliente'
    end
    object edtNomeCliente: TEdit
      Left = 24
      Top = 36
      Width = 520
      Height = 23
      TabOrder = 0
      OnKeyPress = edtNomeClienteKeyPress
    end
    object btnPesquisar: TButton
      Left = 568
      Top = 34
      Width = 104
      Height = 27
      Caption = 'Pesquisar'
      TabOrder = 1
      OnClick = btnPesquisarClick
    end
  end
  object sgContas: TStringGrid
    Left = 0
    Top = 144
    Width = 900
    Height = 304
    Align = alClient
    FixedCols = 0
    RowCount = 2
    TabOrder = 2
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 448
    Width = 900
    Height = 72
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    object lblValorAberto: TLabel
      Left = 24
      Top = 14
      Width = 93
      Height = 15
      Caption = 'Valor em Aberto'
    end
    object edtValorAberto: TEdit
      Left = 24
      Top = 34
      Width = 160
      Height = 23
      Alignment = taRightJustify
      ReadOnly = True
      TabOrder = 0
    end
    object btnFechar: TButton
      Left = 772
      Top = 22
      Width = 96
      Height = 30
      Cancel = True
      Caption = 'Fechar'
      TabOrder = 1
      OnClick = btnFecharClick
    end
  end
end
