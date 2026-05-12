object frmPrincipalFinanceiro: TfrmPrincipalFinanceiro
  Left = 0
  Top = 0
  Caption = 'ERP Financeiro'
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
  OnDestroy = FormDestroy
  TextHeight = 15
  object pnlMenu: TPanel
    Left = 0
    Top = 0
    Width = 760
    Height = 158
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 24
      Top = 16
      Width = 153
      Height = 25
      Caption = 'ERP Financeiro'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblStatusRabbitMQ: TLabel
      Left = 24
      Top = 132
      Width = 712
      Height = 15
      AutoSize = False
      Caption = 'RabbitMQ'
    end
    object btnBaixaFinanceiro: TButton
      Left = 24
      Top = 56
      Width = 144
      Height = 28
      Caption = 'Baixar Financeiro'
      TabOrder = 0
      OnClick = btnBaixaFinanceiroClick
    end
    object btnConsultaFinanceiro: TButton
      Left = 184
      Top = 56
      Width = 144
      Height = 28
      Caption = 'Consultar Financeiro'
      TabOrder = 1
      OnClick = btnConsultaFinanceiroClick
    end
    object btnRelatorioFinanceiro: TButton
      Left = 344
      Top = 56
      Width = 144
      Height = 28
      Caption = 'Rel. Financeiro'
      TabOrder = 2
      OnClick = btnRelatorioFinanceiroClick
    end
    object btnDashboardVendas: TButton
      Left = 504
      Top = 56
      Width = 144
      Height = 28
      Caption = 'Dashboard Vendas'
      TabOrder = 3
      OnClick = btnDashboardVendasClick
    end
    object btnDesbloquearUsuarios: TButton
      Left = 24
      Top = 92
      Width = 168
      Height = 28
      Caption = 'Desbloquear usuarios'
      TabOrder = 4
      OnClick = btnDesbloquearUsuariosClick
    end
  end
  object tmrRabbitMQ: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = tmrRabbitMQTimer
    Left = 696
    Top = 24
  end
end
