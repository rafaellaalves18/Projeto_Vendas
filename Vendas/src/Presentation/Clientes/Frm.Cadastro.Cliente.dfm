object frmCadastroCliente: TfrmCadastroCliente
  Left = 0
  Top = 0
  Caption = 'Cadastro de Clientes'
  ClientHeight = 390
  ClientWidth = 720
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 15
  object pnlTitulo: TPanel
    Left = 0
    Top = 0
    Width = 720
    Height = 64
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 24
      Top = 20
      Width = 177
      Height = 21
      Caption = 'Cadastro de Clientes'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object pnlCampos: TPanel
    Left = 0
    Top = 64
    Width = 720
    Height = 262
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object lblCodigo: TLabel
      Left = 24
      Top = 20
      Width = 42
      Height = 15
      Caption = 'Codigo'
    end
    object lblNome: TLabel
      Left = 144
      Top = 20
      Width = 33
      Height = 15
      Caption = 'Nome'
    end
    object lblDocumento: TLabel
      Left = 24
      Top = 78
      Width = 68
      Height = 15
      Caption = 'Documento'
    end
    object lblEmail: TLabel
      Left = 264
      Top = 78
      Width = 32
      Height = 15
      Caption = 'E-mail'
    end
    object lblTelefone: TLabel
      Left = 24
      Top = 136
      Width = 49
      Height = 15
      Caption = 'Telefone'
    end
    object lblCidade: TLabel
      Left = 264
      Top = 136
      Width = 40
      Height = 15
      Caption = 'Cidade'
    end
    object lblUF: TLabel
      Left = 608
      Top = 136
      Width = 15
      Height = 15
      Caption = 'UF'
    end
    object edtCodigo: TEdit
      Left = 24
      Top = 40
      Width = 96
      Height = 23
      TabOrder = 0
      OnExit = edtCodigoExit
      OnKeyPress = edtCodigoKeyPress
    end
    object edtNome: TEdit
      Left = 144
      Top = 40
      Width = 536
      Height = 23
      TabOrder = 1
    end
    object edtDocumento: TEdit
      Left = 24
      Top = 98
      Width = 216
      Height = 23
      TabOrder = 2
    end
    object edtEmail: TEdit
      Left = 264
      Top = 98
      Width = 416
      Height = 23
      TabOrder = 3
    end
    object edtTelefone: TEdit
      Left = 24
      Top = 156
      Width = 216
      Height = 23
      TabOrder = 4
    end
    object edtCidade: TEdit
      Left = 264
      Top = 156
      Width = 320
      Height = 23
      TabOrder = 5
    end
    object edtUF: TEdit
      Left = 608
      Top = 156
      Width = 72
      Height = 23
      CharCase = ecUpperCase
      MaxLength = 2
      TabOrder = 6
    end
  end
  object pnlBotoes: TPanel
    Left = 0
    Top = 326
    Width = 720
    Height = 64
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object btnNovo: TButton
      Left = 272
      Top = 16
      Width = 96
      Height = 30
      Caption = 'Novo'
      TabOrder = 0
      OnClick = btnNovoClick
    end
    object btnSalvar: TButton
      Left = 376
      Top = 16
      Width = 96
      Height = 30
      Caption = 'Salvar'
      Default = True
      TabOrder = 1
      OnClick = btnSalvarClick
    end
    object btnExcluir: TButton
      Left = 480
      Top = 16
      Width = 96
      Height = 30
      Caption = 'Excluir'
      TabOrder = 2
      OnClick = btnExcluirClick
    end
    object btnSair: TButton
      Left = 584
      Top = 16
      Width = 96
      Height = 30
      Cancel = True
      Caption = 'Sair'
      TabOrder = 3
      OnClick = btnSairClick
    end
  end
end
