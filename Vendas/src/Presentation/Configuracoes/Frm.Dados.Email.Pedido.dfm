object frmDadosEmailPedido: TfrmDadosEmailPedido
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Dados Email Pedido'
  ClientHeight = 352
  ClientWidth = 560
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object pnlTitulo: TPanel
    Left = 0
    Top = 0
    Width = 560
    Height = 56
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 24
      Top = 16
      Width = 177
      Height = 21
      Caption = 'Dados Email Pedido'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlBotoes: TPanel
    Left = 0
    Top = 300
    Width = 560
    Height = 52
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 8
    object btnSalvar: TButton
      Left = 24
      Top = 12
      Width = 120
      Height = 28
      Caption = 'Salvar'
      Default = True
      TabOrder = 0
      OnClick = btnSalvarClick
    end
    object btnSair: TButton
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
  object lblHost: TLabel
    Left = 24
    Top = 72
    Width = 76
    Height = 15
    Caption = 'Servidor SMTP'
  end
  object lblPorta: TLabel
    Left = 416
    Top = 72
    Width = 29
    Height = 15
    Caption = 'Porta'
  end
  object lblUsuario: TLabel
    Left = 24
    Top = 128
    Width = 43
    Height = 15
    Caption = 'Usuario'
  end
  object lblSenha: TLabel
    Left = 288
    Top = 128
    Width = 33
    Height = 15
    Caption = 'Senha'
  end
  object lblEmailRemetente: TLabel
    Left = 24
    Top = 184
    Width = 93
    Height = 15
    Caption = 'E-mail remetente'
  end
  object lblNomeRemetente: TLabel
    Left = 288
    Top = 184
    Width = 96
    Height = 15
    Caption = 'Nome remetente'
  end
  object edtHost: TEdit
    Left = 24
    Top = 92
    Width = 376
    Height = 23
    TabOrder = 1
  end
  object edtPorta: TEdit
    Left = 416
    Top = 92
    Width = 96
    Height = 23
    TabOrder = 2
    OnKeyPress = edtPortaKeyPress
  end
  object edtUsuario: TEdit
    Left = 24
    Top = 148
    Width = 248
    Height = 23
    TabOrder = 3
  end
  object edtSenha: TEdit
    Left = 288
    Top = 148
    Width = 224
    Height = 23
    PasswordChar = '*'
    TabOrder = 4
  end
  object edtEmailRemetente: TEdit
    Left = 24
    Top = 204
    Width = 248
    Height = 23
    TabOrder = 5
  end
  object edtNomeRemetente: TEdit
    Left = 288
    Top = 204
    Width = 224
    Height = 23
    TabOrder = 6
  end
  object lblSeguranca: TLabel
    Left = 24
    Top = 240
    Width = 90
    Height = 15
    Caption = 'Seguranca SMTP'
  end
  object cbxSeguranca: TComboBox
    Left = 24
    Top = 260
    Width = 248
    Height = 23
    Style = csDropDownList
    ItemIndex = 0
    TabOrder = 7
    Text = 'STARTTLS (porta 587)'
    OnChange = cbxSegurancaChange
    Items.Strings = (
      'STARTTLS (porta 587)'
      'SSL/TLS implicito (porta 465)'
      'Sem TLS')
  end
end
