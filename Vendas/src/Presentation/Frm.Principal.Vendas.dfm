object frmPrincipalVendas: TfrmPrincipalVendas
  Left = 0
  Top = 0
  Caption = 'ERP Vendas'
  ClientHeight = 420
  ClientWidth = 760
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object pnlMenu: TPanel
    Left = 0
    Top = 0
    Width = 760
    Height = 132
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 24
      Top = 16
      Width = 176
      Height = 25
      Caption = 'ERP Vendas'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnClientes: TButton
      Left = 24
      Top = 56
      Width = 120
      Height = 28
      Caption = 'Clientes'
      TabOrder = 0
      OnClick = btnClientesClick
    end
    object btnProdutos: TButton
      Left = 152
      Top = 56
      Width = 120
      Height = 28
      Caption = 'Produtos'
      TabOrder = 1
      OnClick = btnProdutosClick
    end
    object btnPedidos: TButton
      Left = 280
      Top = 56
      Width = 120
      Height = 28
      Caption = 'Pedidos'
      TabOrder = 2
      OnClick = btnPedidosClick
    end
    object btnRelPedidos: TButton
      Left = 408
      Top = 56
      Width = 144
      Height = 28
      Caption = 'Rel. Pedidos'
      TabOrder = 3
      OnClick = btnRelPedidosClick
    end
    object btnDesbloquearUsuarios: TButton
      Left = 200
      Top = 92
      Width = 168
      Height = 28
      Caption = 'Desbloquear usuarios'
      TabOrder = 5
      OnClick = btnDesbloquearUsuariosClick
    end
    object btnDadosEmailPedido: TButton
      Left = 24
      Top = 92
      Width = 168
      Height = 28
      Caption = 'Dados Email Pedido'
      TabOrder = 4
      OnClick = btnDadosEmailPedidoClick
    end
  end
  object lblStatusQuitacao: TLabel
    Left = 24
    Top = 148
    Width = 221
    Height = 15
    Caption = 'Aguardando quitacoes do Financeiro...'
  end
  object tmrContaRecebida: TTimer
    Enabled = False
    Interval = 30000
    OnTimer = tmrContaRecebidaTimer
    Left = 24
    Top = 180
  end
end
