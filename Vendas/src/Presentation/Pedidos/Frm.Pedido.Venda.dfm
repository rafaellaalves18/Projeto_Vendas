object frmPedidoVenda: TfrmPedidoVenda
  Left = 0
  Top = 0
  Caption = 'Pedido de Venda'
  ClientHeight = 640
  ClientWidth = 960
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
    Width = 960
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 24
      Top = 17
      Width = 129
      Height = 21
      Caption = 'Pedido de Venda'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlCabecalho: TPanel
    Left = 0
    Top = 56
    Width = 960
    Height = 112
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 1
    object lblNumero: TLabel
      Left = 24
      Top = 16
      Width = 43
      Height = 15
      Caption = 'Pedido'
    end
    object lblEmissao: TLabel
      Left = 144
      Top = 16
      Width = 47
      Height = 15
      Caption = 'Emissao'
    end
    object lblCliente: TLabel
      Left = 24
      Top = 66
      Width = 39
      Height = 15
      Caption = 'Cliente'
    end
    object lblNomeCliente: TLabel
      Left = 144
      Top = 66
      Width = 76
      Height = 15
      Caption = 'Nome Cliente'
    end
    object edtNumero: TEdit
      Left = 24
      Top = 36
      Width = 96
      Height = 23
      ReadOnly = True
      TabOrder = 0
    end
    object dtpEmissao: TDateTimePicker
      Left = 144
      Top = 36
      Width = 130
      Height = 23
      Date = 45000.000000000000000000
      Time = 0.000000000000000000
      TabOrder = 1
    end
    object edtCodCliente: TEdit
      Left = 24
      Top = 86
      Width = 96
      Height = 23
      TabOrder = 2
      OnExit = edtCodClienteExit
      OnKeyPress = edtCodClienteKeyPress
    end
    object edtNomeCliente: TEdit
      Left = 144
      Top = 86
      Width = 560
      Height = 23
      ReadOnly = True
      TabOrder = 3
    end
  end
  object pnlItem: TPanel
    Left = 0
    Top = 168
    Width = 960
    Height = 112
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object lblCodProduto: TLabel
      Left = 24
      Top = 16
      Width = 45
      Height = 15
      Caption = 'Produto'
    end
    object lblDescProduto: TLabel
      Left = 144
      Top = 16
      Width = 55
      Height = 15
      Caption = 'Descricao'
    end
    object lblQuantidade: TLabel
      Left = 544
      Top = 16
      Width = 65
      Height = 15
      Caption = 'Quantidade'
    end
    object lblValorUnitario: TLabel
      Left = 664
      Top = 16
      Width = 75
      Height = 15
      Caption = 'Vr. Unitario'
    end
    object edtCodProduto: TEdit
      Left = 24
      Top = 36
      Width = 96
      Height = 23
      TabOrder = 0
      OnExit = edtCodProdutoExit
      OnKeyPress = edtCodProdutoKeyPress
    end
    object edtDescProduto: TEdit
      Left = 144
      Top = 36
      Width = 376
      Height = 23
      ReadOnly = True
      TabOrder = 1
    end
    object edtQuantidade: TEdit
      Left = 544
      Top = 36
      Width = 96
      Height = 23
      TabOrder = 2
      OnKeyPress = edtQuantidadeKeyPress
    end
    object edtValorUnitario: TEdit
      Left = 664
      Top = 36
      Width = 112
      Height = 23
      TabOrder = 3
      OnKeyPress = edtValorUnitarioKeyPress
    end
    object btnAdicionarItem: TButton
      Left = 800
      Top = 34
      Width = 120
      Height = 27
      Caption = 'Adicionar Item'
      TabOrder = 4
      OnClick = btnAdicionarItemClick
    end
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 568
    Width = 960
    Height = 72
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 4
    object lblTotalPedido: TLabel
      Left = 24
      Top = 18
      Width = 87
      Height = 15
      Caption = 'Total do Pedido'
    end
    object edtValorTotal: TEdit
      Left = 24
      Top = 38
      Width = 160
      Height = 23
      Alignment = taRightJustify
      ReadOnly = True
      TabOrder = 0
    end
    object btnNovo: TButton
      Left = 536
      Top = 25
      Width = 88
      Height = 30
      Caption = 'Novo'
      TabOrder = 1
      OnClick = btnNovoClick
    end
    object btnSalvar: TButton
      Left = 632
      Top = 25
      Width = 88
      Height = 30
      Caption = 'Salvar'
      TabOrder = 2
      OnClick = btnSalvarClick
    end
    object btnRemoverItem: TButton
      Left = 728
      Top = 25
      Width = 104
      Height = 30
      Caption = 'Remover Item'
      TabOrder = 3
      OnClick = btnRemoverItemClick
    end
    object btnSair: TButton
      Left = 840
      Top = 25
      Width = 88
      Height = 30
      Cancel = True
      Caption = 'Sair'
      TabOrder = 4
      OnClick = btnSairClick
    end
  end
  object sgItens: TStringGrid
    Left = 0
    Top = 280
    Width = 960
    Height = 288
    Align = alClient
    FixedCols = 0
    RowCount = 2
    TabOrder = 3
  end
end
